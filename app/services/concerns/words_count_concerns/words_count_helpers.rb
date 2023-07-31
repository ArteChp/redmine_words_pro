module WordsCountConcerns
  module WordsCountHelpers

    extend ActiveSupport::Concern

    def get_desc_text(settings, text)
      desc_regexp = settings['description_regexp']
      text.match(desc_regexp.to_s).try(:captures).to_a[0].to_s
    end

    def get_title_text(settings, text)
      title_regexp = settings['title_regexp']
      text.match(title_regexp.to_s).try(:captures).to_a[0].to_s
    end

    def get_words_range(kw_range)
      range = kw_range.split(/[^0-9]+/i).map { |d| Integer(d) }
      words_range_begin = range[0].to_i
      words_range_end = range[1].nil? ? words_range_begin : range[1].to_i
      words_range_begin..words_range_end
    end

    def attached_text(issue, attachment, kw_range_type, kw_range)
      generate_document(attachment)
      @doc_text
    end

    def google_text(issue, google_doc, kw_range_type, kw_range)
      google_doc = google_doc[0].scan(/[-\w ]{15,}/)
      content = GoogleDocsAuthorize.new.parse_google_content(google_doc[0])
      GoogleDocsAuthorize.new.read_strucutural_elements(content)
    end

    def clear_text(text, location)
      settings = Setting.plugin_redmine_keywords
      if location == 'title'
        get_title_text(settings, text).strip
      elsif location == 'description'
        get_desc_text(settings, text).strip
      elsif location == 'article_without_meta'
        title_text = get_title_text(settings, text)
        text.gsub!(title_text, '')
        desc_text = get_desc_text(settings, text)
        text.gsub!(desc_text, '')
        text = text.gsub("\n", ' ').squeeze(' ')
        text.split(/[\s!@$#%^&*()\-–=_+\[\]:;,.\/<>?\\|]/).reject { |c| c.empty? }
      elsif location == 'article'
        text = text.gsub("\n", ' ').squeeze(' ')
        text.split(/[\s!@$#%^&*()\-–=_+\[\]:;,.\/<>?\\|]/).reject { |c| c.empty? }
      end
    end

    def get_count(issue, kw_range_type, text)
      if kw_range_type === 'Including Spaces'
        text = text.join(' ') if text.kind_of?(Array)
        text.gsub!(/\s+/, '').try(:size).to_i
      elsif kw_range_type == 'Symbols'
        calculate_symbols(issue, text)
      else
        text.try(:size).to_i
      end
    end

    def calculate_symbols(issue, text)
      text.join(' ').gsub(/\s+/, '').try(:size).to_i
    end

    def words_count_row(issue, text, kw_range, kw_range_type)
      text = clear_text(text, location)
      words_range = get_words_range(kw_range)
      count = get_count(issue, kw_range_type, text)
      delta = calculate_delta(count, words_range)
      expand_flatten_hash(count, kw_range, kw_range_type, delta, location)
      get_words_count_row(count, words_range)
    end

    def check_text
      text = if attachment
        attached_text(issue, attachment, kw_range, kw_range_type).to_s
      else
        google_text(issue, google_doc, kw_range_type, kw_range).to_s
      end
      words_count_row(issue, text, kw_range, kw_range_type)
    end

    def expand_flatten_hash(count, kw_range, kw_range_type, delta, location)
      location = 'Article (without meta)' if location == 'article_without_meta'
      @fl_hsh['negative_words_count_message'] = "add a #{location}"
      @fl_hsh['count_metric'] = count
      @fl_hsh['target_count_metric'] = kw_range
      @fl_hsh['tpl_count_metric'] = "#{delta.abs} #{kw_range_type.to_s.downcase}"
      @fl_hsh['report_type'] = "#{location.capitalize}"
      @fl_hsh['kw_count_unit_type'] = "#{kw_range_type.to_s.downcase}"
      @fl_hsh['kw_count_status'] = "#{location} missed" if count === 0
    end

  end
end
