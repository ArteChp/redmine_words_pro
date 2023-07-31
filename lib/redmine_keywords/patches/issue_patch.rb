require_dependency 'issue'

module RedmineKeywords
  module Patches
    module IssuePatch

      include FormVisibleConcerns::Keywords
      include FormVisibleConcerns::Layout
      include FormVisibleConcerns::KwRange
      include FormVisibleConcerns::GoogleDocuments
      include FormVisibleConcerns::TitleCharactersRange
      include FormVisibleConcerns::TitleCharactersRangeType
      include FormVisibleConcerns::DescriptionCharactersRange
      include FormVisibleConcerns::DescriptionCharactersRangeType

      def self.included(base)
        base.class_eval do
          include InstanceMethods

          include IssueAssociationsConcerns::KeywordsAssociation
          include IssueAssociationsConcerns::LayoutsAssociation
          include IssueAssociationsConcerns::KWRangesAssociation
          include IssueAssociationsConcerns::GoogleDocumentsAssociation
          include IssueAssociationsConcerns::TitleCharactersRangeAssociation
          include IssueAssociationsConcerns::DescriptionCharactersRangeAssociation

          after_save :save_kw

          attr_accessor :kw_list
          attr_accessor :layouts_list
          attr_accessor :kw_ranges_list
          attr_accessor :kw_ranges_type_list
          attr_accessor :google_documents_list
          attr_accessor :title_characters_range_list
          attr_accessor :title_characters_range_type_list
          attr_accessor :description_characters_range_list
          attr_accessor :description_characters_range_type_list

          has_one :keyword, dependent: :destroy
          has_one :layout, dependent: :destroy
          has_one :kw_range, dependent: :destroy
          has_one :google_document, dependent: :destroy
          has_one :units_type_count, dependent: :destroy
          has_one :title_characters_range, dependent: :destroy
          has_one :description_characters_range, dependent: :destroy

          def copy_from(arg, options={})
            copy_keyword_attributes(arg)

            issue = arg.is_a?(Issue) ? arg : Issue.visible.find(arg)
            self.attributes = issue.attributes.dup.except(
              'id', 'root_id', 'parent_id', 'lft', 'rgt', 'created_on',
              'updated_on', 'status_id', 'closed_on'
            )

            self.custom_field_values = issue.custom_field_values.inject({}) { |h,v| h[v.custom_field_id] = v.value; h }
            self.status = issue.status if options[:keep_status]
            self.author = User.current
            unless options[:attachments] == false
              self.attachments = issue.attachments.map do |attachement|
                attachement.copy(container: self)
              end
            end
            unless options[:watchers] == false
              self.watcher_user_ids =
                issue.watcher_users.select { |u| u.status == User::STATUS_ACTIVE}.map(&:id)
            end

            @copied_from = issue
            @copy_options = options
            self
          end

          def copy_keyword_attributes(arg)
            issue = arg.is_a?(Issue) ? arg : Issue.visible.find(arg)

            begin
              keyword = copy_keywords(issue)
              google_document = copy_google_documents(issue)
              layout = copy_layouts(issue)
              kw_range = copy_kw_ranges(issue)
              title_characters_range = copy_title_characters_range(issue)
              description_characters_range = copy_description_characters_range(issue)

              self.keyword = keyword
              self.layout = layout
              self.google_document = google_document
              self.kw_range = kw_range
              self.title_characters_range = title_characters_range
              self.description_characters_range = description_characters_range
            rescue
            end
          end

          def save_kw
            google_document_value = google_documents_list
            layout_value = layouts_list
            keyword_value = kw_list
            kw_range_value = kw_ranges_list
            kw_range_type_value = kw_ranges_type_list
            title_characters_range_value = title_characters_range_list
            description_characters_range_value = description_characters_range_list
            title_characters_range_type_value = title_characters_range_type_list
            description_characters_range_type_value = description_characters_range_type_list

            save_keywords(keyword_value)
            save_google_documents(google_document_value)
            save_layouts(layout_value)
            save_kw_ranges(kw_range_value, kw_range_type_value)
            save_title_characters_range(title_characters_range_value, title_characters_range_type_value)
            save_description_characters_range(description_characters_range_value, description_characters_range_type_value)
          end

          alias_method :safe_attributes_without_safe_keywords=, :safe_attributes=
          alias_method :safe_attributes=, :safe_attributes_with_safe_keywords=
        end
      end

      module InstanceMethods
        def safe_attributes_with_safe_keywords=(attrs, user = User.current)
          self.safe_attributes_without_safe_keywords = attrs

          if attrs && attrs[:kw_list]
            self.kw_list = attrs[:kw_list]
          elsif keyword
            self.kw_list = keyword.current
          end

          if attrs && attrs[:layouts_list]
            layouts = attrs[:layouts_list]
            self.layouts_list = layouts
          elsif layout
            self.layouts_list = layout.layout
          end

          if attrs && attrs[:google_documents_list]
            google_documents = attrs[:google_documents_list]
            self.google_documents_list = google_documents
          elsif google_document
            self.google_documents_list = google_document.current
          end

          if attrs && attrs[:kw_ranges_list]
            kw_ranges = attrs[:kw_ranges_list]
            self.kw_ranges_list = kw_ranges
          elsif kw_range
            self.kw_ranges_list = kw_range.current
          end

          if attrs && attrs[:kw_range_type]
            kw_range_type = attrs[:kw_range_type]
            self.kw_ranges_type_list = kw_range_type
          elsif kw_range
            self.kw_ranges_type_list = kw_range.kw_range_type
          end

          if attrs && attrs[:title_characters_ranges_list]
            title_characters_range = attrs[:title_characters_ranges_list]
            self.title_characters_range_list = title_characters_range
          elsif title_characters_range
            self.title_characters_range_list = kw_range.title_characters_range
          end

          if attrs && attrs[:description_characters_range_list]
            description_characters_range = attrs[:description_characters_range_list]
            self.description_characters_range_list = description_characters_range
          elsif description_characters_range
            self.description_characters_range_list = description_characters_range.count
          end

          if attrs && attrs[:title_characters_ranges_type]
            title_characters_range_type = attrs[:title_characters_ranges_type]
            self.title_characters_range_type_list = title_characters_range_type
          elsif kw_range
            self.title_characters_range_type_list = title_characters_range.try(:range_type)
          end

          if attrs && attrs[:description_characters_range_type]
            description_characters_range_type = attrs[:description_characters_range_type]
            self.description_characters_range_type_list = description_characters_range_type
          elsif kw_range
            self.description_characters_range_type_list = description_characters_range.try(:range_type)
          end
        end
      end
    end
  end
end

unless Issue.included_modules.include?(RedmineKeywords::Patches::IssuePatch)
  Issue.send(:include, RedmineKeywords::Patches::IssuePatch)
end
