# coding: utf-8
# chcp 65001
# http://www.rubular.com/r/Fofh6u3NmW
require 'rubygems'
require 'hpricot'
require 'fileutils'
require 'yaml'
require 'time'
require 'pandoc-ruby'

module Jekyll
  # This importer takes a wordpress.xml file, which can be exported from your
  # wordpress.com blog (/wp-admin/export.php).
  module WordpressDotCom
    def self.h()
      puts "help"
    end

    def self.prepocess(content)
      # 预处理正文

      reg1 = /\[(?<tag>cc(?<opti>[a-zA-Z]*)) +(lang="(?<lang>\w+)")\](?<content>.*?)(\[\/\k<tag>\])/m
      reg = /\[(?<tag>cc(?<opti>[a-zA-Z]*)(_(?<lang>\w+))?)\](?<content>.*?)(\[\/\k<tag>\])/m
      
      reg2 = /\[tex\](?<content>.*?)\[\/tex\]/im

      content = content.gsub(reg,'<pre><code language="\k<lang>">\k<content></code></pre>')
      content = content.gsub(reg1,'<pre><code language="\k<lang>">\k<content></code></pre>')
      content = content.gsub(reg2,"\n<script type=\"math/tex; mode=display\">\n\k<content>\n</script>\n")
      return content
    end
    
    def self.process(filename = "wordpress.xml")
      import_count = Hash.new(0)
      doc = Hpricot::XML(File.read(filename))
      h()
      (doc/:channel/:item).each do |item|
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

        type = item.at('wp:post_type').inner_text

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

        content = prepocess(content)
        
        FileUtils.mkdir_p "_#{type}s"
        File.open("_#{type}s/#{name}", "w") do |f|
          f.puts header.to_yaml
          f.puts '---'
          f.puts PandocRuby.convert(content, :from => :html, :to => :'markdown')
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
