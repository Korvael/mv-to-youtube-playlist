# frozen_string_literal: true

require 'yt'

# Autenticación OAuth 2.0 para operar con la playlist
class YouTubeAuth
  # Constantes para la generación del token
  CLIENT_ID = ''
  CLIENT_SECRET = ''
  SCOPES = ['youtube'].freeze
  REDIRECT_URI = 'https://google.es'

  def self.setup_token
    # Seguir las instrucciones en https://github.com/Fullscreen/yt#web-apps-that-require-user-interactions
    Yt.configure do |config|
      config.client_id = CLIENT_ID
      config.client_secret = CLIENT_SECRET

      Yt::Account.new(scopes: SCOPES, redirect_uri: REDIRECT_URI).authentication_url
      Yt::Account.new authorization_code: '', redirect_uri: REDIRECT_URI
    end
  end

  def self.config_auth
    Yt::Account.new access_token: ''
  end
end
