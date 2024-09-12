# install.packages("dplyr")
# install.packages("haven")
# install.packages("readxl")
# install.packages("ggplot2")

# Cargar las bibliotecas
library(dplyr)
library(haven)
library(ggplot2)
library(readxl)

# setwd("Desktop/CC/estadistica_II")

### Para unificar por comunas necesitamos que en cada archivo estas estén en minúsculas y compartan una "rutificación"/clasificación por código
codigo_comuna <- read_excel("datos/Libro de codigos Base de datos comuna Casen 2022.xlsx")
codigo_comuna$comuna <- tolower(iconv(codigo_comuna$comuna, from = "UTF-8", to = "ASCII//TRANSLIT"))                       # Primero se quitan todas las tildes y luego se pasa a minúsculas

# Importar el archivo .xls de la tasa de natalidad
origin_tasa_de_natalidad <- read_excel("datos/tasa_de_natalidad.xls")
origin_tasa_de_natalidad$comuna <- tolower(iconv(origin_tasa_de_natalidad$comuna, from = "UTF-8", to = "ASCII//TRANSLIT")) # Mismo tratamiento para las tildes y mayúsculas
tasa_de_natalidad_comuna <- merge(origin_tasa_de_natalidad, codigo_comuna, by = "comuna", all.x = TRUE)                    # Fusionamos los códigos por comuna del casen a la tasa de natalidad
tasa_de_natalidad_comuna <- tasa_de_natalidad_comuna[!is.na(tasa_de_natalidad_comuna$código), ]
tasa_de_natalidad_comuna$tasa <- as.numeric(as.character(tasa_de_natalidad_comuna$tasa))
tasa_de_natalidad_comuna$tasa <- round(tasa_de_natalidad_comuna$tasa, 1)                                                   # Redondeamos al segundo decimal


# Importar el archivo .xlsx (en específico la data por comuna)
origin_censo <- read_excel("datos/censo2017.xlsx", sheet=2)
censo <- origin_censo %>% select(-c(3:5, 'ORDEN', `Código Comuna`))                                                        # Eliminamos las columnas que no usaremos
censo <- censo %>% rename(comuna = `NOMBRE COMUNA`)   
censo <- censo %>% rename(region = `NOMBRE REGIÓN`)   
censo$region <- tolower(iconv(censo$region, from = "UTF-8", to = "ASCII//TRANSLIT"))                                       # Mismo tratamiento para caracteres nuevamente
censo$comuna <- tolower(iconv(censo$comuna, from = "UTF-8", to = "ASCII//TRANSLIT"))
censo <- merge(censo, codigo_comuna, by = "comuna", all.x = TRUE)                                                          # Fusionar los códigos por comuna del casen al censo
censo <- censo[!is.na(censo$código), ]                                                                                     # Descartar provincias y datos nivel país que provienen del censo
censo <- censo %>% filter(Edad == "Total Comunal")                                                                         # Descartar el resto de edades
censo <- censo %>% select(-"Edad")

# Importar la encuesta de caracterización socio-económica
origin_casen <- read_dta("datos/Casen 2022.dta")
casen <- origin_casen %>%
  select(estrato, area, educ, y1, y2_hrs, y3a, ypch, ymes, pobreza, ytotcorh, ytrabajocorh, pobreza_multi_4d)

casen <- casen %>%
  mutate(código = as.integer(substr(estrato, 1, nchar(estrato) - 2))) %>%                                                  # Crear la variable código
  select(-estrato)

# SUPUESTO: reemplazaremos los datos -88 por la mediana de la variable respectiva (sin considerar los NA)
reemplazo_por_comuna <- function(df, val=-88) {
  df %>%
    group_by(código) %>%
    mutate(across(where(is.numeric), ~ replace(., . == val, median(., na.rm = TRUE)))) %>%
    ungroup()
}

casen <- reemplazo_por_comuna(casen)
casen <- reemplazo_por_comuna(casen, -88.000)

# No podemos trabajar con individuos como tal por lo que es necesario hacer alguna transformación para colapsar la información por comuna
casen <- casen %>%
  group_by(código) %>%
  summarise(across(c(educ, y1, y2_hrs, y3a, ypch, ymes, pobreza, ytotcorh, ytrabajocorh, pobreza_multi_4d), mean, na.rm = TRUE))

# Primero fusionamos los data frames de tasa y censo por comuna Y código, luego incorporamos estos datos a un solo data frame en conjunto con las variables del casen
df <- merge(censo, tasa_de_natalidad_comuna, by = c("comuna", "código"), all.x = TRUE)
df <- merge(df, casen, by = "código", all.x = TRUE)

df_contraste <- df %>% filter(region %in% c("metropolitana de santiago", "la araucania"))
# df_araucanaia <- df %>% filter(region == "la araucania")

p1 <- ggplot(df, aes(x = `educ`, y = `tasa`)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "title", x = "x", y = "Tasa de natalidad")
print(p1)

# Gráfico de líneas comparativo para las dos regiones filtradas
ggplot(df_contraste, aes(x = ytrabajocorh, y = tasa, color = region, group = region)) +
  geom_line(linewidth = 1) +
  geom_point() +
  labs(title = "Comparación de *** entre la región Metropolitana y La Araucanía",
       x = "x", y = "Tasa de natalidad") +
  theme_minimal()

