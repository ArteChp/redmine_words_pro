# module for authorize in google document
class GoogleDocsAuthorize

  require 'google/apis/docs_v1'
  require 'googleauth'
  require 'googleauth/stores/file_token_store'
  require 'fileutils'
  require 'google_drive'

  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'Repo Words plugin'.freeze
  CREDENTIALS_PATH = "#{Rails.root}/credentials.json".freeze
  TOKEN_PATH = "#{Rails.root}/tmp/docs-api-token.yml".freeze
  SCOPE = Google::Apis::DocsV1::AUTH_DOCUMENTS_READONLY
  CODE = Setting.plugin_redmine_keywords['credentials']

  def parse_google_content(doc)
    begin
      service = Google::Apis::DocsV1::DocsService.new
      service.client_options.application_name = APPLICATION_NAME
      service.authorization = authorize
      document = service.get_document doc
      content = []
      catch(:horizontal_line) do
        document.body.content.each_with_index do |value, index|
          value.paragraph&.elements&.each_with_index do |element, i|
            throw(:horizontal_line, true) if element.horizontal_rule
          end
          content << value
        end
      end
      content
    rescue Exception => error
      content = nil
    end
  end

  def authorize
    begin
      client_id = Google::Auth::ClientId.from_file CREDENTIALS_PATH
      token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
      authorizer = Google::Auth::UserAuthorizer.new(
        client_id, SCOPE, token_store
      )
      user_id = 'default'
      credentials = authorizer.get_credentials user_id
      if credentials.nil?
        credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id,
          code: CODE,
          base_url: OOB_URI
        )
      end

      credentials
    rescue Exception => error
      nil
    end
  end

  def read_paragraph_element(element)
    if element.text_run
      text_run = element.text_run
    else
      return ''
    end
    text_run.content
  end

  def read_strucutural_elements(elements)
    text = ''
    elements.each do |value|
      if value.paragraph
        elements = value.paragraph.elements
        elements.each do |elem|
          text << read_paragraph_element(elem) if elem
        end
      elsif value.table
        table = value.table
        puts table.inspect
        table.table_rows.each do |row|
          cells = row.table_cells
          cells.each do |cell|
            text << read_strucutural_elements(cell.content)
          end
        end
      end
    end
    text
  end

  def read_with_links(elements)
    text = ''
    elements.each do |value|
      if value.paragraph
        elements = value.paragraph.elements
        elements.each do |elem|
          if elem.try(:text_run).try(:text_style)
            if elem.text_run.text_style.link.nil?
              text << read_paragraph_element(elem)
            else
              elem_text = read_paragraph_element(elem)
              elem_link = elem.text_run.text_style.link.url
              text << "(#{elem_link})#{elem_text}"
            end
          end
        end
      elsif value.table
        table = value.table
        puts table.inspect
        table.table_rows.each do |row|
          cells = row.table_cells
          cells.each do |cell|
            text << read_strucutural_elements(cell.content)
          end
        end
      end
    end
    text
  end

end
