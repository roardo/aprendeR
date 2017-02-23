# Instalamos dplyr y cargamos la librería 
# (no tenemos que hacer el primer paso si ya la tenemos instalada)
install.packages('dplyr')
library(dplyr)

# Al tener dplyr cargada, podemos usar el operador pipe (%>%), que nos permite componert funciones:
iris %>% head(10)

# Tomamos el dataset iris, lo filtramos para los renglones donde Sepal.Length sea < 5 y 
# luego seleccionamos la columna Species. Esto nos regresa sólo la columna Species, pero filtrada por el criterio de arriba.
iris %>% 
  filter(Sepal.Length < 5) %>%
  select(Species)

# Hacemos un ejercicio parecido, usando dos filtros (i.e., esto nos regresa los renglones que cumplan ambos criterios)
# Luego, seleccionamos todas las variables de Sepal.Length hasta Sepal.Width. Al usar rangos, tenemos que tomar en cuenta el orden de las columnas.
iris %>%
  filter(Sepal.Length < 5,
         Species == 'setosa') %>%
  select(Sepal.Length:Petal.Width)

# Podemos usar select helpers para no tener que escribir a mano los nombres de las variables:
# Para más dudas sobre los select helpers, revisen ?select
iris %>%
  select(starts_with('Sepal'))

iris %>%
  select(contains('Wid')) %>%
  head()

# El signo - implica que estamos haciendo selección "negativa": pedimos todas las variables menos las que tengan un nombre con "Wid"
iris %>%
  select(-contains('Wid'))

#Hacemos selección con dos criterios: "dame las variables que empiecen con Petal, pero no contengan "Width"
iris %>%
  select(starts_with('Petal'),
           -contains('Width')) %>%
  head()

# Otro select helper: one_of
vars <- c('Petal.Length', 'Petal.Width')

iris %>%
  select(one_of(vars))


# Podemos usar el operador pipe hacia otras funciones, no de dplyr:
# names() me regresa los nombres del objeto en cuestión
iris %>% names()

# unique() me regresa un vector con los valores únicos de un vector (los números son row numbers, no la cuenta de cuántos tiene cada valor)
iris %>%
  select(Species) %>%
  unique()
  
# Todas las fuciones de dplyr tienen su versión normal y su versión _. 
# El _ nos permite usar variables de texto para que dplyr las tome literalmente

# Esto nos regresa la columna Species
iris %>% select_('Species')

mivariable <- 'Species'

# Esto no sirve, porque no pusimos _
iris %>% select(mivariable)

# Esto nos da el mismo resultado que el de arriba:
iris %>% select_(mivariable)

micriterio <- 'Species == "Setosa"' # Hay que revisar cómo escapar esto:

# Podemos usar esto también para filters:
micriterio2 <- 'Petal.Length < 4'
iris %>%
  filter_(micriterio2)

# Arrange.
# El default arregla en orden ascendente
iris %>% 
  arrange(Petal.Length) %>%
  head(20)
# Agregando un menos, ordenamos en orden descendente
iris %>% 
  arrange(-Petal.Length) %>%
  head(20)

#Podemos combinar criterios
iris %>% 
  arrange(Petal.Length, -Petal.Width) %>%
  head(20)

# Mutate: crea nuevas variables.
# Nota cómo podemos usar la variable recién creada en la misma función:
iris %>%
  mutate(area = Petal.Length*Petal.Width,
         area100 = area*100)

# Puedo meter cualquier función que se me ocurra (mientras se pueda calcular con mis datos) adentro del mutate
mifun <- function(a, b){
  a*b
}

iris %>%
  mutate(area = mifun(Petal.Length, Petal.Width))

# Group_by: agrupa el dataframe de acuerdo a cierta variable (tiene más sentido si es categórica):

# Aquí, estoy agrupando por especie y luego sacando las medias de largo, ancho y área por especie

iris %>%
  group_by(Species) %>%
  summarise(petal_length_mean = mean(Petal.Length),
            petal_width_mean = mean(Petal.Width),
            petal_area_mean = mean(mifun(Petal.Length, Petal.Width)))

# Nota que esto nos arroja justo el mismo resultado:

iris %>%
  mutate(area = mifun(Petal.Length, Petal.Width)) %>%
  group_by(Species) %>%
  summarise(petal_length_mean = mean(Petal.Length),
            petal_width_mean = mean(Petal.Width),
            petal_area_mean = mean(petal_area))

# El arrange también respeta el criterio de agrupación. Si hago un group_by antes, el arrange ordena las filas
# de acuerdo a Petal.Length, pero para cada especie (i.e., son tres órdenes separados):

iris %>%
  group_by(Species) %>%
  arrange(Petal.Length) %>% View()

# Nota cómo podemos usar el group_by con el resto de las funciones de dplyr. 
# Aquí, el mutate toma la media por especie en el denominador. 
# Así, petal_length_relativo es la razón entre Petal.Length y la media de Petal.Length de la especie
iris %>%
  group_by(Species) %>%
  mutate(petal_length_relativo = Petal.Length/mean(Petal.Length))
