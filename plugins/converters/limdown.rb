require 'redcarpet'
class LIM_HTML < Redcarpet::Render::HTML
  attr_reader :headers
   def initialize(options={})
     @headers = []
     super options.merge(:with_toc_data => true)
  end
  def header(text, level)
    @headers << {:text => text, :level => level}
    "<h#{level}>#{text}</h#{level}>"
  end
  def block_code(code, language)
    require 'cgi'
    code = CGI.escapeHTML code
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
      s << "<li>#{@value[:text]}</li>"
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
    root.to_html
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
