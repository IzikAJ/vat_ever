require "http/client"
require "http/headers"

module VatEver
  class Requestor
    DEFAULTS = {
      "traderName"       => "",
      "traderStreet"     => "",
      "traderPostalCode" => "",
      "action"           => "check",
      "check"            => "Verify",
    }

    DEFAULT_HEADERS = HTTP::Headers{
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.81 Safari/537.36",
      "Referer"    => "http://ec.europa.eu/taxation_customs/vies/vatRequest.html",
      "Origin"     => "http://ec.europa.eu",
    }

    def check(code : String, requestor : String?, placeholder : String?)
      puts "MAKE EXTERNAL REQUEST C[#{code}] R[#{requestor}] P[#{placeholder}]"
      resp = post(Normalizer.request_params(code, requestor))
      parser = Parser.new(resp.body, placeholder)
      parser.data
    end

    def post(data : Hash(String, String), extra_headers : HTTP::Headers? = nil)
      headers = DEFAULT_HEADERS
      headers.merge!(extra_headers) if extra_headers
      HTTP::Client.post(
        "http://ec.europa.eu/taxation_customs/vies/vatResponse.html",
        headers: headers,
        form: DEFAULTS.merge(data)
      )
    end
  end
end
