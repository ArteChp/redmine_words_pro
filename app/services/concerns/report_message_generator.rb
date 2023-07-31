module ReportMessageGenerator

  extend ActiveSupport::Concern

  include GenerateReportRow

  def generate_messages(keywords, text, location, report, keywords_counts)
    keywords.each do |keyword|
      next if keyword.nil?

      keyword = downcase_keyword(keyword)
      needed_kw_count = keywords_counts[keyword]
      if !keywords_counts[keyword] && keywords_counts['or'].any?
        needed_kw_count = keywords_counts['or'].first.try(:fetch, 1)
      end
      generate_report_row(keyword, text, location, report, needed_kw_count)
    end
  end

end
