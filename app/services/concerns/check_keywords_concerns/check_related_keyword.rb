module CheckKeywordsConcerns
  module CheckRelatedKeyword

    extend ActiveSupport::Concern

    HEADER_TAGS = [
      '<h1>', '</ h1>', '<h2>', '</ h2>', '</h2>', '<h3>', '</ h3>', '</h3>',
      '<h4>', '</ h4>', '</h4>', '<h5>', '</ h5>', '</h5>', '<h6>', '</ h6>',
      '</h6>'
    ]

    def check_related_keyword(status, to_do, keyword, formated_text, related_keywords_count = 0, out_of_place = [])
      return if keyword.is_a? Array

      HEADER_TAGS.each { |h| formated_text.gsub!(h, ' ') }
      all_words = keyword.split(' ')
      regex = get_regex(all_words)
      return unless regex

      res = []
      related_keywords = []
      check_related(formated_text, regex, related_keywords)
      return if @catastrophic_backtracking_regex

      founded_kws, words_between = get_words_between(words_between, all_words, res)
      related_keywords_count += related_keywords.length unless words_between.empty?
      if founded_kws != all_words
        out_of_place << founded_kws.join(' ')
        formated_text.gsub!(founded_kws.join(' '), '')
        while founded_kws != all_words && regex.match(formated_text.to_s).to_a.any?
          check_related_keyword(status, to_do, keyword, formated_text, related_keywords_count, out_of_place)
        end
      end

      clear_related_keywords(related_keywords)
      related_keywords_count = out_of_place.count + related_keywords.count
      status_with_related(status, out_of_place, related_keywords, related_keywords_count) unless status.include?('related keyword/-s:')
    end

    def check_related(formated_text, regex, related_keywords)
      @catastrophic_backtracking_regex = false
      begin
        # check while has related_keywords
        while SafeRegexp.execute(regex, :match?, formated_text.to_s)
          sub_res = SafeRegexp.execute(regex, :match, formated_text.to_s)
          related_keywords << sub_res[0]
          formated_text = formated_text.gsub(sub_res[0], '')
        end
      rescue
        @catastrophic_backtracking_regex = true
      end
    end

    def status_with_related(status, out_of_place, related_keywords, related_keywords_count)
      if out_of_place.any? && related_keywords.any?
        status << "found #{related_keywords_count} related keyword/-s: <pre>#{related_keywords.join("</pre> <pre>")} </pre> <pre>#{out_of_place.join("</pre> <pre>")} </pre>"
      elsif out_of_place.any?
        status << " + found #{related_keywords_count} related keyword/-s: <pre>#{out_of_place.join("</pre> <pre>")} </pre>"
      elsif related_keywords.any?
        status << " + found #{related_keywords_count} related keyword/-s: <pre>#{related_keywords.join("</pre> <pre>")} </pre>"
      end
      status
    end

    def get_regex(all_words)
      regex = ''
      related_keyword_regex = '[\\W]*([\\S?(\\w)?]+)?[\\W]*?([\\S?(\\w)?]+)?[\\W]*?'
      all_words.each do |r|
        regex += "(#{all_words.join('(\s+)|([\p{P}\p{S}])|')})"
        regex += related_keyword_regex
      end
      regex.chomp!(related_keyword_regex)
      regex << ' '
      Regexp.new regex.delete(' ')
    end

    def clear_related_keywords(related_keywords)
      related_keywords.each_with_index do |relate, index|
        related_keywords.slice!(index) if relate.strip == keyword
      end
      related_keywords = related_keywords.uniq
      related_keywords.reject! { |x| x.to_s.length > keyword.length + 15 }
    end

    def get_words_between(words_between, all_words, res)
      words_between = all_words - res | res - all_words
      founded_kws = res - words_between | words_between - res
      words_between = if res.empty?
        []
      else
        all_words - res | res - all_words
      end
      return founded_kws, words_between
    end

  end
end
