# -*- coding: utf-8 -*-
require 'redcarpet'
class LIM_HTML < Redcarpet::Render::HTML
  attr_reader :headers
  def initialize(options={})
     @headers = []
     @header_count = 0
     super options.merge(:with_toc_data => true)
  end
  def header(text, level)
    @headers << {:text => text, :level => level, :count => @header_count}
    @header_count = @header_count +1
    "<h#{level}>#{text}</h#{level}>"
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

class Tree
  attr_reader :value
  attr_reader :children
  def initialize(value)
    @value = value
    @children = []
  end
  
  def <<(value)
    subtree = Tree.new(value)
    @children << subtree
    return subtree
  end
  def depth
    @children==[]? 0 : (@children.map {|child| child.depth}.max+1)
  end
  
  def to_html 
    s = ""
    if @value.key? :text
      s << "<li><a href=\"#toc_#{@value[:count]}\">#{@value[:text]}</a></li>"
    end
    if @children != []
      s << "<ul>"
      @children.each {|child| s << child.to_html}
      s << "</ul>"
    end 
    s
  end
end 

class TOC
  def self.render(headers)
    root = Tree.new({:level => 0})
    stack = [root]
    headers.each do |h|
      while stack.last.value[:level] > h[:level]
        stack.pop
      end
      note = stack.last
      if h[:level] == note.value[:level] 
        stack.pop
        note = stack.last
      end
      note = note << h
      stack.push note
    end
    s = ""
    if root.children.size > 4
      s = '<div id="toc_container" class="toc_wrap_right toc_black no_bullets" style="display: none; "><p class="toc_title">目录</p><ul class="toc_list">'
      root.children.each {|child| s << child.to_html}
      s << '</ul></div>'
    end
    s
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
        html_render = LIM_HTML.new
        markdown = Redcarpet::Markdown.new(html_render,
          :autolink => true, 
          :fenced_code_blocks => true, 
        )
        result = markdown.render(content)
        result << TOC.render(html_render.headers)
        result
      end
    end
  end
end
