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
  
  # 與toc 相同,但可以通過 sub_content指定 toc_wrapper
  def toc_wrapper(sub_content)
    html_render = Ruhoh::TOC::TOCRender.new
    html_render.setup(get_page_content[0]) #[content , id]
    html_render.toc(@ruhoh.db.partials[sub_content.split("\n").first.strip])
  end

  def _toc
    html_render = Ruhoh::TOC::TOCRender.new
    html_render.setup(get_page_content[0]) #[content , id]
    html_render.toc(@ruhoh.db.partials["toc_wrapper"])
  end

  def toc
    html_render = Ruhoh::TOC::TOCRender.new
    html_render.setup(get_page_content[0]) #[content , id]
    html_render.toc
  end
    
  def post_next
    if pointer['resource'] != 'pages'
      self.next
    else
      nil
    end
  end

  def post_previous
    if pointer['resource'] != 'pages'
      self.previous
    else
      nil
    end
  end
end

Ruhoh::Resources::Page::ModelView.send(:include, PageModelViewAddons)
