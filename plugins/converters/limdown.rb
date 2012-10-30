# -*- coding: utf-8 -*-
require 'redcarpet'

module Lim
  class HTML < Redcarpet::Render::HTML
    
    def preprocess(full_document)
      @headers = []
      @header_count = 0
      full_document
    end
    
    def header(text, level)
      @headers << {:text => text, :level => level, :count => @header_count}
      @header_count = @header_count +1
      "<h#{level} id=\"toc_#{@header_count-1}\">#{text}</h#{level}>"
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
       "<img class=\"lazy\" src=\"#{link}\" title=\"#{title}\"  alt=\"#{alt_text}\">"
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

    def postprocess(full_document)
      toc << full_document
    end
    
    def toc
      root = Tree.new({:level => 0})
      stack = [root]
      @headers.each do |h|
        while stack.last.value[:level] > h[:level]
          stack.pop
        end
        node = stack.last
        if h[:level] == node.value[:level] 
          stack.pop
          node = stack.last
        end
        node = node << h
        stack.push node
      end
      result = ""
      if root.size > 4
        result = '<div class="cf"></div><div id="toc_container" class="toc_wrap_right toc_black no_bullets" ><p class="toc_title">目录</p><ul class="toc_list">'
        root.children.each {|child| result << tree_html(child)}
        result << '</ul></div>'
      end
      result
    end
    
    def tree_html node # Tree
      value = node.value
      children = node.children
      html = ""
      html << "<li><a href=\"#toc_#{value[:count]}\">#{value[:text]}</a></li>" if value.key? :text
      if children != []
        html << "<ul>"
        children.each {|child| html << tree_html(child) }
        html << "</ul>"
      end
      html
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
                                           :no_intra_emphasis => true
                                           )
        markdown.render(content)
      end
    end
  end
end
