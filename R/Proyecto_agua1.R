############Librerias

suppressMessages(suppressWarnings(library(dplyr)))
library(stringi)


###############################################
##########Lectura de bases de datos############
###############################################

setwd("C:\\Users\\Luis_Romero\\Desktop\\Proyecto agua\\Bases_finales")
#setwd()
#Base_final<.read.csv("")

#################################################
#############Precipitación anual#################
#################################################

##For para obtener las precipitaciones por municipio
#Anuales y mensuales
z<-"http://201.116.60.29/servicios/api/Ambiental/PrecipitacionMensualMunicipio/2000"
#Esta base final contiene las precipitaciones por municipios
Base_final<-XML::xmlToDataFrame(z)
Base_final["Año"]<-2000
for(i in 2001:2018){
  w<-XML::xmlToDataFrame(paste("http://201.116.60.29/servicios/api/Ambiental/PrecipitacionMensualMunicipio/",i,sep=""))
  w["Año"]<-i
  Base_final<-rbind(Base_final,w)
}

#write.csv(Base_final, file = "precipitacion.csv",fileEncoding="latin1")



#############################################3
#Proyecto agua Precipitaciones
#############################################
w<-merge(municipios,datos_agua_1,all.y=TRUE)
aux<-unique(w$CUENCA)
unique(filter(w,!(CUENCA %in% aux))$CUENCA)
head(w)
which(is.na(w$n))
###########333333
library(dplyr)
data/precipitacion.csv
#https://github.com/mnaR99/proyectoCONAGUA/blob/main/data/precipitacion.csv
Preci<-read.csv("https://raw.githubusercontent.com/mnaR99/proyectoCONAGUA/main/data/precipitacion.csv")
Preci<-Base_final
head(Preci)
names(Preci)
length(unique(Preci$Mpio))
filter(Preci,Cve_Mpio==8002)
str(Preci)

##########################################################
#####Precipitaciones por municipio en un futuro###########
##########################################################


####La función que se nos compartio en clase para obtener el mejor modelo
###En base al AIC

get.best.arima <- function(x.ts, maxord = c(1, 1, 1, 1, 1, 1)){
  best.aic <- 1e8
  n <- length(x.ts)
  for(p in 0:maxord[1])for(d in 0:maxord[2])for(q in 0:maxord[3])
    for(P in 0:maxord[4])for(D in 0:maxord[5])for(Q in 0:maxord[6])
    {
      fit <- arima(x.ts, order = c(p, d, q),
                   seas = list(order = c(P, D, Q),
                               frequency(x.ts)), method = "CSS")
      fit.aic <- -2*fit$loglik + (log(n) + 1)*length(fit$coef)
      if(fit.aic < best.aic){
        best.aic <- fit.aic
        best.fit <- fit
        best.model <- c(p, d, q, P, D, Q)
      }
    }
  list(best.aic, best.fit, best.model)
}

#columns<-names(Preci)[7:19]
#Preci %>% mutate_each_(list(num=as.double),columns)
#Preci$Cve_Mpio

##Aquí se podia poner desde que municipio empezar ya que se tuvierón problemas con los siguientes municipios
#1520,2151,2170,2214,2260,2275.De aquí para adelante los municipios son "aridos"
#Error in optim(init[mask], armaCSS, method = optim.method, hessian = TRUE,  : 
#                 valor inicial en 'vmmin' no es finito
#               Además: There were 50 or more warnings (use warnings() to see the first 50)

n11<-1
Preci<-Base_final
Preci<-filter(Preci,Mpio %in% faltantes[,1])
names(Preci)
#Municipios unicos
Mun<-as.vector(unique(Preci$Cve_Mpio[n11:length(Preci$Cve_Mpio)]))
#Base inicial que tendra al final las predicciones por municipio
#227
base_mun_fin<-data.frame(prep_anu=c(),year=c(),Mpio=c())
#Años de predicción
year<-2019:2023
#Este for se tardo 4 horas en completar
for (i in n11:length(Mun)){
  #Ver como avanza el for
  print(i)
  
  #Convertir los datos de cada municipio en serie de tiempo
  Datos<-filter(Preci,Cve_Mpio==Mun[i])
  Años<-select(Datos,Anio)
  Serie<-select(Datos,Enero:Diciembre)
  vec<-as.numeric(as.vector(t(Serie)))
  plot(vec, xlab = "Tiempo",
       main = "Reserva de pasajeros aéreos internacionales", 
       sub = "Estados Unidos en el periodo 1949-1960")
  #En caso de que se tuviera una precipitación de 0 se decidio poner 0.5
  #Para que el logaritmo no puera un problema 
  Time<-ts(replace(vec,vec==0,0.5),start=c(Años[1,1]),frequency=12)
  
  #Función para encontrar el mejor modelo arima
  best.arima.elec <- get.best.arima(log(Time),
                                    maxord = c(2, 2, 2, 2, 2, 2))
  
  #El mejor modelo y predicciones
  best.fit.elec <- best.arima.elec[[2]]
  pr <- predict(best.fit.elec,60)$pred 
  
  #Transformar esta información a precipitación anual 
  vec.serie<-as.vector(aggregate.ts(exp(pr), FUN = sum))
  data.serie<-data.frame(prep_anu=vec.serie,year,MUNICIPIO=rep(as.vector(Mun[i]),5))
  base_mun_fin<-rbind(base_mun_fin,data.serie)
  
}

##Aquí se iban guardando los resultados
base_aux1<-base_mun_fin
write.csv(base_aux1,"C:\\Users\\Luis_Romero\\Documentos6.csv",fileEncoding="latin1")  

##Revisar que si se haya escrito bien 
prueba<-read.csv("C:\\Users\\Luis_Romero\\Documentos.csv")
prueba$MUNICIPIO
names(datos_agua_1)
datos_finales



#####Esto es lo necesaio antes de lo de ayer
