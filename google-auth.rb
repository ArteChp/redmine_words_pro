require "google/apis/docs_v1"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"

OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
APPLICATION_NAME = "Google Docs API Ruby Quickstart".freeze
CREDENTIALS_PATH = "config/docs-api-credentials.json".freeze
TOKEN_PATH = "/tmp/docs-api-token.yml".freeze
SCOPE = Google::Apis::DocsV1::AUTH_DOCUMENTS_READONLY

def authorize
  client_id = Google::Auth::ClientId.from_file CREDENTIALS_PATH
  token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
  authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
  user_id = "default"
  credentials = authorizer.get_credentials user_id
  url = authorizer.get_authorization_url base_url: OOB_URI
  puts "Open the following URL in the browser and enter the " \
         "resulting code after authorization:\n" + url
end

service = Google::Apis::DocsV1::DocsService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize
