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

  def mm_page_counters
    if (!Redmine::Plugin.installed?(:magic_my_page) || params[:type].blank?)
      mmp_render_counters(nil, nil, url_for(only_path: true))
      return
    end

    settings = (Setting.plugin_unread_issues[:magic_my_page_necessary_actions] || { })[params[:type]]
    if (settings.nil? || settings == { })
      mmp_render_counters(nil, nil, url_for(only_path: true))
      return
    end

    settings = settings.clone( )

    data = { count: 0, affects: nil }
    result = [ ]

    case params[:type]
      when 'changes_in_issues'
        data[:count] = 0
      when 'new_issues'
        data[:count] = 0
    end

    result << data if (result.size == 0)
    result.collect { |it|
      it[:custom_link] ||= "<a href='#{url_for({ controller: :kpi_period_users, action: params[:type] })}'><span>#{l('label_' + params[:type].to_s)}</span></a>".html_safe
    }

    mmp_render_counters(result, settings, url_for(only_path: true))
  end

end