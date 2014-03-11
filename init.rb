Redmine::Plugin.register :unread_issues do
  name 'Unread Issues plugin'
  author 'Vladimir Pitin, Danil Kukhlevskiy'
  description 'This is a plugin for Redmine, that marks unread issues'
    version '0.0.1'
    url 'http://pitin.su'
    author_url 'http://pitin.su'

  delete_menu_item :top_menu, :my_page
  delete_menu_item :top_menu, :home
  menu :top_menu, :my_page, { :controller => 'my', :action => 'page' }, :caption => Proc.new { User.current.my_page_caption },  :if => Proc.new { User.current.logged? }, :first => true
end

Rails.application.config.to_prepare do
  Issue.send(:include, UnreadIssues::IssuePatch)
  User.send(:include, UnreadIssues::UserPatch)
  IssuesController.send(:include, UnreadIssues::IssuesControllerPatch)
end

require 'unread_issues/hooks_views'