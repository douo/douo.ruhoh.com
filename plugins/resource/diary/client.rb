module Ruhoh::Resources::Diary
  class Client
    Help = [
      {
        "command" => "today",
        "desc" => "Create a new diary, Name by today.",
      },
      {
        "command" => "yesterday",
        "desc" => "Create a new diary, Name by yesterday.",
      },
      {
        "command" => "empty",
        "desc" => "List all empty content diary.",
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
    
    def today
       create Time.now.strftime('%Y-%m-%d')
    end
    
    def yesterday
      create (Time.now - 86400).strftime('%Y-%m-%d')
    end
    
    def create(date)
      ext  =  @collection.config["ext"] 
      filename = File.join(@ruhoh.paths.base, @collection.resource_name, "#{date}#{ext}")
      
      ruhoh = @ruhoh
      resource_name = @collection.resource_name
      
      if File.exist?(filename)
        Ruhoh::Friend.say {
          red "Create #{resource_name} fail:"
          red "  >#{ruhoh.relative_path(filename)} already exist"
        }
        return
      end
  
      FileUtils.mkdir_p File.dirname(filename)

      File.open(filename, 'w:UTF-8') { |f| f.puts render_scaffold }

      
      Ruhoh::Friend.say { 
        green "New #{resource_name}:"
        green "  > #{ruhoh.relative_path(filename)}"
      }
    end
    
    # Public - renders the scaffold, if available, for this resource.
    def render_scaffold
      (@collection.scaffold || '')
        .gsub('{{DATE}}', Time.now.strftime('%Y-%m-%d'))
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