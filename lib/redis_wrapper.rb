require 'redis'
require 'hiredis-client'

class RedisWrapper
  def initialize(prefix)
    @prefix = prefix
    @client = Redis.new
  end

  def get(key)
    return @client.get(@prefix + key)
  end
  
  def set(key, value)
    @client.set(@prefix + key, value)
  end

  def keys
    return @client.keys(@prefix + "*")
  end

  def del(key)
    @client.del(@prefix + key)
  end
end