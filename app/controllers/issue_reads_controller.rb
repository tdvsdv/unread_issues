class IssueReadsController < ApplicationController

  def count
    unless (Redmine::Plugin.installed?(:ajax_counters))
      render nothing: true
    end

    num_issues = 0
    case params[:req]
      when 'assigned'
        query_id = (Setting.plugin_unread_issues || { })[:assigned_issues].to_i

        unless (query_id == 0)
          begin
            query = IssueQuery.find(query_id)
            query.group_by = ''
            num_issues = query.issues.count
          rescue ActiveRecord::RecordNotFound
          end
        end
      when 'unread'
        num_issues = User.current.count_unread_issues
      when 'updated'
        num_issues = User.current.count_updated_issues
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

    case params[:type]
      when 'changes_in_issues'
        counts = { }
        query.issues.each do |it|
          unless (it.user_read.nil?)
            counts[it.user_read.read_date] ||= 0
            counts[it.user_read.read_date] += 1
          end
        end
      when 'new_issues'
        counts = { }
        query.issues.each do |it|
          counts[it.created_on] ||= 0
          counts[it.created_on] += 1
        end
    end

    if (counts.nil?)
      mmp_render_counters(nil, nil, url_for(only_path: true))
      return
    end

    mmp_prepare_data_and_render_counter({ plugin: :unread_issues, type: params[:type] }, "<a href='#{url_for({ controller: :issues, action: :index, query_id: settings[:query_id] })}'><span>#{l('unread_issues.magic_my_page.label_' + params[:type].to_s)}</span></a>".html_safe, counts)
  end

end
