module ExtensionConverter

  extend ActiveSupport::Concern

  def convert_file(attachment_id)
    attachment = Attachment.find(attachment_id)
    begin
      file = attachment.diskfile
      file_extension = File.extname(file.to_s)
      if file_extension == '.docx'
        new_docx_name = File.basename("#{file}", File.extname("#{file}"))
        new_doc_name = File.basename("#{file}", File.extname("#{file}"))
        system("unoconv -f doc -o /tmp/#{new_doc_name}.doc #{file}")
        system("unoconv -f docx -o /tmp/#{new_docx_name}.docx #{file}")
        doc = MSWordDoc::Extractor.load("/tmp/#{new_doc_name}.doc")
        @docx = Docx::Document.open("/tmp/#{new_docx_name}.docx")
        system("rm /tmp/#{new_doc_name}.doc")
        system("rm /tmp/#{new_docx_name}.docx")
      elsif file_extension == '.doc'
        doc = MSWordDoc::Extractor.load(file.to_s)
        new_docx_name = File.basename("#{file}", File.extname("#{file}"))
        system("unoconv -f docx -o /tmp/#{new_docx_name}.docx #{file}")
        @docx = Docx::Document.open("/tmp/#{new_docx_name}.docx")
        system("rm /tmp/#{new_docx_name}.docx")
      else
        new_file_name = File.basename("#{file}", File.extname("#{file}"))
        system("unoconv -f doc -o /tmp/#{new_file_name}.doc #{file}")
        doc = MSWordDoc::Extractor.load("/tmp/#{new_file_name}.doc")
        system("unoconv -f docx -o /tmp/#{new_file_name}.docx #{file}")
        @docx = Docx::Document.open("/tmp/#{new_file_name}.docx")
        system("rm /tmp/#{new_file_name}.doc")
        system("rm /tmp/#{new_file_name}.docx")
      end
      @doc_text = doc.whole_contents
      @doc_text_array = @doc_text.split
    rescue Exception => error
      @doc_text_array = []
    end
  end

end
