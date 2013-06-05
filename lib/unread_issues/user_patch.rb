

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
			s="<span class='my_page'>#{l(:my_issues_on_my_page)}</span> "
			s <<"<span class='hidden'><span id='unread_issues_frequency'>#{Setting.plugin_unread_issues['frequency'].to_s}</span><span id='unread_issues_decay'>#{Setting.plugin_unread_issues['decay'].to_s}</span></span><span id='my_page_issues_count'>" 
			s << my_page_counts
			s <<"</span>"
			s.html_safe
		end

		def my_page_counts
			s = "<span class=\"count\">#{count_opened_assigned_issues}</span>"
			s << "<span class=\"count #{'unread' if count_unread_issues>0}\"> #{count_unread_issues}</span>"
			s << "<span class=\"count #{'updated' if count_updated_issues>0}\"> #{count_updated_issues}</span>"
			s.html_safe				
		end

		def opened_assigned_issues
			@opened_assigned_issues||=assigned_issues.find(:all, :conditions => ["#{IssueStatus.table_name}.is_closed = ?", false], :include => :status)
		end

		def count_opened_assigned_issues
			@count_opened_assigned_issues||=opened_assigned_issues.size
		end

		def count_opened_assigned_read_issues
			@count_opened_assigned_read_issues||=IssueRead.count_by_sql("SELECT COUNT(*) FROM #{IssueStatus.table_name}, #{Issue.table_name}, #{IssueRead.table_name}
																		WHERE 
																		#{IssueStatus.table_name}.is_closed!=1
																		AND #{IssueStatus.table_name}.id=#{Issue.table_name}.status_id
																		AND #{Issue.table_name}.assigned_to_id=#{id}																	
																		AND #{Issue.table_name}.id=#{IssueRead.table_name}.issue_id
																		AND #{IssueRead.table_name}.user_id=#{id}
																		")			
		end

		def count_unread_issues
			@count_unread_issues||=count_opened_assigned_issues-count_opened_assigned_read_issues
		end

		def count_updated_issues
			@count_updated_issues||=assigned_issues.count(:include => [:issue_reads, :status], :conditions => ["#{IssueRead.table_name}.read_date < #{Issue.table_name}.updated_on AND #{IssueRead.table_name}.user_id=? AND #{IssueStatus.table_name}.is_closed = ?", id, false])
		end		
	end
	
  end
end
