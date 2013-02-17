require 'find'
module Amalgam
  module TemplateFinder
    @@cache = (Rails.env == 'production')
    mattr_accessor :cache

    class Rule
      @@rules = {}

      def self.load(root,model)
        @@rules[model] = []
        path = "#{root}/app/views/#{model.tableize}/"
        Find.find(path).each do |p|
          if File.file?(p) && Amalgam.accepted_formats.include?(File.extname(p))
            p.slice!(path)
            list = p.split('/')
            list[list.length-1] = list.last.split('.').first
            @@rules[model] << Rule.new(list)
          end
        end
        @@rules[model].sort{|x,y| y.list.length<=>x.list.length}
      end

      def initialize(list)
        @list = list
        @result = 0
      end

      def self.rules
        @@rules
      end

      def list
        @list
      end

      def self.look_up(pages,options = {})
        list = []
        @@rules[options[:path] || pages.first.class.model_name.tableize].clone.each{|rule| list << rule.look_up_single(pages.clone)}
        result1 = list.max{|x,y| x[1] <=> y[1]}
        result2 = list.select{|x| x[0].first != 'default' && x[0].first != 'show'}.max{|x,y| x[1] <=> y[1]}
        return result1[0] unless result2
        result = result1[1]>result2[1] ? result1[0] : result2[0]
      end

      def look_up_single(pages)
        result = 0
        is_self = true
        list = @list.clone.reverse<<nil
        pages<<nil
        level = nil
        rule = list.shift
        while list.present? && pages.present?
          page = pages.shift
          break unless page
          check_result = check(rule,page,is_self)
          is_self = false if is_self
          #puts check_result.to_s + ':'+rule+":"+page.template_keys.to_s
          if check_result>0 || rule.match(/^&?(\d+)/)
            result += check_result*(level&&rule!='default' ? 10*(1.0/level) : 1) unless rule=='default'&&pages.length>1&&list.length<=1
            level = nil
            rule = list.shift unless rule.match(/^&?(\d+)/)
            if rule && rule.match(/^&?(\d+)/)
              position = rule.match(/^&?(\d+)/)[1].to_i-1
              if pages.length > position+1
                rule = list.shift
                position.times{pages.shift}
                level = position + 1
              else
                break
              end
            end
          else
            if level
              return [@list,0]
            end
          end
        end
        if list.present?
          return [@list,0]
        else
          return [@list,result]
        end
      end

      private

      def check(rule,page,is_self)
        return 1 if rule=='default' || rule=='show'
        keys = rule.split('@')
        (1..keys.length-1).each do |i|
          keys[i] = '@' + keys[i]
        end
        keys.shift unless keys.first.present?
        if keys & page.template_keys == keys
          result = keys.first.include?('@') ? keys.length*100 : (keys.length-1)*100+10000
          result = keys.length unless is_self
          result
        else
          return 0
        end
      end
    end

    def self.included(base)
       class << base
        attr_accessor :slug_template_cache
       end
       base.slug_template_cache = Hash.new
    end

    protected

    def template_for(page,options={})
      if Rails.application.config.consider_all_requests_local
        Amalgam.load_templates
      end
      options[:path] ||= controller_name
      rule = Amalgam::TemplateFinder::Rule.look_up(page.ancestors.reverse.unshift(page),options)
      options[:path]+'/'+rule.join('/')
    end
  end
end