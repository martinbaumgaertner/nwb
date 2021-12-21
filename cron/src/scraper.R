suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(purrr))
suppressPackageStartupMessages(library(tidyr))
suppressPackageStartupMessages(library(httr))
suppressPackageStartupMessages(library(jsonlite))
suppressPackageStartupMessages(library(RMariaDB))
suppressPackageStartupMessages(library(stringr))
print("Load functions")

get_station_data<-function(eva){
  api_call<-paste0("https://marudor.de/api/iris/v2/abfahrten/",eva,"?lookbehind=360")
  x<-GET(api_call)
  return(x)
}

read_call<-function(dat){
  #turn api call in list
  out<-fromJSON(str_conv(rawToChar(dat$content), "utf-8"))
  return(out)
}

get_route<-function(eva){
  #call api for all stations in a (named) list
  
  data<-lapply(eva,get_station_data)%>% 
    map(~read_call(.x))
  
  return(data)
}

write_data<-function(data){
  
  maria_connection <- dbConnect(
    drv = RMariaDB::MariaDB(), 
    username = "Martin",
    password = "Alpen1680!", 
    host = "192.168.178.26", 
    port = 3307,
    "RB31"
  )
  
  dbWriteTable(maria_connection, "station_data", data,append=T)
  dbDisconnect(maria_connection)
}

glue_messages<-function(message){
  
  if(class(message)=="list"){
    out<-NA
  }
  if(class(message)=="data.frame"){
    if(sum(dim(message))==0){
      out<-NA
    }else{
      out<-message %>% 
        unite("out",c(text,value,timestamp),sep = "|") %>%
        dplyr::summarise(out = paste(out, collapse = "}")) %>% 
        pull(out)
    }
  }
  
  return(out)
}

eva<-list("Duisburg Hbf"=8000086,"Rheinhausen"=8000317,"Rumeln"=8005225,"Trompet"=8005910,
          "Moers"=8000644,"Rheinberg (Rheinl)"=8005059,"Millingen (b Rheinb)"=8004023,
          "Alpen"=8000500,"Xanten"=8006630)
print("API call")
x<-get_route(eva)
print("Process")
data<-lapply(x, "[[","lookbehind") %>% 
  bind_rows(.id="station") %>% 
  tibble() %>% 
  select(-c(contains("currentStopPlace"),contains("route"),contains("ref")))

data<-tibble(do.call(data.frame, data))%>% 
  mutate(messages.delay=glue_messages(messages.delay),
         messages.qos=glue_messages(messages.qos),
         messages.him=glue_messages(messages.him),
         logtime=Sys.time())

print("Write data")
write_data(data)
print("Finished")