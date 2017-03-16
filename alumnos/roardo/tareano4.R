library(readr)
library(dplyr)
library(lubridate)
library(tidyr)
library(stringr)
library(knitr)

#Fechas
limpia_fechas <- function(date){
  fecha <- as.Date(as.numeric(date), origin="1899-12-30")
  fecha[grepl("\\/", date)] <- dmy(date[grepl("\\/", date)])
  fecha
}

#Leer la bases de datos

df <- read_csv("base_iniciales.csv") %>%
  dplyr::select(., clave:dummy_nulidad, fecha_termino:liq_total_tope) %>%
  mutate_each(., funs(limpia_fechas), 
              contains("fecha"), -contains("vac"), -contains("ag")) 

View(df)

##################### Codemanda IMSS ########################
function_dummy = function(x){
  if(grepl("INSTITUTO MEXICANO DEL SEGURO SOCIAL",x)){
    dummy <- 1
  }
  else{
    dummy <- 0
  }
  dummy
}
#
function_dummy = function(x){
  dummy <- ifelse(x %in% c("INSTITUTO MEXICANO DEL SEGURO SOCIAL",
                  "IMSS", "INFONAVIT",
                  "INSTITUTO DEL FONDO NACIONAL DE LA VIVIENDA PARA LOS TRABAJADORES"),
                  1, 0)
  dummy
}
#
df %>% select(starts_with('nombre_d'), id_exp) %>% 
  gather(key = nombre,value = nombre_d, -id_exp) %>% 
  arrange(id_exp) %>% 
  mutate(dummy = function_dummy(nombre_d)) %>% 
  group_by(id_exp) %>% View()


#########Terminaciones y cuantificaciones##############


#Funciona!#
df %>% mutate(c_sal_caidos= 
                as.numeric(gsub('[^[:digit:]]','',c_sal_caidos))) %>%
  select(starts_with("c_")) %>%
  View()

#Dado que los números que aparecen ahí son en realidad texto
#lo mejor que se me ocurre es primero pasar cada entrada a número
#si en realidad es un número entonces lo pasa a número, de otra forma
#lo pone en cero
na_function = function(x){
  dummy <- ifelse(is.na(x),0,x)
  dummy
}
otra_function = function(x){
  dummy <- gsub('[^[:digit:]]','',x)
}

#El problema que resta son los espacios vacios, no sé como los interprete R
df %>% 
  mutate(monto_hextra_sem = otra_function(monto_hextra_sem)) %>%
  mutate(monto_vac = otra_function(monto_vac)) %>%
  mutate(monto_ag = otra_function(monto_ag)) %>%
  select(contains("monto")) %>%  View()


