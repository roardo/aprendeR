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
  dummy <- ifelse(x %in% c("INSTITUTO MEXICANO DEL SEGURO SOCIAL",
                  "IMSS", "INFONAVIT",
                  "INSTITUTO DEL FONDO NACIONAL DE LA VIVIENDA PARA LOS TRABAJADORES"),
                  1, 0)
  dummy
}
#Aquí no quiero que me modifique el data set original, sino un subconjunto
#del mismo. Así que, voy a crear un nuevo dataset y ese subconjunto ahí.

codemandas <- data.frame(df %>% select(starts_with('nombre_d'), id_exp) %>% 
  gather(key = nombre,value = nombre_d, -id_exp) %>% 
  arrange(id_exp) %>% 
  mutate(dummy = function_dummy(nombre_d)) %>% 
  group_by(id_exp) %>% filter(.,dummy==1)) 

View(codemandas)
#########Terminaciones y cuantificaciones##############


#Limpia la variable c_sal_caidos:

df <- df %>% mutate(c_sal_caidos= 
                as.numeric(gsub('[^[:digit:]]','',c_sal_caidos)))
df %>% select(starts_with("c_sal")) %>% View()
#Supongo que debe de haber una forma de poner esas dos lineas en una sola.

na_function = function(x){
  dummy <- ifelse(is.na(x),0,x)
  dummy
}
otra_function = function(x){
  dummy <- gsub('[^[:digit:]]','',x)
}

#Lo que no es númerico quedan como NA
df <- df %>% 
  mutate(monto_hextra_sem = na_function(otra_function(monto_hextra_sem))) %>%
  mutate(monto_vac = na_function(otra_function(monto_vac))) %>%
  mutate(monto_ag = na_function(otra_function(monto_ag))) %>%
  mutate(monto_indem = na_function(otra_function(monto_indem))) %>%
  mutate(monto_sal_caidos = na_function(otra_function(monto_sal_caidos))) %>%
  mutate(monto_prima_antig = na_function(otra_function(monto_prima_antig))) %>%
  mutate(monto_prima_vac = na_function(otra_function(monto_prima_vac))) %>%
  mutate(monto_hextra_total = na_function(otra_function(monto_hextra_total))) %>%
  mutate(monto_desc_sem= na_function(otra_function(monto_desc_sem))) %>%
  mutate(monto_desc_ob= na_function(otra_function(monto_desc_ob))) %>%
  mutate(monto_utilidades= na_function(otra_function(monto_utilidades)))

df %>% select(contains("monto")) %>%  View()

df <- df %>% 
  mutate(liq_total = na_function(liq_total)) %>%
  mutate(liq_total_tope = na_function(liq_total_tope)) 

df %>% select(contains("liq_total")) %>% View()

df <- df %>% mutate(proxy_exa = c_total/min_ley)
df %>% select(proxy_exa) %>% View()

df <- df %>%  
  mutate(dummy_prevencion = na_function(dummy_prevencion))
df %>% select(dummy_prevencion) %>%  View()

#¿Qué es "con modo de término"?

df <- df %>% mutate(prop_hextra = c_hextra/c_total)
df %>% select(prop_hextra) %>% View()

#*****************TOP Despachos***********************

top_despachos <- df %>% count(despacho_ac)
top_despachos %>% arrange(-n) %>% View()

#No es exactamente la frecuencia, pero es caaaaasi igual 
#¯\_(ツ)_/¯

