# Limpia la lista de objetos
rm(list = ls()) 

# Librerías necesarias
library(dplyr)
library(ggplot2)

# Definir número de observaciones y número total de simulaciones
num_obs <- 1000
total_sim <- 1000

# Vector para almacenar el porcentaje de falsos positivos para cada número de variables dependientes
falsos_positivos <- numeric(10)

for (num_vars in 1:10) {
  bingo <- 0
  
  for (simul in 1:total_sim) {
    # Asignación de tratamiento aleatorio
    u <- runif(num_obs)
    tratamiento <- ifelse(rank(u) <= num_obs / 2, 1, 0)
    
    # Generación de variables dependientes
    vardep <- replicate(num_vars, qnorm(runif(num_obs)), simplify = FALSE)
    
    # Comprobación de significancia en múltiples variables dependientes
    significativo <- FALSE
    for (v in vardep) {
      reg <- lm(v ~ tratamiento)
      if (summary(reg)$coefficients[2, 4] < 0.05) {
        significativo <- TRUE
        break
      }
    }
    
    if (significativo) {
      bingo <- bingo + 1
    }
  }
  
  # Cálculo del porcentaje de falsos positivos para el número actual de variables dependientes
  falsos_positivos[num_vars] <- bingo / total_sim * 100
}

# Crear un dataframe para ggplot
df_resultados <- data.frame(
  NumVariables = 1:10,
  PorcentajeFalsosPositivos = falsos_positivos
)

# Gráfico del porcentaje de falsos positivos
ggplot(df_resultados, aes(x = NumVariables, y = PorcentajeFalsosPositivos)) +
  geom_line() +
  geom_point() +
  labs(
    title = "Porcentaje de Falsos Positivos en función del Número de Variables Dependientes",
    x = "Número de Variables Dependientes",
    y = "Porcentaje de Falsos Positivos"
  ) +
  theme_minimal()
