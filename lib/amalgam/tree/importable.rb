module Amalgam
  module Tree
    class Importable
      def self.import(yaml,force,attributes=[])
        Page.delete_all if force == true
        pages = YAML.load(yaml)
        create_tree(pages) do |slug,attrs,parent_id|
          page = ::Page.new
          unless attributes.empty?
            columns = Page.column_names & attributes
            columns.each do |column|
              page.send("#{column}=",attrs[column])if attrs[column] && !['lft','rgt'].include?(column)
            end
          else
            Page.column_names.each do |column|
              page.send("#{column}=",attrs[column])if attrs[column] && !['lft','rgt'].include?(column)
            end
          end
          if page.save
            page
          else
            if parent_id
              page = Page.where("parent_id = ? and slug = ?", parent_id, page.slug).first
            else
              page = Page.where("parent_id is ? and slug = ?", parent_id, page.slug).first
            end
          end
          page
        end
      end

      private

      def self.create_tree(object, parent_id = nil, &block)
        case object
          when Array then object.each { |tree| create_tree(tree, parent_id, &block) }
          when Hash then
            name, attrs = object.first
            node = yield(name,attrs,parent_id)
            (attrs['children']||[]).each { |c| node.children << create_tree(c, node.id, &block) }
            return node
        end
      end
    end
  end
end