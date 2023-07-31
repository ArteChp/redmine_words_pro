require 'redmine'

TAGS_VERSION_NUMBER = '2.1.0'.freeze

Redmine::Plugin.register :redmine_keywords do
  name 'Repo Words plugin'
  author ''
  description 'This is a plugin for parsing attached files and google docs'
  version TAGS_VERSION_NUMBER
  url ''
  author_url ''

  requires_redmine version_or_higher: '2.6'

  settings default: {
    'select_template_field' => 0,
    'select_words_count' => 0,
    'select_symbols_count' => 0,
    'select_words_count_field' => 0,
    'replaceable_field' => 'tpl_layouts',
    'select_google_doc' => 0,
    'select_units_type_count' => 0,
    'select_keywords' => 0,
    'custom_field_visible' => '1',
    'custom_field_role_ids' => [''],
    'custom_field_tracker_ids' => ['1', '2', '3', ''],
    'form_layout_visible' => '1',
    'form_layout_role_ids' => [''],
    'form_layout_tracker_ids' => ['1', '2', '3', ''],
    'form_kw_range_visible' => '1',
    'form_kw_range_role_ids' => [''],
    'form_kw_range_tracker_ids' => ['1', '2', '3', ''],
    'form_google_documents_visible' => '1',
    'form_google_documents_role_ids' => [''],
    'form_google_documents_tracker_ids' => ['1', '2', '3', ''],
    'form_units_type_count_visible' => '1',
    'form_units_type_count_role_ids' => [''],
    'form_units_type_count_tracker_ids' => ['1', '2', '3', ''],
    'form_keywords_visible' => '1',
    'form_keywords_role_ids' => [''],
    'form_keywords_tracker_ids' => ['1', '2', '3', ''],
    'show_layout_visible' => '1',
    'show_layout_role_ids' => [''],
    'show_layout_tracker_ids' => ['1', '2', '3', ''],
    'show_kw_range_visible' => '1',
    'show_kw_range_role_ids' => [''],
    'show_kw_range_tracker_ids' => ['1', '2', '3', ''],
    'show_google_documents_visible' => '1',
    'show_google_documents_role_ids' => [''],
    'show_google_documents_tracker_ids' => ['1', '2', '3', ''],
    'show_units_type_count_visible' => '1',
    'show_units_type_count_role_ids' => [''],
    'show_units_type_count_tracker_ids' => ['1', '2', '3', ''],
    'show_keywords_visible' => '1',
    'show_keywords_role_ids' => [''],
    'show_keywords_tracker_ids' => ['1', '2', '3', ''],
    'show_title_characters_range_visible' => '1',
    'show_title_characters_range_role_ids' => [''],
    'show_title_characters_range_tracker_ids' => ['1', '2', '3', ''],
    'show_title_characters_range_type_visible' => '1',
    'show_title_characters_range_type_role_ids' => [''],
    'show_title_characters_range_type_tracker_ids' => ['1', '2', '3', ''],
    'show_description_characters_range_visible' => '1',
    'show_description_characters_range_role_ids' => [''],
    'show_description_characters_range_tracker_ids' => ['1', '2', '3', ''],
    'show_description_characters_range_type_visible' => '1',
    'show_description_characters_range_type_role_ids' => [''],
    'show_description_characters_range_type_tracker_ids' => ['1', '2', '3', ''],
    'select_user' => '1',
    'assignment_kw_count' => 0,
    'successful_message' => " | ►►report_type◄◄ | ►►kw_count_unit_type◄◄ | ►►kw_count_status◄◄ | ►►count_metric◄◄ / ►►target_count_metric◄◄ | |",
    'min_unsuccessful_message' => " | ►►report_type◄◄ | ►►kw_count_unit_type◄◄ | ►►kw_count_status◄◄ | %{color:red}►►count_metric◄◄% / ►►target_count_metric◄◄ | ►►tpl_count_metric◄◄ |",
    'max_unsuccessful_message' => " | ►►report_type◄◄ | ►►kw_count_unit_type◄◄ | ►►kw_count_status◄◄ | %{color:red}►►count_metric◄◄% / ►►target_count_metric◄◄ | ►►tpl_count_metric◄◄ |",
    'successful_message_private_notes' => false,
    'min_unsuccessful_message_private_notes' => false,
    'max_unsuccessful_message_private_notes' => false,
    'successful_keyword_verification_message' => "%{color:green}That's okay!%",
    'min_unsuccessful_keyword_verification_message' => "+Let's add *►►delta_kw_count◄◄ time/-es.+*",
    'max_unsuccessful_keyword_verification_message' => "+*►►delta_kw_count◄◄ time/-es* extra, but that's okay!+",
    'successful_keyword_verification_message_private_notes' => false,
    'min_unsuccessful_keyword_verification_message_private_notes' => false,
    'max_unsuccessful_keyword_verification_message_private_notes' => false,
    'title_regexp' => "^\\s*[Tt]itle:|^\\s*[Tt]itle [Tt]ag:|^\\s*[Mm][Tt]|^\\s*[Tt]ag [Tt]itle:",
    'description_regexp' => "^\\s*[Mm]eta [Dd]escription:|^\\s*[Dd]escription:|^\\s*[Mm][Dd]:",
    'custom_field_google_doc_ids' => [''],
    'credentials' => '',
    'infelicity' => 0,
    'tables_heading' => 'Name, KWs ,Counts, Link',
    'form_template_role_ids' => [''],
    'form_check_docs_role_ids' => [''],
    'form_template_visible' => '1',
    'form_check_docs_visible' => '1',
      }, partial: 'settings/redmine_keywords'
end

require 'redmine_keywords'

Rails.application.paths['app/overrides'] ||= []
Dir.glob("#{Rails.root}/plugins/*/app/overrides").each do |dir|
  unless Rails.application.paths['app/overrides'].include?(dir)
    Rails.application.paths['app/overrides'] << dir
  end
end
