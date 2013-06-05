Redmine::Plugin.register :unread_issues do
 	name 'Unread Issues plugin'
 	author 'Pitin Vladimir Vladimirovich'
 	description 'This is a plugin for Redmine, that marks unread issues'
  	version '0.0.1'
  	url 'http://pitin.su'
  	author_url 'http://pitin.su'

	settings 	:partial => 'settings/unread_issues_settings',
            	:default => {
              	"frequency" => 600, 
			  	      "decay" => 2
           		}  

  delete_menu_item :top_menu, :home
	menu :top_menu, :my_page, { :controller => 'my', :action => 'page' }, :caption => Proc.new { User.current.my_page_caption },  :if => Proc.new { User.current.logged? }, :first => true
end

Rails.application.config.to_prepare do
  Issue.send(:include, UnreadIssues::IssuePatch)
  User.send(:include, UnreadIssues::UserPatch)
  #UsersController.send(:include, UnreadIssues::UsersControllerPatch)
  IssuesController.send(:include, UnreadIssues::IssuesControllerPatch)
end

require 'unread_issues/hooks_views'