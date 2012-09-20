# -*- coding: utf-8 -*-

require 'nokogiri'
class Ruhoh
  module Compiler
    # the origin rss compiler is provided by David Long 
    # http://www.davejlong.com/ 
    # https://github.com/davejlong
    # Thanks David!

    # this rss compiler is modified by Douo
    # use  page.render_content instead of page.render 
    # add some useful tag
    # todo: add some configuration to site.yml

    module Rss
      # TODO: This renders the page content even though we already need to
      # render the content to save to disk. This will be a problem when posts numbers expand. Merge this in later.
      def self.run(target, page)
        feed = Nokogiri::XML::Builder.new do |xml|
         xml.rss(:version => '2.0', 
                 'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
                 'xmlns:content' => "http://purl.org/rss/1.0/modules/content/"
                 ) {
            xml.channel {
              
              xml.title_ Ruhoh::DB.site['title']
              xml.link_ Ruhoh::DB.site['config']['production_url']
              xml.description_ Ruhoh::DB.site['tagline']
              xml.lastBuildDate_ Time.now.strftime("%a, %d %b %Y %H:%M:%S %z")

              Ruhoh::DB.posts['chronological'].each do |post_id|
                post = Ruhoh::DB.posts['dictionary'][post_id]
                page.change(post_id)
                xml.item {
                  xml.title_ post['title']
                  xml.link "#{Ruhoh::DB.site['config']['production_url']}#{post['url']}"
                  xml.pubDate_ Time.parse(post['date']).strftime("%a, %d %b %Y %H:%M:%S %z")
                  xml['dc'].creator_ Ruhoh::DB.site['author']['name']

                  # xml.guid(:isPermalink => 'false'){  
                  #   xml.text "#{Ruhoh::DB.site['config']['production_url']}/?id=#{post_id}"
                  # }

                  # append categories and tags
                  post['categories'].each do |c|
                    xml.category {
                      xml.cdata c
                    }
                  end
                  post['tags'].each do |t|
                    xml.category {
                      xml.cdata t
                    }
                  end
                  
                  xml.description_  post['description'] 
                  xml['content'].encoded {
                    xml.cdata  page.render_content
                  }
                }
              end
            }
          }
        end
        # 不知道爲什麼要強制制定爲UTF-8
        #Ruhoh::Friend.say {red feed.to_xml.force_encoding(Encoding.default_external).encoding }
        File.open(File.join(target, 'rss.xml'), 'w:UTF-8'){ |p| p.puts feed.to_xml.force_encoding(Encoding.default_external) }
        Ruhoh::Friend.say { green "processed: rss.xml" }
      end
    end #Rss
  end #Compiler
end #Ruhoh
