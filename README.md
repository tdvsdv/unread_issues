## Unread issues

#### Plugin for Redmine

Плагин реализует удобную функциональность контроля за изменениями в заданиях.

В списке заданий появляются цветные индикаторы, которые показывают текущее состояние задания.
Если задание новое и вы еще еге не просматривали, то рядом с названием задания появляется зеленый кружок.
Если в задании были какие-то изменения с вашего последнего просмотра, то рядом с названием задания появляется синий кружок.

Также плагин реализует счетчик в главном меню рядом с пунктом "Мои задания".
Счетчик состоит из 3 значений:
* 1) Показывает количество заданий, назначенных на вас. 
* 2) Показывает количество новых заданий, назначенных на ваc, которые вы еще не просматривали.
* 3) Показывает количество заданий, назначенных на вас, в которых были изменения с вашего последнего просмотра задания.

![Interface](https://github.com/tdvsdv/unread_issues/raw/master/screenshots/interface.png "Interface")

#### Installation
Для установки необходимо перейти в папку "plugins" каталога в который установлен Redmine.
Склонировать плагин в данную папку.

		git clone https://github.com/tdvsdv/unread_issues.git

Выполнить миграции плагина (убедитесь, что выполняя команду, находитесь в корневой директории установки «Redmine»):

		rake redmine:plugins:migrate NAME=unread_issues

Перезапустить веб-сервер Redmine.

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
Copyright (c) 2011-2013 Vladimir Pitin.
