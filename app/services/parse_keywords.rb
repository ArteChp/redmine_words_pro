class ParseKeywords

  def run(issue, attachment, google_doc, keywords, kw_range)
    kw_range_type = issue.kw_range.kw_range_type
    kw = keywords.gsub("/\r\n/", "\n")
    if attachment
      words_count = WordsCountCommon.new(issue.id, attachment, nil, 'article').calculate_file_words
    else
      google_doc = google_doc[0].scan(/[-\w ]{15,}/)
      words_count = WordsCountCommon.new(issue.id, nil, google_doc, 'article').calculate_file_words
    end
    keywords_for_file = {}
    kw_text = TemplateFieldsService.new.parse_kw_text(kw, words_count)
    kw_text.each_with_index do |val, index|
      keys = []
      if val[1]['kw_arr']
        val[1]['kw_arr'].each do |v|
          key = v[0] if v[1] != 0
          if v[0] == 'or'
            v[1].each do |or_key, or_value|
              keys << or_key
            end
          elsif !val[1]['kw_arr_links'][key].nil?
            word = v[0].to_s
            link = val[1]['kw_arr_links'][word]
            keys << "(#{link})#{word}"
          else
            keys << key
          end
        end
      end
      keywords_for_file[index] = keys
    end
    keywords_for_file
  end
end
