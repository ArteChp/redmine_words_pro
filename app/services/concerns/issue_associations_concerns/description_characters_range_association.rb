module IssueAssociationsConcerns
  module DescriptionCharactersRangeAssociation
    def current_description_characters_range_value
      description_characters_range.try(:current)
    end

    def copy_description_characters_range(issue)
      DescriptionCharactersRange.create(
        current: issue.description_characters_range.current,
        previous: issue.description_characters_range.previous,
        range_type: issue.description_characters_range.range_type,
      )
    end

    def save_description_characters_range(range_value, type_value)
      if description_characters_range
        description_characters_range.update(
          current: range_value,
          previous: current_description_characters_range_value,
          range_type: type_value
        )
      else
        create_description_characters_range(
          current: range_value,
          range_type: type_value
        )
      end
    end
  end
end
