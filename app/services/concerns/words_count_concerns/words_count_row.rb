module WordsCountConcerns
  module WordsCountRow

    extend ActiveSupport::Concern

    def get_words_count_row(count, words_range)
      settings = Setting.plugin_redmine_keywords
      template_fields = TemplateFieldsService.new
      if count == 0
        message = ' | ►►report_type◄◄ | ►►kw_count_unit_type◄◄ | ►►kw_count_status◄◄ | %{color:red}►►count_metric◄◄% / ►►target_count_metric◄◄ | ►►negative_words_count_message◄◄ |'
        message = template_fields.replace_template(@fl_hsh, message)
      elsif count >= words_range.begin && count <= words_range.end
        message = successful_message(template_fields, settings)
      elsif count > words_range.end
        message = max_unsuccessful_message(template_fields, settings)
      elsif count < words_range.begin
        message = min_unsuccessful_message(template_fields, settings)
      end
    end

    private

    def successful_message(template_fields, settings)
      template_fields.replace_template(@fl_hsh, settings['successful_message'])
    end

    def min_unsuccessful_message(template_fields, settings)
      template_fields.replace_template(@fl_hsh, settings['min_unsuccessful_message'])
    end

    def max_unsuccessful_message(template_fields, settings)
      template_fields.replace_template(@fl_hsh, settings['max_unsuccessful_message'])
    end

  end
end
