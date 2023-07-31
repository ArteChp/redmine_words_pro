module IssueHookConcerns
  module KwTable

    extend ActiveSupport::Concern

    LOCATION_VALUES = {
      'except_meta' => 'Anywhere except meta',
      'title' => 'Title',
      'desc' => 'Description',
      'all' => 'Anywhere',
      'p' => 'Paragraphs',
      'h' => 'Headers',
      'every_h' => 'Every heading',
      '100w' => 'First 100 Words',
      '150w' => 'First 150 Words',
      '200w' => 'First 200 Words',
      '250w' => 'First 250 Words',
      '1h' => 'First Header',
      '2h' => 'Second Header',
      '3h' => 'Third Header',
      'h1' => 'H1',
      'h2' => 'H2',
      'h3' => 'H3',
      'h4' => 'Heading4',
      'h5' => 'Heading5',
      'h6' => 'Heading6',
      '1h1' => 'First Heading1',
      '1h2' => 'First Heading2',
      '1h3' => 'First Heading3',
      '1h4' => 'First Heading4',
      '1h5' => 'First Heading5',
      '1h6' => 'First Heading6',
      '2h1' => 'Second Heading1',
      '2h2' => 'Second Heading2',
      '2h3' => 'Second Heading3',
      '2h4' => 'Second Heading4',
      '2h5' => 'Second Heading5',
      '2h6' => 'Second Heading6',
      '3h1' => 'Third Heading1',
      '3h2' => 'Third Heading2',
      '3h3' => 'Third Heading3',
      '3h4' => 'Third Heading4',
      '3h5' => 'Third Heading5',
      '3h6' => 'Third Heading6',
      '4h1' => 'Fourth Heading1',
      '4h2' => 'Fourth Heading2',
      '4h3' => 'Fourth Heading2',
      '4h4' => 'Fourth Heading4',
      '4h5' => 'Fourth Heading5',
      '4h6' => 'Fourth Heading6',
      '5h1' => 'Fifth Heading1',
      '5h2' => 'Fifth Heading2',
      '5h3' => 'Fifth Heading3',
      '5h4' => 'Fifth Heading4',
      '5h5' => 'Fifth Heading5',
      '5h6' => 'Fifth Heading6',
      '6h1' => 'Sixth Heading1',
      '6h2' => 'Sixth Heading2',
      '6h3' => 'Sixth Heading3',
      '6h4' => 'Sixth Heading4',
      '6h5' => 'Sixth Heading5',
      '1p' => 'First Paragraph',
      '2p' => 'Second Paragraph',
      '3p' => 'Third Paragraph',
      '4p' => 'Fourth Paragraph',
      '5p' => 'Fifth Paragraph',
      '6p' => 'Sixth Paragraph',
      '7p' => 'Seventh Paragraph',
      '8p' => 'Eighth Paragraph',
      '9p' => 'Ninth Paragraph',
      '10p' => 'Tenth Paragraph'
    }

    def print_kw_table(kw_hash)
      begin
        tables_heading = Setting.plugin_redmine_keywords['tables_heading']
        tables_heading = tables_heading.to_s.split(',').join('|')
        kw_tbl = ''
        bar = '|'
        space = ' '
        newline = "\r\n"
        header = bar + tables_heading + bar + newline
        kw_tbl << header
        kw_hash.each_with_index do |(k, row), line_i|
          if line_i < 1
            row['kw_arr'].each_with_index do |(col, cnt), kw_i|
              kw_tbl << bar << space
              kw_tbl << "*#{col}*" << space
              kw_tbl << bar << newline if kw_i == row['kw_arr'].size - 1
            end
          else
            kw_count = {}
            kw_ors = []
            row_size = 0
            row['kw_arr'].each do |kw_v, kw_c|
              if kw_c.is_a? Array
                kw_c.each do |kw_c_or|
                  kw_ors << kw_c_or
                  row_size += kw_c_or.size
                end
              else
                if kw_c.is_a? Hash
                  kw_c.each do |or_kw, or_kw_count|
                    alternative = or_kw[0][1..(or_kw.length)].split(',')
                    or_kw = "#{or_kw[0][0]} (#{alternative})"
                    kw_count[or_kw] = or_kw_count
                  end
                else
                  kw_count[kw_v] = 0 if kw_count[kw_v].nil?
                  if kw_c == 'at least 1'
                    kw_count[kw_v] = 1
                  else
                    kw_count[kw_v] += kw_c.to_i
                  end
                end
              end
            end
            row_size += kw_count.size
            kw_tbl << bar
            kw_tbl << "/#{row_size}."

            kw_type = row['kw_type']
            loc = LOCATION_VALUES[kw_type] || kw_type
            kw_tbl << space << "*#{loc}*" << space

            kw_ors.each_with_index do |kw_or, kw_or_i|
              kw_or.each_with_index do |kw_or_v, kw_or_v_i|
                kw_tbl << bar << space
                kw_tbl << kw_or_v << space
                kw_tbl << bar
                if kw_or_v_i.zero?
                  kw_tbl << "/#{kw_or.size}."
                  kw_tbl << space << "select one from #{kw_or.size}"
                  kw_tbl << space << bar
                  kw_tbl << "/#{kw_or.size}."
                  kw_tbl << space << row['kw_arr_links']['or'][kw_or_i]
                  kw_tbl << space << bar
                end
                kw_tbl << newline
              end
            end
            kw_count.each do |kw_n, kw_v|
              kw_tbl << bar << space
              kw_tbl << kw_n << space
              kw_tbl << bar << space
              kw_tbl << kw_v.to_s << space
              kw_tbl << bar << space
              unless row['kw_arr_links'][kw_n].nil?
                kw_tbl << row['kw_arr_links'][kw_n].to_s << space
              end
              kw_tbl << bar << newline
            end
          end
        end
        kw_tbl
      rescue
        nil
      end
    end
  end
end
