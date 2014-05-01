module UnreadIssues
  module IssueQueryPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do

        alias_method_chain :issues, :uis
        alias_method_chain :joins_for_order_statement, :uis
        alias_method_chain :available_filters, :uis
        alias_method_chain :issue_count_by_group, :uis


        base.add_available_column(QueryColumn.new(:uis_unread, sortable: Proc.new { "case when #{Issue.table_name}.assigned_to_id = #{User.current.id} and (#{IssueStatus.table_name}.is_closed = #{connection.quoted_false}) and uis_ir.id is null then 1 else 0 end" }, groupable: true, caption: :unread_issues_label_filter_unread))
        base.add_available_column(QueryColumn.new(:uis_updated, sortable: Proc.new { "case when #{Issue.table_name}.assigned_to_id = #{User.current.id} and (#{IssueStatus.table_name}.is_closed = #{connection.quoted_false}) and uis_ir.read_date < #{Issue.table_name}.updated_on then 1 else 0 end" }, groupable: true, caption: :unread_issues_label_filter_updated))
      end
    end

    module InstanceMethods
      def issues_with_uis(options={})
        options[:include] ||= [ ]
        unless (options[:include].include?(:user_read))
          options[:include] << :user_read
        end
        issues_without_uis(options)
      end

      def issue_count_by_group_with_uis
        if (group_by_statement == 'uis_unread')
          gr_b = "case when #{Issue.table_name}.assigned_to_id = #{User.current.id} and #{IssueStatus.table_name}.is_closed = #{connection.quoted_false} and uis_ir.id is null then 1 else 0 end"
          return Issue.visible.joins(:status, :project).where(statement).joins(joins_for_order_statement(gr_b)).group(gr_b).count
        elsif (group_by_statement == 'uis_updated')
          gr_b = "case when #{Issue.table_name}.assigned_to_id = #{User.current.id} and #{IssueStatus.table_name}.is_closed = #{connection.quoted_false} and uis_ir.read_date < #{Issue.table_name}.updated_on then 1 else 0 end"
          return Issue.visible.joins(:status, :project).where(statement).joins(joins_for_order_statement(gr_b)).group(gr_b).count
        end

        return issue_count_by_group_without_uis
      end

      def sql_for_uis_unread_field(field, operator, value)
        return '' if (value == [ ])
        case operator
          when '=', '!'
            "#{operator == '!' ? 'NOT ' : ''}case when (#{Issue.table_name}.assigned_to_id = #{User.current.id} and #{IssueStatus.table_name}.is_closed = #{connection.quoted_false} and NOT EXISTS(SELECT * FROM #{IssueRead.table_name} uis_ir WHERE uis_ir.issue_id = #{Issue.table_name}.id and uis_ir.user_id = #{User.current.id})) then 1 else 0 end in (#{value.join(',')})"
        end
      end

      def sql_for_uis_updated_field(field, operator, value)
        return '' if (value == [ ])
        case operator
          when '=', '!'
            "#{operator == '!' ? 'NOT ' : ''}case when (#{Issue.table_name}.assigned_to_id = #{User.current.id} and #{IssueStatus.table_name}.is_closed = #{connection.quoted_false} and EXISTS(SELECT * FROM #{IssueRead.table_name} uis_ir WHERE uis_ir.issue_id = #{Issue.table_name}.id and uis_ir.user_id = #{User.current.id} and uis_ir.read_date < #{Issue.table_name}.updated_on))  then 1 else 0 end in (#{value.join(',')})"
        end
      end

      def available_filters_with_uis
        @available_filters = available_filters_without_uis( )

        # i can use custom fields (possible_values_options for bool), but i dont want ^^
        @available_filters['uis_unread'] = { type: :list, order: 7, values: [[l(:general_text_Yes), '1'], [l(:general_text_No), '0']], name: l(:unread_issues_label_filter_unread) }
        @available_filters['uis_updated'] = { type: :list, order: 8, values: [[l(:general_text_Yes), '1'], [l(:general_text_No), '0']], name: l(:unread_issues_label_filter_updated) }

        return @available_filters
      end

      def joins_for_order_statement_with_uis(order_options)
        joins = joins_for_order_statement_without_uis(order_options)
        joins ||= ''

        joins << " LEFT JOIN #{IssueRead.table_name} uis_ir ON uis_ir.issue_id = #{Issue.table_name}.id and uis_ir.user_id = #{User.current.id}"
        return joins
      end

      def uis_issues_scope
        order_option = [group_by_sort_order, options[:order]].flatten.reject(&:blank?)

        return Issue.visible.
                     joins(:status, :project, :user_read).
                     where(statement).
                     joins(joins_for_order_statement(order_option.join(',')))
      end
    end
  end
end
