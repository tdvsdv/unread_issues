module UnreadIssues
  module IssuePatch

    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        has_many :issue_reads, dependent: :delete_all, order: 'read_date DESC'
        has_one :user_read, class_name: 'IssueRead', foreign_key: 'issue_id', conditions: lambda { |*args| "#{IssueRead.table_name}.user_id = #{User.current.id}" }
        has_one :user_read_list, class_name: 'IssueRead', foreign_key: 'issue_id', conditions: lambda { |*args| "#{IssueRead.table_name}.user_id = #{Issue.table_name}.assigned_to_id" }
        alias_method_chain :css_classes, :unread_issues
      end
    end

    module InstanceMethods
      def css_classes_with_unread_issues
        s = css_classes_without_unread_issues
        s << ' unread' if (self.uis_unread)
        s << ' updated' if (self.uis_updated)
        s
      end

      def uis_read_date
        return nil if (self.user_read_list.nil?)
        return self.user_read_list.read_date
      end

      def uis_unread
        return !self.closed? && self.user_read.nil? && self.assigned_to_id == User.current.id
      end

      def uis_updated
        return !self.closed? && self.user_read && self.user_read.read_date && self.updated_on && self.user_read.read_date < self.updated_on && self.assigned_to_id == User.current.id
      end
    end
  end
end
