document.observe('dom:loaded', function(){	
	if(! Object.isUndefined($('my_page_issues_count')))
		{
		new Ajax.PeriodicalUpdater('my_page_issues_count',
								   '/counts/user/issues/',
								    {method: 'get',
								     frequency: $('unread_issues_frequency').innerHTML,
								     decay: $('unread_issues_decay').innerHTML,
								     asynchronous:true,
								     evalScripts:true,
								 	 onCreate: function(){$('ajax-indicator').style.opacity=0},
								 	 onComplete: function(){$('ajax-indicator').style.opacity=0.5}
								 	});
		}
	});
