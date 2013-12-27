module UnreadIssues
  module IssuesControllerPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        after_filter :make_issue_read, :only => [:show]
      end
    end

    module ClassMethods
    end

    module InstanceMethods

      def make_issue_read
        issue_read=IssueRead.find_or_create_by_user_id_and_issue_id(User.current.id, @issue.id)
        issue_read.user_id=User.current.id
        issue_read.issue_id=@issue.id
        issue_read.read_date=Time.now
        issue_read.save
      end
    end
  end
end
