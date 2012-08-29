require 'yaml'

module TreeMacros

  def setup_tree(model_class,tree)
    create_tree(model_class,YAML.load(tree))
  end

  def nodes(name)
    @nodes[name].reload
  end

  def print_tree(node, inspect = false, depth = 0)
    print '  ' * depth
    print '- ' unless depth == 0
    print node.title
    print " (#{node.inspect})" if inspect
    print ':' if node.children.any?
    print "\n"
    node.children.each { |c| print_tree(c, inspect, depth + 1) }
  end

private
  def create_tree(model_class,object)
    case object
      when String then return create_node(model_class,object)
      when Array then object.each { |tree| create_tree(model_class,tree) }
      when Hash then
        name, children = object.first
        node = create_node(model_class,name)
        children.each { |c| node.children << create_tree(model_class,c) }
        return node
    end
  end

  def create_node(model_class,name)
    @nodes ||= HashWithIndifferentAccess.new
    @nodes[name] = model_class.create(:title => name , :slug => name)
  end
end

RSpec.configure do |config|
  config.include TreeMacros
end
