module FormVisibleConcerns
  module GoogleDocuments
    def edit_google_documents_check_tracker
      Setting.plugin_redmine_keywords['form_google_documents_tracker_ids'].include? self.try(:tracker_id).to_s
    end

    def edit_google_documents_visible
      User.current.admin? || edit_google_documents_any_role? || edit_google_documents_role_available
    end

    def edit_google_documents_role_available
      User.current.roles.any? && edit_google_documents_common_roles.any? && edit_google_documents_roles_selected?
    end

    def edit_google_documents_common_roles
      User.current.roles_for_project(self.try(:project)).map(&:id).to_a.map(&:to_s) & Setting.plugin_redmine_keywords['form_google_documents_role_ids'].to_a.map(&:to_s)
    end

    def edit_google_documents_any_role?
      Setting.plugin_redmine_keywords['form_google_documents_visible'] == '1'
    end

    def edit_google_documents_roles_selected?
      Setting.plugin_redmine_keywords['form_google_documents_visible'] == '0'
    end
  end
end
