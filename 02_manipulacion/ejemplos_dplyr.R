# Experimentitos con la base de datos flights.csv para explicar algunas funciones de dplyr

nuevos_datos <- group_by(flights, carrier) %>%
                arrange(., dep_delay) %>%
                mutate(., no_departure = row_number()) %>%
                select(., carrier, dep_delay, no_departure) %>%
                filter(., carrier=="AA" | carrier=="AS") %>%
                arrange(., carrier)


nuevos_datos2 <- arrange(flights, dep_delay) %>%
  group_by(., carrier) %>%
  mutate(., no_departure = row_number()) %>%
  select(., carrier, dep_delay, no_departure) %>% 
  filter(., carrier=="AA" | carrier=="AS") %>%
  
  
nuevos_datos3 <- group_by(flights, carrier) %>%
  dplyr::summarise(., media_dd = mean(dep_delay, na.rm =T))
