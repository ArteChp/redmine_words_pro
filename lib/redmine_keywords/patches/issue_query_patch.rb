require_dependency 'issue'

module RedmineKeywords
  module Patches
    module IssueQueryPatch
      def self.included(base)
        base.class_eval do
          after_initialize :update_available_columns

          def update_available_columns
            available_columns << QueryColumn.new(
              :current_keyword,
              sortable: "#{Keyword.table_name}.current",
              groupable: true
            )

            available_columns << QueryColumn.new(
              :current_google_document,
              sortable: "#{GoogleDocument.table_name}.current",
              groupable: true
            )

            available_columns << QueryColumn.new(
              :current_layout,
              sortable: "#{Layout.table_name}.layout",
              groupable: true
            )

            available_columns << QueryColumn.new(
              :current_kw_range,
              sortable: "#{KwRange.table_name}.words_range",
              groupable: true
            )
          end
        end
      end
    end
  end
end

unless IssueQuery.included_modules.include?(RedmineKeywords::Patches::IssueQueryPatch)
  IssueQuery.send(:include, RedmineKeywords::Patches::IssueQueryPatch)
end
