module Ruhoh::Resources::Notes  
  class Client
    Help = [
      {
        "command" => "new <(category title)/title>",
        "desc" => "Create a new note. Specific category and title or just title. if no title will create quick note",
      },
      {
        "command" => "drafts",
        "desc" => "List all drafts.",
      },
      {
        "command" => "empty",
        "desc" => "List all empty content notes.",
      },
      {
        "command" => "list",
        "desc" => "List all resources.",
      }
    ]
    def initialize(collection, data)
      @ruhoh = collection.ruhoh
      @collection = collection
      @args = data[:args]
      @options = data[:options]
      @iterator = 0
    end
    
    def new
      create
    end
    

    def render_scaffold(title, quick_note)
      (@collection.scaffold || '')
        .gsub('{{DATE}}', Time.now.strftime('%Y-%m-%d'))
        .gsub('{{TITLE}}', quick_note ? Time.now.strftime(@collection.config['quick_title'])  : title)
    end
  
    def quick_note_name
      format = @collection.config['quick_name']  || 'note-%Y-%m-%d'
      Time.now.strftime(format)
    end
    
    def default_category(quick_note)
      if quick_note
        format = @collection.config['quick_dir'] || "#{@collection.config['default_dir']}%Y/%m"
        "#{Time.now.strftime(format)}" 
      else
        @collection.config['default_dir']
      end
    end
    
    protected
    
    def create
      title = @args[3]
      category = nil
      if title        
        category = @args[2]
      else
        title = @args[2]
      end
      ruhoh = @ruhoh
      resource_name = @collection.resource_name
      quick_note = title == nil
      title ||= quick_note_name # 无标题作为  quick note 对待
      category ||= default_category(quick_note)
      ext  = @collection.config["ext"]
      
      name =  Ruhoh::StringFormat.clean_slug(title)
      filename = category.start_with?(resource_name)?
          File.join(@ruhoh.paths.base, category, "#{name}#{ext}") :
          File.join(@ruhoh.paths.base, resource_name, category, "#{name}#{ext}")
      if File.exist?(filename)
         
         Ruhoh::Friend.say { 
          red "create #{resource_name} fail:"
          red "  > #{ruhoh.relative_path(filename)}"
          red "  > aleady exist!"
        }
      else
        FileUtils.mkdir_p File.dirname(filename)
        File.open(filename, 'w:UTF-8') { |f| f.puts render_scaffold(title,quick_note) }
        Ruhoh::Friend.say { 
          green "New #{resource_name}:"
          green "  > #{ruhoh.relative_path(filename)}"
        }
      end
    end
    
    
    def drafts
      _list(@collection.drafts)
    end

    def list
      _list(@collection.all)
    end
    
    def empty
      _list(@collection.empty)
    end
    
    def _list(data)
      if @options.verbose
        Ruhoh::Friend.say {
          data.each do |p|
            cyan("- #{p['id']}")
            plain("  title: #{p['title']}") 
            plain("  url: #{p['url']}")
          end
        }
      else
        Ruhoh::Friend.say {
          data.each do |p|
            cyan("- #{p['id']}")
          end
        }
      end
    end
    
  end
end