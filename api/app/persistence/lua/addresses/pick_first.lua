local tokens = redis.call('ZRANGE', KEYS[1], 0, 0, 'WITHSCORES')
if next(tokens) == nil then
  return nil
end
redis.call('ZINCRBY', KEYS[1], 1, tostring(tokens[1]))
return tokens
