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
end

r = Tree.new 0
r << 1
r << 2
r << 3
r.children[1] << 4
r.children[1] << 5
r.children[2] << 6
r.children[2] << 7
r.children[2].children[0] << 8
puts r.depth
puts r.children[1].depth

