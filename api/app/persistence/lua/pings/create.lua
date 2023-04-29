local existing_data = redis.call('HGET', KEYS[1], ARGV[1])
local expiration_time = redis.call('PEXPIRETIME', KEYS[2])
local current_time = redis.call('TIME')
local current_time_ms = current_time[1] * 1000 + current_time[2] / 1000
if expiration_time ~= nil and expiration_time > 0 then
  return {'retry_later', expiration_time - current_time_ms}
end

redis.call("HSET", KEYS[1], ARGV[1], ARGV[2])
redis.call("SET", KEYS[2], ARGV[4])
redis.call("PEXPIRE", KEYS[2], ARGV[3])

if existing_data ~= nil and existing_data ~= false then
  return {'expired', ARGV[2], existing_data}
end

return {'done', ARGV[2]}
