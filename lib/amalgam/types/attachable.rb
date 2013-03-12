# encoding: UTF-8
module Amalgam
  module Types
    module Attachable
      extend ActiveSupport::Concern

      included do
        attr_accessible :attachments_attributes, :as => Amalgam.admin_access_attr_as
        attr_accessible :attachments_attributes, :as => Amalgam.edit_access_attr_as
        has_many :attachments, :as => :attachable, :class_name => Amalgam.attachment_class_name, :extend => ::Amalgam::Models::Attachable::AttachmentExtension
        accepts_nested_attributes_for :attachments,
          :allow_destroy => true,
          :reject_if => proc {|attachment| attachment[:id].blank? && attachment[:file].blank?}
      end

      module AttachmentExtension
        # 返回一个 <tt>#HashWithIndifferentAccess</tt>
        # 包含所有的附件,key为附件的name或者索引, value 为集合, 可直接作为第一个元素调用
        # 举例:
        #  page[:attachments]
        #  # => [{:name => 'file' , :file => <FILE1> },
        #  #     {:name => 'file2' , :file => <FILE2> },
        #  #     {:name => 'file3', :file => <FILE3>}
        #  #     {:file => <FILE4>}]
        #  page.attachments
        #  #  => {0 => <FILE1> , 1 => <FILE2> , 2 => <FILE3> ,3 => <FILE4>
        #         'file' => [<FILE1>,<FILE2>],
        #         'file2' => [<FILE3>]
        #        }
        #  page.attachments['file'].name #=> page.attachments['file'].first.name
        def [](key)
          return @attachments_hash[key] if @attachments_hash
          @attachments_hash = HashWithIndifferentAccess.new
          each_with_index do |a,i|
            @attachments_hash[i] = a
            if a.name.present?
              @attachments_hash[a.name] = (@attachments_hash[a.name] || Amalgam::Utils::DelegateArray.new) << a
            end
          end
          @attachments_hash[key]
        end
      end
    end
  end
end