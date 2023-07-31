module FormVisibleConcerns
  module DescriptionCharactersRangeType

    def edit_description_characters_range_type_check_tracker
      Setting.plugin_redmine_keywords['show_description_characters_range_type_tracker_ids'].include? self.try(:tracker_id).to_s
    end

    def edit_description_characters_range_type_visible
      User.current.admin? || edit_description_characters_range_type_any_role? || edit_description_characters_range_type_role_available
    end

    def edit_description_characters_range_type_role_available
      User.current.roles.any? && edit_description_characters_range_type_common_roles.any? && edit_description_characters_range_type_roles_selected?
    end

    def edit_description_characters_range_type_common_roles
      User.current.roles_for_project(self.try(:project)).map(&:id).to_a.map(&:to_s) & Setting.plugin_redmine_keywords['show_description_characters_range_type_role_ids'].to_a.map(&:to_s)
    end

    def edit_description_characters_range_type_any_role?
      Setting.plugin_redmine_keywords['show_description_characters_range_type_visible'] == '1'
    end

    def edit_description_characters_range_type_roles_selected?
      Setting.plugin_redmine_keywords['show_description_characters_range_type_visible'] == '0'
    end

  end
end
