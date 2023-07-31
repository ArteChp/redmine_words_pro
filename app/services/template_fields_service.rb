class TemplateFieldsService

  def parse_kw_text(kw, words_count)
    words_count_range = words_count.to_s.split(/[^0-9]+/i).map { |d| Integer(d) }

    if words_count_range[0].to_i == words_count_range[1].to_i
      infelicity = Setting.plugin_redmine_keywords['infelicity'].to_i
      min = words_count_range[0].to_i
      max = words_count_range[0].to_i + infelicity
      words_count = min..max
    else
      words_count = words_count_range[0].to_i..words_count_range[1].to_i
    end

    @kw_hash = {}
    @kw_hash[0] = {}
    @kw_hash[0]['kw_arr'] = {}
    @kw_hash[0]['kw_arr_links'] = {}

    blocks = kw.split("\n\n")
    blocks.each_with_index do |block, index|
      lines = block.split("\n")
      index += 1

      @kw_hash[index] = {}

      @kw_hash[index]['kw_type'] = ''
      @kw_hash[index]['kw_loc'] = ''
      @kw_hash[index]['kw_arr'] = {}
      @kw_hash[index]['kw_arr_links'] = {}
      @kw_hash[index]['kw_arr']['or'] = {}
      @kw_hash[index]['kw_arr_links']['or'] = []

      lines.each_with_index do |line, i|
        next if line == '#  - ' || line == '# - ' || line.blank?

        if i.zero?
          @kw_hash[index]['kw_type'] = line.split(' - ')[0].gsub('#', '').rstrip.strip
          @kw_hash[index]['kw_loc'] = line.split(' - ')[1].rstrip.strip
       else
         if line.include? '|'
           or_keywords = []
           or_keywords << line.split('|').map! { |l| l.rstrip.strip }
           or_keywords[0].map! { |keyword| keyword.split(' - ')[0] }
           count = line.split(' - ')[1].try(:rstrip).try(:strip) || 1
           unless @kw_hash[index]['kw_arr']['or']
             @kw_hash[index]['kw_arr']['or'] = {}
           end
           @kw_hash[index]['kw_arr']['or'][or_keywords] = count
         elsif line.include? ' - '
           if line.include? '%'
             percent_count = line.split(' - ')[1].gsub('%', '').rstrip.strip.chomp
             word = line.split(' - ')[0].rstrip.strip

             words_count_range = words_count.to_s.split(/[^0-9]+/i).map { |d| Integer(d) }

             if words_count_range[0].to_i == words_count_range[1].to_i
               infelicity = Setting.plugin_redmine_keywords['infelicity'].to_i
               min = words_count_range[0].to_i
               max = words_count_range[0].to_i + infelicity
               words_count = min..max
             else
               start_range = words_count_range[0].to_i
               end_range = words_count_range[1].to_i

               words_count = start_range..end_range
             end

             if @kw_hash[index]['kw_arr'].key?(word)
               if @kw_hash[index]['kw_arr'][word] != 'at least 1'
                 word_count = (@kw_hash[index]['kw_arr'][word] + (words_count.first * percent_count.gsub(',', '.').to_f / 100)).round
               else
                 word_count = (1 + words_count.first * (percent_count.gsub(',', '.').to_f / 100)).round
               end
             else
               word_count = (words_count.first * (percent_count.gsub(',', '.').to_f / 100)).round
             end

             @kw_hash[index]['kw_arr'][word] = word_count
           elsif line.include? 'http'
             if line.include? '|'
               words = line.split(' - ')[0]
               link = line.split(' - ')[1]
               @kw_hash[index]['kw_arr']['or'] << words.split('|').map! { |l| l.rstrip.strip.gsub('@', '') }
               @kw_hash[index]['kw_arr_links']['or'] << link
              else
                word = line.split(' - ')[0].gsub('@', '').rstrip.strip
                word_count = 1
                links_word = line.split(' - ')[0].gsub('@', '').rstrip.strip
                links_word_count = line.split(' - ')[1].rstrip.strip
                @kw_hash[index]['kw_arr'][word] = word_count
                @kw_hash[index]['kw_arr_links'][links_word] = links_word_count
              end
           elsif line.include? ','
             keywords = line.split(' - ')[0]
             keywords.split(',').each do |keyword|
               keyword = keyword.rstrip.strip
               if @kw_hash[index]['kw_arr'].key?(keyword)
                 if @kw_hash[index]['kw_arr'][keyword] != 'at least 1'
                   line = line.split(' - ')[1].rstrip.strip.to_i
                   word_count = @kw_hash[index]['kw_arr'][keyword] + line
                 else
                   word_count = 1 + line.split(' - ')[1].rstrip.strip.to_i
                 end
               else
                 word_count = line.split(' - ')[1].rstrip.strip.to_i
               end
               @kw_hash[index]['kw_arr'][keyword] = word_count
             end
           elsif line.include? "\t"
             keywords = line.split(' - ')[0]
             keywords.split("\t").each do |keyword|
               keyword = keyword.rstrip.strip
               if @kw_hash[index]['kw_arr'].key?(keyword)
                 if @kw_hash[index]['kw_arr'][keyword] != 'at least 1'
                   line = line.split(' - ')[0].rstrip.strip.to_i
                   word_count = @kw_hash[index]['kw_arr'][keyword] + line
                 else
                   word_count = 1 + line.split(' - ')[0].rstrip.strip.to_i
                 end
               else
                 word_count = line.split(' - ')[0].rstrip.strip.to_i
               end
              @kw_hash[index]['kw_arr'][keyword] = word_count
             end
           elsif line.include? ';'
             keywords = line.split(' - ')[0]
             keywords.split(';').each do |keyword|
               keyword = keyword.rstrip.strip
               if @kw_hash[index]['kw_arr'].key?(keyword)
                 if @kw_hash[index]['kw_arr'][keyword] != 'at least 1'
                   line = line.split(' - ')[0].rstrip.strip.to_i
                   word_count = @kw_hash[index]['kw_arr'][keyword] + line
                 else
                   word_count = 1 + line.split(' - ')[0].rstrip.strip.to_i
                 end
               else
                 word_count = line.split(' - ')[0].rstrip.strip.to_i
               end
              @kw_hash[index]['kw_arr'][keyword] = word_count
             end
           else
             word = line.split(' - ')[0].rstrip.strip
             if @kw_hash[index]['kw_arr'].key?(word)
               if @kw_hash[index]['kw_arr'][word] != 'at least 1'
                 line = line.split(' - ')[1].rstrip.strip.to_i
                 word_count = @kw_hash[index]['kw_arr'][word].to_i + line
               else
                 word_count = 1 + @kw_hash[index]['kw_arr'][keyword].to_i
               end
             else
               word_count = line.split(' - ')[1].rstrip.strip
             end

             @kw_hash[index]['kw_arr'][word] = word_count
           end
         else
           if line.include? ','
             keywords = line.split(' - ')[0]
             keywords.split(',').each do |keyword|
               keyword = keyword.rstrip.strip
               if @kw_hash[index]['kw_arr'].key?(keyword)
                 if @kw_hash[index]['kw_arr'][keyword] != 'at least 1'
                   word_count = @kw_hash[index]['kw_arr'][keyword].to_i + 1
                 else
                   word_count = 2
                 end
               else
                 word_count = 'at least 1'
               end
              @kw_hash[index]['kw_arr'][keyword] = word_count
             end
           elsif line.include? "\t"
             keywords = line.split(' - ')[0]
             keywords.split("\t").each do |keyword|
               keyword = keyword.rstrip.strip
               if @kw_hash[index]['kw_arr'].key?(keyword)
                 if @kw_hash[index]['kw_arr'][keyword] != 'at least 1'
                   word_count = @kw_hash[index]['kw_arr'][keyword].to_i + 1
                 else
                   word_count = 2
                 end
               else
                 word_count = 'at least 1'
               end
              @kw_hash[index]['kw_arr'][keyword] = word_count
             end
           elsif line.include? ';'
             keywords = line.split(' - ')[0]
             keywords.split(';').each do |keyword|
               keyword = keyword.rstrip.strip
               if @kw_hash[index]['kw_arr'].key?(keyword)
                 if @kw_hash[index]['kw_arr'][keyword] != 'at least 1'
                   word_count = @kw_hash[index]['kw_arr'][keyword] + 1
                 else
                   word_count = 2
                 end
               else
                 word_count = 'at least 1'
               end
              @kw_hash[index]['kw_arr'][keyword] = word_count
             end
           else
             word = line.split(' - ')[0].rstrip.strip

            if @kw_hash[index]['kw_arr'].key?(word)
              if @kw_hash[index]['kw_arr'][word] != 'at least 1'
                word_count = @kw_hash[index]['kw_arr'][word] + 1
              else
                word_count = 2
              end
            else
              word_count = 'at least 1'
            end

             @kw_hash[index]['kw_arr'][word] = word_count
           end
          end
        end
      end
    end

    n = 0
    new_hash = {}
    @kw_hash.each do |k, v|
      if v['kw_arr'] == { 'or' => [] } && v['kw_arr_links'] == { 'or' => [] }
        n += 1
      else
        new_hash[k.to_i - n] = v
      end
    end
    @kw_hash = new_hash

    @kw_hash.each do |k, v|
      v["kw_arr"].tap { |h| h.delete('') }
    end

    @kw_hash
  end

  def replace_template(rpl_hash, tpl)
    return unless tpl

    rpl_hash.each do |k, v|
      @tpl_chk = tpl.match(/\►([^\►\◄]*)\►[\ \t]*#{k}[\ \t]*\|?[\ \t]*([^\|\ \t\►\◄\(\)]*)[\ \t]*\(?([^\(\)\►\◄\|]*)\)?[\ \t]*\|?[\ \t]*([^\ \t\►\◄\(\)\|]*)[\ \t]*\(?([^\(\)\►\◄\|]*)\)?[\ \t]*\◄([^\►\◄]*)\◄/i)
      if not @tpl_chk.nil? and not v.nil? and v != ''
        v = replace_func_init(v, @tpl_chk[2].strip, @tpl_chk[3].strip)
        v = replace_func_init(v, @tpl_chk[4].strip, @tpl_chk[5].strip)
        v = @tpl_chk[1] + v.to_s + @tpl_chk[6]
        tpl = tpl.gsub(/\►([^\►\◄]*)\►[\ \t]*#{k}[\ \t]*\|?[\ \t]*([^\|\ \t\►\◄\(\)]*)[\ \t]*\(?([^\(\)\►\◄\|]*)\)?[\ \t]*\|?[\ \t]*([^\ \t\►\◄\(\)\|]*)[\ \t]*\(?([^\(\)\►\◄\|]*)\)?[\ \t]*\◄([^\►\◄]*)\◄/i) { v }
      end
    end
    tpl = tpl.gsub(/\►([^\►\◄]*)\►[\ \t]*[^\ \t\►\◄\|]*[\ \t]*\|?[\ \t]*([^\|\ \t\►\◄\(\)]*)[\ \t]*\(?([^\(\)\►\◄\|]*)\)?[\ \t]*\|?[\ \t]*([^\ \t\►\◄\(\)\|]*)[\ \t]*\(?([^\(\)\►\◄\|]*)\)?[\ \t]*\◄([^\►\◄]*)\◄/i) { '' }
    tpl
  end

  def replace_func_init(v, f_n, f_p)
    f_n = f_n.strip
    f_p = f_p.strip
    if f_n != '' and f_p != ''
      f_p_a = f_p.tr('\'\'', '').strip.split(/[,;]+/).collect(&:strip)
      begin
        if respond_to?(f_n)
          f_p_a = f_p_a.unshift(v)
          v = send(f_n, *f_p_a)
        else
          v = v.send(f_n, *f_p_a)
        end
      rescue
        return v
      end
    elsif f_n != '' and f_p == ''
      begin
        v = if respond_to?(f_n)
              send(f_n, v)
            else
              v.send(f_n)
            end
      rescue
        return v
      end
    end
    v
  end

  def cm_delete(val)
    val.delete!("\C-M")
  end

  def add_time(v,cf)
    cf_v = @fl_hsh[cf].to_i
    (v.to_time + cf_v * 60 * 60).to_datetime
  end

end
