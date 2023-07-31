module GenerateReportRow

  extend ActiveSupport::Concern

  def generate_report_row(keyword, text, location, report, needed_kw_count)
    search_kw(text, keyword, needed_kw_count, @fl_hsh, 'attachment', location)
    unless keyword.split.select { |str| str.length == 1 }.any? || text.kind_of?(Array)
      formated_text = text.gsub(/[^0-9a-z ]/i, ' ')
      check_related_keyword(status, to_do, keyword, formated_text)
    end
    if keyword.is_a? Array
      alternative = keyword[1..(keyword.length)].split(',')
      keyword = "#{keyword[0]} (#{alternative})"
    end
    needed_kw_count = 1 if needed_kw_count == 'at least 1' || needed_kw_count.nil?
    quantity = if successful_check
      "#{found_count} / #{needed_kw_count}"
    else
      "%{color:red}#{found_count}% / #{needed_kw_count}"
    end
    @to_do = to_do.gsub("\r\n", '').gsub("\n", '')
    message = "| #{location} | #{keyword} | #{status} | #{quantity} | #{to_do} | \r\n"
    delete_duplicate_before_add(message, report, location, keyword)
  end

  def delete_duplicate_before_add(message, report, location, keyword)
    unless report.include?("| #{location} | #{keyword} |")
      report << "\n#{message}\n" unless report.include? message
    end
  end

end
