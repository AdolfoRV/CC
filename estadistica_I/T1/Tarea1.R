# Tarea 1: Adolfo Rojas

#install.packages("ggplot2")
#install.packages("dplyr")
#install.packages("tidyr")
#install.packages("haven")
#install.packages("DescTools")

library(haven)      # Para importar y exportar datos de archivos SPSS, SAS y Stata
library(ggplot2)    # Generar gráficos
library(dplyr)      # Manipular datos
library(DescTools)
library(tidyr)


options(scipen = 999)
setwd("C:/Users/adolf/Desktop/CC/Progra/Estadística/Problem_Set_1_-_Data/EOD_diciembre")

## Sección 2.1
# Item 1

dic2022 <- read_dta("Diciembre2022.dta")

# Item 2

p_activa_dic2022 <- dic2022[(dic2022$edad >= 15 & dic2022$edad <= 65),]

histograma1 <- ggplot(p_activa_dic2022, aes(x = ingtrab)) +
  geom_histogram(binwidth = 5000, fill = "blue", color = "black") +
  labs(title = "Distribución de ingresos del trabajo para la población activa",
       x = "Ingresos población activa", y = "Frecuencia") +
  annotate("text", x = Inf, y = Inf, label = paste("Observaciones incluidas:", nrow(p_activa_dic2022)), vjust = 1, hjust = 1, color = "red")

histograma1
summary(p_activa_dic2022$ingtrab)

# Ítem 3

# Limpiar datos para la población activa
datos_limpios <- dic2022[dic2022$edad >= 15 & dic2022$edad <= 65 & dic2022$ingtrab != 99999999, ]

# Estadísticos básicos
estadisticas <- data.frame(
  Observaciones = nrow(datos_limpios),
  Promedio = mean(datos_limpios$ingtrab, na.rm = TRUE),
  Desviacion_Estandar = sd(datos_limpios$ingtrab, na.rm = TRUE),
  Minimo = min(datos_limpios$ingtrab, na.rm = TRUE),
  Maximo = max(datos_limpios$ingtrab, na.rm = TRUE),
  Mediana = median(datos_limpios$ingtrab, na.rm = TRUE),
  Percentil_1 = quantile(datos_limpios$ingtrab, 0.01, na.rm = TRUE),
  Percentil_99 = quantile(datos_limpios$ingtrab, 0.99, na.rm = TRUE)
)

# Tabla de estadísticas básicas
print(estadisticas)

# Su histograma
histograma2 <- ggplot(datos_limpios, aes(x = ingtrab)) +
  geom_histogram(binwidth = 5000, fill = "blue", color = "black") +
  labs(title = "Distribución de ingresos registrados del trabajo para la población activa",
       x = "Ingresos población activa", y = "Frecuencia") +
  annotate("text", x = Inf, y = Inf, label = paste("Observaciones incluidas:", nrow(datos_limpios)), vjust = 1, hjust = 1, color = "red")

histograma2

# Ítem 4

# Calcular la media y la desviación estándar de los ingresos del trabajo
media_ingresos <- mean(datos_limpios$ingtrab, na.rm = TRUE)
desviacion_estandar_ingresos <- sd(datos_limpios$ingtrab, na.rm = TRUE)
mediana_ingresos <- median(datos_limpios$ingtrab, na.rm = TRUE)

limite_maximo_y <- 0.000025

# Generar el histograma
histograma3 <- ggplot(datos_limpios, aes(x = ingtrab)) +
  geom_histogram(binwidth = 5000, fill = "blue", color = "black", aes(y = ..density..)) +  # establecer aes(y = ..density..) para obtener densidad
  labs(title = "Distribución de ingresos del trabajo para la población activa",
       x = "Ingresos población activa", y = "Densidad") +
  geom_density(aes(y = ..density..), color = "red", size = 1.5, linetype = "dashed", alpha = 0.8) +  # ajustar alpha para hacer la curva menos transparente
  coord_cartesian(ylim = c(0, limite_maximo_y)) +  # establecer límite máximo en el eje y
  annotate("text", x = Inf, y = Inf, label = paste("Observaciones incluidas:", nrow(datos_limpios)), vjust = 1, hjust = 1, color = "red")

print(histograma3)

# Gráfico Q-Q y prueba de Shapiro-Wilk
qqnorm(datos_limpios$ingtrab)
qqline(datos_limpios$ingtrab)
# extra: shapiro.test(datos_limpios$ingtrab)

# Item 5a)

# Filtramos los jefes de hogares que sí saben cuánto ganan
datos_filtrados <- dic2022[dic2022$pcoh == 1 &  dic2022$ingfam !=99999999, ]

# Calcular los quintiles y deciles del ingreso familiar
quintiles <- quantile(datos_filtrados$ingfam, probs = seq(0, 1, by = 0.2), na.rm = TRUE)
View(quintiles)
deciles <- quantile(datos_filtrados$ingfam, probs = seq(0, 1, by = 0.1), na.rm = TRUE)
View(deciles)

# Crear la variable quintil en los datos filtrados
datos_filtrados$quintil <- cut(datos_filtrados$ingfam, breaks = quintiles, labels = FALSE)

# Calcular el porcentaje de hogares con deuda educacional por quintil
porcentaje_deuda_quintil <- aggregate(f5i ~ quintil, data = datos_filtrados, FUN = function(x) mean(x == 1, na.rm = TRUE) * 100)

# Generar el gráfico de barras
deudasbarrasq <- ggplot(porcentaje_deuda_quintil, aes(x = quintil, y = f5i)) +
  geom_bar(stat = "identity", fill = "#6E8B3D") +
  labs(title = "Porcentaje de hogares con deuda educacional por quintil",
       x = "Quintil",
       y = "Porcentaje endeudados (%)") +
  annotate("text", x = Inf, y = Inf, label = paste("Observaciones incluidas:", nrow(porcentaje_deuda_quintil)), vjust = 1, hjust = 1, color = "red")

# Mostrar el gráfico
print(deudasbarrasq)

# Item 5c)

# Crear la variable decil en los datos filtrados
datos_filtrados$decil <- cut(datos_filtrados$ingfam, breaks = deciles, labels = FALSE)

# Calcular el porcentaje de hogares con deuda educacional por decil
porcentaje_deuda_por_decil <- aggregate(f5i ~ decil, data = datos_filtrados, FUN = function(x) mean(x == 1, na.rm = TRUE) * 100)

# Generar el gráfico de barras
deudasbarrasd <- ggplot(porcentaje_deuda_por_decil, aes(x = decil, y = f5i)) +
  geom_bar(stat = "identity", fill = "#556B2F") +
  labs(title = "Porcentaje de hogares con deuda educacional por decil",
       x = "Decil",
       y = "Porcentaje endeudados (%)") +
  annotate("text", x = Inf, y = Inf, label = paste("Observaciones incluidas:", nrow(porcentaje_deuda_por_decil)), vjust = 1, hjust = 1, color = "red")

# Mostrar el gráfico
print(deudasbarrasd)

# Ítem 5d)

# Crear variable dicotómica quintil_5
datos_filtrados$quintil_5 <- ifelse(datos_filtrados$ingfam > quintiles[5] & datos_filtrados$ingfam <= quintiles[6], 1, 0)

# Dividir los datos en dos grupos
grupo0 <- subset(datos_filtrados, datos_filtrados$quintil_5 == 0)
grupo1 <- subset(datos_filtrados, datos_filtrados$quintil_5 == 1)

# Realizar el test t
resultado_test <- t.test(grupo0$f5i, grupo1$f5i)

# Realizar el test t
resultado_test <- t.test(grupo0$f5i, grupo1$f5i)

# Resultado del test t
print(resultado_test)

# Calcular los promedios con eliminación de NA
promedio_x <- mean(grupo0$f5i, na.rm = TRUE)
promedio_y <- mean(grupo1$f5i, na.rm = TRUE)

# Extraer el intervalo de confianza del resultado del test
intervalo_confianza <- resultado_test$conf.int

# Crear tabla con estadísticos relevantes
estadistico <- c("Promedio x", "Promedio y", "IC inferior", "IC superior", "t", "Grados de libertad", "p-value")
valor <- c(promedio_x, promedio_y, intervalo_confianza[1], intervalo_confianza[2], resultado_test$statistic, resultado_test$parameter, resultado_test$p.value)
tabla_resultados <- data.frame(Estadístico = estadistico, Valor = valor)

# Tabla de resultados
print(tabla_resultados)
View(tabla_resultados)

##Sección 2.2
setwd("C:/Users/adolf/Desktop/CC/Progra/Estadística/Problem_Set_1_-_Data/mix_encuestas")
# Ítem 1

# Crear listas para almacenar los datos de cada trimestre
trimestre1 <- vector(mode = "list", length = 26)
trimestre2 <- vector(mode = "list", length = 26)
trimestre3 <- vector(mode = "list", length = 26)
trimestre4 <- vector(mode = "list", length = 26)

# Loop para cargar los datos de cada trimestre desde 1997 hasta 2022 (codigo puede ser optimizable)
for (x in 1997:2022){
  # Cargar datos de cada trimestre
  marzo <- read_dta(paste0("Marzo", x, ".dta"))
  junio <- read_dta(paste0("Junio", x, ".dta"))
  septiembre <- read_dta(paste0("Septiembre", x, ".dta"))
  diciembre <- read_dta(paste0("Diciembre", x, ".dta"))
  
  # Asignar trimestre y año a los datos y almacenarlos en las listas correspondientes
  trimestre1[[x-1996]] <- marzo
  trimestre1[[x-1996]]$trimestre <- 1
  trimestre1[[x-1996]]$año <- x
  
  trimestre2[[x-1996]] <- junio
  trimestre2[[x-1996]]$trimestre <- 2
  trimestre2[[x-1996]]$año <- x
  
  trimestre3[[x-1996]] <- septiembre
  trimestre3[[x-1996]]$trimestre <- 3
  trimestre3[[x-1996]]$año <- x
  
  trimestre4[[x-1996]] <- diciembre
  trimestre4[[x-1996]]$trimestre <- 4
  trimestre4[[x-1996]]$año <- x
}

# Combinar los datos de cada trimestre en un solo objeto
datos_agrupados <- c(trimestre1, trimestre2, trimestre3, trimestre4)
# Añadir las variables de identificación de filas faltantes y seleccionar las variables especificadas
for (i in 1:length(datos_agrupados)){
  colf <- setdiff(c("año", "trimestre", "ident", "orden", "numper", "pcoh", "sexo", "edad", "horas", "ingfam", "ingtrab", "arriendo", "arrienm", "sitocup1", "sitocup2"), names(datos_agrupados[[i]]))
  for (columna in colf) {
    datos_agrupados[[i]][[columna]] <- NA
  }
  datos_agrupados[[i]] <- datos_agrupados[[i]][, c("año", "trimestre", "ident", "orden", "numper", "pcoh", "sexo", "edad", "horas", "ingfam", "ingtrab", "arriendo", "arrienm", "sitocup1", "sitocup2")]
}
# Combinar todos los datos en un solo dataframe
datos_combinados <- do.call(bind_rows, datos_agrupados)

# Ítem 2

# Realizar el subset para el año 1997 y 2017, con horas menores o iguales a 168
horas1997 <- subset(datos_combinados, año == 1997 & horas <= 168)
horas2017 <- subset(datos_combinados, año == 2017 & horas <= 168)

# Realizar el test t de medias
resultado_test <- t.test(x = horas1997$horas, y = horas2017$horas)

# Definir una función para formatear el valor de p
formato_valor_p <- function(p_value) {
  ifelse(p_value < 0.00000000000000022, "< 0.00000000000000022", format(p_value, scientific = FALSE))
}

# Formatear el valor de p
valor_p <- formato_valor_p(resultado_test$p.value)

# Formatear el intervalo de confianza
intervalo_confianza_inf <- format(resultado_test$conf.int[1], scientific = FALSE)
intervalo_confianza_sup <- format(resultado_test$conf.int[2], scientific = FALSE)

# Crear un dataframe con los estadísticos relevantes del test
tablahoras <- data.frame(
  Variables = c("Media de x", "Media de y", "Intervalo de confianza inferior", "Intervalo de confianza superior", "t", "df", "valor-p"),
  Valores = c(mean(horas1997$horas), mean(horas2017$horas), intervalo_confianza_inf, intervalo_confianza_sup, resultado_test$statistic, resultado_test$parameter, valor_p)
)

# Mostrar la tabla
print(tablahoras)
View(tablahoras)


# Ítem 3

# Filtrar observaciones con más de 100 horas trabajadas
datos_filtrados <- subset(datos_combinados, horas <= 100)

# Obtener las medias y los intervalos de confianza
medias_intervalos <- datos_filtrados %>%
  mutate(trimestre_id = ifelse(trimestre == "MARZO", 0, ifelse(trimestre == "JUNIO", 1, ifelse(trimestre == "SEPTIEMBRE", 2, 3)))) %>%
  group_by(año, trimestre_id) %>%
  summarise(media = mean(horas),
            lower = mean(horas) - qt(0.975, length(horas) - 1) * sd(horas) / sqrt(length(horas)),
            upper = mean(horas) + qt(0.975, length(horas) - 1) * sd(horas) / sqrt(length(horas)),
            n = n())

# Definir colores para cada trimestre
colores_trimestres <- c("black", "green", "red", "purple")

# Obtener el total de observaciones
total_observaciones <- sum(medias_intervalos$n)

# Graficar las medias con intervalos de confianza
ggplot(medias_intervalos, aes(x = año, y = media, color = factor(trimestre_id))) +
  geom_line() +
  geom_point() +
  geom_errorbar(aes(ymin = lower, ymax = upper), width = 0.2) +
  geom_text(x = Inf, y = Inf, label = paste("Observaciones incluidas:", total_observaciones), hjust = 1, vjust = 1, size = 3, color = "red") +
  labs(x = "Año", y = "Media de horas trabajadas", title = "Medias de horas trabajadas por trimestre con intervalos de confianza") +
  scale_color_manual(values = colores_trimestres) +
  theme_minimal() +
  theme(legend.position = "none")

# Ítem 4

# Filtrar observaciones por género
hombres <- datos_filtrados %>% filter(sexo == 1)
mujeres <- datos_filtrados %>% filter(sexo == 2)

# Calcular medias e intervalos de confianza para hombres
medias_intervalos_hombres <- hombres %>%
  group_by(año, trimestre) %>%
  summarise(media = mean(horas),
            lower = mean(horas) - qt(0.975, n() - 1) * sd(horas) / sqrt(n()),
            upper = mean(horas) + qt(0.975, n() - 1) * sd(horas) / sqrt(n()))

# Calcular medias e intervalos de confianza para mujeres
medias_intervalos_mujeres <- mujeres %>%
  group_by(año, trimestre) %>%
  summarise(media = mean(horas),
            lower = mean(horas) - qt(0.975, n() - 1) * sd(horas) / sqrt(n()),
            upper = mean(horas) + qt(0.975, n() - 1) * sd(horas) / sqrt(n()))

# Obtener el número total de observaciones para hombres y mujeres
total_obs_hombres <- nrow(hombres)
total_obs_mujeres <- nrow(mujeres)

# Graficar las medias con intervalos de confianza para hombres y mujeres
ggplot() +
  geom_point(data = medias_intervalos_hombres, aes(x = año, y = media, color = "Hombres"), size = 3) +
  geom_errorbar(data = medias_intervalos_hombres, aes(x = año, ymin = lower, ymax = upper, color = "Hombres"), width = 0.2) +
  geom_point(data = medias_intervalos_mujeres, aes(x = año, y = media, color = "Mujeres"), size = 3) +
  geom_errorbar(data = medias_intervalos_mujeres, aes(x = año, ymin = lower, ymax = upper, color = "Mujeres"), width = 0.2) +
  geom_text(x = Inf, y = Inf, label = paste("Observaciones incluidas:", total_obs_hombres + total_obs_mujeres), hjust = 1, vjust = 1, size = 3, color = "red") +
  geom_text(x = 1997, y = 100, label = paste("Hombres:", total_obs_hombres), size = 3, color = "blue") +
  geom_text(x = 1997, y = 90, label = paste("Mujeres:", total_obs_mujeres), size = 3, color = "red") +
  labs(x = "Año", y = "Media de horas trabajadas", color = "Género") +
  scale_color_manual(values = c("Hombres" = "green", "Mujeres" = "black")) +
  theme_minimal()

#He intentado reiteradas veces y no me deja mostrar las observaciones en pantalla, sorry :(

# Ítem 5

# Filtrar los datos para pcoh = 3
nuevodatos <- datos_filtrados %>%
  filter(pcoh == 3, !is.na(edad), !is.na(horas), horas <= 100) %>%
  mutate(año_trimestre = paste(año, trimestre, sep = "-"))

# Calcular la media y los intervalos de confianza para la edad y las horas trabajadas semanales
edaddif <- nuevodatos %>%
  group_by(año_trimestre) %>%
  summarize(promedio_edad = mean(edad),
            limite_inferior_edad = mean(edad) - qt(0.975, length(edad) - 1) * sd(edad) / sqrt(length(edad)),
            limite_superior_edad = mean(edad) + qt(0.975, length(edad) - 1) * sd(edad) / sqrt(length(edad)))

horasdif <- nuevodatos %>%
  group_by(año_trimestre) %>%
  summarize(promedio_horas = mean(horas),
            limite_inferior_horas = mean(horas) - qt(0.975, length(horas) - 1) * sd(horas) / sqrt(length(horas)),
            limite_superior_horas = mean(horas) + qt(0.975, length(horas) - 1) * sd(horas) / sqrt(length(horas)))

# Crear un nuevo dataframe agrupado
react <- merge(edaddif, horasdif, by = "año_trimestre")

obsne <- nrow(nuevodatos)

# Gráfico de promedio de edad y horas trabajadas semanalmente por año-trimestre
edadhoras <- 
  ggplot(react, aes(x = año_trimestre)) +
  geom_line(aes(y = promedio_edad, color = "Edad"), linetype = "solid", size = 1.2) +
  geom_point(aes(y = promedio_edad, color = "Edad"), size = 3) +
  geom_errorbar(aes(y = promedio_edad, ymin = limite_inferior_edad, ymax = limite_superior_edad, color = "Edad"), width = 0.2) +
  geom_line(aes(y = promedio_horas, color = "Horas"), linetype = "dashed", size = 1.2) +
  geom_point(aes(y = promedio_horas, color = "Horas"), size = 3) +
  geom_errorbar(aes(y = promedio_horas, ymin = limite_inferior_horas, ymax = limite_superior_horas, color = "Horas"), width = 0.2) +
  annotate("text", x = Inf, y = Inf, label = paste("Observaciones incluidas:", obsne), hjust = 1, vjust = 1, size = 3, color = "red") +
  labs(x = "Año-Trimestre", y = "Promedio", title = "Promedio de edad y horas trabajadas semanalmente por año-trimestre") +
  scale_color_manual(values = c(Edad = "red", Horas = "black"), labels = c("Edad", "Horas")) +
  theme_minimal() +
  theme(legend.position = "right", axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))

print(edadhoras)