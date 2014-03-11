class IssueReadsController < ApplicationController

  def count
    num_issues = 0
    case params[:req]
    when 'assigned'
      # assigned_issues = User.current.assigned_issues.joins(:status).where("#{IssueStatus.table_name}.is_closed = ?", false).count
      # num_issues = assigned_issues.size
      num_issues = User.current.count_opened_assigned_issues
    when 'unread'
      num_issues = User.current.count_unread_issues
    when 'updated'
      num_issues = User.current.count_updated_issues
    end
    # save counter to prevent extra ajax request

    ajax_counter_respond(num_issues)
  end

end