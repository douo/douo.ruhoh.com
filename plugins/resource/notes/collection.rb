# -*- coding: utf-8 -*-
require 'pp'
module Ruhoh::Resources::Notes
  class Node
    attr_accessor :name, :level, :data, :parent
    attr_reader :children
    
    def initialize(is_leaf = false)
      @level = 0
      @children = [] unless is_leaf
    end
    
    def []=(name, node)
       node.name = name
       node.level = @level + 1
       insert(node)
    end
    
    def [](name)
      children.each{|c| return c if c.name==name}
      nil
    end
    
    def insert(node)
      idx = 0
      children.each do |v|
        break if (node <=> v) > 0
        idx += 1
      end
      children.insert(idx,node)
    end
    
    def has_child
      @children && @children.size > 0
    end
    
    def is_leaf
      ! @children
    end
    
    def size
      @children ? @children.size : 0
    end
    
    # 计算所有叶节点数目，也就是当前分类的所有笔记数目
    # Returns 所有叶节点数目，叶节点返回 1
    # 可用 DP 算法，优化编译的效率
    def count
      if has_child
        @children.inject(0){|sum,child|
          sum + child.count
        }
      else
        1
      end
    end
    
    def <=> (y)
      if !is_leaf and y.is_leaf
        1
      elsif is_leaf and !y.is_leaf
        -1
      else
        name<=>y.name
      end
    end

    def submenu
      level>1
    end
    
  end
  module Tree
    def tree
      return @root if @root
      @root = Node.new
      dictionary
      @root
    end

    def tree_add(data)
      @root ||= Node.new
      p = @root
      link = data['id'].split(File::SEPARATOR)
      link.each{|n|
        if File.basename(n,'.*') == 'index'
          break
        end
        if !p[n]
          node = (n == link.last ? Node.new(true) : Node.new)
          node.parent = p
          p[n] = node
        end
        p = p[n]
      }
      p.data = data
    end

    # TODO
    def tree_delete(pointer)
      puts 'node_delete'
      puts pointer
    end
  end
  
  class Collection < Ruhoh::Resources::Pages::Collection
    include Tree
    
    def navigation
      tree
    end
    
    def self.is_acting_as_pages
      true
    end
    def update(model_data)
      return if @ruhoh.env != "development" and model_data['data']['type'] == "draft"
      super
      tree_add(model_data['data'])
    end
    
    def touch(name_or_pointer)
      super
      tree_delete(pointer)
    end
    
    def _all_files
      dict = {}
      paths.each do |path|
        FileUtils.cd(path) { 
          Dir[glob].each { |id|
            next unless File.exist?(id) && FileTest.file?(id)
            # 与父目录相同文件名的文件也当作index处理
            _id = is_index?(id) ? "#{File.dirname(id)}/index.md" : id
            
            dict[_id] = {
              "id" => _id,
              "realpath" => File.realpath(id),
              "resource" => resource_name,
            }
          }
        }
      end

      dict
    end
    
     def is_index?(id)
      File.basename(File.dirname(id)).casecmp(File.basename(id,'.*')) == 0
    end
   end
end
