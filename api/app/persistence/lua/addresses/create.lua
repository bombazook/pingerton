local address = ARGV[1]
local first_item = redis.call('ZRANGE', KEYS[1], 0, 0, 'WITHSCORES')
if address == nil then
  return nil
end
if next(first_item) == nil then
  return redis.call('ZADD', KEYS[1], 1, address)
else
  local first_score = first_item[2]
  return redis.call('ZADD', KEYS[1], 'NX', first_score, address)
end
