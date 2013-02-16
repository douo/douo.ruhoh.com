# -*- coding: utf-8 -*-
require 'redcarpet'
#require 'fastimage'
module Lim
  class HTML < Redcarpet::Render::HTML
    def preprocess(full_document)
      @helper = Ruhoh::TOC::TOCHelper.new
      full_document
    end
    def block_code(code, language)
      if language == 'mathjax'
        "<script type=\"math/tex; mode=display\">
        #{code}
        </script>"
      else
        require 'cgi'
        code = CGI.escapeHTML code
        "<pre><code class=\"#{language}\">#{code}</code></pre>"
      end
    end
    
    def image(link, title, alt_text)
      ## 为本地的图片声明宽和高,需要 fastimage
      ## gem install fastimage
      ## https://github.com/sdsykes/fastimage
      # if(link.match(Regexp.new("^#{Ruhoh.urls.media}")))
      #   file = link.sub(Ruhoh.urls.media,Ruhoh.paths.media)
      #   w,h = FastImage.size(file)         
      #   "<img class=\"lazy\" src=\"#{link}\" width=\"#{w}\" height=\"#{h}\" title=\"#{title}\"  alt=\"#{alt_text}\">"
      # else
      "<img class=\"lazy\" src=\"#{link}\" title=\"#{title}\"  alt=\"#{alt_text}\">"
      #end
    end
    
    def link(link, title, content)
      if content =~ /<img.*>/
        "<a class=\"fancybox\" rel=\"group\" href=\"#{link}\" title=\"#{title}\">#{content}</a>"
      else 
        "<a href=\"#{link}\" title=\"#{title}\">#{content}</a>"
      end
    end

    def codespan(code)
      if code[0] == "$" && code[-1] == "$"
        code.gsub!(/^\$/,'')
        code.gsub!(/\$$/,'')
        "<script type=\"math/tex\">#{code}</script>"
      else
        code = CGI.escapeHTML code
        "<code>#{code}</code>"
      end
    end
    def header(text, level)
      @helper.header(text,level)
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
        html_render = Lim::HTML.new
        markdown = Redcarpet::Markdown.new(html_render,
                                           :autolink => true, 
                                           :fenced_code_blocks => true, 
                                           :no_intra_emphasis => false
                                           )
        markdown.render(content)
      end
    end
  end
end
