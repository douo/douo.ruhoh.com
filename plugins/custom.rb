# -*- coding: utf-8 -*-
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
      
      def to_what(sub_context)
        puts sub_context
      end
      
      def toc
        html_render = Lim::HTML.new
        markdown = Redcarpet::Markdown.new(html_render)
        markdown.render(get_page_content[0]) #[content , id]
        html_render.toc
      end
      

    end
  end
end

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
