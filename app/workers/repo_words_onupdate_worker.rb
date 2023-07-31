class RepoWordsOnupdateWorker
  include Sidekiq::Worker
  include CommonReportService
  include WordsRangeParser
  include CheckFile

  def perform(issue_id, attachment_size)
    issue = Issue.find(issue_id)
    keyword = issue.keyword.current
    kw_range = issue.kw_range.current
    kw_range_type = issue.kw_range.kw_range_type
    google_doc = issue.google_document.try(:current)
    @notes = Setting.plugin_redmine_keywords['successful_message_private_notes']
    @user_id = Setting.plugin_redmine_keywords['select_user'].to_i
    @google_doc_title = google_doc
    @report = ''

    kw = clear_keyword(keyword)
    words_count_range = kw_range.to_s.split(/[^0-9]+/i).map { |d| Integer(d) }
    kw_range = parse_words_range(kw_range, kw_range_type, words_count_range)

    google_doc = google_doc.scan(/[-\w ]{15,}/) unless google_doc.blank?
    check_file(issue_id, nil, kw, kw_range, 'attachment') unless attachment_size.nil? || attachment_size.zero?
    check_file(issue_id, google_doc, kw, kw_range, 'google')
  end

  def clear_keyword(keyword)
    keyword.gsub("\t", ',').gsub(/,\s*,+/, ',').gsub("\r\n", "\n").gsub('\\r\\n', "\n")
  end

end
