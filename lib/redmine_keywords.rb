require 'redmine_keywords/hooks/model_issue_hook'
require 'redmine_keywords/hooks/views_issues_hook'
require 'redmine_keywords/patches/issue_patch'
require 'redmine_keywords/patches/issue_query_patch'
require 'redmine_keywords/patches/attachment_patch'
require 'redmine_keywords/hooks/views_layouts_hook'

if Redmine::Plugin.installed?(:redmine_agile) &&
   Gem::Version.new(Redmine::Plugin.find(:redmine_agile).version) >= Gem::Version.new('1.4.3') && AGILE_VERSION_TYPE == 'PRO version'
end

module RedmineKeywords
  def self.settings
    Setting[:plugin_redmine_keywords].stringify_keys
  end
end
