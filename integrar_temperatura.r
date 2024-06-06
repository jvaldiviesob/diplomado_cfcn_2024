#### Eliminar graficos y variables del entorno Rstudio ####

graphics.off()
rm(list=ls())

#### Instalar paquetes e importar librerías ####

#install.packages("raster")
#install.packages("ncdf4")
#install.packages("dplyr")

library("raster")
library("ncdf4")
library("dplyr")

#### Definir rutas, nombre de NetCDF, variable considerada y SRC ####

setwd("C:/Users/jvald/OneDrive/Ayudantía Diplomado/Ejercicio_Clases_2_y_3/EJERCICIO_Integracion_NetCDF_Temperatura/Resultados/") # Carpeta donde se imprimirán los Resultados.
dir_nc = "C:/Users/jvald/OneDrive/Ayudantía Diplomado/Ejercicio_Clases_2_y_3/EJERCICIO_Integracion_NetCDF_Temperatura/NetCDF/t2m/" # Carpeta donde se encuentran los archivos .nc.
dir_cuencas = "C:/Users/jvald/OneDrive/Ayudantía Diplomado/Ejercicio_Clases_2_y_3/EJERCICIO_Integracion_NetCDF_Temperatura/HRU_y_Bandas_de_Elevacion/" # Carpeta con los shape de la cuenca.

netcdf <- list.files(dir_nc) # Nombre archivo netcdf a procesar.
var <- "t2m" # Variable a extraer. Dependiendo del NetCDF, puede ser Baseflow, Runoff, pr, t2m, ff, rh, tmin, tmax.
SRC <- "+proj=longlat +datum=WGS84 +no_defs" # Asignar sistema de referencia de coordenadas de los archivos shapes, los que se entregan para el presente practico se encuentran en coordenadas geográficas WGS 84.

#### Abrir y explorar una archivo NetCDF ####

# Para abrir un archivo Netcdf y explorar sus metadatos se debe usar el comando nc_open().

nc <- nc_open(paste0(dir_nc,netcdf))

# Observar los metadatos del archivo NetCDF.

print(nc)

# Se puede explorar dentro del archivo NetCDF usando el símbolo “$”, donde podremos observar el nombre de la variable y sus unidades.

nc$var$t2m$name
nc$var$t2m$units

#Crear vector de tiempo.

time <- ncvar_get(nc, varid = "time")

#Crear vector con las fechas.

fecha <- seq(as.Date("1979-01-01"), length=(length(time)), by="day") # Puede cambiar entre completar de forma mensual o diaria.

#Para revisar los primeros 6 registros de este nuevo vector de fechas puede usar la función head()

head(fecha)

#Para revisar los últimos 6 registros de este nuevo vector de fechas puede usar la función tail()

tail(fecha)

#### Convertir de NetCDF a Ráster ####

# Para leer el archivo NetCDF en formato ráster se debe usar la función stack(). Se debe indicar
# también el nombre de la variable a ser leída, otros productos NetCDF pueden contener más de una 
# variable almacenada

nc_ras <- stack(paste0(dir_nc, netcdf), varname = var)

# Plot de verificación (puede necesitar modificaciones: reflejar o trasponer).

# De forma referencial se plotea uno de los días del evento de precipitación de marzo de 2015, el que generó aluviones en la zona norte de Chile

plot(nc_ras[[13232]])

# PAUSA....
# En caso de ser necesario reflejar o transponer se deben usar las funciones flip() y t() respectivamente.
# Con los datos del presente ejercicio no es necesario ejecutar estas operaciones, pero para conocer
# visualmente como modifican a los archivos ráster puede ejecutar las siguientes líneas de comando:
  # # La función t() transpone el ráster
  # t_nc_ras <- t(nc_ras)
  # plot(t_nc_ras[[1]])
  # # La función flip() refleja el ráster, requiere que se ingrese el eje de reflección, eje x o y
  # flip_nc_ras <- flip(nc_ras, direction = "y") # En el presente ejemplo se reflejará en el eje y
  # plot(flip_nc_ras[[1]])
# Continuando con el ejercicio...
  # Seleccionar archivos con extensión ".shp". Luego eliminar la extensión de los strings.

shapes <- list.files(path = dir_cuencas, pattern = glob2rx("*.shp"))
shapes <- gsub(".shp", "", shapes)

#### Acotar NetCDF a .shp de HRU, desagregar pixeles y calcular promedio por paso de tiempo. Exportar resultados. ####

for (a in 1:length(shapes)){
  
  # Cargar .shp.
  
  shp.shp <- shapefile(x=paste(paste(dir_cuencas , shapes[a] , sep="/"), "shp" ,sep="."))
  projection(shp.shp) <- SRC # Indicar el sistema de referencia de coordenadas del archivo shp.shp
  plot(shp.shp, add = TRUE) 
  
    # Definir nombre y extensión geográfica del .shp.
  
  nombre_shape <- shapes[a]
  ext <- extent(shp.shp)
  ext@xmin <- ext@xmin - 0.05
  ext@xmax <- ext@xmax + 0.05
  ext@ymin <- ext@ymin - 0.05
  ext@ymax <- ext@ymax + 0.05
  
  # Descarte de pixeles fuera de la HRU. Plot de verificación.
  
  nc_ras_crop <- crop(nc_ras, ext)
  plot(nc_ras_crop[[13299]])
  plot(shp.shp, add = T)
  
  # Desagregar para disminuir el tamaño de pixeles y ajustar el ráster de mejor forma al contorno de la HRU.
  
  nc_ras_crop <- disaggregate(nc_ras_crop, fact = 3, method = "bilinear" ) # Puede modificar el valor de fact, 
  # mientras más grande sea este valor, de menor tamaño serán los pixeles luego del resampleo.
  
  # Puede probar distintos valores de fact al momento de realizar el resampleo, observe en "plots" el ajuste de los pixeles sobre el archivo shape.
  
  # A menor tamaño de pixel el ajuste es mejor, pero es necesario considerar mayores tiempos de cómputo.
  
  plot(nc_ras_crop[[13299]])
  plot(shp.shp, add = T)
  
  # Aplicar máscara (.shp de HRU). Plot de verificación.
  
  nc_ras_crop_mask <- mask(nc_ras_crop, shp.shp)
  plot(nc_ras_crop_mask[[13299]])
  plot(shp.shp, add = T)
  
  # Obtener el promedio para cada paso de tiempo.
  
  promedio_valor <- as.numeric(cellStats(nc_ras_crop_mask, 'mean',na.rm=T))
  tabla<-data.frame(fecha,promedio_valor)
  
  # Escribir archivo csv con los promedios por unidad de tiempo de la variable en la HRU.
  
  write.csv(tabla, file = paste0(nombre_shape, "_", var, ".csv", sep=""), row.names = F)
}
