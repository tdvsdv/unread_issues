module UnreadIssues
  module IssuePatch

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)  

      base.class_eval do
        has_many :issue_reads, :dependent=>:delete_all
        has_one :user_read, :class_name => 'IssueRead', :foreign_key => 'issue_id', :conditions => lambda{|*args| "user_id=#{User.current.id}" }
        alias_method_chain :css_classes, :unread_issues
      end
    end
  
    module ClassMethods    
    end
  
    module InstanceMethods
      def css_classes_with_unread_issues
        s = css_classes_without_unread_issues
        s << ' unread' if unread?
        s << ' updated' if updated?
        s
      end
  
      def unread?
        not (!user_read.nil? or (assigned_to_id != User.current.id) or closed?)
      end 
  
      def updated?
        !user_read.nil? and (user_read.read_date < updated_on) and (assigned_to_id == User.current.id) and !closed?
      end
  
    end
  
  end
end
