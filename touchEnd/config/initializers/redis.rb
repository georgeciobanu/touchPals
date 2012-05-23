# Permanent redis connection used to send messages to clients
TouchEnd::Application.config.redisConnection  = Redis.new()