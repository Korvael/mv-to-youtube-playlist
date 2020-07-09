# frozen_string_literal: true

require 'nokogiri'
require 'httparty'

# Genera una playlist en YouTube a partir de las aportaciones del hilo de Mediavida
class MvToYoutube
  # Constantes definidas por el usuario
  MV_USER = 'Korvael'
  YT_TOKEN = ''
  YT_PLAYLIST_NAME = ''

  # Constantes del scraper
  MV_URL = 'https://www.mediavida.com/foro/feda/cancion-estas-escuchando-ahora-mismo-329209?'
  MV_DIV_CLASS = 'div.youtube_lite'
  MV_HREF_CLASS = '.preinit'

  def run
    # Scrap de la primera página, de la que obtenemos todos los enlaces de YouTube y el total de páginas
    scrape = scrape('1')
    total_pages = scrape.css('.side-pages').css('a').last.children.text.to_i

    (1..total_pages).each do |i|
      scrape = scrape(i)
      scrape.css(MV_DIV_CLASS).css(MV_HREF_CLASS).each do |href|
        href['href']
      end
    end
  end

  def scrape(page)
    Nokogiri::HTML(HTTParty.get(MV_URL + 'u=' + MV_USER + '&pagina=' + page.to_s))
  end
end

generate_playlist = MvToYoutube.new
generate_playlist.run
