# Vamos a recordar la utilidad de summarise:
mtcars %>%
  group_by(am, cyl) %>%
  summarise(mpg_mean = mean(mpg, na.rm = T),
            disp_mean = mean(disp),
            mpg_sd = sd(mpg))

# Esto puede ser cansado si tenemos que tomar todas las variables,
# Porque tenemos que enunciarlas una por una
mtcars %>%
  group_by(am, cyl) %>%
  summarise_all(mean) %>% View()

# Notemos que podemos usar más de una función para sintentizar variables:
mtcars %>%
  group_by(am, cyl) %>%
  summarise_all(c('mean', 'sd')) %>% View()

# Podemos además usar summarise_at, que funciona con todos los select helpers:
# Sólo necesitamos llamar a vars(), y usar cualquier sintáxis que usaríamos en un select adentro de ese ambiente.
mtcars %>%
  group_by(am, cyl) %>%
  summarise_at(vars(contains('qsec')), mean)

# Otro ejemplo de cómo podemos usar los select helpers:
mtcars %>%
  group_by(am, cyl) %>%
  summarise_at(vars(mpg:vs), mean)

# Otro select helper: one_of. Ejemplo:
mis_variables <- c('mpg', 'drat')

mtcars %>%
  group_by(am, cyl) %>%
  summarise_at(vars(one_of(mis_variables)),
               mean)

# Paréntesis: notemos que podemos usar cualquier tipo de función que colapse nuestros datos con summarise.
# Por ejemplo, la función n() nos permite sacar tablas de frecuencias.
# Tanto frecuencias absolutas:
mtcars %>%
  group_by(am, cyl) %>%
  summarise(freq = n())

# Como frecuencias relativas. Este ejemplo nos lleva a darnos cuenta de otra cosa:
# Cuando usamos el operador %>%, podemos indicarle a R dónde queremos que ponga el resultado del pipe.
# Así:
mtcars %>%
  group_by(am, cyl) %>%
  summarise(freq = n()/nrow(.))

# y 
mtcars %>%
  group_by(am, cyl) %>%
  summarise(data = ., freq = n()/nrow(.))

# nos dan los mismos resultados. Aquí arriba, estoy tomando el número de observaciones por grupo, n(), 
# y dividiéndolo entre el número de filas de todo el dataset para sacar frecuencias relativas.

# Notemos que, en general, podemos indicarle a R tantas veces como necesitemos que use el resultado del pipe:
# (Este ejemplo no se corre):
mtcars %>%
  mifuncion(data = ., x = 1, otroparametro = .)

#Este ejemplo no se corre, pero noten cómo puedo crear cualquier función y usarla en un mutate_at. 
# Si tengo muchas variables a las que quiero limpiar de la misma manera, puede ser bastante útil aplicarles lo mismo

# Otro ejemplo que no se corre:
mifuncion <- function(x){
  x %>%
  gsub('$', '', .) %>%
  as.numeric()
}

misdatos %>%
  mutate_at(vars(misvariables), mifuncion)

# Regresemos a mtcars. Último ejemplo interesante: summarise_if. 
# Podemos mutar o resumir condicionalmente a cierta característica DE LAS VARIABLES (por ejemplo, tipo de variable): 
mtcars %>%
  group_by(am, cyl) %>%
  summarise_if(is.numeric, mean, na.rm = T)

# Cambiando un poco de tema: datos limpios. Esto significa:
# 1. Cada renglón es una observación
# 2. Cada variable es una columna
# 3. Cada unidad observacional es una tabla

# Suena tonto y obvio, pero la mayoría de los datos que analizamos no fueron recolectados pensando en analizarse.
# Recordemos los ejemplos que vimos en clase, las bases de datos de INEGI, etc...

# Primero, instalemos el paquete y llamemos a la librería:
# install.packages('tidyr')
# library(tidyr)

# Primero, vamos a ver gather
# Tomemos un ejemplo genérico. Imaginemos que tenemos una matriz de datos así: 
library(pryr)
# Si no tienes pryr instalado, sólo descárgalo y llámalo

# Voy a usar la función partial para declarar unos valores por default
# Esta es una especie de atajo para no siempre declarar todo cada vez, si quieren luego lo platicamos
my_sample <- partial(sample, x = 20:200, size = 26, replace = T)

# Vamos a crear unos datos cualquiera, para ejemplificar un caso de non-tidy data. 
misdatos <- data.frame(region = LETTERS, 
                       age0_14 = my_sample(), 
                       age15_30 = my_sample(),
                       age31_45 = my_sample())

# Notemos cómo la variable edad está en tres columnas distintas,
# y la variable frecuencia no tiene su propia columna.
# Vamos a arreglar eso con la función gather. 

misdatos %>%
  gather(key = age, value = frequency,
         -region) 

# Lo que hace es lo siguiente: 
# Toma misdatos, 
# toma los nombres de las columnas (menos los que pedí que excluyera, que en este caso es religion)
# Los nombres de las columnas, los pone en una variable que se llame age. Los valores que toman esas columnas,
# los pone en una variable que se llame frequency. 

# Otro ejemplo de non-tidy data: a veces, hay más de una fila para la misma observación.
# Mira estos datos: nos gustaría tener una sola fila de estado, con tres columnas: temp_max, temp_min y temp_avg
misdatos_vertical <- data.frame(region = sort(rep(LETTERS[1:10], 3)),
                                type = rep(c('temp_max',
                                           'temp_min',
                                           'temp_avg'), 10),
                                temp = rnorm(30))

# Para eso vamos a usar la función spread.
# Lo que hace es, a la inversa de gather: toma la columna que te especifico en key, y sepárala en una columna distinta para cada valor que tenga
# Llena esas columnas con el valor de la variable que te especifique en value. Mira el resultado:

misdatos_vertical %>%
  spread(key = type,
         value = temp)

# Último ejemplo: a veces tenemos datos mezclados en más de una columna. Un ejemplo típico son los datos agregados de INEGI:

datos_juntos <- data.frame(estado = LETTERS,
                           m_0_14 = my_sample(),
                           m_15_30 = my_sample(),
                           m_31_45 = my_sample(),
                           f_0_14 = my_sample(),
                           f_15_30 = my_sample(),
                           f_31_45 = my_sample())

# Parece que tenemos dos variables en la misma columna: sexo y edad. Por otro lado, la variable frecuencia otra vez no tiene su columna
# Necesitamos separar esas columnas, como para llegar a algo parecido al primer ejemplo. Sin embargo, está un poco difícil hacerlo para cada columna
# (i.e., separar m0_14, y luego separar m15_30, etc...). Mejor primero las colapsamos todas a una sola columna:


datos_juntos <- datos_juntos %>% 
                gather(key = column, 
                       value = freq, -estado)

# Ya tenemos una sola columna que queremos separar: la columna llamada "column". Ahora, podemos usar la función separate de tidyr:
  
datos_juntos <- datos_juntos %>%
                separate(column, 
                         into = c('sex', 'age'),
                         sep = '_',
                         extra = 'merge')

# Ahora sí, tenemos una columna de sexo, otra de edad, y otra de frecuencia. 
# Con esto sí podemos hacer una gráfica de la distribución de edades, o pirámides poblacionales. (:

