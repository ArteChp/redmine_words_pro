module IssueAssociationsConcerns
  module LayoutsAssociation
    def current_layout
      layout.try(:layout)
    end

    def copy_layouts(issue)
      Layout.create(layout: issue.layout.layout)
    end

    def save_layouts(value)
      if layout
        layout.update(layout: value)
      else
        create_layout(layout: value)
      end
    end
  end
end
