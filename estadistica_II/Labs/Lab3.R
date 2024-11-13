library("MASS")
library("dplyr")
library("ivreg")
library("readxl")

df <- read_excel("datos/df_lab3_2024.xlsx")

# Compliers vs No compliers
table(df[, c('Z', 'X')])

pi1 = sum(df$Z==1 & df$X==1)/sum(df$Y[df$Z==1]) # 235/(235+0): compliers del grupo de tratamiento
pi0 = sum(df$Z==0 & df$X==1)/sum(df$Y[df$Z==0]) # 91/(91+174): no compliers del grupo de control (z=0, x=1, o sea que fueron tratados pero no asignados) / grupo de control 

# Estimaciones OLS, ITT y LATE
OLS = summary(lm(Y ~ X, data=df))
OLS
print(OLS$coefficients[2,1]) # recibir la estimación asociada a la variable endógena (fila 2 columna 1)

# LATE = ITT/ITTd
ITT = summary(lm(Y ~ Z, data=df))
print(ITT)
ITT = mean(df$Y[df$Z==1]) - mean(df$Y[df$Z==0])
ITTd = pi1 - pi0
LATE = ITT/ITTd         # Solo funciona para estimaciones sin variables de controles
print(LATE)

# LATE en 2 etapas
first_stage = lm(X ~ Z, data=df)
df$X_hat = predict(first_stage, newdata=df)

second_stage = summary(lm(Y ~ X_hat, data=df))
print(second_stage)

# LATE 2SLS sin controles
iv_reg1 = summary(ivreg(Y ~ X | Z, data=df))   # Aquí te da el test de relevancia (weak instrument) e independencia (Hausman)
print(iv_reg1)

# LATE 2SLS con controles
iv_reg2 = summary(ivreg(Y ~ X + Q1 + Q2 + Q3 | Z + Q1 + Q2 + Q3, data=df))
print(iv_reg2)

### Chequear supuestos

# El instrumento es relevante (!= 0)
summary(lm(X ~ Z, data=df))
summary(lm(X ~ Z, data=df))coefficients[2,1]

# Supuesto de independencia (si se aplica asignación aleatoria), esto se puede seudo verificar con el test de Hausman o con un balance donde si las covariables son en promedio iguales para ambos grupos se tiene independencia
df %>% group_by(Z) %>% summarize("promedio Q" = mean(Q1))
df %>% group_by(Z) %>% summarize("promedio Q" = mean(Q2))
df %>% group_by(Z) %>% summarize("promedio Q" = mean(Q3))

# Restricciones de exclusión, argumentar que el instrumento no afecta directamente a la variable dependiente

###

# Cuando hay endogeneidad LATE a dos etapas es más ineficiente que OLS pero es insesgado