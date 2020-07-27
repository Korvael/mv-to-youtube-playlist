# frozen_string_literal: true

require 'yaml'

# En la primera ejecución, crea y rellena el fichero de configuración
class Settings
  def self.generate_settings_file
    # Se solicitan datos únicamente si el fichero no existe o está vacío
    return if File.exist?('settings.yml') && !File.zero?('settings.yml')

    p 'Datos de configuración no encontrados. Se generarán en este momento.'

    p 'Introduce el nombre de tu usuario de Mediavida:'
    mv_user = gets.chomp

    p 'Introduce el nombre de la playlist de YouTube que se creará o a la que se añadirán los vídeos:'
    yt_playlist_name = gets.chomp

    p 'Selecciona el nivel de privacidad de la playlist (private/unscheduled/public):'
    yt_playlist_privacy_status = gets.chomp

    p 'Introduce tu ID de cliente:'
    client_id = gets.chomp

    p 'Introduce tu secreto de cliente:'
    client_secret = gets.chomp

    settings = { settings:
      { mv_user: mv_user,
        yt_playlist_name: yt_playlist_name,
        yt_playlist_privacy_status: yt_playlist_privacy_status,
        client_id: client_id,
        client_secret: client_secret,
        refresh_token: '' } }

    File.open('settings.yml', 'w') { |f| f.write settings.to_yaml }

    p 'Fichero de configuración generado. Si necesitas modificar algún dato, edita '\
      "el fichero 'settings.yml' en la carpeta del proyecto."
  end
end
