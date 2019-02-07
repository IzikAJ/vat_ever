module VatEver
  class Result
    def self.as_json(result)
      {
        "version" => VatEver::VERSION,
      }.to_h.merge(result)
    end
  end
end
