require "redis"

module VatEver
  class Cached
    # 1 day in seconds
    EXPIRE_TIMEOUT = 60 * 60 * 24 * 1
    PREFIX         = "vat_ever_"

    def initialize(@redis : Redis = Redis.new, @scope : String = "_global")
      #
    end

    def clear
      cursor, found_keys = @redis.scan(0, "#{PREFIX}#{@scope}*")
      if keys = found_keys.as(Array(Redis::RedisValue))
        puts "CLEAR CACHE: #{keys.size} ITEMS"
        keys.each do |key|
          puts "DEL #{key}" if @redis.del("#{key}")
        end
      end
    end

    def fetch(key : String)
      if chached = @redis.get("#{PREFIX}#{@scope}#{key}")
        chached
      else
        value = yield.to_json
        @redis.setex("#{PREFIX}#{@scope}#{key}", EXPIRE_TIMEOUT, value)
        value
      end
    end
  end
end
