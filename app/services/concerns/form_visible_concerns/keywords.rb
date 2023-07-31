module FormVisibleConcerns
  module Keywords
    def edit_keywords_check_tracker
      Setting.plugin_redmine_keywords['form_keywords_tracker_ids'].include? self.try(:tracker_id).to_s
    end

    def edit_keywords_visible
      User.current.admin? || edit_keywords_any_role? || edit_keywords_role_available
    end

    def edit_keywords_role_available
      User.current.roles.any? && edit_keywords_common_roles.any? && edit_keywords_roles_selected?
    end

    def edit_keywords_common_roles
      User.current.roles_for_project(self.try(:project)).map(&:id).to_a.map(&:to_s) & Setting.plugin_redmine_keywords['form_keywords_role_ids'].to_a.map(&:to_s)
    end

    def edit_keywords_any_role?
      Setting.plugin_redmine_keywords['form_keywords_visible'] == '1'
    end

    def edit_keywords_roles_selected?
      Setting.plugin_redmine_keywords['form_keywords_visible'] == '0'
    end
  end
end
