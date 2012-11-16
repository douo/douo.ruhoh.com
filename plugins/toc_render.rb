# -*- coding: utf-8 -*-
class Ruhoh
  module TOC
    class TOCRender < Redcarpet::Render::HTML
      
      def setup (content,
                 friendly_anchor = true, # 使用標題名作為anchor，但用jquery-smooth-scroll時會出錯
                 header_limit = 4  # 標題數量超過 limit 才顯示 toc
                 )
        @limit = header_limit
        @helper = TOCHelper.new(friendly_anchor)
        markdown = Redcarpet::Markdown.new(self,
                                           :fenced_code_blocks => true, 
                                           :no_intra_emphasis => true)
        markdown.render(content)
      end
      
      def toc(toc_wrapper = 'toc_wrapper')

        toc_wrapper = toc_wrapper.to_sym
        root = Tree.new({:level => 0})
        stack = [root]
        # build tree
        @helper.headers.each do |h|
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
        # gen code
        if root.size > @limit
          result = ''
          root.children.each {|child| result << tree_html(child)}

          if Ruhoh::DB.partials[toc_wrapper]
            result = Mustache.render(Ruhoh::DB.partials[toc_wrapper],
                                     :toc => result)
          end
          result
        else
          nil
        end
      end
      
      def tree_html node # Tree
        value = node.value
        children = node.children
        html = ""
        html << "<li><a href=\"##{TOCHelper.get_anchor(value)}\">#{value[:text]}</a></li>" if value.key? :text
        if children != []
          html << "<ul>"
          children.each {|child| html << tree_html(child) }
          html << "</ul>"
        end
        html
      end
      
      #override
      def header(text, level)
        @helper.header(text,level)
      end
      
    end

    class TOCHelper
      attr_reader :headers
      
      def initialize(friendly_anchor=true) # 使用標題名作為anchor，但用jquery-smooth-scroll時會出錯
        @anchor = friendly_anchor
        @headers = []
        @header_count = 0
      end
      def self.get_anchor node
        if @anchor
          node[:anchor]
        else
          "toc_#{node[:count]}"
        end
      end
      def header(text,level)
        value = {:text => text, :level => level, :count => @header_count ,:anchor => "#{Ruhoh::Urls.to_url_slug(text)}"}
        @headers << value
        @header_count = @header_count +1
        "<h#{level} id=\"#{TOCHelper.get_anchor(value)}\">#{text}</h#{level}>"
      end
    end
  end
end

