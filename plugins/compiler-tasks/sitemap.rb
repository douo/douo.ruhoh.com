# Sitemap Generator is a Ruhoh plugin that generates a sitemap.xml file by
# traversing all of Ruhoh::DB.pages and Ruhoh::DB.posts object.
#
# How to Use:
#   1.) Copy this file to your blog's plugins folder within your Ruhoh project
#   2.) Custom settings in the ruhoh's site.yml (See Notes)
#
# Customizations:
#   1.) If there are any files you don't want to included in the sitemap, add
#       their ID (find it in `ruhoh payload`) to the *exclude_id* yaml config
#   2.) If you want to include the optional changefreq and priority attributes,
#       simply include custom variables in the YAML Front Matter of that file.
#       The names of these custom variables are defined in the config file
#       named:
#         - change_frequency_custom_name  #default "changefreq"
#         - priority_custom_variable_name #default "priority"
#
# Notes:
#   1.) The lastmod time is determined by the latest from the following(TODO):
#         - git log date of the page or post
#         - git log date of included layout
#         - git log date of included layout within that layout
#         - ...
#   2.) Full config of this plugin (all is optional)
#
#        #plugins:
#        #  sitemap_generator:
#        #    file_name: sitemap.xml
#        #    exclude_id:
#        #      - search.html
#        #    change_frequency_custom_name: changefreq
#        #    priority_custom_variable_name: priority
#
# Author: Ruohan Chen
# Site: https://github.com/crhan/ruhoh_plugins
# Distributed Under A Creative Commons License
#   - http://creativecommons.org/licenses/by-sa/3.0/

require 'nokogiri'

class Ruhoh
  module Compiler
    module Sitemap
      def self.run(target, page)
        production_url = Ruhoh::DB.site['config']['production_url']

        config = Ruhoh::DB.site['plugins']['sitemap_generator'] || {} rescue {}
        sitemap_file_name = config['file_name'] || "sitemap.xml"
        exclude_id = config['exclude_id'] || []
        change_frequency_custom_name = config['change_frequency_custom_name'] || "changefreq"
        priority_custom_name = config['priority_custom_variable_name'] || "priority"

        sitemap = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.urlset(:xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9") {
            Ruhoh::DB.posts['chronological'].each do |post_id|
              post = Ruhoh::DB.posts['dictionary'][post_id]
              page.change(post_id)
              xml.url {
                xml.loc_ "#{production_url}#{post['url']}"
                xml.lastmod_ File.mtime(post_id)
                xml.priority_ (post[priority_custom_name] ? post[priority_custom_name] : '0.2') 
                xml.changefreq_ (post[change_frequency_custom_name] ? post[change_frequency_custom_name] : 'monthly') 
              }
            end #posts

            Ruhoh::DB.pages.each do |id, page|
              next if exclude_id.include? id
              xml.url {
                xml.loc_ "#{production_url}#{page['url']}"
                xml.lastmod_ File.mtime("pages/#{id}")
                xml.priority_ (page[priority_custom_name] ? page[priority_custom_name] : (page['url']=='/' ? '1.0':'0.2')) 
                xml.changefreq_ (page[change_frequency_custom_name] ? page[change_frequency_custom_name] : (page['url']=='/' ? 'daily':'monthly')) 
              }
            end #pages
          }
        end
        File.open(File.join(target, sitemap_file_name), 'w') { |p| p.puts sitemap.to_xml }
        Ruhoh::Friend.say { green "processed: #{sitemap_file_name}" }
      end
    end #Sitemap
  end #Compiler
end #Ruhoh
