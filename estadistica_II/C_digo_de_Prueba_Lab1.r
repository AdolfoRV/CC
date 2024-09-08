rm(list=ls())         # Limpia la lista de objetos 
options(spicen = 999) # para evitar imprimir numeros en notación científica

# Antes de ejecutar las library() deben tener instaladas las respectivas 
# librerías. Esto que se puede hace directamente en la consola con la función
# install.packages("") que se las entregamos a continuación en comentarios:

# install.packages("dplyr")
library(dplyr)

# install.packages("ggplot2")
library(ggplot2)

# A continuación, testearemos el funcionamiento de la librería de ggplot2, 
# la cual nos entregará el df de diamonds y nos permite realizar gráficos.
# Por otro lado, la librería dplyr nos permitirá hacer un resumen y seleccionar
# columnas del df.

# Resumen de los datos de diamonds
summarize(diamonds)

# Seleccionamos las columnas del df diamonds, carat y price.
diamonds_selected <- diamonds %>%
  select(carat, price)

# Probamos la librería ggplot2 utilizando geom_bin_2d
grafico_bin_2d <- ggplot(diamonds_selected, aes(x = carat, y = price)) +
  geom_bin_2d(bins = 25) +
  labs(title = "Gráfico de dispersión binario 2D",
       x = "Quilates",
       y = "Precio")

# Ahora con geom_histogram
grafico_histograma <- ggplot(diamonds_selected, aes(x = price)) +
  geom_histogram(binwidth = 500) +
  labs(title = "Histograma del precio de los diamantes",
       x = "Precio",
       y = "Frecuencia")

# Mostrar ambos gráficos
grafico_bin_2d
grafico_histograma


#ahora se prueba un for and if en R 
partidos <- list(c(2,1),c(3,7),c(6,3))
for (partido in partidos){
  if (partido[1] > partido[2]){
    print("Victoria")
  } else {
    print ("Derrota")
  }
}
