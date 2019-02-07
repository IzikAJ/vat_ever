# require "myhtml"
require "../../../myhtml/src/myhtml"

module VatEver
  class Parser
    property body : String
    property table : Myhtml::Node?
    property norm = Normalizer
    property value_placeholder : String?

    PARSE_FAILED = {
      "error"  => "unparseable",
      "detail" => "can`t parse server response",
    }.to_h

    def initialize(@body : String, @value_placeholder : String? = nil)
    end

    def data
      parse_data
    end

    private def parse_data
      data = Hash(String, String | Bool | Nil).new

      html = Myhtml::Parser.new(body)
      resp_tables = html.css("#vatResponseFormTable")
      @table = resp_tables.first if resp_tables.size > 0
      if tbl = @table
        valid = tbl.css(".validStyle").size > 0
        data = data.merge({"valid" => valid}.to_h)
        if (trs = tbl.scope.nodes(:tr)).size > 0
          trs.each do |row|
            next if row.css("td.labelStyle").size == 0
            if (labelNode = row.css("td.labelStyle").first) &&
               (valueNode = row.css("td.labelStyle + td").first)
              if (label = norm.value(labelNode.inner_text))
                if value = (norm.value(valueNode.inner_text) || value_placeholder)
                  data[norm.label(label)] = value
                end
              end
            end
          end
        end
      else
        data = data.merge(PARSE_FAILED.merge(
          {"raw_body" => body.to_s}.to_h
        ))
      end
      # {

      #   "raw_body" => body.to_s,
      # }.to_h
      data
    end
  end
end
