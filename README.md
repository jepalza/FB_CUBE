# FB_CUBE
Freebasic 3D Engine CUBE


No es un motor gráfico 3D verdadero, ya que no permite (por ahora), alterar su funcionamiento, como incluir entidades, eliminar enemigos, etc, pero sirve como portal de entrada o como pruebas sobre el motor 3D llamado "CUBE".

Se necesitan los ficheros originales que se pueden descargar desde:
https://sourceforge.net/projects/cube/files/cube/2005_08_22/

Instalamos usando el fichero "cube_2005_08_22_win32.exe" y entonces copiamos en el directorio "BIN" los dos ficheros CUBE.DLL y FBCUBE.EXE.

Creamos un BAT en el directorio principal, donde reside el actual "CUBE.BAT" , con un contenido como esto:
  BIN\FBCUBE xxxx 

(donde xxxx es el nombre del mapa que queremos cargar, si lo dejamos vacio, entra el mapa por defecto asginado en el propio motor como "METL3")
Y ejecutamos el BAT

Acepta los mismos comandos que el CUBE original, pero he cambiado el orden del comando "-t" que hace "FULLSCREEN", para que por defecto entre siempre en modo "WINDOWED"
Si queremos "FULLSCREEN" añadimos "-t"
Para resoluciones, usamos "-w1024 -h768" con nuestra resolución.

Detalles:
La DLL es exactamente igual al 99% que el propio motor "CUBE.EXE", pero compilado en MINGW (gcc de windows) y añadiendo unos pocos comandos para compilar como DLL en lugar de como EXE.
EL Código FREEBASIC es casi identico al módulo "MAIN()" del fichero principal de los fuentes originales, se puede comparar para ver sus similitudes.

![Imagen fbcube1.jpg](https://github.com/jepalza/FB_CUBE/blob/main/fbcube1.jpg)
