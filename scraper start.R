library(tidyverse)
library(httr)
library(jsonlite)
library(RMariaDB)

get_station_data<-function(eva){
  api_call<-paste0("https://marudor.de/api/iris/v2/abfahrten/",eva,"?lookbehind=360")
  x<-GET(api_call)
  return(x)
}

read_call<-function(dat){
  #turn api call in list
  out<-fromJSON(rawToChar(dat$content))
  return(out)
}

get_route<-function(eva){
  #call api for all stations in a (named) list
  
  data<-lapply(eva,get_station_data)%>% 
    map(~read_call(.x))
  
  return(data)
}

write_data<-function(data){
  
  data %>% 
    mutate("api_call"=Sys.time())
  
  maria_connection <- dbConnect(
    drv = RMariaDB::MariaDB(), 
    username = Sys.getenv("maria_username"),
    password = Sys.getenv("maria_pw"), 
    host = Sys.getenv("maria_ip"), 
    port = Sys.getenv("maria_port"),
    "RB31"
  )
  
  dbWriteTable(maria_connection, "station_data", data,append=T)
  
}

eva<-list("Duisburg Hbf"=8000086,"Rheinhausen"=8000317,"Rumeln"=8005225,"Trompet"=8005910,
          "Moers"=8000644,"Rheinberg (Rheinl)"=8005059,"Millingen (b Rheinb)"=8004023,
          "Alpen"=8000500,"Xanten"=8006630)

x<-get_route(eva)

data<-lapply(x, "[[","lookbehind") %>% 
  bind_rows(.id="station") %>% 
  tibble() %>% 
  select(-c(currentStopPlace,route,ref)) %>% 
  unnest(cols = c(arrival,train,departure,messages), names_sep = ".")

write_data(data)