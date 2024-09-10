# install.packages("dplyr")
# install.packages("haven")
# install.packages("readxl")

# Cargar las bibliotecas
library(dplyr)
library(haven)
library(readxl)

# setwd("Desktop/CC/estadistica_II")

### Para unificar por comunas necesitamos que en cada archivo estas estén en minúsculas y compartan una "rutificación"/clasificación por código
codigo_comuna <- read_excel("datos/Libro de codigos Base de datos comuna Casen 2022.xlsx")
codigo_comuna$comuna <- tolower(iconv(codigo_comuna$comuna, from = "UTF-8", to = "ASCII//TRANSLIT"))  # Primero se quitan todas las tildes y luego se pasa a minúsculas

# Importar el archivo .xls de la tasa de natalidad
tasa_de_natalidad <- read_excel("datos/tasa_de_natalidad.xls")
tasa_de_natalidad$comuna <- tolower(iconv(tasa_de_natalidad$comuna, from = "UTF-8", to = "ASCII//TRANSLIT")) # Mismo tratamiento para las tildes y mayúsculas
tasa_natalidad_comuna <- merge(tasa_de_natalidad, codigo_comuna, by = "comuna", all.x = TRUE)  # Fusionamos los códigos por comuna del casen a la tasa de natalidad

# Importar el archivo .xlsx (en específico la data por comuna)
censo <- read_excel("datos/censo2017.xlsx", sheet=2)
censo <- censo %>% select(-c(1:5, `Código Comuna`))                  # Eliminamos las columnas que no usaremos
censo <- censo %>% rename(comuna = `NOMBRE COMUNA`)                                  
censo$comuna <- tolower(iconv(censo$comuna, from = "UTF-8", to = "ASCII//TRANSLIT")) # Mismo tratamiento para caracteres nuevamente

# Importar la encuesta de caracterización socio-económica
casen <- read_dta("datos/Casen 2022.dta")

### Falta poner las variables que se van a estudiar
casen <- casen %>%
  select(id_vivienda, area, nse, estrato)