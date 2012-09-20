require 'redcarpet'
class HTMLwithAlbino < Redcarpet::Render::HTML
  def block_code(code, language)
    if language == 'mathjax'
      "<script type=\"math/tex; mode=display\">
        #{code}
      </script>"
    else
      "<pre><code class=\"#{language}\">#{code}</code></pre>"
    end
  end
  
  def codespan(code)
    if code[0] == "$" && code[-1] == "$"
      code.gsub!(/^\$/,'')
      code.gsub!(/\$$/,'')
      "<script type=\"math/tex\">#{code}</script>"
    else
      "<code>#{code}</code>"
    end
  end
end

class Ruhoh
  module Converter
    module Markdown
      def self.extensions
        ['.md', '.markdown']
      end
      def self.convert(content)
        require 'redcarpet'
        toc =  Redcarpet::Markdown.new(Redcarpet::Render::HTML_TOC.new)
        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(:with_toc_data => true),
          :autolink => true, 
          :fenced_code_blocks => true, 
        )
        "#{toc.render(content)}#{markdown.render(content)}"
      end
    end
  end
end
