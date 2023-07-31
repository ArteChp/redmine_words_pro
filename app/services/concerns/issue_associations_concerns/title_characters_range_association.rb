module IssueAssociationsConcerns
  module TitleCharactersRangeAssociation
    def current_title_characters_range_value
      title_characters_range.try(:current)
    end

    def copy_title_characters_range(issue)
      TitleCharactersRange.create(
        current: issue.title_characters_range.current,
        previous: issue.title_characters_range.previous,
        range_type: issue.title_characters_range.range_type,
      )
    end

    def save_title_characters_range(range_value, type_value)
      if title_characters_range
        title_characters_range.update(
          current: range_value,
          previous: current_title_characters_range_value,
          range_type: type_value
        )
      else
        create_title_characters_range(
          current: range_value,
          range_type: type_value
        )
      end
    end
  end
end
