# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'issue_reads/count/:req', controller: 'issue_reads', action: 'count'
get 'issue_reads/mm_page/counters/:type', controller: 'issue_reads', action: 'mm_page_counters'