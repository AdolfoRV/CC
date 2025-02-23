# install.packages("data.table")
# install.packages("dplyr")
# install.packages("ggplot2")
# install.packages("haven")
# install.packages("ivreg")
# install.packages("MASS")
# install.packages("rdd")
# install.packages("readr")
# install.packages("stargazer")

library(data.table)
library(dplyr)
library(ggplot2)
library(haven)
library(ivreg)
library(MASS)
library(rdd)
library(readr)
library(stargazer)

# setwd("Desktop/CC/estadistica_II")

# Creación de las bases de datos ------------------------------------------------------------------

base_diff_in_diff = read.csv("datos/T2/Base (Diff in Diff).csv")
base_vi_rd = read_dta("datos/T2/Base (VI, RD).dta")

# Colapsar la base de datos por año y essem
vi_rd <- base_vi_rd %>%
  group_by(anno, esse_m) %>%
  summarise(
    # No incluimos eligm en la base de datos puesto que ya tenemos la variable elegibilidad
    # eligm = mean(elig_m, na.rm = TRUE),
    lnc = mean(lnc, na.rm = TRUE),
    lncn = mean(lncn, na.rm = TRUE),
    lnjconsal = mean(lnjconsal, na.rm = TRUE),
    var1 = mean(ncomp, na.rm = TRUE),
    var2 = mean(children, na.rm = TRUE),
    var3 = mean(educ_m, na.rm = TRUE),
    var4 = mean(eta_m, na.rm = TRUE),
    # Agregamos el caso de los recién jubilados esse_m = 0
    elegibilidad = mean(ifelse(esse_m >= 0, 1, 0), na.rm = TRUE),
    porcentaje_retirados = mean(qu_m, na.rm = TRUE)
  )

# Filtrar los datos para incluir solo a los hogares cuyos jefes de hogar se encuentren a menos de un epsilon = 10 años de cumplir la edad de jubilación y los que tengan menos de 10 años posteriores a la edad de jubilación
vi_rd <- vi_rd %>% filter(esse_m >= -10 & esse_m <= 10)

#---# DISEÑO DE REGRESIÓN DISCONTINUA -------------------------------------------------------------

### Chequear supuestos

# 1. Discontinuidad del tratamiento en torno a la running variable ================================
ggplot(vi_rd, aes(x = esse_m, y = elegibilidad)) +
  geom_point() +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(title = "Discontinuidad de la elegibilidad en torno a esse_m", x = "esse_m", y = "elegibilidad")

# Mostrar los resultados de la regresión respecto a la elegibilidad
# cat("Coeficiente de interés (elegibilidad):", summary(rd_model)$coefficients["elegibilidad", "Estimate"], "\n")
# cat("Error estándar:", summary(rd_model)$coefficients["elegibilidad", "Std. Error"], "\n")
# cat("Significancia estadística:", summary(rd_model)$coefficients["elegibilidad", "Pr(>|t|)"], "\n")

# 2. No manipulación de la variable running variable ==============================================
# Graficar la distribución de esse_m para verificar la ausencia de manipulación
ggplot(vi_rd, aes(x = esse_m)) +
  geom_density() +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(title = "Gráfico de densidad de esse_m", x = "esse_m", y = "Densidad")

# Prueba de densidad de McCrary
  # H0: No hay discontinuidad en la densidad de esse_m en torno a 0
  # H1: Hay discontinuidad en la densidad de esse_m en torno a 0
DCdensity(vi_rd$esse_m, cutpoint = 0, verbose = TRUE)

# 3. Continuidad de los resultados potenciales en torno a esse_m ==================================
# Este supuesto no es comprobable directamente, pero asumiremos que los resultados potenciales son continuos en torno a esse_m.

# 4. Continuidad de las covariables en torno al punto de corte ====================================
covariables <- c("var3", "var4")
esse_vs_covariables <- list()

for (var in covariables) {
  grado1 <- lm(as.formula(paste(var, "~ elegibilidad + esse_m")), data = vi_rd)
  grado2 <- lm(as.formula(paste(var, "~ elegibilidad + esse_m + I(esse_m**2)")), data = vi_rd)
  grado3 <- lm(as.formula(paste(var, "~ elegibilidad + esse_m + I(esse_m**2) + I(esse_m**3)")), data = vi_rd)
  esse_vs_covariables[[var]] <- list(grado1, grado2, grado3)
  
  stargazer(grado1, grado2, grado3, type = "text", 
            title = paste("Resultados de la regresión para", var), 
            column.labels = c(paste(var, "grado 1"), paste(var, "grado 2"), paste(var, "grado 3")),
            dep.var.labels.include = FALSE)
}

# De manera grafica vemos las covariables en función de esse_m para verificar la continuidad
for (var in covariables) {
  ggplot(vi_rd, aes(x = esse_m, y = get(var))) +
    geom_point() +
    geom_smooth(data = vi_rd %>% filter(esse_m < 0), method = "lm", se = FALSE, color = "blue") +
    geom_smooth(data = vi_rd %>% filter(esse_m >= 0), method = "lm", se = FALSE, color = "red") +
    labs(title = paste("Gráfico de", var, "en función de esse_m"), x = "esse_m", y = var)
}

# Regresiones discontinuas ------------------------------------------------------------------------

# Modelo 1: Sin controles, ventana [-10, 10]
rd_model1 <- lm(lnc ~ elegibilidad + esse_m, data = vi_rd)

# Modelo 2: Con controles, ventana [-10, 10]
rd_model2 <- lm(lnc ~ elegibilidad + esse_m + var1 + var2 + var3 + var4, data = vi_rd)

# Modelo 3: Con controles, ventana [-8, 8]
vi_rd_ventana8 <- vi_rd %>% filter(esse_m >= -8 & esse_m <= 8)
rd_model3 <- lm(lnc ~ elegibilidad + esse_m + var1 + var2 + var3 + var4, data = vi_rd_ventana8)

# Modelo 4: Con controles, ventana [-6, 6]
vi_rd_ventana6 <- vi_rd %>% filter(esse_m >= -6 & esse_m <= 6)
rd_model4 <- lm(lnc ~ elegibilidad + esse_m + var1 + var2 + var3 + var4, data = vi_rd_ventana6)

# Modelo 5: Con controles, ventana [-3, 3]
vi_rd_ventana3 <- vi_rd %>% filter(esse_m >= -3 & esse_m <= 3)
rd_model5 <- lm(lnc ~ elegibilidad + esse_m + var1 + var2 + var3 + var4, data = vi_rd_ventana3)

# Presentar los resultados en una tabla
stargazer(rd_model1, rd_model2, rd_model3, rd_model4, rd_model5, type = "text",
      title = "Resultados de los Modelos de regresiones discontinuas",
      column.labels = c("Modelo 1", "Modelo 2", "Modelo 3", "Modelo 4", "Modelo 5"),
      model.names = FALSE)

#---# DISEÑO DE VARIABLES INSTRUMENTALES ----------------------------------------------------------

### Chequear supuestos

# 1. Relevancia del instrumento ===================================================================
# Verificar la relevancia del instrumento usando el modelo IV (la otra forma de hacerlo es haciendo la doble regresión pero esto fue visto en el laboratorio 3)
iv_reg <- summary(ivreg(porcentaje_retirados ~ elegibilidad | elegibilidad, data = vi_rd))
print(iv_reg)

# 2. Independencia del instrumento ================================================================
# Verificamos que el instrumento sea independiente de los errores en la ecuación con un test de balance
balance <- vi_rd %>%
  group_by(elegibilidad) %>%
  summarise(
    mean_var1 = mean(var1, na.rm = TRUE),
    mean_var2 = mean(var2, na.rm = TRUE),
    mean_var3 = mean(var3, na.rm = TRUE),
    mean_var4 = mean(var4, na.rm = TRUE)
  )
print(balance)

# 3. Exclusión del instrumento ====================================================================
# El instrumento debe afectar a la variable dependiente (lnc) solo a través de la variable endógena (porcentaje_retirados)
# Argumentar que elegibilidad no afecta directamente a lnc, sino a través de porcentaje_retirados

# Realizar la regresión IV
iv_model <- ivreg(lnc ~ porcentaje_retirados + var1 + var2 + var3 + var4 | elegibilidad + var1 + var2 + var3 + var4, data = vi_rd)
summary(iv_model)

# Presentar los resultados en una tabla
stargazer(iv_model, type = "text", title = "Resultados del Modelo de Variables Instrumentales")

# Modelos por mínimos cuadrados ordinarios (OLS)
ols_model1 <- lm(lnc ~ porcentaje_retirados, data = vi_rd)
ols_model2 <- lm(lnc ~ porcentaje_retirados + var1 + var2 + var3 + var4, data = vi_rd)
stargazer(ols_model1, ols_model2, type = "text",
      title = "Resultados de los Modelos OLS",
      column.labels = c("OLS Modelo 1", "OLS Modelo 2"),
      model.names = FALSE)

# Modelos de intención a tratar (ITT)
itt_model3 <- lm(lnc ~ elegibilidad, data = vi_rd)
itt_model4 <- lm(lnc ~ elegibilidad + var1 + var2 + var3 + var4, data = vi_rd)
stargazer(itt_model3, itt_model4, type = "text",
      title = "Resultados de los Modelos ITT",
      column.labels = c("ITT Modelo 3", "ITT Modelo 4"),
      model.names = FALSE)

# Modelos de variables instrumentales (2SLS)
iv_model5 <- ivreg(lnc ~ porcentaje_retirados | elegibilidad, data = vi_rd)
iv_model6 <- ivreg(lnc ~ porcentaje_retirados + var1 + var2 + var3 + var4 | elegibilidad + var1 + var2 + var3 + var4, data = vi_rd)
stargazer(iv_model5, iv_model6, type = "text",
      title = "Resultados de los Modelos IV",
      column.labels = c("IV Modelo 5", "IV Modelo 6"),
      model.names = FALSE)

#---# DIFERENCIAS EN DIFERENCIAS ------------------------------------------------------------------

# Análisis del Efecto del Incinerador de Basura en el Precio de las Viviendas =====================

# a)
# Filtrar datos para el año 1981 y hacer la regresión lineal
df_1981 <- base_diff_in_diff %>% filter(year == 1981)

modelo_1981 <- lm(rprice ~ nearinc, data = df_1981)
# stargazer(modelo_1981, type = "text", title = "Resultados de la Regresión Lineal para 1981")

# b)
# Lo mismo que en a), filtramos datos para el año 1978 y hacemos la regresión lineal
df_1978 <- base_diff_in_diff %>% filter(year == 1978)

modelo_1978 <- lm(rprice ~ nearinc, data = df_1978)
# stargazer(modelo_1978, type = "text", title = "Resultados de la Regresión Lineal para 1978")

stargazer(modelo_1981, modelo_1978, type = "text", 
          title = "Resultados de las Regresiones Lineales para 1978 y 1981", 
          column.labels = c("Modelo 1981", "Modelo 1978"), 
          model.names = FALSE)

# c) 
precio_real <- base_diff_in_diff
precio_real$nearinc <- ifelse(precio_real$nearinc == 1, "Cerca", "Lejos")
precio_real$nearinc <- factor(precio_real$nearinc, levels = c("Cerca", "Lejos"))

# d)
# Graficar el precio real de las casas en el tiempo, diferenciando por proximidad al incinerador
ggplot(precio_real, aes(x = factor(year), y = rprice, color = nearinc)) +
  geom_boxplot() +
  geom_jitter(alpha = 0.6, position = position_jitter(width = 0.2)) +
  labs(title = "Precio Real de las Casas en 1978 y 1981",
       x = "Año",
       y = "Precio Real",
       color = "Proximidad al Incinerador")

# e) 
# Calcular los promedios de rprice por año y proximidad al incinerador
promedios <- base_diff_in_diff %>%
  group_by(year, nearinc) %>%
  summarize(prom_rprice = mean(rprice, na.rm = TRUE))
print(promedios)

# Calcular el efecto Diff-in-Diff
promedio_1978_lejos = promedios[1, 3]
promedio_1978_cerca = promedios[2, 3]
promedio_1981_lejos = promedios[3, 3]
promedio_1981_cerca = promedios[4, 3]

diff_in_diff = (promedio_1981_cerca - promedio_1978_cerca) - (promedio_1981_lejos - promedio_1978_lejos)
print(diff_in_diff)

# f)
# Realizar la regresión lineal Diff-in-Diff
diff_in_diff_model <- lm(rprice ~ y81 + nearinc + y81*nearinc, data = base_diff_in_diff)
stargazer(diff_in_diff_model, type = "text", title = "Resultados de la Regresión Diff-in-Diff")

# Análisis de la Influencia de la Distancia al Incinerador sobre el Precio de las Viviendas =======

# Estimamos el modelo con la interacción
modelo_a <- lm(lprice ~ y81 + ldist + y81ldist, data = base_diff_in_diff)

# Estimamos el modelo con las otras variables
modelo_b <- lm(lprice ~ y81 + ldist + y81ldist +
                age + agesq + rooms + baths + lintst + lland + larea, data = base_diff_in_diff)

stargazer(modelo_a, modelo_b, type = "text",
      title = "Resultados de los Modelos de Regresión",
      column.labels = c("Modelo 1", "Modelo 2"),
      model.names = FALSE)
