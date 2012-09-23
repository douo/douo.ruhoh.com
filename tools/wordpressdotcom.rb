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
require 'open-uri'
require 'cgi'
module Ruhoh
  # This importer takes a wordpress.xml file, which can be exported from your
  # wordpress.com blog (/wp-admin/export.php).
  module WordpressPraser
  
    def self.hackCode!()
      ## 转换codecolor 短标签的代码

      @content.sub!(/<\/q>/,'')
      i = 0
      short1 = /\[(?<tag>cc(?<opti>[a-zA-Z]*)) +(lang="(?<lang>\w+)")[^\]]*\](?<content>.*?)(\[\/(\k<tag>)\])/m
      short2 = /\[(?<tag>cc(?<opti>[a-zA-Z]*)(_(?<lang>\w+))?)[^\]]*\](?<content>.*?)(\[\/(\k<tag>)\])/m
      long1 = /<code +(lang="(?<lang>\w+)")[^>]*>(?<content>.*?)<\/code>/m
      long2 = /<code +(?<inline>inline="true")>(?<content>.*?)<\/code>/m
      [short1,short2,long1,long2].each do |reg|

        while res = @content.match(reg)
          key  = "placeholderfor#{i}code"
          i = i + 1
          content = ""

          if (res.names.include? 'inline') || ((res.names.include? 'opti') && (res['opti'] =~ /i/))
            @holder[key] = "`#{res['content']}`"
          else
            if res['content'].start_with?("\n")
              content << res['content']
            else
              content << "\n" << res['content']
            end
            if content.end_with?("\n") == false
              content << "\n"
            end
            content=CGI.unescapeHTML(content)
            @holder[key] = "\n\n```#{res['lang']}#{content}```\n\n"
          end
          # puts key ,content
          @content.sub!(reg,key)
        end
      end
      
      
      # @content.gsub!(reg,'<pre><code class="\k<lang>">\k<content></code></pre>')
      # @content.gsub!(reg1,'<pre><code class="\k<lang>">\k<content></code></pre>')
    end

    def self.hackTex!()
      
      reg = /\[tex\](?<content>.*?)\[\/tex\]/im
      #rep = "\n<script type=\"math/tex; mode=display\">\n\k<content>\n</script>\n"
      i = 0
      reg1 = /(?<=[\r\n])\[tex\](?<content>((?!\[tex\]).)*?)\[\/tex\]/im

      # if @content =~ reg
      #   @content.gsub!(/(?!([\r\n].+))_(?<c>.+?)_/,'\_\k<c>\_')
      # end

      while res = @content.match(reg1)
        #        puts res
        key = "[[tex#{i}]]"
        i = i+1
        # @holder[key] = "\n<script type=\"math/tex; mode=display\">#{res['content']}</script>\n".gsub('\\\\','\\\\\\\\\\\\\\\\').gsub('&amp;','&')
        @holder[key] =  "\n```mathjax\n#{res['content']}\n```\n".gsub('\\\\','\\\\\\\\\\\\\\\\').gsub('&amp;','&')
        @content.sub!(reg1,key)
      end
      while res = @content.match(reg)
        key = "[[tex#{i}]]"
        i = i+1
        # @holder[key] = "<script type=\"math/tex\">#{res['content']}</script>".gsub('\\\\','\\\\\\\\\\\\\\\\').gsub('&amp;','&')
        @holder[key] =  "`$#{res['content']}$`".gsub('\\\\','\\\\\\\\\\\\\\\\').gsub('&amp;','&')
        @content.sub!(reg,key)
      end
    end

    def self.hackPjs!()
      reg = /<canvas.+?><\/canvas>/
      i = 0 
      while res = @content.match(reg)
        key = "hightentropyp#{i}js"
        i = i+1
        @holder[key] = res[0].sub(/http:\/\/dourok.info/,'{{urls.media}}')
        @content.sub!(reg,key)
      end
    end

    def self.hackImg()
      html =  Nokogiri::HTML(@content)
      imgurl = []
      i = 0
      regex = /http:\/\/dourok.info\/(.+)/
      html.css('a').select{|a| !a.css('img').empty?}.each do |a|
        a.css('img').each do |img|
          if src = img['src'].match(regex)
            key = "#{i}.veryhighentropy"
            i = i+1
            imgurl << {:url => src[0].gsub("\\",""),:file => "media/#{src[1].gsub("\\","")}"}
            img['src'] = "#{key}"
            a['href'] = "#{key}"
            @holder[key] = "{{urls.media}}/#{src[1]}"
          end
        end
      end
      html.css('img').each do |img|
        if src = img['src'].match(regex)
          key = "#{i}.png"
          i = i+1
          imgurl << {:url => src[0].gsub("\\",""),:file => "media/#{src[1].gsub("\\","")}"}
          img['src'] = "#{key}"
          @holder[key] = "{{urls.media}}/#{src[1]}"
        end
      end
      @content = html.to_s
      #dlImg imgurl
    end
    
    def self.dlImg(imgurl)
      
      imgurl.each do |i|
        FileUtils.mkdir_p File.dirname(i[:file])
        File.open(i[:file], 'wb') do |f|
          f << open(i[:url]).read
        end
      end
    end
      
    
    def self.prepocess!()
      methods(false).find_all {|m| m=~ /hack.*/}.each {|m| __send__(m)}
    end
    
    

    def self.process(filename = "wordpress.xml")
      exnames =[
                "男子因压力大跳桥自杀-9岁儿子跪求未果.md",
                "方格图的最短路径探讨.md",
                "方格图的最短路径探讨-2.md",
                "png格式与me中的png.md",
                "hello-world！.md",
                "test.md",
               ]

      

      import_count = Hash.new(0)
      doc = Hpricot::XML(File.read(filename))
      (doc/:channel/:item).each do |item|
        type = item.at('wp:post_type').inner_text
        
        if type != 'post'
          next
        end
        
        title = item.at(:title).inner_text.strip
        # if !(title =~ /Codecolorer/i)
        #   next
        # end

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
          draft = false
        else
          draft = true
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
        

        next if exnames.any? {|w| w == name } 


        header = {
          'date'   => date.strftime('%Y-%m-%d'),
          'layout' => type,
          'title'  => title,
          'tags'   => tags,
          'categories' => categories,
          #'status'   => status,
          #'type'   => type,
          'meta'   => metas,
          'postid' => postid,
          'guid'   => guid
        }
        if draft
          header['type'] = 'draft'
        end
        
        @content = item.at('content:encoded').inner_text
        
        @holder =Hash.new
        prepocess!
        # 先当成 markdown 转换到 html 可以修复没有p标签的段落问题        
        @content = PandocRuby.convert(@content, :from => :'markdown', :to => :'html')
        
        @content = PandocRuby.convert(@content, :from => :html, :to => :'markdown')
        
        # pp @holder if @holder != {}

        @holder.each {|k,v| 
          #puts k,v  if k =~ /placeholder.*/ 
          @content.gsub!(k,v)
        }

        
        
        #FileUtils.mkdir_p "_#{type}s"
        #File.open("_#{type}s/#{name}", "w") do |f|
        FileUtils.mkdir_p "../posts/wp"
        File.open("../posts/wp/#{name}", "w") do |f|
          s = header.to_yaml
          f.puts header.to_yaml
          
          f.puts '---'
          f.puts @content
        end
        import_count[type] += 1
      end
      
      import_count.each do |key, value|
        puts "Imported #{value} #{key}s"
      end
    end
  end
end

Ruhoh::WordpressPraser.process("wordpress.xml")

