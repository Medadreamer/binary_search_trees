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
        @raw_data = array
        @root = build_tree(@raw_data.sort.uniq)
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

    def insert(value, node= @root)
        if value > node.data
            if !node.right_child 
                return node.right_child = Node.new(value)
            else
                return insert(value, node.right_child)
            end
        end


            
        if value < node.data
            if !node.left_child
                return node.left_child= Node.new(value)
            else
                return insert(value, node.left_child)
            end
        end

        if value == node.data
            return "Value already exists"
        end

    end

    def find_closest(node)
        !node.left_child ? node : find_closest(node.left_child)
    end


    def delete(value, node= @root, parent= nil)
        if node.data == value
            if !node.right_child && !node.left_child
                parent.right_child = nil if parent && value > parent.data
                parent.left_child = nil if parent && value < parent.data
                @root = nil if !parent
            elsif node.right_child && node.left_child
                closest_node = find_closest(node.right_child)
                delete(closest_node.data)
                node.data = closest_node.data
            elsif node.right_child
                parent.right_child = node.right_child if parent && value > parent.data
                parent.left_child = node.right_child if parent && value < parent.data
                node.right_child = nil
                @root = node.right_child if !parent
            else
                parent.right_child = node.left_child if parent && value > parent.data
                parent.left_child = node.left_child if parent && value < parent.data
                node.left_child = nil
                @root = node.left_child if !parent
            end

        end

        delete(value, node.right_child, node) if value > node.data && node.right_child
        delete(value, node.left_child, node) if value < node.data && node.left_child
    end

    def find(value, node= @root)
        node.data == value ? node :
        value > node.data && node.right_child ? find(value, node.right_child) : 
        value < node.data && node.left_child ? find(value, node.left_child) : return
    end

    def level_order
        queue = [@root]
        ordered_data = []

        while !queue.empty?
            current_node = queue.shift
            ordered_data.push(current_node.data)
            queue.push(current_node.left_child) if current_node.left_child
            queue.push(current_node.right_child) if current_node.right_child
        end

        block_given? ? ordered_data.select {|data| yield(data)} : ordered_data 
    end

    def level_order_rec(queue= [@root], ordered_data= [])
        current_node = queue.shift
        ordered_data.push(current_node.data)

        queue.push(current_node.left_child) if current_node.left_child
        queue.push(current_node.right_child) if current_node.right_child

        level_order(queue, ordered_data) unless queue.empty?

        block_given? ? ordered_data.select {|data| yield(data)} : ordered_data
    end

    def preorder(node= @root, ordered_data= [])
        ordered_data.push(node.data)
        preorder(node.left_child, ordered_data) if node.left_child
        preorder(node.right_child, ordered_data) if node.right_child

        block_given? ? ordered_data.select {|data| yield(data)} : ordered_data
    end

    def inorder(node= @root, ordered_data= [])

        inorder(node.left_child, ordered_data) if node.left_child
        ordered_data.push(node.data)
        inorder(node.right_child, ordered_data) if node.right_child

        block_given? ? ordered_data.select {|data| yield(data)} : ordered_data
    end

    def postorder(node= @root, ordered_data= [])
        postorder(node.left_child, ordered_data) if node.left_child
        postorder(node.right_child, ordered_data) if node.right_child
        ordered_data.push(node.data)

        block_given? ? ordered_data.select {|data| yield(data)} : ordered_data
    end

    def height(data, height= -1)
        return "Not found" if find(data).nil?

        node = find(data)
        height += 1

        return height if node.right_child.nil? && node.left_child.nil?
        return height(node.left_child.data, height) if node.right_child.nil?
        return height(node.right_child.data, height) if node.left_child.nil?
       
        height = height(node.left_child.data, height) > height(node.right_child.data, height) ? height(node.left_child.data, height) : height(node.right_child.data, height)
    end

    def depth(data, node= @root, depth= -1)
        return "Not found" if find(data).nil?
        depth += 1
        node.data == data ? depth :
        data > node.data && node.right_child ? depth(data, node.right_child, depth) : 
        data < node.data && node.left_child ? depth(data, node.left_child, depth) : return
    end

    def balanced?
        # gather all nodes with two children
        nodes_array = self.inorder do |data| 
            node = find(data)
            node.right_child && node.left_child ? true : false    
        end

        #check the height diffrence for all parents
        diff_checker = nodes_array.map do |node|
            node = find(node)
            (height(node.right_child.data) - height(node.left_child.data)).abs > 1
        end

        # return true if all diffs <= 1
        diff_checker.all?{|diff| !diff}
    end

    def rebalance
        @root = build_tree(self.inorder.sort)
    end

    def pretty_print(node = @root, prefix = '', is_left = true)
        pretty_print(node.right_child, "#{prefix}#{is_left ? '???   ' : '    '}", false) if node.right_child
        puts "#{prefix}#{is_left ? '????????? ' : '????????? '}#{node.data}"
        pretty_print(node.left_child, "#{prefix}#{is_left ? '    ' : '???   '}", true) if node.left_child
    end

end
