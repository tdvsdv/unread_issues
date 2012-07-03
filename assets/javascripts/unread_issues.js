document.observe('dom:loaded', function(){	
	if(! Object.isUndefined($('my_page_issues_count')))
		{
		new Ajax.PeriodicalUpdater('my_page_issues_count', '/counts/user/issues/', {method: 'get', frequency: $('unread_issues_frequency').innerHTML, decay: $('unread_issues_decay').innerHTML, asynchronous:true, evalScripts:true});
		}
	});
