rm(list = ls())

getwd()

setwd("C:/Users/pc/Downloads")

# Define la nueva ruta de instalaci?n de paquetes
nueva_ruta <- "C:\Users\pc\Downloads\Base final (2).xlsx"
# Configura la nueva ruta como la primera ubicaci?n de bibliotecas
.libPaths(c(nueva_ruta, .libPaths()))

install.packages("readxl")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("corrplot")
library(readxl)
library(dplyr)
library(ggplot2)
library(corrplot)
#Cargamos la base con nuestras variables y la nombramos como "viviendas"
viviendas = read_excel("Base final (2).xlsx")
#View(viviendas)



#Reemplazamos los "No Recepcionado" en las otras columnas por el promedio de cada cosa
cols_to_update <- c("Disponibilidad presupuestaria municipal por habitante")

viviendas <- viviendas %>%
  mutate(across(all_of(cols_to_update), ~ifelse(. == "No Recepcionado",
                                                mean(as.numeric(.[. != "No Recepcionado"]), na.rm = TRUE),
                                                .)))

#Visualizamos la base ya con los arregines
View(viviendas)


#Nos dimos cuenta que se nos estaban calculando mal las funciones para el EDA asi que revisamos el texto de la base
str(viviendas)
#La base esta considerando muchos datos como texto, hay que arreglaro

#Convertimos todas los valores a n?meros en cada columna
viviendas$"Disponibilidad presupuestaria municipal por habitante" <- as.numeric(viviendas$"Disponibilidad presupuestaria municipal por habitante")
viviendas$"Indice de pobreza CASEN" <- as.numeric(viviendas$"Indice de pobreza CASEN")
viviendas$"Superficie total comunal en km2" <- as.numeric(viviendas$"Superficie total comunal en km2")
viviendas$"Distancia con respecto a la capital regional" <- as.numeric(viviendas$"Distancia con respecto a la capital regional")
viviendas$"Porcentaje de poblacion rural" <- as.numeric(viviendas$"Porcentaje de poblacion rural")

#Calcular la mediana del porcentaje de poblaci?n rural
mediana_rural <- median(viviendas$`Porcentaje de poblacion rural`)


#Crear la base de datos con comunas de alto porcentaje de población rural
viviendas_alto_rural <- viviendas %>%
  filter(`Porcentaje de poblacion rural` > mediana_rural) %>%
  filter(`Cantidad de viviendas irregulares por comuna` > 0)
# Crear la base de datos con comunas de bajo porcentaje de población rural
viviendas_bajo_rural <- viviendas %>%
  filter(`Porcentaje de poblacion rural` < mediana_rural) %>%
  filter(`Cantidad de viviendas irregulares por comuna` > 0)

#Gráfico de dispersi?n: Cantidad de viviendas irregulares vs Disponibilidad presupuestaria
p1 <- ggplot(viviendas_alto_rural, aes(x = `Disponibilidad presupuestaria municipal por habitante`, y = `Cantidad de viviendas irregulares por comuna`)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Cantidad de viviendas irregulares vs Disponibilidad presupuestaria", x = "Disponibilidad presupuestaria", y = "Cantidad de viviendas irregulares")

#Gr?fico de dispersi?n: Cantidad de viviendas irregulares vs ?ndice de pobreza CASEN
p2 <- ggplot(viviendas_alto_rural, aes(x = `Indice de pobreza CASEN`, y = `Cantidad de viviendas irregulares por comuna`)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Cantidad de viviendas irregulares vs ?ndice de pobreza CASEN", x = "?ndice de pobreza CASEN", y = "Cantidad de viviendas irregulares")

#Gr?fico de dispersi?n: Cantidad de viviendas irregulares vs Superficie comunal
p3 <- ggplot(viviendas_alto_rural, aes(x = `Superficie total comunal en km2`, y = `Cantidad de viviendas irregulares por comuna`)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Cantidad de viviendas irregulares vs Superficie comunal", x = "Superficie comunal", y = "Cantidad de viviendas irregulares")

#Gr?fico de dispersi?n: Cantidad de viviendas irregulares vs Distancia a la capital
p4 <- ggplot(viviendas_alto_rural, aes(x = `Distancia con respecto a la capital regional`, y = `Cantidad de viviendas irregulares por comuna`)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Cantidad de viviendas irregulares vs Distancia a la capital", x = "Distancia a la capital", y = "Cantidad de viviendas irregulares")

#Mostrar los gráficos
print(p1)
print(p2)
print(p3)
print(p4)

#Gráfico de dispersión: Comuna vs Índice de pobreza CASEN, clasificado por ruralidad
p1 <- ggplot() +
  geom_point(data = viviendas_alto_rural, aes(x = `Indice de pobreza CASEN`, y = Municipio, color = "Alto % rural")) +
  geom_point(data = viviendas_bajo_rural, aes(x = `Indice de pobreza CASEN`, y = Municipio, color = "Bajo % rural")) +
  labs(title = "Cantidad de viviendas irregulares vs ?ndice de pobreza CASEN",
       x = "?ndice de pobreza CASEN",
       y = "Comuna",
       color = "Ruralidad") +
  theme_minimal()

print(p1)

q1 <- ggplot() +
  geom_point(data = viviendas_alto_rural, aes(x = `Indice de pobreza CASEN`, y = `Cantidad de viviendas irregulares por comuna`, color = "Alto % rural")) +
  geom_point(data = viviendas_bajo_rural, aes(x = `Indice de pobreza CASEN`, y = `Cantidad de viviendas irregulares por comuna`, color = "Bajo % rural")) +
  geom_smooth(data = viviendas_alto_rural, aes(x = `Indice de pobreza CASEN`, y = `Cantidad de viviendas irregulares por comuna`, color = "Alto % rural"), method = "lm", se = FALSE) +
  geom_smooth(data = viviendas_bajo_rural, aes(x = `Indice de pobreza CASEN`, y = `Cantidad de viviendas irregulares por comuna`, color = "Bajo % rural"), method = "lm", se = FALSE) +
  labs(title = "Cantidad de viviendas irregulares vs ?ndice de pobreza CASEN",
       x = "?ndice de pobreza CASEN",
       y = "Cantidad de viviendas irregulares",
       color = "Ruralidad") +
  theme_minimal()

print(q1)

### Tras ver estos datos nos damos cuentas que quizáa la base esta sesgada o hay muchos outliers, asi que 
### realizaremos cambios en las viviendas a considerar para realizar los gráficos


#Como nos dan datos raros, vamos a hacerlo no por la mediana de la ruralidad, sino separar por el percentil 60
percentil_70 <- quantile(viviendas$`Porcentaje de poblacion rural`, probs = 0.7, na.rm = TRUE)
#Crear la base de datos con comunas de alto porcentaje de población rural
viviendas_alto_rural_1 <- viviendas %>%
  filter(`Porcentaje de poblacion rural` > percentil_70) %>%
  filter(`Cantidad de viviendas irregulares por comuna` > 0)
#View(viviendas_alto_rural)
#Crear la base de datos con comunas de bajo porcentaje de población rural
viviendas_bajo_rural_1 <- viviendas %>%
  filter(`Porcentaje de poblacion rural` >percentil_70) %>%
  filter(`Cantidad de viviendas irregulares por comuna` > 0)


#Gr?fico de dispersi?n: Cantidad de viviendas irregulares vs Disponibilidad presupuestaria
p1 <- ggplot(viviendas_bajo_rural_1, aes(x = `Disponibilidad presupuestaria municipal por habitante`, y = `Cantidad de viviendas irregulares por comuna`)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Cantidad de viviendas irregulares vs Disponibilidad presupuestaria", x = "Disponibilidad presupuestaria", y = "Cantidad de viviendas irregulares")

#Gr?fico de dispersi?n: Cantidad de viviendas irregulares vs ?ndice de pobreza CASEN
p2 <- ggplot(viviendas_bajo_rural_1, aes(x = `Indice de pobreza CASEN`, y = `Cantidad de viviendas irregulares por comuna`)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Cantidad de viviendas irregulares vs Índice de pobreza CASEN", x = "índice de pobreza CASEN", y = "Cantidad de viviendas irregulares")

#Gr?fico de dispersi?n: Cantidad de viviendas irregulares vs Superficie comunal
p3 <- ggplot(viviendas_bajo_rural_1, aes(x = `Superficie total comunal en km2`, y = `Cantidad de viviendas irregulares por comuna`)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Cantidad de viviendas irregulares vs Superficie comunal", x = "Superficie comunal", y = "Cantidad de viviendas irregulares")

#Gr?fico de dispersi?n: Cantidad de viviendas irregulares vs Distancia a la capital
p4 <- ggplot(viviendas_bajo_rural_1, aes(x = `Distancia con respecto a la capital regional`, y = `Cantidad de viviendas irregulares por comuna`)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Cantidad de viviendas irregulares vs Distancia a la capital", x = "Distancia a la capital", y = "Cantidad de viviendas irregulares")
#Mostrar los gráficos
print(p1)
print(p2)
print(p3)
print(p4)


#Cargamos una base de datos que solo contemple las regiones de Tarapacá, Antofagasta, Valparaíso y Metropolitana
#Explicamos en el informe porque solo contemplaremos estas 3
viviendas_modificadas <- read_excel("Libro 21.xlsx")
#Repetimos todo para esta misma base

#Reemplazamos los "No Recepcionado" en las otras columnas por el promedio de cada cosa
cols_to_update <- c("Disponibilidad presupuestaria municipal por habitante")

viviendas_modificadas <- viviendas_modificadas %>%
  mutate(across(all_of(cols_to_update), ~ifelse(. == "No Recepcionado",
                                                mean(as.numeric(.[. != "No Recepcionado"]), na.rm = TRUE),
                                                .)))

#Nos dimos cuenta que se nos estaban calculando mal las funciones para el EDA asi que revisamos el texto de la base
str(viviendas_modificadas)
#La base esta considerando muchos datos como texto, hay que arreglaro

#Convertimos todas los valores a n?meros en cada columna
viviendas_modificadas$"Disponibilidad presupuestaria municipal por habitante" <- as.numeric(viviendas_modificadas$"Disponibilidad presupuestaria municipal por habitante")
viviendas_modificadas$"Indice de pobreza CASEN" <- as.numeric(viviendas_modificadas$"Indice de pobreza CASEN")
viviendas_modificadas$"Superficie total comunal en km2" <- as.numeric(viviendas_modificadas$"Superficie total comunal en km2")
viviendas_modificadas$"Distancia con respecto a la capital regional" <- as.numeric(viviendas_modificadas$"Distancia con respecto a la capital regional")
viviendas_modificadas$"Porcentaje de poblacion rural" <- as.numeric(viviendas_modificadas$"Porcentaje de poblacion rural")

View(viviendas_modificadas)

#Como nos dan datos raros, vamos a hacerlo no por la mediana de la ruralidad, sino separar por el percentil 60

percentil_80_m <- quantile(viviendas_modificadas$`Porcentaje de poblacion rural`, probs = 0.8, na.rm = TRUE)
#Crear la base de datos con comunas de alto porcentaje de población rural
viviendas_alto_rural_m <- viviendas_modificadas %>%
  filter(`Porcentaje de poblacion rural` > percentil_80) %>%
  filter(`Cantidad de viviendas irregulares por comuna` > 0)

#Crear la base de datos con comunas de bajo porcentaje de población rural
viviendas_bajo_rural_m <- viviendas_modificadas %>%
  filter(`Porcentaje de poblacion rural` < percentil_80) %>%
  filter(`Cantidad de viviendas irregulares por comuna` > 0)

viviendas_bajo_rural_m$"Disponibilidad presupuestaria municipal por habitante" <- as.numeric(viviendas_bajo_rural_m$"Disponibilidad presupuestaria municipal por habitante")
viviendas_bajo_rural_m$"Indice de pobreza CASEN" <- as.numeric(viviendas_bajo_rural_m$"Indice de pobreza CASEN")
viviendas_bajo_rural_m$"Superficie total comunal en km2" <- as.numeric(viviendas_bajo_rural_m$"Superficie total comunal en km2")
viviendas_bajo_rural_m$"Distancia con respecto a la capital regional" <- as.numeric(viviendas_bajo_rural_m$"Distancia con respecto a la capital regional")
viviendas_bajo_rural_m$"Porcentaje de poblacion rural" <- as.numeric(viviendas_bajo_rural_m$"Porcentaje de poblacion rural")

viviendas_alto_rural_m$"Disponibilidad presupuestaria municipal por habitante" <- as.numeric(viviendas_alto_rural_m$"Disponibilidad presupuestaria municipal por habitante")
viviendas_alto_rural_m$"Indice de pobreza CASEN" <- as.numeric(viviendas_alto_rural_m$"Indice de pobreza CASEN")
viviendas_alto_rural_m$"Superficie total comunal en km2" <- as.numeric(viviendas_alto_rural_m$"Superficie total comunal en km2")
viviendas_alto_rural_m$"Distancia con respecto a la capital regional" <- as.numeric(viviendas_alto_rural_m$"Distancia con respecto a la capital regional")
viviendas_alto_rural_m$"Porcentaje de poblacion rural" <- as.numeric(viviendas_alto_rural_m$"Porcentaje de poblacion rural")


#Gráfico de dispersión: Cantidad de viviendas irregulares vs Disponibilidad presupuestaria
p1 <- ggplot(viviendas_bajo_rural_m, aes(x = `Disponibilidad presupuestaria municipal por habitante`, y = `Cantidad de viviendas irregulares por comuna`)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Cantidad de viviendas irregulares vs Disponibilidad presupuestaria", x = "Disponibilidad presupuestaria", y = "Cantidad de viviendas irregulares")

#Gr?fico de dispersi?n: Cantidad de viviendas irregulares vs ?ndice de pobreza CASEN
p2 <- ggplot(viviendas_bajo_rural_m, aes(x = `Indice de pobreza CASEN`, y = `Cantidad de viviendas irregulares por comuna`)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Cantidad de viviendas irregulares vs Índice de pobreza CASEN", x = "índice de pobreza CASEN", y = "Cantidad de viviendas irregulares")

#Gr?fico de dispersi?n: Cantidad de viviendas irregulares vs Superficie comunal
p3 <- ggplot(viviendas_bajo_rural_m, aes(x = `Superficie total comunal en km2`, y = `Cantidad de viviendas irregulares por comuna`)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Cantidad de viviendas irregulares vs Superficie comunal", x = "Superficie comunal", y = "Cantidad de viviendas irregulares")

#Gr?fico de dispersi?n: Cantidad de viviendas irregulares vs Distancia a la capital
p4 <- ggplot(viviendas_bajo_rural_m, aes(x = `Distancia con respecto a la capital regional`, y = `Cantidad de viviendas irregulares por comuna`)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Cantidad de viviendas irregulares vs Distancia a la capital", x = "Distancia a la capital", y = "Cantidad de viviendas irregulares")
#Mostrar los gráficos
print(p1)
print(p2)
print(p3)
print(p4)


#Datos útiles para el EDA
#Disponibilidad presupuestaria
mediana_DP <- median(viviendas$`Disponibilidad presupuestaria municipal por habitante`)
media_DP <- mean(viviendas$`Disponibilidad presupuestaria municipal por habitante`)
desv_DP <- sd(viviendas$`Disponibilidad presupuestaria municipal por habitante`)
max_DP <- max(viviendas$`Disponibilidad presupuestaria municipal por habitante`)
min_DP <- min(viviendas$`Disponibilidad presupuestaria municipal por habitante`)
#Indice Pobreza
mediana_IP <- median(viviendas$`Indice de pobreza CASEN`)
media_IP <- mean(viviendas$`Indice de pobreza CASEN`)
desv_IP <- sd(viviendas$`Indice de pobreza CASEN`)
max_IP <- max(viviendas$`Indice de pobreza CASEN`)
min_IP <- min(viviendas$`Indice de pobreza CASEN`)
#Superficie total
mediana_SP <- median(viviendas$`Superficie total comunal en km2`)
media_SP <- mean(viviendas$`Superficie total comunal en km2`)
desv_SP <- sd(viviendas$`Superficie total comunal en km2`)
max_SP <- max(viviendas$`Superficie total comunal en km2`)
min_SP <- min(viviendas$`Superficie total comunal en km2`)
#Distancia capital
mediana_DC <- median(viviendas$`Distancia con respecto a la capital regional`)
media_DC <- mean(viviendas$`Distancia con respecto a la capital regional`)
desv_DC <- sd(viviendas$`Distancia con respecto a la capital regional`)
max_DC <- max(viviendas$`Distancia con respecto a la capital regional`)
min_DC <- min(viviendas$`Distancia con respecto a la capital regional`)


#Gráfico de dispersión: Comuna vs Índice de pobreza CASEN, clasificado por ruralidad ACTUALIZADO CON DATOS MENOS "MALOS"
p <- ggplot() +
  geom_point(data = viviendas_alto_rural_m, aes(x = `Indice de pobreza CASEN`, y = Municipio, color = "Alto % rural")) +
  geom_point(data = viviendas_bajo_rural_m, aes(x = `Indice de pobreza CASEN`, y = Municipio, color = "Bajo % rural")) +
  labs(title = "Cantidad de viviendas irregulares vs ?ndice de pobreza CASEN",
       x = "?ndice de pobreza CASEN",
       y = "Comuna",
       color = "Ruralidad") +
  theme_minimal()

print(p)

q <- ggplot() +
  geom_point(data = viviendas_alto_rural, aes(x = `Indice de pobreza CASEN`, y = `Cantidad de viviendas irregulares por comuna`, color = "Alto % rural")) +
  geom_point(data = viviendas_bajo_rural, aes(x = `Indice de pobreza CASEN`, y = `Cantidad de viviendas irregulares por comuna`, color = "Bajo % rural")) +
  geom_smooth(data = viviendas_alto_rural, aes(x = `Indice de pobreza CASEN`, y = `Cantidad de viviendas irregulares por comuna`, color = "Alto % rural"), method = "lm", se = FALSE) +
  geom_smooth(data = viviendas_bajo_rural, aes(x = `Indice de pobreza CASEN`, y = `Cantidad de viviendas irregulares por comuna`, color = "Bajo % rural"), method = "lm", se = FALSE) +
  labs(title = "Cantidad de viviendas irregulares vs ?ndice de pobreza CASEN",
       x = "?ndice de pobreza CASEN",
       y = "Cantidad de viviendas irregulares",
       color = "Ruralidad") +
  theme_minimal()

print(q)



#no cambia demasiado la forma de los datos, pero si se puede diferencia más el comportamiento entre los bajos y los altos %´s de ruralidad

# Calcular la matriz de correlación
datos <- viviendas_alto_rural_m[, c("Cantidad de viviendas irregulares por comuna",
                                    "Disponibilidad presupuestaria municipal por habitante",
                                    "Indice de pobreza CASEN",
                                    "Superficie total comunal en km2",
                                    "Distancia con respecto a la capital regional",
                                    "Porcentaje de poblacion rural")]

# Calcular correlación
correlacion <- cor(datos, use = "pairwise.complete.obs")

# Limpiar ventana gráfica
plot.new()
dev.off()

# Graficar correlación
corrplot(correlacion, method = "color", tl.cex = 0.7)

##Parte 4 regresiones
#vamos agregando variables en cada modelo
#Modelo 1 (Base):
viviendas_lm1 <- lm(log(`Cantidad de viviendas irregulares por comuna`) ~ `Indice de pobreza CASEN`, data = viviendas_bajo_rural_m)

summary(viviendas_lm1)

# Gráfico de dispersión
ggplot(viviendas_bajo_rural_m, aes(x = `Indice de pobreza CASEN`, y = log(`Cantidad de viviendas irregulares por comuna`))) +
  geom_point() +  # Añade los puntos
  geom_smooth(method = "lm", se = FALSE) +  # Añade la línea de regresión lineal sin intervalos de confianza
  labs(x = "Índice de pobreza CASEN", y = "Log(Cantidad de viviendas irregulares por comuna)") +  # Etiquetas de los ejes
  ggtitle("Regresión Lineal") +  # Título del gráfico
  theme_minimal()  # Estilo minimalista del gráfico

#Modelo 2:
viviendas_lm2 <- lm(log(`Cantidad de viviendas irregulares por comuna`) ~ `Indice de pobreza CASEN` + `Disponibilidad presupuestaria municipal por habitante`, data = viviendas_bajo_rural_m)

summary(viviendas_lm2)

# Crear el gráfico de dispersión y la línea de regresión
ggplot(viviendas_bajo_rural_m, aes(x = `Indice de pobreza CASEN`, y = log(`Cantidad de viviendas irregulares por comuna`))) +
  geom_point() +  # Gráfico de dispersión
  geom_smooth(method = "lm", se = FALSE, color = "blue") +  # Línea de regresión
  labs(x = "Índice de pobreza CASEN", y = "Log(Cantidad de viviendas irregulares por comuna)", title = "Regresión Lineal") +
  theme_minimal()

#Modelo 3:
viviendas_lm3 <-lm(formula = log(`Cantidad de viviendas irregulares por comuna`) ~ `Indice de pobreza CASEN` * `Porcentaje de poblacion rural`, data = viviendas_bajo_rural_m)

summary(viviendas_lm3)

ggplot(viviendas_bajo_rural_m, aes(x = `Indice de pobreza CASEN`, y = log(`Cantidad de viviendas irregulares por comuna`))) +
  geom_point() +  # Gráfico de dispersión
  geom_smooth(method = "lm", se = FALSE, color = "blue") +  # Línea de regresión
  labs(x = "Índice de pobreza CASEN", y = "Log(Cantidad de viviendas irregulares por comuna)", title = "Regresión Lineal") +
  theme_minimal()

#Modelo 4 :
viviendas_lm4 <- lm(log(`Cantidad de viviendas irregulares por comuna`) ~ `Indice de pobreza CASEN` * `Porcentaje de poblacion rural` + `Distancia con respecto a la capital regional`, data = viviendas_bajo_rural_m)

summary(viviendas_lm4)   

ggplot(viviendas_bajo_rural_m, aes(x = `Indice de pobreza CASEN` * `Porcentaje de poblacion rural`, y = log(`Cantidad de viviendas irregulares por comuna`))) +
  geom_point() +  # Gráfico de dispersión
  geom_smooth(method = "lm", se = FALSE, color = "blue") +  # Línea de regresión
  labs(x = "Índice de pobreza CASEN * Porcentaje de poblacion rural", y = "Log(Cantidad de viviendas irregulares por comuna)", title = "Regresión Lineal") +
  theme_minimal()

#Modelo 5 :
viviendas_lm5 <- lm(log(`Cantidad de viviendas irregulares por comuna`) ~ `Indice de pobreza CASEN` * `Porcentaje de poblacion rural` + `Distancia con respecto a la capital regional` + `Superficie total comunal en km2`, data = viviendas_bajo_rural_m)

summary(viviendas_lm5) 

# Crear el gráfico de dispersión y la línea de regresión
ggplot(viviendas_bajo_rural_m, aes(x = `Indice de pobreza CASEN` * `Porcentaje de poblacion rural` * `Distancia con respecto a la capital regional` * `Superficie total comunal en km2`, y = log(`Cantidad de viviendas irregulares por comuna`))) +
  geom_point() +  # Gráfico de dispersión
  geom_smooth(method = "lm", se = FALSE, color = "blue") +  # Línea de regresión
  labs(x = "Indice de pobreza CASEN * Porcentaje de poblacion rural * Distancia con respecto a la capital regional * Superficie total comunal en km2", y = "Log(Cantidad de viviendas irregulares por comuna)", title = "Regresión Lineal") +
  theme_minimal()

# Comprobar homocedasticidad
install.packages("lmtest")
library(lmtest)

# Realiza la prueba de White con el modelo viviendas_lm5
white_test <- bptest(viviendas_lm5)
white_test

## El resultado de la prueba de Breusch-Pagan (BP) 
## muestra un valor p de 0.195. Esto indica que los errores tienen varianzas constantes.
## el supuesto de homocedasticidad parece no ser violado en el modelo lineal 


# Comprobrar multicolinealidad 
# Cálculo de VIF para cada variable independiente
vif_values <- car::vif(viviendas_lm5)

print(vif_values)

# Según los resultados del VIF dicen que la variable
#Porcentaje de población rural y la interacción Indice de pobreza 
#CASEN:Porcentaje de población rural tienen VIFs altos, 
# lo que indica la presencia de multicolinealidad significativa













