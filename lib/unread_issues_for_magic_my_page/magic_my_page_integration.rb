module UnreadIssuesForMagicMyPage
  module MagicMyPageIntegration
    def self.necessary_actions_list( )
      resData = [ ]
      resData << { name: I18n.t('unread_issues.magic_my_page.label_changes_in_issues'), url: { controller: 'issue_reads', action: 'mm_page_counters', type: 'changes_in_issues' } }
      resData << { name: I18n.t('unread_issues.magic_my_page.label_new_issues'), url: { controller: 'issue_reads', action: 'mm_page_counters', type: 'new_issues' } }
      return resData == [ ] ? nil : resData
    end
  end
end