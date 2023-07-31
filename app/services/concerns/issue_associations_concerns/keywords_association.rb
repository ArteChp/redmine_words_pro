module IssueAssociationsConcerns
  module KeywordsAssociation
    def current_keyword
      keyword.try(:current)
    end

    def copy_keywords(issue)
      Keyword.create(
        current: issue.keyword.current,
        previous: issue.keyword.previous,
      )
    end

    def save_keywords(value)
      if keyword
        current_keywords = keyword.current
        keyword.update(current: value, previous: current_keywords)
      else
        create_keyword(current: value, previous: nil)
      end
    end
  end
end
