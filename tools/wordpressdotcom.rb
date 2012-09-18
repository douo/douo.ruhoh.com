# coding: utf-8
# chcp 65001
# http://www.rubular.com/r/Fofh6u3NmW
require 'rubygems'
require 'hpricot'
require 'nokogiri'
require 'fileutils'
require 'yaml'
require 'time'
require 'pandoc-ruby'

module Jekyll
  # This importer takes a wordpress.xml file, which can be exported from your
  # wordpress.com blog (/wp-admin/export.php).
  module WordpressDotCom
  
    def self.convertCode!(content,later)
      ## 转换codecolor 短标签的代码

      reg1 = /\[(?<tag>cc(?<opti>[a-zA-Z]*)) +(lang="(?<lang>\w+)")\](?<content>.*?)(\[\/\k<tag>\])/m
      reg = /\[(?<tag>cc(?<opti>[a-zA-Z]*)(_(?<lang>\w+))?)\](?<content>.*?)(\[\/\k<tag>\])/m
      content.gsub!(reg,'<pre><code class="\k<lang>">\k<content></code></pre>')
      content.gsub!(reg1,'<pre><code class="\k<lang>">\k<content></code></pre>')
    end

    def self.convertTex!(content,later)
      
      reg = /\[tex\](?<content>.*?)\[\/tex\]/im
      #rep = "\n<script type=\"math/tex; mode=display\">\n\k<content>\n</script>\n"
      i = 0
      reg1 = /(?<=[\r\n])\[tex\](?<content>((?!\[tex\]).)*?)\[\/tex\]/im

      if content =~ reg
        content.gsub!(/(?!([\r\n].+))_(?<c>.+?)_/,'\_\k<c>\_')
      end

      while res = content.match(reg1)
        #        puts res
        key = "[[tex#{i}]]"
        i = i+1
        later[key] = "\n<script type=\"math/tex; mode=display\">#{res['content']}</script>\n".gsub('\\\\','\\\\\\\\\\\\\\\\').gsub('&amp;','&')
        content.sub!(reg1,key)
      end
      while res = content.match(reg)
        key = "[[tex#{i}]]"
        i = i+1
        later[key] = "<script type=\"math/tex\">#{res['content']}</script>".gsub('\\\\','\\\\\\\\\\\\\\\\').gsub('&amp;','&')
        content.sub!(reg,key)
      end
      
    end

    def self.convertImg(content,later)
      html =  Nokogiri::HTML(content)
      imgurl = []
      html.css('img').each do |img|
      regex = /http:\/\/dourok.info\/(.+)/
        
        if src = img['src'].match(regex)
          imgurl = {:url => src[0],:file => src[1]}
          img['src'] = "{{urls.media}}/#{src[1]}"
        end
      end
      puts imgurl
    end

    def self.prepocess!(content,later)
      methods(false).find_all {|m| m=~ /convert.*/}.each {|m| __send__(m,content,later)}
    end
    
    def self.process(filename = "wordpress.xml")
      import_count = Hash.new(0)
      doc = Hpricot::XML(File.read(filename))
      (doc/:channel/:item).each do |item|
        type = item.at('wp:post_type').inner_text
        
        if type != 'post'
          next
        end
        
        title = item.at(:title).inner_text.strip
        permalink_title = item.at('wp:post_name').inner_text
        # Fallback to "prettified" title if post_name is empty (can happen)
        if permalink_title == ""
          permalink_title = title.downcase.split.join('-')
        end

        date = Time.parse(item.at('wp:post_date').inner_text)
        status = item.at('wp:status').inner_text

        postid = item.at('wp:post_id').inner_text
        guid = item.at(:guid).inner_text

        if status == "publish" 
          published = true
        else
          published = false
        end



        categories = []
        tags = []
        (item/:category).each do |c|
          if c.attributes['domain'] == 'category'
            categories.push(c.inner_text.downcase)
          else
            tags.push(c.inner_text)
          end

        end
        # tags = (item/:category).map{|c| c.inner_text}.reject{|c| c == 'Uncategorized'}.uniq

        metas = Hash.new
        item.search("wp:postmeta").each do |meta|
          key = meta.at('wp:meta_key').inner_text
          value = meta.at('wp:meta_value').inner_text
          metas[key] = value;
        end

        name = "#{URI.unescape(permalink_title)}.md"
        header = {
          'date'   => date.strftime('%Y-%m-%d'),
          'layout' => type,
          'title'  => title,
          'tags'   => tags,
          'categories' => categories,
          'status'   => status,
          'type'   => type,
          'published' => published,
          'meta'   => metas,
          'postid' => postid,
          'guid'   => guid
        }
        
        content = item.at('content:encoded').inner_text
        
        later =Hash.new
        prepocess!(content,later)
        # 先当成 markdown 转换到 html 可以修复没有p标签的段落问题        
        content = PandocRuby.convert(content, :from => :'markdown', :to => :'html')
        
        content = PandocRuby.convert(content, :from => :html, :to => :'markdown')
        
        # pp later if later != {}
        later.each {|k,v| content.sub!(k,v)}

        FileUtils.mkdir_p "_#{type}s"
        File.open("_#{type}s/#{name}", "w") do |f|
          f.puts header.to_yaml
          f.puts '---'
          f.puts content
        end
        


        import_count[type] += 1
      end
      
      import_count.each do |key, value|
        puts "Imported #{value} #{key}s"
      end
    end
  end
end

Jekyll::WordpressDotCom.process("wordpress.xml")
