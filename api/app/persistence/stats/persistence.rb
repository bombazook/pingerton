# frozen_string_literal: true

module Stats
  class Persistence
    include Import['clickhouse.pool', 'config']
    IPV4_TABLE = 'ipv4pings'
    IPV6_TABLE = 'ipv6pings'
    FIELDS = %i[avg max min stddev median count timeout_percent].freeze

    def create(address, ping:, pong: nil, timeout: nil)
      ip = IPAddr.new(address.to_s)
      ping = ping&.to_f
      pong = pong&.to_f
      pong, duration = calc_pong_duration(ping:, pong:)
      timeout = timeout != false && duration >= max_duration
      values = [{ ip: ip.to_s, ping: ping.to_s, pong: pong.to_s, duration: duration.to_s, timeout: }]
      pool.insert(table_name(ip), values:)
    end

    def get(address, from: nil, to: nil)
      ip = IPAddr.new(address.to_s)
      result = format_values(successes_sql(ip, from:, to:), keys: FIELDS)
      failures = format_values(failures_sql(ip, from:, to:), keys: [:count])
      result[:count] += failures[:count]
      result[:count] = result[:count].to_i
      result[:timeout_percent] = calc_timeout_percent(count: result[:count], failures_count: failures[:count])
      result
    end

    private

    def calc_timeout_percent(count:, failures_count:)
      count.positive? ? failures_count.to_f / count : 0.0
    end

    def max_duration
      config.timeout / 1000
    end

    def calc_pong_duration(ping:, pong: nil)
      if pong
        duration = (pong - ping).round(3)
        return [pong, duration] unless duration > max_duration
      end

      [ping + max_duration, max_duration]
    end

    def format_values(values, keys:)
      values.each do |k, v|
        values[k] ||= 0 if keys.include?(k)
        values[k] = v.to_f
      end
      values
    end

    def successes_sql(ip, from: nil, to: nil)
      pool.select_one <<~SQL
        SELECT
          AVG(duration) AS avg,
          MAX(duration) as max,
          MIN(duration) as min,
          stddevSamp(duration) as stddev,
          quantile(0.5)(duration) as median,
          count() as count
        FROM #{table_name(ip)}
        WHERE (ip == #{format_ip(ip)})
          AND timeout == false
          AND #{time_conditions(from:, to:)}
      SQL
    end

    def failures_sql(ip, from: nil, to: nil)
      pool.select_one <<~SQL
        SELECT count() as count
        FROM #{table_name(ip)}
        WHERE (ip == #{format_ip(ip)})
          AND timeout == true
          AND #{time_conditions(from:, to:)}
      SQL
    end

    def time_conditions(from: nil, to: nil)
      conditions = []
      conditions << "ping >= toDateTime64('#{format_datetime(from)}', 3)" if from
      conditions << "pong < toDateTime64('#{format_datetime(to)}', 3)" if to
      result = conditions.join(' AND ')
      result.empty? ? 'true' : result
    end

    def format_ip(ip)
      ip.ipv4? ? "toIPv4('#{ip}')" : "toIPv6('#{ip}')"
    end

    def format_datetime(time)
      Time.at(time).to_f
    end

    def table_name(ip)
      return IPV4_TABLE if ip.ipv4?

      IPV6_TABLE
    end
  end
end
