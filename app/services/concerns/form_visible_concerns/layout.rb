module FormVisibleConcerns
  module Layout
    def edit_layout_check_tracker
      Setting.plugin_redmine_keywords['form_layout_tracker_ids'].include? self.try(:tracker_id).to_s
    end

    def edit_layout_visible
      User.current.admin? || edit_layout_any_role? || edit_layout_role_available
    end

    def edit_layout_role_available
      User.current.roles.any? && edit_layout_common_roles.any? && edit_layout_roles_selected?
    end

    def edit_layout_common_roles
      User.current.roles_for_project(self.try(:project)).map(&:id).to_a.map(&:to_s) & Setting.plugin_redmine_keywords['form_layout_role_ids'].to_a.map(&:to_s)
    end

    def edit_layout_any_role?
      Setting.plugin_redmine_keywords['form_layout_visible'] == '1'
    end

    def edit_layout_roles_selected?
      Setting.plugin_redmine_keywords['form_layout_visible'] == '0'
    end
  end
end
