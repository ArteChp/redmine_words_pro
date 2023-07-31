module RedmineKeywords
  module Hooks
    class ModelIssueHook < Redmine::Hook::ViewListener

      include IssueHookConcerns::KwTable
      include IssueHookConcerns::ModelIssueHookDecisions
      include IssueHookConcerns::ModelIssueHookHelpers
      include FlattenHash

      def initialize
        @template_fields = TemplateFieldsService.new
        @empty_values_array = ["\r\n", '', "\n", ' ', nil]
      end

      def controller_issues_new_before_save(context={})
        current_tracker = [] << context[:issue][:tracker_id].to_s
        if tracker_decision(current_tracker) && role_decision_template(context[:params][:project_id], nil)
          save_callback(context)
        end
      end

      def controller_issues_after_click(context={})
        current_tracker = [] << context[:issue][:tracker_id].to_s
        if tracker_decision(current_tracker) && role_decision_check_docs(nil, context[:issue].id)
          if VerificationNeed.new({issue_id: context[:issue].id}).after_click
            RepoWordsOnclickWorker.perform_async(context[:issue].id)
          end
        end
      end

      def controller_issues_new_after_save(context={})
        current_tracker = [] << context[:issue][:tracker_id].to_s
        if tracker_decision(current_tracker) && role_decision_check_docs(context[:params][:project_id], nil)
          if VerificationNeed.new({issue_id: context[:issue].id}).after_click
            RepoWordsOnsaveWorker.perform_async(context[:issue].id, context[:params][:issue])
          end
        end
      end

      def controller_issues_edit_before_save(context={})
        begin
          current_tracker = [] << context[:issue][:tracker_id].to_s
          if tracker_decision(current_tracker) && role_decision_template(nil, context[:issue].id)
            save_callback(context)
          end
        rescue
        end
        @current_attachment_ids =  Issue.find(context[:params][:id]).try(:attachment_ids)
      end

      def controller_issues_edit_after_save(context={})
        current_tracker = [] << context[:issue][:tracker_id].to_s
        if tracker_decision(current_tracker) && role_decision_check_docs(nil, context[:issue].id)
          issue = Issue.find_by(id: context[:issue].id)
          attachments = issue.attachments.select { |attachment| attachment.is_document? }
          verification_need = VerificationNeed.new({
            attachments: attachments,
            issue_id: context[:issue].id,
            current_attachment_ids: @current_attachment_ids
          }).edit_after_save
          return unless verification_need

          RepoWordsOnupdateWorker.perform_async(context[:issue].id, attachments.try(:count))
        end
      end

      private

      def calc_words(words_count=nil, symbols_count=nil, word_length = 4.7)
        if words_count.nil? && !symbols_count.nil?
          symbols_arr = symbols_count.split(/[^0-9]+/i)
          symbols_count = symbols_arr.inject { |sum, el| sum.to_i + el.to_i } / symbols_arr.size
          words_count = symbols_count / word_length
        elsif words_count.nil? && symbols_count.nil?
          words_count = 1000
        else
          words_count_range = words_count.to_s.split(/[^0-9]+/i).map { |d| Integer(d) }
          if words_count_range[0].to_i == words_count_range[1].to_i
            infelicity = Setting.plugin_redmine_keywords['infelicity'].to_i
            min = words_count_range[0].to_i
            max = words_count_range[0].to_i + infelicity
            words_count = min..max
          else
            words_count = words_count_range[0].to_i..words_count_range[1].to_i
          end
        end
        words_count
      end

    end
  end
end
