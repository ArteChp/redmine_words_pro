module IssueHookConcerns
  module ModelIssueHookDecisions

    extend ActiveSupport::Concern

    def role_decision_check_docs(project_id=nil, issue_id=nil)
      if project_id
        project = Project.find(project_id)
      elsif issue_id
        project = Issue.find(issue_id).project
      end

      if !Setting.plugin_redmine_keywords['form_check_docs_visible'].to_b
        # get current role
        required_roles = Setting.plugin_redmine_keywords['form_check_docs_role_ids']
        current_roles = []

        if User.current.admin?
          true
        else
          User.current.roles_for_project(project).each do |record|
            current_roles << record.id.to_s
          end
          !(required_roles & current_roles).empty?
        end
      else
        true
      end
    end

    def role_decision(project_id=nil, issue_id=nil)
      if project_id
        project = Project.find(project_id)
      elsif issue_id
        project = Issue.find(issue_id).project
      end

      if !Setting.plugin_redmine_keywords['custom_field_visible'].to_b
        # get current role
        required_roles = Setting.plugin_redmine_keywords['custom_field_role_ids']
        current_roles = []

        if User.current.admin?
          true
        else
          User.current.roles_for_project(project).each do |record|
            current_roles << record.id.to_s
          end
          !(required_roles & current_roles).empty?
        end
      else
        true
      end
    end

    def form_layout_role_decision(project_id=nil, issue_id=nil)
      if project_id
        project = Project.find(project_id)
      elsif issue_id
        project = Issue.find(issue_id).project
      end

      if User.current.admin?
        true
      else
        required_roles = Setting.plugin_redmine_keywords['form_layout_role_ids']
        current_roles = []
        User.current.roles_for_project(project).each do |record|
          current_roles << record.id.to_s
        end
        !(required_roles & current_roles).empty?
      end
    end

    def tracker_decision(current_tracker)
      # get current tracker
      required_trackers = Setting.plugin_redmine_keywords['custom_field_tracker_ids']
      !(required_trackers & current_tracker).empty?
    end

    def role_decision_template(project_id=nil, issue_id=nil)
      if project_id
        project = Project.find(project_id)
      elsif issue_id
        project = Issue.find(issue_id).project
      end

      if !Setting.plugin_redmine_keywords['form_template_visible'].to_b
        # get current role
        required_roles = Setting.plugin_redmine_keywords['form_template_role_ids']
        current_roles = []

        if User.current.admin?
          true
        else
          User.current.roles_for_project(project).each do |record|
            current_roles << record.id.to_s
          end
          !(required_roles & current_roles).empty?
        end
      else
        true
      end
    end

  end
end
