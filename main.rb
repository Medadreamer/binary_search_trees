require "pry-byebug"

class Node
    include Comparable
    attr_accessor :data, :right_child, :left_child
    def initialize(data)
        @data = data
        @right_child = nil
        @left_child = nil
    end

    def <=>(other)
        @data <=> other.data
    end
end


class BinaryTree
    attr_reader :root
    def initialize(array)
        @root = build_tree(array.sort.uniq)
    end

    def build_tree(array)
        left_children = array.slice!(0, array.length/2)
        right_children = array
        middle = right_children.length == left_children.length ? left_children.pop : right_children.shift
        

        parent = Node.new(middle)
        parent.left_child = build_tree(left_children) if !left_children.empty?
        parent.right_child = build_tree(right_children) if !right_children.empty?
        parent
    end
end

