module CommonReportService

  extend ActiveSupport::Concern

  include GenerateCommonReport

  def common_report_data(locations, keywords_block, kw_range, attachment, issue, keywords_hash, google_doc, words_count_report, title_characters_report, description_characters_report)
    keyword_report = ''
    locations.each_with_index do |location, index|
      next if location[1].nil?

      @keywords = {}
      location_array = location[1].split(',')
      kw_text = TemplateFieldsService.new.parse_kw_text(keywords_block, kw_range)
      keywords_counts = kw_text[index]['kw_arr']
      keyword_report << CheckKeywords.new(location_array, issue.attributes).run(issue, attachment, google_doc, keywords_hash[index], keywords_counts)
      keyword_report.gsub! "\n\n", "\n" if keyword_report.include?("\n\n")

      if google_doc
        title = @google_doc_title
        content = GoogleDocsAuthorize.new.parse_google_content(google_doc[0])
        @report = generate_common_report(issue, words_count_report, keyword_report, title_characters_report, description_characters_report, title)
      elsif attachment
        title = Attachment.find(attachment).filename
        @report = generate_common_report(issue, words_count_report, keyword_report, title_characters_report, description_characters_report, title)
      end
    end
  end

end
