module Ruhoh::Resources::Diary
  class ModelView < SimpleDelegator
    include Ruhoh::Base::PageViewable

    def post_next
      self.next
    end

    def post_previous
      self.previous
    end

    end
end
