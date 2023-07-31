# module for search specific words in any headers of google document

module CheckKeywordsConcerns
  module CheckLocation

    extend ActiveSupport::Concern

    include ParseAttachmentLocations
    include ParseGoogleLocations
    include ReportMessageGenerator
    include GenerateNegativeReportMessage

    def check_location(params = {})
      keywords = params[:keywords]
      words = params[:words]
      paragraph = params[:paragraph]
      headers_type = params[:headers_type]
      headers_number = params[:headers_number]
      keywords_counts = params[:keywords_counts]
      location = params[:location]
      google_doc = params[:google_doc]
      doc_type = params[:doc_type]
      report = ''
      location_name = I18n.t(
        location.to_sym,
        headers_number: headers_number,
        headers_type: headers_type,
        paragraph_number: paragraph,
        words: words
      )
      if doc_type == 'google'
        google_doc = google_doc[0].scan(/[-\w ]{15,}/)
        unless google_doc.empty?
          content = GoogleDocsAuthorize.new.parse_google_content(google_doc[0])
          text = google_location_text(content: content, location: location)
        end
      else
        text = attachment_location_text(
          location: location,
          text_with_location: @text_with_location,
          doc_text_array: @doc_text_array,
        )
        keywords = keywords.compact
      end
      if text.blank?
        keywords.each do |keyword|
          message = generate_negative_report_message(location_name, keyword)
          report << message
        end
      else
        generate_messages(keywords, text, location_name, report, keywords_counts)
      end
      report = delete_duplicate(report)
    end

  end
end
