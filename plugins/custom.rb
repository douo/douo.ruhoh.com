# -*- coding: utf-8 -*-

module PageModelViewAddons
  def greeting
    "Hello there! How are you?"
  end

  def raw_code(sub_context)
    code = sub_context.gsub('{', '&#123;').gsub('}', '&#125;').gsub('<', '&lt;').gsub('>', '&gt;')
    "<pre><code>#{code}</code></pre>"
  end
  
  def to_what(sub_context)
    puts sub_context
  end
  
  
  def breadcrumb
    path = []
    id = pointer['id']
    id.split('/').reduce{|s,p|
      path <<  @ruhoh.db.notes[s]
      s = "#{s}/#{p}"
    }
    path
  end

  def toc
    # @ruhoh.config['toc']['friendly_anchor']
    content = __getobj__.content # 这个方法在 model_view 调用来获取正在的model.content 才是未经处理的
    html_render = Ruhoh::TOC::TOCRender.new
    html_render.setup(content) #[content , id]
    html_render.toc
  end
  
    def post_next
    if pointer['resource'] != '_root'
      self.next
    else
      nil
    end
  end

  def post_previous
    if pointer['resource'] != '_root'
      self.previous
    else
      nil
    end
  end
end

Ruhoh.model('pages').send(:include, PageModelViewAddons)
Ruhoh.model('diary').send(:include, PageModelViewAddons)

module PageCollectionViewAddons
 # 分类文章列表应该根据日期排序
  def categories_sorted
    categories_url = nil
    [ruhoh.to_url("categories"), ruhoh.to_url("categories.html")].each { |url|
      categories_url = url and break if ruhoh.routes.find(url)
    }
    dict = {}
    dictionary.values.sort{|a,b| b["date"] <=> a["date"]}.each do |model|
      Array(model.data['categories']).each do |cat|
        cat = Array(cat).join('/')
        if dict[cat]
          dict[cat]['count'] += 1
        else
          dict[cat] = { 
            'count' => 1, 
            'name' => cat, 
            resource_name => [],
            'url' => "#{categories_url}##{cat}-ref"
          }
        end 

        dict[cat][resource_name] << model.id
      end
    end  
    dict["all"] = dict.each_value.map { |cat| cat }
    dict
  end
end

Ruhoh.collection('pages').send(:include, PageCollectionViewAddons)
