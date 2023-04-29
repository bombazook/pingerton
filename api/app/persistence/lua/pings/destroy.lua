local existing_data = redis.call('HGET', KEYS[1], ARGV[1])
local ping_sequence = tonumber(redis.call('GET', KEYS[2]))
local expiration_time = redis.call('PEXPIRETIME', KEYS[2])
local pong_sequence = tonumber(ARGV[2])

if pong_sequence >= 0 and expiration_time > 0 then
  if ping_sequence ~= nil and ping_sequence ~= pong_sequence then
    return {'error', '{"message": "wrong sequence"}'}
  end
end

redis.call('HDEL', KEYS[1], ARGV[1])

if (expiration_time == nil or expiration_time < 0) and existing_data ~= nil and existing_data ~= false then
  return {'expired', '{}', existing_data}
end

return {'done', existing_data}
