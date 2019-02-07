require "http/client"

module VatEver
  class Normalizer
    NORMAL_MAPPING = {
      "Member State"               => "state",
      "VAT Number"                 => "vat_code",
      "Date when request received" => "recived_at",
      "Consultation Number"        => "consultation_id",
      "Postal Code"                => "postal_code",
      "Company Type"               => "company_type",
      "City/Town"                  => "city",
    }

    REQUEST_MAPPING = {
      checkState:  "memberStateCode",
      checkNumber: "number",
      ownState:    "requesterMemberStateCode",
      ownNumber:   "requesterNumber",
    }

    def self.request_params(code : String, requestor : String?) : Hash(String, String)
      data = {} of String => String
      data[REQUEST_MAPPING[:checkState]] = code[0...2]
      data[REQUEST_MAPPING[:checkNumber]] = code[2..-1]
      if requestor && requestor.size > 2
        data[REQUEST_MAPPING[:ownState]] = requestor[0...2]
        data[REQUEST_MAPPING[:ownNumber]] = requestor[2..-1]
      end
      data.to_h
    end

    def self.label(label : String) : String
      label_to_key(normalize(label).as(String))
    end

    def self.value(value : String) : String | Nil
      normalize(value)
    end

    private def self.label_to_key(label : String) : String
      return label.downcase.gsub(/[^a-z]+/, '_') unless NORMAL_MAPPING.has_key?(label)
      NORMAL_MAPPING[label]
    end

    private def self.normalize(text : String?) : String | Nil
      return nil unless text
      text = text.strip
      return nil if text.size == 0
      return nil if text == "---"
      text = text.chomp(':')
      text
    end
  end
end
