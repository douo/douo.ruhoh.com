class Tree
  attr_reader :value
  attr_reader :children

  def initialize(value)
    @value = value
    @children = []
  end
  
  def <<(value)
    subtree = Tree.new(value)
    @children << subtree
    return subtree
  end
  
  def depth
    @children==[]? 0 : (@children.map {|child| child.depth}.max+1)
  end
  
  def size 
    @children.reduce(@children.size){|s,c| s+c.size}
  end
  
end
