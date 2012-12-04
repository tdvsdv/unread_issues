$(document).ready(function(){
  if( $('#my_page_issues_count').length > 0 ) {
    setTimeout(fetch_issues_stats,$("#unread_issues_frequency").html())
  }
});

function fetch_issues_stats(){
  $("#my_page_issues_count").load('/counts/user/issues/')
  setTimeout(fetch_issues_stats,$("#unread_issues_frequency").html()*1000);
}
