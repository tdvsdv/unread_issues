module UnreadIssues
  module UnreadIssues
    class Hooks < Redmine::Hook::ViewListener
      render_on :view_layouts_base_html_head, :partial => 'hooks/unread_isues/add_css', :layout => false
    end
  end
end