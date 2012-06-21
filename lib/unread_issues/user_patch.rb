module UnreadIssues
  module UserPatch
    def self.included(base)
		base.extend(ClassMethods)
		base.send(:include, InstanceMethods)	

		base.class_eval do
			has_many :issue_reads, :dependent=>:delete_all
			has_many :assigned_issues, :class_name =>'Issue' , :foreign_key => 'assigned_to_id'
		end
		
    end
	
	module ClassMethods   
	
	end
	
	module InstanceMethods
		def my_page_caption
			s="<span>#{l(:my_issues_on_my_page)} </span> "
			s << "<span>(#{assigned_issues.open(true).size}/</span>"
			s << "<span class='#{'unread' if count_unread_issues>0}'> #{count_unread_issues}/</span>"
			s << "<span class='#{'updated' if count_updated_issues>0}'> #{count_updated_issues})</span>"
			s.html_safe
		end

		def count_unread_issues
			assigned_issues.open(true).count(:include => [:issue_reads], :conditions => ["#{IssueRead.table_name}.user_id=?", id])
		end

		def count_updated_issues
			assigned_issues.open(true).count(:include => [:issue_reads], :conditions => ["#{IssueRead.table_name}.read_date < #{Issue.table_name}.updated_on AND #{IssueRead.table_name}.user_id=?", id])
		end		
	end
	
  end
end
