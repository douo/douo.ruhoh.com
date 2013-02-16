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
