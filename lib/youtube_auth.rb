# frozen_string_literal: true

require 'yt'

# Autenticación OAuth 2.0 para operar con la playlist
class YouTubeAuth
  # Constantes para la generación del token
  SCOPES = ['youtube'].freeze
  REDIRECT_URI = 'https://google.es'

  def self.setup_token(client_id, client_secret, refresh_token)
    # Petición de acceso por parte de la aplicación
    return unless refresh_token.eql? ''

    p 'Para poder crear la playlist y añadir los vídeos de forma automática, '\
      'accede al siguiente enlace desde un navegador, autoriza el acceso a tu '\
      'cuenta de YouTube por parte de la aplicación y copia el valor del parámetro '\
      "'code=...' del enlace cuando seas redireccionado a google.es tras la autorización."

    Yt.configure do |config|
      config.client_id = client_id
      config.client_secret = client_secret

      p CGI.unescape Yt::Account.new(scopes: SCOPES, redirect_uri: REDIRECT_URI).authentication_url

      p "Introduce el valor del parámetro 'code=...':"
      auth_param = gets.chomp
      account = Yt::Account.new authorization_code: auth_param, redirect_uri: REDIRECT_URI
      account.refresh_token
    end
  end

  def self.config_auth(client_id, client_secret, refresh_token)
    Yt.configure do |config|
      config.client_id = client_id
      config.client_secret = client_secret
    end

    Yt::Account.new refresh_token: refresh_token
  end
end
