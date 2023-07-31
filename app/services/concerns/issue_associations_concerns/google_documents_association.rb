module IssueAssociationsConcerns
  module GoogleDocumentsAssociation
    def current_google_document
      google_document.try(:current)
    end

    def copy_google_documents(issue)
      GoogleDocument.create(
        current: issue.google_document.current,
        previous: issue.google_document.previous,
      )
    end

    def save_google_documents(value)
      if google_document
        current_google_documents = google_document.current
        google_document.update(
          current: value, previous: current_google_documents
        )
      else
        create_google_document(current: value, previous: nil)
      end
    end
  end
end
