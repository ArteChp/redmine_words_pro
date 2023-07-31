module IssueHookConcerns
  module ModelIssueHookHelpers

    extend ActiveSupport::Concern

    def get_current_keyword(context, issue)
      current_keyword = unless context[:params][:issue]['kw_list'].try :blank?
        context[:params][:issue]['kw_list']
      else
        issue.try(:keyword).try(:current)
      end
      current_keyword.gsub!("\r\n", "\n") if current_keyword
      current_keyword
    end

    def get_kw_ranges_list(context, issue)
      kw_ranges_list = context[:params][:issue]['kw_ranges_list']
      kw_ranges_list = issue.try(:kw_range).try(:current) if kw_ranges_list.try :blank?
      kw_ranges_list
    end

    def get_counts(context, issue)
      kw_ranges_list = get_kw_ranges_list(context, issue)
      words_count, symbols_count = if context[:params][:issue]['kw_range_type'] == 'Words'
        [kw_ranges_list.to_s, (kw_ranges_list.to_i * 4.7).to_s]
      else
        [(kw_ranges_list.to_i / 4.7).to_s, kw_ranges_list.to_s]
      end
      return words_count, symbols_count
    end

    def get_tpl(context, issue)
      tpl = context[:params][:issue]['layouts_list']
      tpl = issue.try(:layout).try(:layout) if tpl.try :blank?
      tpl.gsub("\r\n ►", '►') if tpl
    end

    def expand_flatten_hash(context, table, words_count, symbols_count, google_doc)
      cf_symbols_count_replaceable_field = Setting.plugin_redmine_keywords['replaceable_field'].to_s
      @fl_hsh = flatten_hash(context[:params][:issue])
      @fl_hsh[cf_symbols_count_replaceable_field] = table
      @fl_hsh['words_ranges'] = words_count
      @fl_hsh['symbols_ranges'] = symbols_count
      @fl_hsh['google_documents'] = google_doc
    end

    def save_callback(context)
      issue = Issue.find_by(id: context[:params][:id])
      google_doc = context[:params][:issue]['google_documents_list']
      current_keyword = get_current_keyword(context, issue)
      words_count, symbols_count = get_counts(context, issue)
      needed_words_count = calc_words(words_count, symbols_count)
      table = formated_kw_table(current_keyword, needed_words_count)
      expand_flatten_hash(context, table, words_count, symbols_count, google_doc)
      tpl = get_tpl(context, issue)
      return if (tpl.try :blank?) && (form_layout_role_decision(context[:params][:project_id], nil))

      context[:issue].description = @template_fields.replace_template(@fl_hsh, tpl)
    end

    def formated_kw_table(current_keyword, needed_words_count)
      table = print_kw_table(@template_fields.parse_kw_text(current_keyword, needed_words_count))
      "\n#{table}\n"
    end

    def kw_table(cf_kw_val, cf_words_count, cf_symbols_count)
      words_count = @fl_hsh[cf_words_count]
      symbols_count = @fl_hsh[cf_symbols_count]
      print_kw_table(@template_fields.parse_kw_text(cm_delete(cf_kw_val), calc_words(words_count, symbols_count)))
    end

  end
end
