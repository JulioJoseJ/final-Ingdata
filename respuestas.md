# Respuestas

## 1. ¿Por qué se pudo consultar el tercer día sin registrar una partición nueva?
Ese dia estaba dentro del rango desdeel principio. Athena tambien buscaba en fecha=2026-10-03/ pero la carpeta estaba vacia por eso salieron 
doce registros. cuando se sube un archivo la busqueda encontro mas datos. La regla no cambio 


## 2. Si se sube un archivo del 4 de octubre con la configuración actual, ¿qué pasaría y qué habría que cambiar?
El dia cuatro esta fuera del rango por eso athena no lo busca en fecha=2026-10-04/. Con proyecciones activas athena ignora particiones hechas a mano por eso alter table add partition no sirve.
La proyeccion no crea datos ni garantiza existencia de estos. si una fecha no esta en la regla sus datos no se ven

