local tokens = redis.call('ZRANGE', KEYS[1], 0, 0, 'WITHSCORES')
if next(tokens) == nil then
  return nil
end
local current_sequence = redis.call('GET', KEYS[2])
local token_score = tonumber(tokens[2])

if current_sequence == false then
  redis.call('SET', KEYS[2], token_score, 'PX', ARGV[1])
  current_sequence = token_score
else
  current_sequence = tonumber(current_sequence)
end

if current_sequence >= token_score then
  redis.call('ZINCRBY', KEYS[1], 1, tostring(tokens[1]))
  return tokens
else
  local current_time = redis.call('TIME')
  local current_time_ms = current_time[1] * 1000 + current_time[2] / 1000
  local expiration_time = redis.call('PEXPIRETIME', KEYS[2])
  return expiration_time - current_time_ms
end
