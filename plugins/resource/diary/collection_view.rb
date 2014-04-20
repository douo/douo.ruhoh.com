module Ruhoh::Resources::Diary
  class CollectionView < Ruhoh::Resources::Pages::CollectionView
    
    # 返回所有无内容的日记
    def empty
      dictionary.each_value.find_all { |model|
        model.empty_content?
      }.sort
    end
    
    def collated_reverse
      collated = []
      pages = all
      pages.to_enum.with_index.reverse_each do |page, i|
        thisYear = page['date'].strftime('%Y')
        thisMonth = page['date'].strftime('%B')
        if (i+1 < pages.size)
          nextYear = pages[i+1]['date'].strftime('%Y')
          nextMonth = pages[i+1]['date'].strftime('%B')
        end

        if(nextYear == thisYear) 
          if(nextMonth == thisMonth)
            collated.last['months'].last[resource_name] << page['id'] # append to last year & month
          else
            collated.last['months'] << {
                'month' => thisMonth,
                resource_name => [page['id']]
              } # create new month
          end
        else
          collated << { 
            'year' => thisYear,
            'months' => [{ 
              'month' => thisMonth,
              resource_name => [page['id']]
            }]
          } # create new year & month
        end

      end

      collated
    end
    
  end
end