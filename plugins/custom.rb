class Ruhoh
  module Templaters
    module Helpers
      def greeting
        "Hello there! How are you?"
      end

      def raw_code(sub_context)
        code = sub_context.gsub('{', '&#123;').gsub('}', '&#125;').gsub('<', '&lt;').gsub('>', '&gt;')
        "<pre><code>#{code}</code></pre>"
      end
    end
  end
end