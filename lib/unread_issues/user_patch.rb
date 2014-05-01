module UnreadIssues
  module UserPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        has_many :issue_reads, dependent: :delete_all
        has_many :assigned_issues, class_name: 'Issue' , foreign_key: 'assigned_to_id'
      end
    end

    module InstanceMethods
      def my_page_caption
        s = "<span class='my_page'>#{l(:my_issues_on_my_page)}</span> "
        s << "<span id='my_page_issues_count'>#{my_page_counts}</span>"
        s.html_safe
      end

      def my_page_counts
        if Redmine::Plugin::registered_plugins.include?(:ajax_counters)
          s = self.ajax_counter('/issue_reads/count/assigned', {period: 0, css: 'count'})
          s << self.ajax_counter('/issue_reads/count/unread', {period: 0, css: 'count unread'})
          s << self.ajax_counter('/issue_reads/count/updated', {period: 0, css: 'count updated'})
        else
          s = "<span class=\"count\">#{count_opened_assigned_issues}</span>"
          s << "<span class=\"count #{'unread' if count_unread_issues>0}\">#{count_unread_issues}</span>"
          s << "<span class=\"count #{'updated' if count_updated_issues>0}\">#{count_updated_issues}</span>"
        end
        s.html_safe
      end

      def count_opened_assigned_issues
        assigned_issues.joins(:status).where("#{IssueStatus.table_name}.is_closed = ?", false).size
      end

      def ui_unread_issues
        Issue.joins(:status)
             .joins("LEFT JOIN #{IssueRead.table_name} ir on ir.issue_id = #{Issue.table_name}.id and ir.user_id = #{User.current.id}")
             .where("ir.read_date is null
                 and #{Issue.table_name}.assigned_to_id = ?
                 and #{IssueStatus.table_name}.is_closed = ?
                    ", self.id, false)
      end

      def count_unread_issues
        return self.ui_unread_issues.count
      end

      def ui_updated_issues
        Issue.joins(:status, :issue_reads)
             .where("#{IssueRead.table_name}.read_date < #{Issue.table_name}.updated_on
                 and #{IssueRead.table_name}.user_id = :user_id
                 and #{Issue.table_name}.assigned_to_id = :user_id
                 and #{IssueStatus.table_name}.is_closed = :false_flag
                    ", user_id: self.id, false_flag: false)
      end

      def count_updated_issues
        return self.ui_updated_issues.count
      end
    end
  end
end
