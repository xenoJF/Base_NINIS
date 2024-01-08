library(tidyverse)
library(openxlsx)
# Directorios y archivos ---------------------------------------------------------------

setwd('./GEIH_NINIS')
Directorio <- dir(getwd())
CSV<- grepl('\\.CSV$|\\.csv$',Directorio,ignore.case = T)
Direct_CSV<- subset(Directorio,CSV==TRUE)

# Data frames---------------------------------------------------

General_info<- list()
No_OCI<- list()


# Detección de campos -----------------------------------------------------
info_general<- grep('Características generales',Direct_CSV,value = T)
Noci<- grep('No ocupados', Direct_CSV,value = T)

# Importación de bases ----------------------------------------------------

# Información general
for(info_general in info_general){
  datos <- read.csv(info_general,sep = c(';',','),dec = '.')
  General_info[[info_general]] <- datos
}

Trim_General<- bind_rows(General_info,.id = 'info_general')

# Desocupados
for(Noci in Noci){
  datos <- read.csv(Noci,sep = c(';',','),dec = '.')
  No_OCI[[Noci]] <- datos
}

Trim_desocupados<- bind_rows(No_OCI,.id = 'Noci')

# Cruce de información 


GEIH_Jul_Sep23<- merge(Trim_General,Trim_desocupados,
                       by=c("DIRECTORIO","SECUENCIA_P","ORDEN"),no.dups = T)


Juventud_NINI<- GEIH_Jul_Sep23 %>% filter(P6040>=15 & P6040<=28,P6170==2)

# Verificación 
fex<- Juventud_NINI$FEX_C18.x
dsi<- Juventud_NINI$DSI
fft<- Juventud_NINI$FFT

w<-round(sum(dsi*(fex/3),na.rm = T))
k<-round(sum(fft*(fex/3),na.rm = T))

w+k # = 2.423.688 ninis colombia (Conmfirmado) 


# NINIS CTG 2023 ---------------------------------------------------------------
CTG_NINIS_Jul_Sep23<- Juventud_NINI %>% filter(AREA.x==13)

# Exportacion de la base de datos
setwd("../Result")
write.xlsx(CTG_NINIS_Jul_Sep23,file = 'NINIS_CTG_jul-sep23.xlsx')





