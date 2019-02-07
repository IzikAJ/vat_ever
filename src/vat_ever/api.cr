require "json"
require "redis"

module VatEver
  class Api
    property redis : Redis
    property requestor : VatEver::Requestor
    property cache : VatEver::Cached

    def initialize
      @redis = Redis.new("127.0.0.1", 6379, nil, nil, 0, ENV["REDIS_URL"]?)
      @cache = VatEver::Cached.new(@redis, "codecheck")
      @requestor = VatEver::Requestor.new

      cache.clear

      add_handler CORSHandler.new
      draw_routes
    end

    def draw_routes
      get "/validate.json" do |env|
        as_json! env
        check = env.params.query["code"]?
        own = env.params.query["own"]?
        placeholder = env.params.query["placeholder"]?

        if check
          key = check
          key = key + "@#{own}" if own
          key = key + ":#{placeholder}" if placeholder

          cache.fetch key do
            # Result.as_json fetch_vat_info(check, own)
            Result.as_json requestor.check(check, own, placeholder)
          end
        else
          {
            error: "code for check is required",
          }.to_json
        end
      end
    end

    protected def as_json!(env)
      env.response.content_type = "application/json"
    end
  end
end
