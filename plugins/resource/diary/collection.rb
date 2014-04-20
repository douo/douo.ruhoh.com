module Ruhoh::Resources::Diary
  class Collection < Ruhoh::Resources::Pages::Collection
    def self.is_acting_as_pages
      true
    end
  end
end
