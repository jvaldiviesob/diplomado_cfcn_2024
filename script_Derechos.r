#### Eliminar graficos y variables del entorno Rstudio ####

graphics.off()
rm(list=ls())

#### Instalar paquetes e importar librerías ####

#install.packages("readxl")

library(readxl)

#### Definir ruta y nombre de archivo ####

dir_archivo <-"C:/Users/jvald/OneDrive/Ayudantía Diplomado/Ejercicio_Clases_2_y_3/EJERCICIO_Demanda_DDAA/Derechos/"
nombre_archivo <- "Derechos_Concedidos_XIV_Region_editado.xlsx"
dir_destino <-"C:/Users/jvald/OneDrive/Ayudantía Diplomado/Ejercicio_Clases_2_y_3/EJERCICIO_Demanda_DDAA/csv/"
  
#### Leer el archivo XLSX y convertirlo en un dataframe ####

dataframe <- read_excel(paste0(dir_archivo,nombre_archivo))

#### Elimina saltos de línea en los encabezados ####

colnames(dataframe ) <- gsub("\n", "", colnames(dataframe))
colnames(dataframe ) <- gsub("\r", "", colnames(dataframe))

#### Filtrar archivos con NA en "Huso" y "Caudal Anual Prom" ####

dataframe <- dataframe[!is.na(dataframe$Huso),]
dataframe <- dataframe[!is.na(dataframe$`Caudal Anual Prom`),]

# Para este ejemplo, se considerarán todos los derechos como derechos con Datum 1984 (no es cierto, simplificacion) #

#### Multiplicar caudal Anual Prom según unidades ####

# Cambiar coma por punto

dataframe$`Caudal Anual Prom` <- gsub(",", ".", dataframe$`Caudal Anual Prom`)

# Castear de string a float

dataframe$`Caudal Anual Prom` <- as.numeric(dataframe$`Caudal Anual Prom`)

# Transformar caudal anual promedio a m3/s. Unidades presentes: lt/día, Lt/h, Lt/min, Lt/s, m3/s 

for(i in 1:dim(dataframe)[1]) {
  if(dataframe$`Unidad de Caudal`[i]=='lt/día'){
    dataframe$`Caudal Anual Prom`[i] <-  dataframe$`Caudal Anual Prom`[i]*1.0/1000.0*1.0/(60.0*60.0*24.0)
  }
  if(dataframe$`Unidad de Caudal`[i]=='Lt/h'){
    dataframe$`Caudal Anual Prom`[i] <-  dataframe$`Caudal Anual Prom`[i]*1.0/1000.0*1.0/(60.0*60.0)
  }
  if(dataframe$`Unidad de Caudal`[i]=='Lt/min'){
    dataframe$`Caudal Anual Prom`[i] <-  dataframe$`Caudal Anual Prom`[i]*1.0/1000.0*1.0/60.0
  }
  if(dataframe$`Unidad de Caudal`[i]=='Lt/s'){
    dataframe$`Caudal Anual Prom`[i] <-  dataframe$`Caudal Anual Prom`[i]*1.0/1000.0
  }
  dataframe$`Unidad de Caudal`[i] <-'m3/s'
}

# Separar dataframes según Huso. POR SIMPLICIDAD, SE CONSIDERA DESPRECIABLE DIFERENCIA ENTRE DATUMS. 

dataframe_18 <- dataframe[dataframe$`Huso`=='18',]
dataframe_19 <- dataframe[dataframe$`Huso`=='19',]

#### Verificar el contenido del dataframe ####

# Configura las opciones para evitar la notación científica

options(scipen = 999)

write.csv(dataframe_18, paste0(dir_destino,"derechos_18.csv"),fileEncoding = "ISO-8859-1") 
write.csv(dataframe_19, paste0(dir_destino,"derechos_19.csv"),fileEncoding = "ISO-8859-1")

print(dataframe_18)
print(dataframe_19)
