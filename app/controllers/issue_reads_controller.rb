class IssueReadsController < ApplicationController

  def count
    unless (Redmine::Plugin.installed?(:ajax_counters))
      render nothing: true
    end

    num_issues = 0
    query_id = (Setting.plugin_unread_issues || { })[:assigned_issues].to_i
    unless (query_id == 0)
      begin
        query = IssueQuery.find(query_id)
        query.group_by = ''
      rescue ActiveRecord::RecordNotFound
        ajax_counter_respond(num_issues)
        return
      end
    end

    case params[:req]
      when 'assigned'
        num_issues = query.issues.count
      when 'unread'
        num_issues = query.issues(include: [:user_read], conditions: "#{IssueRead.table_name}.read_date is null").count
      when 'updated'
        num_issues = query.issues(include: [:user_read], conditions: "#{IssueRead.table_name}.read_date < #{Issue.table_name}.updated_on").count
    end
    # save counter to prevent extra ajax request

    ajax_counter_respond(num_issues)
  end

  def mm_page_counters
    unless (Redmine::Plugin.installed?(:magic_my_page))
      render nothing: true
    end

    if (params[:type].blank?)
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
      query.group_by = ''
    rescue ActiveRecord::RecordNotFound
      mmp_render_counters(nil, nil, url_for(only_path: true))
      return
    end

    counts = nil

    users = [User.current.id]
    if (Redmine::Plugin.installed?(:ldap_users_sync) && settings[:use_unders])
      users += (User.current.id == 69 ? User.find(10) : User.current).subordinates(true).collect(&:id)

      if (query.filters['assigned_to_id'])
        query.filters['assigned_to_id'][:values] = query.filters['assigned_to_id'][:values] + users.collect { |it| it.to_s }
      end
    end

    case params[:type]
      when 'changes_in_issues'
        counts = { }

        query.issues.each do |it|
          unless (it.user_read.nil?)
            counts[it.user_read.read_date.to_date] ||= { }
            counts[it.user_read.read_date.to_date][it.assigned_to] ||= 0
            counts[it.user_read.read_date.to_date][it.assigned_to] += 1
          end
        end
      when 'new_issues'
        counts = { }
        query.issues.each do |it|
          counts[it.created_on.to_date] ||= { }
          counts[it.created_on.to_date][it.assigned_to] ||= 0
          counts[it.created_on.to_date][it.assigned_to] += 1
        end
    end

    if (counts.nil?)
      mmp_render_counters(nil, nil, url_for(only_path: true))
      return
    end

    mmp_prepare_data_and_render_counter({ plugin: :unread_issues, type: params[:type] }, "<a href='#{url_for({ controller: :issues, action: :index, query_id: settings[:query_id] })}'><span>#{l('unread_issues.magic_my_page.label_' + params[:type].to_s)}</span></a>".html_safe, counts)
  end

end
