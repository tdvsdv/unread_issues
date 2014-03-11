## Unread issues

#### Plugin for Redmine

The plugin implements a convenient functionality of monitoring changes in issues.

In the list of issues appears colored indicators that show the current status of the issue.
If the issue is new and you have not viewed it yet, a green circle will lights before the title of the issue.
If the issue had any changes since your last view, a blue circle will lights before the title of the issue.

Plugin removes useless menu-item "Home" in main menu and renames menu-item "My page" to "My issues".
Also plugin implements the counter in the main menu next to menu-item "My issues".
The counter consists of three values:
* 1) Shows the number of issues, assigned to you.
* 2) Shows the number of new issues, assigned to the you, that you have not viewed yet.
* 3) Shows the number of issues, assigned to you, which had changes since last view.

![Interface](https://github.com/tdvsdv/unread_issues/raw/master/screenshots/interface.png "Interface")

#### Installation
To install plugin, go to the folder "plugins" in root directory of Redmine.
Clone plugin in that folder.

		git clone https://github.com/tdvsdv/unread_issues.git

Perform plugin migrations (make sure performing command in the root installation folder of «Redmine»):

		rake redmine:plugins:migrate NAME=unread_issues RAILS_ENV=production

Restart your web-server.

#### Supported Redmine, Ruby and Rails versions.

Plugin aims to support and is tested under the following Redmine implementations:
* Redmine 2.3.1
* Redmine 2.3.2
* Redmine 2.3.3

Plugin aims to support and is tested under the following Ruby implementations:
* Ruby 1.9.2
* Ruby 1.9.3
* Ruby 2.0.0

Plugin aims to support and is tested under the following Rails implementations:
* Rails 3.2.13

#### Copyright
Copyright (c) 2011-2013 Vladimir Pitin, Danil Kukhlevskiy.
[skin]: https://github.com/tdvsdv/redmine_alex_skin
For better appearance we recommend to use this plugin with Redmine skin of our team - [Redmine Alex Skin][skin].

Another plugins of our team you can see on site http://rmplus.pro
