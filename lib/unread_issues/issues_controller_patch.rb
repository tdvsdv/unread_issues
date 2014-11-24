module UnreadIssues
  module IssuesControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        after_filter :make_issue_read, only: [:show]
        after_filter :make_issue_read_after_bulk_edit, only: [:bulk_update]
      end
    end

    module InstanceMethods

      def  make_issue_read
                save_issue_read(@issue.id)
      end

        def make_issue_read_after_bulk_edit
          unless params[:ids].empty?
                params[:ids].each do |id|
                         save_issue_read(id)
                end
          end

        end

        private

        def save_issue_read(issue_id)

                issue_read = IssueRead.find_or_create_by_user_id_and_issue_id(User.current.id, issue_id)
                issue_read.user_id = User.current.id
                issue_read.issue_id = issue_id
                issue_read.read_date = Time.now
                issue_read.save
       end

    end
  end
