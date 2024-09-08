# install.packages("haven")
# install.packages("readxl")

# Cargar las bibliotecas
library(haven)
library(readxl)

# Importar la encuesta de caracterización socio-económica
casen <- read_dta("Casen 2022.dta")

# Importar el archivo .xls
tasa_de_natalidad <- read_excel("tasa_de_natalidad.xls")

# Importar el archivo .xlsx
censo <- read_excel("censo2017.xlsx", sheet=2)