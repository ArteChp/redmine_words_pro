module GenerateCommonReport

  extend ActiveSupport::Concern

  def generate_common_report(issue, words_count_report, keyword_report, title_characters_report, description_characters_report, title)
    keyword_report = "\n#{keyword_report}" if title.include?('http')
    keyword_report.gsub!("\n\n", "\n")
    title_characters_report = "\n#{title_characters_report}" unless title_characters_report.blank?
    description_characters_report = "\n#{description_characters_report}" unless description_characters_report.blank?
    keyword_report = "\n#{keyword_report}" unless keyword_report.start_with?("\n")
    report = %{
      *REPORT ##{get_report_numer(issue)}* #{title}\r\n\r\n
      {{collapse(REPORT)
        |\\5={background-color: #3C78D8;}.%{color:white}VOLUME REPORT%|
        |={background-color: #6D9EEB;}. %{color:white}Volume type% |={background-color: #6D9EEB;}. %{color:white}Unit type% |={background-color: #6D9EEB;}. %{color:white}Status% |={background-color: #6D9EEB;}. %{color:white}Quantity\n (current / required)% |={background-color: #6D9EEB;}. %{color:white}To Do% |
        #{words_count_report}#{title_characters_report}#{description_characters_report}
        |\\5={background-color: #3C78D8;}. %{color:white}KEYWORD REPORT% |
        |={background-color: #6D9EEB;}. %{color:white}Location% |={background-color: #6D9EEB;}. %{color:white}Keyword% |={background-color: #6D9EEB;}. %{color:white}Status% |={background-color: #6D9EEB;}. %{color:white}Quantity\n (current / required)% |={background-color: #6D9EEB;}. %{color:white}To Do% |#{keyword_report}}}
    }
    return report
  end

  def get_report_numer(issue)
    report_journals = Issue.find_by(id: issue.id).journals.where('notes LIKE ?', "%REPORT%")
    last_report_journal = report_journals.nil? ? nil : report_journals.last
    begin
      number_captures = last_report_journal.notes.match(/\#(.*)/i).captures
      report_numer = if number_captures.any?
        number_captures.first.split('*').first.to_i
      else
        0
      end
    rescue
      report_numer = 0
    end
    report_numer += 1
  end

end
