module Ruhoh::Resources::Diary
  class Model
    include Ruhoh::Base::PageLike
    
      def empty_content?
        Ruhoh::Parse.page_file(@pointer['realpath'])['content'].gsub(/\s/,'').size == 0      
      end
    
    end
end