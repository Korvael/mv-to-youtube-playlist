# Mediavida to YouTube playlist
Genera una playlist de YouTube con todos los vídeos del usuario indicado a partir de sus contribuciones en el hilo "[¿Qué canción estás escuchando ahora mismo?](https://www.mediavida.com/foro/feda/cancion-estas-escuchando-ahora-mismo-329209)".
* Añade los vídeos a una playlist ya existente o crea una nueva de forma automática en el proceso
* Se comprueba la disponibilidad de los vídeos antes de insertarlos en la playlist
* Las siguientes ejecuciones añadirán únicamente los vídeos que no estén ya presentes en la playlist

## Requisitos
* [Ruby 2.5.8](https://www.ruby-lang.org/en/downloads/)
* Con Ruby 2.5.8 ya en el sistema, instala la gema [bundler](https://bundler.io/) con `gem install bundler`
* Instala todas las gemas requeridas por el script ejecutando `bundle install` en el directorio raíz del proyecto

## Ejecutar el script
En el directorio raíz del proyecto, ejecuta el comando `ruby lib/mv_to_youtube.rb`.

Si es la primera vez que se lanza el script, se solicitarán a través de la consola varios datos necesarios para el correcto funcionamiento del mismo:
* Nombre del usuario de Mediavida
* Nombre de la playlist de YouTube
* Nivel de la privacidad de la playlist (en caso de que sea necesario crearla)

Además, tendrás que otorgar al script acceso a tu cuenta Google para que pueda gestionar la playlist de YouTube siguiendo la URL que se te indicará.

Una vez insertados los datos, se guardarán en el fichero **settings.yml** para futuras ejecuciones, situado en el directorio raíz del proyecto. Si necesitas modificar algún dato, puedes editar este fichero o eliminarlo, lo que provocará que se soliciten de nuevo los datos requeridos en la siguiente ejecución del script.

## TODO
* Ampliar control de excepciones
* Controlar y sanear las cadenas que el usuario puede introducir a través de la consola
* Añadir test unitarios

## Licencia
MIT License.
