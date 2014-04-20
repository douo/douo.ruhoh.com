module Ruhoh::Resources::Notes
  class CollectionView < Ruhoh::Resources::Pages::CollectionView
    def all
      ruhoh.cache.get("#{ resource_name }-all") ||
        ruhoh.cache.set("#{ resource_name }-all", dictionary.each_value.find_all { |model|
                   "draft" != model['data']['type'] 
            }.sort
          )
    end
    
    def drafts
      dictionary.each_value.find_all { |model|
        "draft" == model['data']['type']
      }.sort
    end
    
    # 返回所有无内容的笔记
    def empty
      dictionary.each_value.find_all { |model|
        model.empty_content?
      }.sort
    end
    
  end
end