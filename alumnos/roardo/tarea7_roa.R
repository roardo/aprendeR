#Tarea 7

library(dplyr)
library(ggplot2)
library(readr)

df <- mtcars

#Millas por galón por tipo de cilindrada

ggplot(df, aes(cyl,mpg)) + 
  geom_boxplot(aes(group=cyl)) +
  theme_bw()

#Distribución de los caballos de fuerza

ggplot(df, aes(hp)) +
  geom_density() + 
  geom_vline(aes(xintercept=mean(hp, na.rm=T))
             ,color="red", linetype="dashed", size=1) +
  theme_bw()

#Distribución de carburadores por tipo de transimisión

df %>% 
  ggplot(aes(carb)) +
  facet_grid(am ~ .) + 
  geom_density()  +
  theme_bw()

#Distribución conjunta de peso con Displacement

df %>%
  ggplot(aes(wt,disp)) + 
  geom_dotplot() + 
  theme_classic()

#Frecuencia absoluta de cada número de carburadores
df %>% 
  ggplot(aes(carb)) + 
  geom_bar() +
  theme_bw()

#Definir la base de datos

superheroes <- '
    name, alignment, gender,         publisher
 Magneto,       bad,   male,            Marvel
   Storm,      good, female,            Marvel
Mystique,       bad, female,            Marvel
  Batman,      good,   male,                DC
   Joker,       bad,   male,                DC
Catwoman,       bad, female,                DC
 Hellboy,      good,   male, Dark Horse Comics
'
superheroes <- read_csv(superheroes, trim_ws = TRUE, skip = 1)

publishers <- '
  publisher, yr_founded
         DC,       1934
     Marvel,       1939
      Image,       1992
'
publishers <- read_csv(publishers, trim_ws = TRUE, skip = 1)

#Tabla con todos los superhéroes que salen en 
#cómics de editoriales fundadas antes de los años 90

tb1 <- inner_join(publishers,superheroes) 
#Hace un merge y dropea si el merge no es perfecto

#Junta ambas tablas

tb2 <- left_join(publishers, superheroes) 
#Hace un merge y dropea todo lo que está en superheroes que no
#matchea con al menos una observación en publishers

tb3 <- anti_join(publishers,superheroes) 

tb4 <- full_join(superheroes, publishers) %>% View()
#Full_join junta ambas tablas por medio de una variable (o unas)
#en esta caso ambas tablas comparten la variable "publisher".
#Ahora, la nueva tabla tendrá 5 variables, si hay un match perfecto
#ninguna observación tendrá un NA, en cambio si alguna variable en alguna tabla
#no está en la otra se le asigna un NA. En otras palabras, hace el merge
#entre las tablas, notamos que tb1 y tb2 son tablas que surgen a partir de tb4.
