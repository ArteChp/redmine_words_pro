module RedmineKeywords
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(_context = {})
        javascript_include_tag(:application, :plugin => 'redmine_keywords')
      end
    end
  end
end
