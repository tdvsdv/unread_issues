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

    settings = ((Setting.plugin_unread_issues || { })[:magic_my_page_necessary_actions] || { })[params[:type]]
    if (settings.nil? || settings == { })
      mmp_render_counters(nil, nil, url_for(only_path: true))
      return
    end

    settings = settings.clone( )

    begin
      query = IssueQuery.find(settings[:query_id])
    rescue ActiveRecord::RecordNotFound
      mmp_render_counters(nil, nil, url_for(only_path: true))
      return
    end
    query.group_by = ''

    data = { count: 0, affects: nil }
    result = [ ]

    today = Date.today
    days_dec = (settings[:deadline] || { })[:days_inc].to_i.days
    old = (today - days_dec)
    week = (today - days_dec + 7.days)
    month = (today.end_of_month - days_dec)
    data[:custom_link] = "<a href='#{url_for({ controller: :issues, action: :index, query_id: settings[:query_id] })}'><span>#{l('unread_issues.magic_my_page.label_' + params[:type].to_s)}</span></a>".html_safe

    counts = nil

    case params[:type]
      when 'changes_in_issues'
        counts = { }
        query.issues.each do |it|
          unless (it.user_read.nil?)
            counts[:old] = counts[:old].to_i + 1 if (it.user_read.read_date < old)
            counts[:soon] = counts[:soon].to_i + 1 if (it.user_read.read_date > old && it.user_read.read_date <= week)
            counts[:in_this_month] = counts[:in_this_month].to_i + 1 if (it.user_read.read_date > week && it.user_read.read_date <= month)
            counts[:in_next_month] = counts[:in_next_month].to_i + 1 if (it.user_read.read_date > month)
          end
        end
      when 'new_issues'
        counts = { }
        query.issues.each do |it|
          counts[:old] = counts[:old].to_i + 1 if (it.created_on < old)
          counts[:soon] = counts[:soon].to_i + 1 if (it.created_on > old && it.created_on <= week)
          counts[:in_this_month] = counts[:in_this_month].to_i + 1 if (it.created_on > week && it.created_on <= month)
          counts[:in_next_month] = counts[:in_next_month].to_i + 1 if (it.created_on > month)
        end
    end

    data[:affects] = today.strftime('%Y-%m-%d')
    data[:count] = counts.nil? ? 0 : counts[:old].to_i
    result << data.clone( )

    data[:affects] = (today + 6.day).strftime('%Y-%m-%d')
    data[:count] = counts.nil? ? 0 : counts[:soon].to_i
    result << data.clone( )

    data[:affects] = (today.end_of_month).strftime('%Y-%m-%d')
    data[:count] = counts.nil? ? 0 : counts[:in_this_month].to_i
    result << data.clone( )

    data[:affects] = (today.end_of_month + 1.day).strftime('%Y-%m-%d')
    data[:count] = counts.nil? ? 0 : counts[:in_next_month].to_i
    result << data.clone( )

    mmp_render_counters(result, settings, url_for(only_path: true))
  end

end