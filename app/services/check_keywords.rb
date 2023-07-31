class CheckKeywords

  include CheckKeywordsConcerns::CheckLocation
  include CheckKeywordsConcerns::CheckRelatedKeyword
  include GenerateDocument
  include FlattenHash

  HEADER_TAGS = [
    '<h1>', '</ h1>', '<h2>', '</ h2>', '</h2>', '<h3>', '</ h3>', '</h3>',
    '<h4>', '</ h4>', '</h4>', '<h5>', '</ h5>', '</h5>', '<h6>', '</ h6>',
    '</h6>'
  ]

  attr_accessor :status, :to_do, :keyword, :successful_check, :found_count

  def initialize(locations, issue_attributes)
    @locations = locations
    @fl_hsh = flatten_hash(issue_attributes)
  end

  def run(issue, attachment_id, google_doc, keywords, keywords_counts)
    keywords_counts.transform_keys! { |key| key.to_s.downcase }
    report = if attachment_id
      check_attached_file(attachment_id, issue, keywords, keywords_counts)
    else
      check_google_doc(issue, keywords, keywords_counts, google_doc)
    end
    report
  end

  def check_attached_file(attachment_id, issue, keywords, keywords_counts)
    generate_document(attachment_id)
    message = ''
    @locations.each do |location|
      message = check_location(
        keywords: keywords,
        keywords_counts: keywords_counts,
        location: location,
        doc_type: 'attachment'
      )
    end
    message
  end

  def check_google_doc(issue, keywords, keywords_counts, google_doc)
    message = ''
    @locations.each do |location|
      message = check_location(
        keywords: keywords,
        keywords_counts: keywords_counts,
        location: location,
        google_doc: google_doc,
        doc_type: 'google'
      )
    end
    message
  end

  def delete_duplicate(message)
    message.split("\n").uniq.join("\n") + "\n"
  end

  def downcase_keyword(keyword)
    @keyword = if keyword.is_a?(Array)
      keyword[0].map(&:downcase)
    else
      keyword.downcase
    end
  end

  def search_kw(text, keyword, needed_kw_count, hash, doc_type=nil, location)
    needed_kw_count = 1 if needed_kw_count == 'at least 1' || needed_kw_count.nil?

    if text.is_a?(Array)
      search_kw_in_array(text, keyword, hash, location)
    elsif keyword.is_a?(Array)
      search_kw_with_alternative(text, keyword, needed_kw_count, hash, location)
    elsif keyword.include? 'http'
      search_kw_with_link(text, keyword, hash, doc_type, location)
    else
      search_plain_kw(text, keyword, needed_kw_count, hash, location)
    end
  end

  def search_plain_kw(text, keyword, needed_kw_count, hash, location)
    HEADER_TAGS.each { |h| text.to_s.gsub!(h, ' ') }
    begin
      contain_keyword = text.to_s.scan(%r{#{keyword.gsub("'", '’')}(\s|\.|\?|"|,|'|!|:|;|\/|\\|\[|\]|{|}|\+|@|`|\$|>|<|&|%|\*|#|~|№|\^|=|\(|\))}).any? || text.to_s.end_with?(keyword)
    rescue RegexpError
      contain_keyword = false
    end
    simple_search_results(text, keyword, needed_kw_count, hash, location)
  end

  def search_kw_with_link(text, keyword, hash, doc_type=nil, location)
    @found_count = text.to_s.scan(keyword).count
    @successful_check = found_count.to_i >= 1
    link_search_results(keyword, hash, location)
  end

  def search_kw_with_alternative(text, keyword, needed_kw_count, hash, location)
    found_count = 0
    keyword.each do |k|
      k_regexp = Regexp.new k
      found_count += text.to_s.scan(k_regexp).count
    end
    @successful_check = found_count.to_i >= needed_kw_count
    array_search_results(keyword, hash, location, needed_kw_count)
    @keyword = keyword.join(' OR ')
  end

  def search_kw_in_array(text, keyword, hash, location)
    needed_kw_count = 1
    contain_keyword = false
    text.each do |t|
      HEADER_TAGS.each { |h| t.to_s.gsub!(h, ' ') }
      begin
        contain_keyword = t.to_s.scan(%r{#{keyword.gsub("'", '’')}(\s|\.|\?|"|,|'|!|:|;|\/|\\|\[|\]|{|}|\+|@|`|\$|>|<|&|%|\*|#|~|№|\^|=|\(|\))}).any? || text.to_s.end_with?(keyword)
      rescue RegexpError
        contain_keyword = false
      end
      break unless contain_keyword
    end
    @found_count = contain_keyword ? 1 : 0
    @successful_check = found_count.to_i >= needed_kw_count.to_i
    @status = get_status(found_count, needed_kw_count, location)
    @to_do = get_to_do(found_count, keyword, hash, needed_kw_count)
  end

  def simple_search_results(text, keyword, needed_kw_count, hash, location)
    begin
      @found_count = text.to_s.scan(%r{#{keyword.gsub("'", '’')}(\s|\.|\?|"|,|'|!|:|;|\/|\\|\[|\]|{|}|\+|@|`|\$|>|<|&|%|\*|#|~|№|\^|=|\(|\))}).count
    rescue RegexpError
      @found_count = 0
    end
    @found_count += 1 if text.to_s.end_with?(keyword)
    @successful_check = found_count.to_i >= needed_kw_count.to_i
    @status = get_status(found_count, needed_kw_count, location)
    @to_do = get_to_do(found_count, keyword, hash, needed_kw_count)
  end

  def link_search_results(keyword, hash, location)
    needed_kw_count = 1
    @status = get_status(found_count, needed_kw_count, location)
    @to_do = get_to_do(found_count, keyword, hash, needed_kw_count)
  end

  def array_search_results(keyword, hash, location, needed_kw_count)
    @status = get_status(found_count, needed_kw_count, location)
    @to_do = get_to_do(found_count, keyword, hash, needed_kw_count)
  end

  def get_to_do(found_keywords_count, keyword, hash, needed_keyword_count)
    setting = Setting.plugin_redmine_keywords
    needed_keyword_count = 1 if needed_keyword_count == 'at least 1'
    assignment_kw_count = needed_keyword_count.to_i
    delta = found_keywords_count - assignment_kw_count
    hash['article_kw_count'] = needed_keyword_count.to_s
    hash['assignment_kw_count'] = assignment_kw_count.to_s
    hash['delta_kw_count'] = delta.abs.to_s
    hash['current_kw_name'] = keyword.to_s
    template_fields = TemplateFieldsService.new
    if needed_keyword_count == 'at least 1'
      message = if delta.positive?
        template_fields.replace_template(hash, setting['successful_keyword_verification_message'])
      else
        template_fields.replace_template(hash, setting['min_unsuccessful_keyword_verification_message'])
      end
    else
      message = if delta.positive?
        template_fields.replace_template(hash, setting['max_unsuccessful_keyword_verification_message'])
      elsif delta.negative?
        template_fields.replace_template(hash, setting['min_unsuccessful_keyword_verification_message'])
      else
        template_fields.replace_template(hash, setting['successful_keyword_verification_message'])
      end
    end
    message
  end

  def get_status(found_keywords_count, needed_keyword_count, location)
    needed_keyword_count = 1 if needed_keyword_count == 'at least 1'
    assignment_kw_count = needed_keyword_count.to_i
    delta = found_keywords_count - assignment_kw_count
    message = if delta.negative? && (location.to_s === 'Every heading' || location.to_s === 'every_h')
      'not all headers contain the given keys '
    end
    message.to_s
  end

end
