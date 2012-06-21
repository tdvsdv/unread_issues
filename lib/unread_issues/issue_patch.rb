module UnreadIssues
  module IssuePatch
    def self.included(base)
		base.extend(ClassMethods)
		base.send(:include, InstanceMethods)	

		base.class_eval do
			has_many :issue_reads, :dependent=>:delete_all
			alias_method_chain :css_classes, :unread_issues
		end
		
    end
	
	module ClassMethods   
	
	end
	
	module InstanceMethods
		def css_classes_with_unread_issues
			s=css_classes_without_unread_issues
			s << ' unread' if unread?
			s << ' updated' if updated?
			s
		end

		def unread?
			if issue_reads.count(:conditions => ["user_id=?", User.current.id])>0 or assigned_to_id != User.current.id or closed?
				return false
			else
			    return true
			end
		end	

		def updated?
			if issue_reads.count(:conditions => ["read_date < ? AND user_id=?", updated_on, User.current.id])>0 and assigned_to_id == User.current.id and not closed?
				return true
			else
			    return false
			end
		end
	end
	
  end
end
