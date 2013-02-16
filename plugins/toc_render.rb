# -*- coding: utf-8 -*-
class Ruhoh
  module TOC
    class TOCRender < Redcarpet::Render::HTML
      
      def setup (content,
                 header_limit = 4  # 標題數量超過 limit 才顯示 toc
                 )
        @limit = header_limit
        @helper = TOCHelper.new
        markdown = Redcarpet::Markdown.new(self,
                                           :fenced_code_blocks => true, 
                                           :no_intra_emphasis => true)
        markdown.render(content)
      end
      
      def toc
        return if @helper.headers.size < @limit
        root = {:level => 0,:children => []}
        stack = [root]
        # build tree
        @helper.headers.each do |h|
          while stack.last[:level] > h[:level]
            stack.pop
          end
          node = stack.last
          if h[:level] == node[:level] 
            stack.pop
            node = stack.last
          end
          h[:children] ||= []
          node[:children] <<  h
          stack.push h
        end
        root
      end
      
      #override
      def header(text, level)
        @helper.header(text,level)
      end
      
    end

    class TOCHelper
      attr_reader :headers
      # 使用標題名作為anchor，但用jquery-smooth-scroll時會出錯
      @@friendly_anchor=false

      def initialize
        @headers = []
        @header_count = 0
      end

      def self.get_anchor node
        if @@friendly_anchor
          node[:anchor]
        else
          "toc_#{node[:count]}"
        end
      end

      def header(text,level)
        value = {:text => text, :level => level, :count => @header_count}
        value[:anchor] = TOCHelper.get_anchor(value)
        @headers << value
        @header_count = @header_count +1
        "<h#{level} id=\"#{TOCHelper.get_anchor(value)}\">#{text}</h#{level}>"
      end
    end
  end
end
