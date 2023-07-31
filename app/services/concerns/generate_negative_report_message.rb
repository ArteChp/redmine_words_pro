module GenerateNegativeReportMessage

  extend ActiveSupport::Concern

  def generate_negative_report_message(location, keyword)
    status = "%{color:red}#{location} missed%"
    to_do = "%{color:red}add #{location}%"
    negative_message = "| #{location} | #{keyword} | #{status} | | #{to_do} | \n"
    return negative_message
  end

end
