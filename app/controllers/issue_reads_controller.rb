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

    today = Date.today
    days_dec = (settings[:deadline] || { })[:days_inc].to_i.days
    old = (today - days_dec).strftime('%Y-%m-%d')
    week = (today - days_dec + 7.days).strftime('%Y-%m-%d')
    month = (today.end_of_month - days_dec).strftime('%Y-%m-%d')
    data[:custom_link] = "<a href='#{my_page_path}'><span>#{l('unread_issues.magic_my_page.label_view')}</span></a>".html_safe

    counts = nil
    case params[:type]
      when 'changes_in_issues'
        counts = Issue.joins(:status, :issue_reads)
                      .where("#{IssueRead.table_name}.read_date < #{Issue.table_name}.updated_on
                          and #{IssueRead.table_name}.user_id = :user_id
                          and #{Issue.table_name}.assigned_to_id = :user_id
                          and #{IssueStatus.table_name}.is_closed = :false_flag
                             ", user_id: User.current.id, false_flag: false)
                      .select("SUM(case when #{IssueRead.table_name}.read_date <= '#{old}' then 1 else 0 end) as old,
                               SUM(case when #{IssueRead.table_name}.read_date > '#{old}' and #{IssueRead.table_name}.read_date <= '#{week}' then 1 else 0 end) as soon,
                               SUM(case when #{IssueRead.table_name}.read_date > '#{week}' and #{IssueRead.table_name}.read_date <= '#{month}' then 1 else 0 end) as in_this_month,
                               SUM(case when #{IssueRead.table_name}.read_date > '#{month}' then 1 else 0 end) as in_next_month
                              ").first
      when 'new_issues'
        counts = Issue.joins(:status)
                      .joins("LEFT JOIN #{IssueRead.table_name} ir on ir.issue_id = #{Issue.table_name}.id and ir.user_id = #{User.current.id}")
                      .where("ir.read_date is null
                          and #{Issue.table_name}.assigned_to_id = :user_id
                          and #{IssueStatus.table_name}.is_closed = :false_flag
                             ", user_id: User.current.id, false_flag: false)
                      .select("SUM(case when #{Issue.table_name}.created_on <= '#{old}' then 1 else 0 end) as old,
                               SUM(case when #{Issue.table_name}.created_on > '#{old}' and #{Issue.table_name}.created_on <= '#{week}' then 1 else 0 end) as soon,
                               SUM(case when #{Issue.table_name}.created_on > '#{week}' and #{Issue.table_name}.created_on <= '#{month}' then 1 else 0 end) as in_this_month,
                               SUM(case when #{Issue.table_name}.created_on > '#{month}' then 1 else 0 end) as in_next_month
                              ").first
    end

    data[:affects] = today.strftime('%Y-%m-%d')
    data[:count] = counts.nil? ? 0 : counts.attributes['old'].to_i
    result << data.clone( )

    data[:affects] = (today + 6.day).strftime('%Y-%m-%d')
    data[:count] = counts.nil? ? 0 : counts.attributes['soon'].to_i
    result << data.clone( )

    data[:affects] = (today.end_of_month).strftime('%Y-%m-%d')
    data[:count] = counts.nil? ? 0 : counts.attributes['in_this_month'].to_i
    result << data.clone( )

    data[:affects] = (today.end_of_month + 1.day).strftime('%Y-%m-%d')
    data[:count] = counts.nil? ? 0 : counts.attributes['in_next_month'].to_i
    result << data.clone( )

    mmp_render_counters(result, settings, url_for(only_path: true))
  end

end