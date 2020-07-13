# frozen_string_literal: true

require 'nokogiri'
require 'httparty'
require_relative 'youtube_auth'
require 'yt'

# Genera una playlist en YouTube a partir de las aportaciones del hilo de Mediavida
class MvToYoutube
  # Constantes definidas por el usuario
  MV_USER = 'Korvael'
  YT_PLAYLIST_NAME = 'Mediavida'

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

    # Crea la playlist de YouTube si no existe
    create_playlist(YT_PLAYLIST_NAME)
  end

  def scrape(page)
    Nokogiri::HTML(HTTParty.get(MV_URL + 'u=' + MV_USER + '&pagina=' + page.to_s))
  end

  def video_ids(total_pages)
    video_ids = []

    p "Obteniendo vídeos de Mediavida del usario #{MV_USER}..."

    (1..total_pages).each do |i|
      scrape = scrape(i)
      scrape.css(MV_DIV_CLASS).css(MV_HREF_CLASS).each do |href|
        video_ids << href['href'].split('v=').last
      end
    end

    p "Se encontraron un total de #{video_ids.size} vídeos en #{total_pages} páginas totales."

    video_ids
  end

  def create_playlist(playlist_name)
    p "Comprobando la existencia de la playlist #{playlist_name}..."

    # Descomentar si no se dispone de token de autenticación. Seguir las instrucciones en https://github.com/Fullscreen/yt#web-apps-that-require-user-interactions
    # YouTubeAuth.setup_token

    account = YouTubeAuth.config_auth
    account.playlists
  end
end

generate_playlist = MvToYoutube.new
generate_playlist.run
