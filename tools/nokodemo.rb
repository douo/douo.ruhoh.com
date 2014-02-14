require 'nokogiri'
builder = Nokogiri::XML::Builder.new do |xml|
  xml.root('xmlns' => 'default', 'xmlns:foo' => 'bar')  {
    xml.products {
      xml.widget {
        xml.id_ "10"
        xml.name "Awesome widget"
      }
    }
  }
end
puts builder.to_xml
