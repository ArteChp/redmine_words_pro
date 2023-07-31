module RedmineKeywords
  module Hooks
    class ViewsIssuesHook < Redmine::Hook::ViewListener
      render_on :view_issues_show_details_bottom, partial: 'issues/keywords'
      render_on :view_issues_form_details_bottom, partial: 'issues/keywords_form'
    end
  end
end
