module Amalgam
  module Tree
    class Exportable
      def self.export(attributes = [])
        tmp_hash = []
        @pages = Page.all
        children_nodes.each do |node|
          render_tree node, tmp_hash, attributes
        end
        tmp_hash
      end

      protected

      def self.render_tree node,hash,attributes
        self_hash = self.create_item(node,attributes)
        hash << self_hash
        if children_nodes(node).present?
          self_hash[node.slug]['children'] = []
          children_nodes(node).each do |child|
            render_tree child, self_hash[node.slug]['children'], attributes
          end
        end
      end

      def self.children_nodes(node=nil)
        node ? @pages.select{ |x| x.parent_id == node.id} : @pages.select{ |x| x.parent_id == nil}
      end

      def self.create_item(node,attributes)
        hash = {node.slug => {}}
        unless attributes.empty?
          attributes.each do |attribute|
            hash[node.slug][attribute] = node.send attribute if node.respond_to?(attribute) and node.send attribute
          end
        else
          Page.column_names.each do |column|
            hash[node.slug][column] = node.send column if node.respond_to?(column) and node.send column
          end
        end
        hash
      end

    end
  end
end