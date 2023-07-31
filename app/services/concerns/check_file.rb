module CheckFile

  extend ActiveSupport::Concern

  def check_file(issue_id, google_doc, keywords_block, kw_range, doc_type)
    issue = Issue.find(issue_id)
    kw_range_type = issue.kw_range.kw_range_type
    attachment = nil
    locations = {}
    kw_text = TemplateFieldsService.new.parse_kw_text(keywords_block, kw_range)
    kw_text.each_with_index do |val, index|
      locations[index] = val[1]['kw_loc']
    end
    if doc_type == 'google'
      return if google_doc.nil? || google_doc.empty?
      google_doc = google_doc[0].scan(/[-\w ]{15,}/)
      content = GoogleDocsAuthorize.new.parse_google_content(google_doc[0])
      unless content
        @report = 'Please open access to google doc'
        issue.journals.create!(notes: @report, private_notes: @notes, user_id: @user_id)
        return
      end
    elsif doc_type == 'attachment'
      document_attachments = issue.attachments.select { |attachment| attachment.is_document? }
      attachment = document_attachments.last.try(:id)
      google_doc = nil
    end
    keywords_hash = ParseKeywords.new.run(issue, attachment, google_doc, keywords_block, kw_range)
    words_count_report = WordsCountCommon.new(issue_id, attachment, google_doc, 'article_without_meta').get_report
    title_characters_report = WordsCountCommon.new(issue_id, attachment, google_doc, 'title').get_report
    description_characters_report = WordsCountCommon.new(issue_id, attachment, google_doc, 'description').get_report
    common_report_data(locations, keywords_block, kw_range, attachment, issue, keywords_hash, google_doc, words_count_report, title_characters_report, description_characters_report)
    issue.journals.create!(notes: @report, private_notes: @notes, user_id: @user_id)
  end

end
