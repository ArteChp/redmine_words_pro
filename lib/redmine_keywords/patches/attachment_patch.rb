module RedmineKeywords
  module Patches
    module AttachmentPatch
        extend ActiveSupport::Concern

      def self.included(base)
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods
        def is_document?
          accepted_formats = ['.odt', '.doc', '.docx']
          extname = File.extname(disk_filename)
          accepted_formats.include?(extname)
        end
      end
    end
  end
end

unless Attachment.included_modules.include?(RedmineKeywords::Patches::AttachmentPatch)
  Attachment.send(:include, RedmineKeywords::Patches::AttachmentPatch)
end
