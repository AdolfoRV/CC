# Tarea 2: Adolfo Rojas

# Instalar paquetes (solo si no están instalados)
# install.packages("ggplot2")
# install.packages("dplyr")
# install.packages("tidyr")
# install.packages("haven")
# install.packages("DescTools")
# install.packages("stargazer")
# install.packages("broom")

library(haven)      # Para importar y exportar datos de archivos SPSS, SAS y Stata
library(stargazer)
library(ggplot2)    # Generar gráficos
library(dplyr)      # Manipular datos
library(DescTools)  # Herramientas estadísticas
library(tidyr)      # Transformación y limpieza de datos
library(broom)      # Convertir modelos en tidy data frames


options(scipen = 999)
setwd("C:/Users/adolf/Desktop/CC/Progra/Estadística")

fab <- read_dta("T2_ENIA.dta")
View(fab)

## Estadística Descriptiva ##

# Parte 1 

# Contar la cantidad de fab por año y crear un data frame
fabAno <- table(fab$year)
fabAno_df <- data.frame(year = as.integer(names(fabAno)),
                                  cantidad = as.integer(fabAno))

# Obtener la cantidad total de observaciones
total_observaciones <- sum(fabAno_df$cantidad)

# Graficar
ggplot(fabAno_df, aes(x = year, y = cantidad)) +
  geom_bar(stat = "identity", fill = "#4F7942") +
  labs(title = "Cantidad de fab activas por año",
       x = "Año",
       y = "Cantidad de fab") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)
  ) +
  scale_x_continuous(breaks = seq(1979, 1998, by = 1)) +  
  scale_y_continuous(breaks = seq(0, max(fabAno_df$cantidad), by = 500)) +  # Intervalos de 500 en el eje Y
  geom_text(aes(x = 1998, y = max(fabAno_df$cantidad)), 
            label = paste("Número total de fab observadas:", total_observaciones), 
            color = "black", hjust = 1, vjust = 1)

# Parte 2  

# Calcular la cantidad de años distintos para cada planta entre 1979 y 1998
fab_por_id <- fab %>%
  group_by(ID) %>%
  summarise(years_active = n_distinct(year[year >= 1979 & year <= 1998]))

# Generar la variable dicotómica siempre activa
fab_por_id <- fab_por_id %>%
  mutate(siempre_activa = ifelse(years_active == 20, 1, 0))  # 20 años entre 1979 y 1998

# Contar cuántas fab tienen toda la información disponible
fab_con_toda_informacion <- sum(fab_por_id$siempre_activa)

# Imprimir el resultado
cat("Cantidad de fabricas activas durante 1979 - 1998:", fab_con_toda_informacion, "\n")

# Parte 3 

# Identificar el último año con fab disponibles para cada planta
ultimoAno_por_id <- fab %>%
  group_by(ID) %>%
  summarise(year_ultimo = max(year))

# Fusionar con el dataset original para obtener la variable de salida
fab_con_salida <- merge(fab, ultimoAno_por_id, by = "ID")

# Generar la variable dicotómica salida
fab_con_salida <- fab_con_salida %>%
  mutate(salida = ifelse(year == year_ultimo, 1, 0))

# Contar cuántas fab cierran cada año
fab_cerradas_por_anio <- fab_con_salida %>%
  group_by(year) %>%
  summarise(salida = sum(salida))

# Imprimir el resultado
print(fab_cerradas_por_anio)

# Parte 4  

# Función para calcular la tasa de salida para un año dado
tasa_salida <- function(data) {
  salida_total <- sum(data)
  total_fab <- length(data)
  if(total_fab == 0) {
    return(0)  # Evitar división por cero
  } else {
    return(salida_total / total_fab)
  }
}

# Calcular la tasa de salida para cada año
tasa_salida_por_anio <- fab_con_salida %>%
  group_by(year) %>%
  summarise(tasa_salida = tasa_salida(salida))

# Graficar la evolución de la tasa de salida
ggplot(tasa_salida_por_anio, aes(x = year, y = tasa_salida)) +
  geom_line(color = "#4F7942") +
  labs(title = "Evolución de la tasa de salida",
       x = "Año",
       y = "Tasa de salida") +
  scale_x_continuous(breaks = seq(1979, 1998, by = 1)) +  # Mostrar todos los años en el eje X
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),  # Centrar el título
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)  # Orientación vertical del eje X
  )

# Parte 5 

# Filtrar los fab para los años 1979 y 1997
data_1979 <- fab %>% filter(year == 1979)
data_1997 <- fab %>% filter(year == 1997)

# Crear gráficos de histogramas superpuestos para cada medida de productividad
# tfp_ls
hist_tfp_ls <- ggplot() +
  geom_histogram(data = data_1979, aes(x = tfp_ls, fill = "1979"), 
                 bins = 30, alpha = 0.5, position = 'identity') +
  geom_histogram(data = data_1997, aes(x = tfp_ls, fill = "1997"), 
                 bins = 30, alpha = 0.5, position = 'identity') +
  scale_fill_manual(values = c("1979" = "#254336", "1997" = "#B7B597"), name = "Año") +
  labs(title = "Histograma productividad tfp_ls en 1979 y 1997", x = "tfp_ls", y = "Frecuencia") +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_x_continuous(breaks = scales::pretty_breaks(n = 10)) +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10))

# tfp_fe
hist_tfp_fe <- ggplot() +
  geom_histogram(data = data_1979, aes(x = tfp_fe, fill = "1979"), 
                 bins = 30, alpha = 0.5, position = 'identity') +
  geom_histogram(data = data_1997, aes(x = tfp_fe, fill = "1997"), 
                 bins = 30, alpha = 0.5, position = 'identity') +
  scale_fill_manual(values = c("1979" = "#254336", "1997" = "#B7B597"), name = "Año") +
  labs(title = "Histograma productividad tfp_fe en 1979 y 1997", x = "tfp_fe", y = "Frecuencia") +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_x_continuous(breaks = scales::pretty_breaks(n = 10)) +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10))

# tfp_lp
hist_tfp_lp <- ggplot() +
  geom_histogram(data = data_1979, aes(x = tfp_lp, fill = "1979"), 
                 bins = 30, alpha = 0.5, position = 'identity') +
  geom_histogram(data = data_1997, aes(x = tfp_lp, fill = "1997"), 
                 bins = 30, alpha = 0.5, position = 'identity') +
  scale_fill_manual(values = c("1979" = "#254336", "1997" = "#B7B597"), name = "Año") +
  labs(title = "Histograma productividad tfp_lp en 1979 y 1997", x = "tfp_lp", y = "Frecuencia") +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_x_continuous(breaks = scales::pretty_breaks(n = 10)) +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10))

# Mostrar los gráficos
print(hist_tfp_ls)
print(hist_tfp_fe)
print(hist_tfp_lp)

# Parte 6 

fab <- fab %>%
  group_by(ciiu3, year) %>%
  mutate(
    mean_tfp_ls = mean(tfp_ls, na.rm = TRUE),
    sd_tfp_ls = sd(tfp_ls, na.rm = TRUE),
    tfp_ls_re = (tfp_ls - mean_tfp_ls) / sd_tfp_ls,
    
    mean_tfp_fe = mean(tfp_fe, na.rm = TRUE),
    sd_tfp_fe = sd(tfp_fe, na.rm = TRUE),
    tfp_fe_re = (tfp_fe - mean_tfp_fe) / sd_tfp_fe,
    
    mean_tfp_lp = mean(tfp_lp, na.rm = TRUE),
    sd_tfp_lp = sd(tfp_lp, na.rm = TRUE),
    tfp_lp_re = (tfp_lp - mean_tfp_lp) / sd_tfp_lp
  ) %>%
  ungroup() %>%
  # Eliminar las columnas temporales de medias y desviaciones estándar
  select(-mean_tfp_ls, -sd_tfp_ls, -mean_tfp_fe, -sd_tfp_fe, -mean_tfp_lp, -sd_tfp_lp)

# Calcular las medias de las métricas de productividad relativa
mean_tfp_ls_re <- mean(fab$tfp_ls_re, na.rm = TRUE)
mean_tfp_fe_re <- mean(fab$tfp_fe_re, na.rm = TRUE)
mean_tfp_lp_re <- mean(fab$tfp_lp_re, na.rm = TRUE)

# Printear las medias
cat("Media de tfp_ls_re:", mean_tfp_ls_re, "\n")
cat("Media de tfp_fe_re:", mean_tfp_fe_re, "\n")
cat("Media de tfp_lp_re:", mean_tfp_lp_re, "\n")

# Parte 7 

# Crear gráficos de densidad para cada medida de productividad relativa
dens_tfp_ls_re <- ggplot(fab, aes(x = tfp_ls_re)) +
  geom_density(fill = "#4F7942", alpha = 0.5) +
  labs(title = "Distribución de tfp_ls_re", x = "tfp_ls_re", y = "Densidad") +
  theme(plot.title = element_text(hjust = 0.5))

dens_tfp_fe_re <- ggplot(fab, aes(x = tfp_fe_re)) +
  geom_density(fill = "#006769", alpha = 0.5) +
  labs(title = "Distribución de tfp_fe_re", x = "tfp_fe_re", y = "Densidad") +
  theme(plot.title = element_text(hjust = 0.5))

dens_tfp_lp_re <- ggplot(fab, aes(x = tfp_lp_re)) +
  geom_density(fill = "#BACD92", alpha = 0.5) +
  labs(title = "Distribución de tfp_lp_re", x = "tfp_lp_re", y = "Densidad") +
  theme(plot.title = element_text(hjust = 0.5))

# Mostrar los gráficos
print(dens_tfp_ls_re)
print(dens_tfp_fe_re)
print(dens_tfp_lp_re)



## En la búsqueda de la productividad ##

# Agregamos la dicotómica de si la planta está activa vista en la parte 1.2
fab <- merge(fab, fab_por_id, by = "ID")
fab_activas <- fab %>% filter(siempre_activa == 1)

# Parte 1

# Regresiones
reg_tfp_ls <- lm(tfp_ls_re ~ K_r, data = fab)
reg_tfp_fe <- lm(tfp_fe_re ~ K_r, data = fab)
reg_tfp_lp <- lm(tfp_lp_re ~ K_r, data = fab)

# Tabla con los resultados de las regresiones
stargazer(reg_tfp_ls, reg_tfp_fe, reg_tfp_lp, type = "text",
          title = "Regresiones de Productividad Relativa vs. Stock de Capital",
          header = FALSE, intercept.bottom = FALSE,
          digits = 10)

#Calculamos covarianza entre la productividad relativa con K_r y la varianza de K_r
cov_tfp_ls_kr <- cov(fab$tfp_ls_re, fab$K_r, use = "complete.obs")
var_kr <- var(fab$K_r, use = "complete.obs")
beta1_ls <- cov_tfp_ls_kr / var_kr

cov_tfp_fe_kr <- cov(fab$tfp_fe_re, fab$K_r, use = "complete.obs")
beta1_fe <- cov_tfp_fe_kr / var_kr

cov_tfp_lp_kr <- cov(fab$tfp_lp_re, fab$K_r, use = "complete.obs")
beta1_lp <- cov_tfp_lp_kr / var_kr

# Resultados de la estimación
# cat("beta1 empírico para tfp_ls_re:", beta1_ls, "\n")
# cat("beta1 empírico para tfp_fe_re:", beta1_fe, "\n")
# cat("beta1 empírico para tfp_lp_re:", beta1_lp, "\n")

# Printeamos la resta de nuestra estimación y los resultados de lm()
cat("diferencia de beta1 para tfp_ls_re:", beta1_ls - coef(reg_tfp_ls)["K_r"], "\n")
cat("diferencia de beta1 para tfp_fe_re:", beta1_fe - coef(reg_tfp_fe)["K_r"], "\n")
cat("diferencia de beta1 para tfp_lp_re:", beta1_lp - coef(reg_tfp_lp)["K_r"], "\n")

# Parte 2

# Regresiones con número de trabajadores
reg_tfp_ls_tra <- lm(tfp_ls_re ~ K_r + employment, data = fab)
reg_tfp_fe_tra <- lm(tfp_fe_re ~ K_r + employment, data = fab)
reg_tfp_lp_tra <- lm(tfp_lp_re ~ K_r + employment, data = fab)

# Tabla con los resultados
stargazer(reg_tfp_ls_tra, reg_tfp_fe_tra, reg_tfp_lp_tra, type = "text",
          title = "Regresiones de Productividad Relativa vs. Stock de Capital y Número de Trabajadores",
          header = FALSE, intercept.bottom = FALSE,
          digits = 10)

# Parte 3

# Sesgos
sesgo_ls <- coef(reg_tfp_ls_tra)["employment"] * (cov(fab$K_r, fab$employment) / var(fab$K_r))
sesgo_fe <- coef(reg_tfp_fe_tra)["employment"] * (cov(fab$K_r, fab$employment) / var(fab$K_r))
sesgo_lp <- coef(reg_tfp_lp_tra)["employment"] * (cov(fab$K_r, fab$employment) / var(fab$K_r))

# Mostramos los resultados
cat("Sesgo para tfp_ls_re:", sesgo_ls, "\n")
cat("Sesgo para tfp_fe_re:", sesgo_fe, "\n")
cat("Sesgo para tfp_lp_re:", sesgo_lp, "\n")

# Parte 4

# Regresiones para todas las fab
reg_tfp_ls_todas <- lm(tfp_ls_re ~ K_r + employment + employees, data = fab)
reg_tfp_fe_todas <- lm(tfp_fe_re ~ K_r + employment + employees, data = fab)
reg_tfp_lp_todas <- lm(tfp_lp_re ~ K_r + employment + employees, data = fab)

# Regresiones para fab siempre activas
reg_tfp_ls_activas <- lm(tfp_ls_re ~ K_r + employment + employees, data = fab_activas)
reg_tfp_fe_activas <- lm(tfp_fe_re ~ K_r + employment + employees, data = fab_activas)
reg_tfp_lp_activas <- lm(tfp_lp_re ~ K_r + employment + employees, data = fab_activas)

# Tablas con los resultados
stargazer(reg_tfp_ls_todas, reg_tfp_fe_todas, reg_tfp_lp_todas, type = "text",
          title = "Regresiones para Todas las fab",
          header = FALSE, intercept.bottom = FALSE,
          digits = 10)

stargazer(reg_tfp_ls_activas, reg_tfp_fe_activas, reg_tfp_lp_activas, type = "text",
          title = "Regresiones para fab Siempre Abiertas",
          header = FALSE, intercept.bottom = FALSE,
          digits = 10)

# Parte 5

# Regresiones con trabajadores no calificados
reg_tfp_ls_workers <- lm(tfp_ls_re ~ K_r + employment + employees + workers, data = fab)
reg_tfp_fe_workers <- lm(tfp_fe_re ~ K_r + employment + employees + workers, data = fab)
reg_tfp_lp_workers <- lm(tfp_lp_re ~ K_r + employment + employees + workers, data = fab)

# Tabla con los resultados
stargazer(reg_tfp_ls_workers, reg_tfp_fe_workers, reg_tfp_lp_workers, type = "text",
          title = "Regresiones para Todas las fab: Productividad Relativa vs. Stock de Capital, Número de Trabajadores, Trabajadores Calificados y No Calificados",
          header = FALSE, intercept.bottom = FALSE, digits = 10)

# Parte 6

# Parte 7

# Regresión con variable de tratamiento técnico
fab <- fab %>% mutate(tratamiento_tecnico = ifelse(tech_asis > 0, 1, 0))

# Definimos las fab con asistencia
fab_con_asistenciaAno <- fab %>% group_by(year) %>% summarise(fab_con_asistencia = sum(tratamiento_tecnico))

# Tabla con año y n de fab con asistencia 
print(fab_con_asistenciaAno)

# Parte 8

# Regresiones considerando tratamiento tecnico
reg_tfp_ls_tec <- lm(tfp_ls_re ~ K_r + employment + tratamiento_tecnico, data = fab)
reg_tfp_fe_tec <- lm(tfp_fe_re ~ K_r + employment + tratamiento_tecnico, data = fab)
reg_tfp_lp_tec <- lm(tfp_lp_re ~ K_r + employment + tratamiento_tecnico, data = fab)

# Tabla con los resultados
stargazer(reg_tfp_ls_tec, reg_tfp_fe_tec, reg_tfp_lp_tec, type = "text",
          title = "Regresiones de Productividad, Stock de Capital, Número de Trabajadores y Asistencia Técnica",
          intercept.bottom = FALSE, digits = 10)

# Parte 9

# Agregamos la dicotómica de salida vista en la parte 1.3
fab <- merge(fab, ultimoAno_por_id, by = "ID")
fab <- fab %>% mutate(salida = ifelse(year == year_ultimo, 1, 0))

# Ordenamos las plantas
fab <- fab %>% arrange(ID, year)

# Creamos las productividades del año pasado y antepasado
fab <- fab %>% group_by(ID) %>% mutate( Productividad_t_1 = lag(tfp_fe_re, 1),Productividad_t_2 = lag(tfp_fe_re, 2)) %>% ungroup()

# Creamos la regresión 
modelo_salida <- lm(salida ~ tfp_fe_re + Productividad_t_1 + Productividad_t_2 + tratamiento_tecnico, data = fab)

# Mostramos los resultados
summary(modelo_salida)

# Parte 10

# Definimos los coeficientes y sus errores estándar
coeficientes <- coef(summary(modelo_salida))
beta_1 <- coeficientes["tfp_fe_re", "Estimate"]
beta_2 <- coeficientes["Productividad_t_1", "Estimate"]
beta_3 <- coeficientes["Productividad_t_2", "Estimate"]
se_beta_1 <- coeficientes["tfp_fe_re", "Std. Error"]
se_beta_2 <- coeficientes["Productividad_t_1", "Std. Error"]
se_beta_3 <- coeficientes["Productividad_t_2", "Std. Error"]

# Calculamos diferencia y error estándar beta1 < beta2
dif_beta_1_2 <- beta_1 - beta_2
se_dif_beta_1_2 <- sqrt(se_beta_1^2 + se_beta_2^2)
t_value_beta_1_2 <- dif_beta_1_2 / se_dif_beta_1_2
p_value_beta_1_2 <- pt(t_value_beta_1_2, df = df.residual(modelo_salida), lower.tail = TRUE)

# Calculamos diferencia y error estándar para beta2 = beta3
dif_beta_2_3 <- beta_2 - beta_3
se_dif_beta_2_3 <- sqrt(se_beta_2^2 + se_beta_3^2)
t_value_beta_2_3 <- dif_beta_2_3 / se_dif_beta_2_3
p_value_beta_2_3 <- 2 * pt(-abs(t_value_beta_2_3), df = df.residual(modelo_salida))  # two-tailed test

# Printeamos los resultados
cat("Test de hipótesis beta1 < beta2:\n",
    "Diferencia:", dif_beta_1_2, "\n",
    "Valor t:", t_value_beta_1_2, "\n",
    "p-value:", p_value_beta_1_2, "\n")
cat("Test de hipótesis beta2 = beta3:\n",
    "Diferencia:", dif_beta_2_3, "\n",
    "Valor t:", t_value_beta_2_3, "\n",
    "p-value:", p_value_beta_2_3, "\n")
                   