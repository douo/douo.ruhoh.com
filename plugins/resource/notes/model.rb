# -*- coding: utf-8 -*-
module Ruhoh::Resources::Notes
  class Model
    include Ruhoh::Base::PageLike
    # 将笔记的 Url 都转换为小写字母
      def url(page_data)
        super(page_data).downcase
      end
      
      def empty_content?
        Ruhoh::Parse.page_file(@pointer['realpath'])['content'].gsub(/\s/,'').size == 0
      end
       
    end
    
    
end
