class WordsCountCommon

  include WordsCountConcerns::CfLayoutVal
  include WordsCountConcerns::WordsDelta
  include WordsCountConcerns::WordsCountHelpers
  include WordsCountConcerns::WordsCountRow
  include GenerateDocument
  include WordsRangeParser
  include FlattenHash
  include Numberic

  attr_accessor :issue, :kw_range, :kw_range_type, :attachment, :google_doc, :location

  def initialize(issue_id, attachment, google_doc, location)
    @issue = Issue.find(issue_id)
    @attachment = attachment
    @google_doc = google_doc
    @location = location
    initialize_range
  end

  def get_report
    @fl_hsh = flatten_hash(issue.attributes)
    cf_layout_val = get_cf_layout_val(kw_range_type, kw_range)
    parse_words_range_from_layout(cf_layout_val)
    words_range = @words ? @words[0]..@words[1] : nil..nil
    return if @words.empty? || words_range.cover?(nil)

    check_text
  end

  def calculate_file_words
    text = if attachment
      attached_text(issue, attachment, kw_range, kw_range_type).to_s
    else
      google_text(issue, google_doc, kw_range_type, kw_range).to_s
    end
    text = clear_text(text, location)
    count = get_count(issue, nil, text)
  end

  def initialize_range
    if location == 'article_without_meta'
      @kw_range = issue.kw_range.try(:current)
      @kw_range_type = issue.kw_range.try(:range_type)
    elsif location == 'title'
      @kw_range = issue.title_characters_range.try(:current)
      @kw_range_type = issue.title_characters_range.try(:range_type)
    elsif location == 'description'
      @kw_range = issue.description_characters_range.try(:current)
      @kw_range_type = issue.description_characters_range.try(:range_type)
    end
  end

end
