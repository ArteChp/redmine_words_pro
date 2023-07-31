module IssueAssociationsConcerns
  module KWRangesAssociation
    def current_kw_range
      kw_range.try(:current)
    end

    def copy_kw_ranges(issue)
      KwRange.create(
        current: issue.kw_range.current,
        previous: issue.kw_range.previous,
        kw_range_type: issue.kw_range.kw_range_type,
      )
    end

    def save_kw_ranges(range_value, type_value)
      if kw_range
        kw_range.update(
          current: range_value,
          previous: current_kw_range,
          kw_range_type: type_value
        )
      else
        create_kw_range(
          current: range_value,
          kw_range_type: type_value
        )
      end
    end
  end
end
