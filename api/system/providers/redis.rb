# frozen_string_literal: true

App.register_provider(:redis) do
  prepare do
    require 'redis'
    target.prepare :common
    pool = Tools::ConnectionPoolProxy.new { Redis.new(url: Config.new.redis_url) }
    register('redis.pool', pool)
    register('redis.lua_cache', Tools::LuaCache.new(connection: pool))
  end
end
