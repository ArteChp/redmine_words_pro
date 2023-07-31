module WordsRangeParser

  extend ActiveSupport::Concern

  include Numberic

  def parse_words_range_from_layout(cf_layout_val)
    @words = if numberic? cf_layout_val.to_s
      infelicity = Setting.plugin_redmine_keywords['infelicity'].to_i
      min = cf_layout_val.to_i - infelicity.to_i
      max = cf_layout_val.to_i + infelicity.to_i
      [min, max]
    elsif cf_layout_val
      cf_layout_val.split(/[^0-9]+/i).map { |d| Integer(d) }
    else
      [nil, nil]
    end
  end

  def parse_words_range(kw_range, kw_range_type, words_count_range)
    if kw_range_type == 'Words'
      min = words_count_range[0].to_i
      max = words_count_range[1].nil? ? min : words_count_range[1].to_i
    elsif kw_range_type == 'Symbols'
      min = words_count_range[0].to_i / 4.7
      max = words_count_range[1].nil? ? min : words_count_range[1].to_i / 4.7
    end
    (min.to_i..max.to_i).to_s
  end

end
