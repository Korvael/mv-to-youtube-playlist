# frozen_string_literal: true

require 'nokogiri'
require 'httparty'
require_relative 'settings'
require_relative 'youtube_auth'
require 'yaml'
require 'yt'

# Genera una playlist en YouTube a partir de las aportaciones del hilo de Mediavida
class MvToYoutube
  # Generación de configuración en primera ejecución
  Settings.generate_settings_file

  # Carga de configuración desde fichero YAML
  @settings = YAML.load_file('settings.yml')

  MV_USER = @settings[:settings][:mv_user]
  YT_PLAYLIST_NAME = @settings[:settings][:yt_playlist_name]
  YT_PLAYLIST_PRIVACY_STATUS = @settings[:settings][:yt_playlist_privacy_status]
  CLIENT_ID = '1040937298085-5m57t818u5t34g2p2ggvppl474r96sbi.apps.googleusercontent.com'
  CLIENT_SECRET = Base64.decode64('ZFRWV0d6by1kRC0wSWN4b3RDc1VnTnJH\n')
  REFRESH_TOKEN = @settings[:settings][:refresh_token]

  # Constantes del scraper
  MV_URL = 'https://www.mediavida.com/foro/feda/cancion-estas-escuchando-ahora-mismo-329209?'
  MV_DIV_CLASS = 'div.youtube_lite'
  MV_HREF_CLASS = '.preinit'

  def run
    # Scrap de la primera página para obtener el total de páginas
    scrape = scrape('1')
    total_pages = scrape.css('.side-pages').css('a').last.children.text.to_i

    # Obtención de los IDs de todos los vídeos
    video_ids = video_ids(total_pages)

    # Autenticación y creación de la playlist de YouTube si no existe
    token = YouTubeAuth.setup_token(CLIENT_ID, CLIENT_SECRET, REFRESH_TOKEN)
    update_settings_file(token) unless token.nil?

    @account = YouTubeAuth.config_auth(CLIENT_ID, CLIENT_SECRET, REFRESH_TOKEN.eql?('') ? token : REFRESH_TOKEN)
    playlist_id = create_playlist(YT_PLAYLIST_NAME)

    # Comprueba la disponibilidad de los vídeos que se van a insertar en la playlist
    available_videos = check_video_availability(video_ids)

    # Inserta los vídeos disponibles en la playlist
    add_videos_to_playlist(available_videos, playlist_id)
  end

  def scrape(page)
    Nokogiri::HTML(HTTParty.get(MV_URL + 'u=' + MV_USER + '&pagina=' + page.to_s))
  end

  def video_ids(total_pages)
    p "Obteniendo vídeos de Mediavida del usuario #{MV_USER}..."
    video_ids = []

    (1..total_pages).each do |i|
      scrape = scrape(i)
      scrape.css(MV_DIV_CLASS).css(MV_HREF_CLASS).each do |href|
        video_ids << href['href'].split('v=').last.split('&').first
      end
    end

    p "Se encontraron un total de #{video_ids.size} vídeos en #{total_pages} páginas."

    video_ids
  end

  def create_playlist(playlist_name)
    p "Comprobando la existencia de la playlist '#{playlist_name}'..."

    if @account.playlists.map(&:title).include? YT_PLAYLIST_NAME
      p "Playlist '#{YT_PLAYLIST_NAME}' encontrada."
      @account.playlists.map.collect { |playlist| playlist.id if playlist.title.eql? YT_PLAYLIST_NAME }.first
    else
      p "Playlist '#{YT_PLAYLIST_NAME}' no encontrada. Se creará en este momento."
      @account.create_playlist(title: YT_PLAYLIST_NAME, privacy_status: YT_PLAYLIST_PRIVACY_STATUS).id
    end
  end

  def check_video_availability(video_ids)
    p 'Comprobando disponibilidad de los vídeos a insertar en la playlist...'
    unavailable_videos = []

    video_ids.each do |video_id|
      begin
        video = Yt::Video.new id: video_id, auth: @account
        unavailable_videos << video.id if video.deleted? || video.rejected?
      rescue StandardError
        p "Vídeo no disponible: #{video.id}."
        unavailable_videos << video.id
      end
    end

    p "De un total de #{video_ids.size} vídeos, se encontraron #{unavailable_videos.size} vídeos no disponibles."

    video_ids - unavailable_videos
  end

  def add_videos_to_playlist(available_videos, playlist_id)
    p "Insertando vídeos en la playlist '#{YT_PLAYLIST_NAME}'. Puede tardar unos minutos..."

    playlist = Yt::Playlist.new id: playlist_id, auth: @account
    playlist_items = playlist.playlist_items.map(&:video_id)
    items_to_add = []

    available_videos.each do |video|
      items_to_add << video unless playlist_items.include? video
    end

    playlist.add_videos items_to_add if items_to_add.size.positive?

    p "Añadidos #{items_to_add.size} vídeos a la playlist '#{YT_PLAYLIST_NAME}'. Se omitieron los vídeos duplicados."
    p "https://www.youtube.com/playlist?list=#{playlist_id}"
  end

  def update_settings_file(token)
    settings = MvToYoutube.instance_variable_get(:@settings)
    settings[:settings][:refresh_token] = token
    File.open('settings.yml', 'w') { |f| YAML.dump settings, f }
  end
end

generate_playlist = MvToYoutube.new
generate_playlist.run
