# frozen_string_literal: true

module Tools
  class ConnectionPoolProxy < BasicObject
    attr_reader :__pool

    def initialize(...)
      @__pool = ::ConnectionPool.new(...)
    end

    def respond_to_missing?(...)
      @__pool.with { |_c| respond_to_missing?(...) }
    end

    def method_missing(...)
      @__pool.with { |c| c.send(...) }
    end
  end
end
