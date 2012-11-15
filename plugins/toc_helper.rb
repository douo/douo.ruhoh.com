# -*- coding: utf-8 -*-
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

class Ruhoh
  module Templaters
    module TOCHelpers
      puts "toc helpers"
      def toc
        html_render = Lim::HTML.new
        markdown = Redcarpet::Markdown.new(html_render)
        markdown.render(content)
        markdown.toc
        end
      
    end
  end
end
