class Tree
  attr_reader :value
  def initialize(value)
    @value = value
    @children = []
  end
  
  def <<(value)
    subtree = Tree.new(value)
    @children << subtree
    return subtree
  end
  def depth n=0
    @children? @children.map {|child| child.depth}.max : 0
  end
end

r = Tree.new "1"
puts r.depth

