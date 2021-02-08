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




























##########################################
#####Esta parte se la tengo que dedicar a pegar esto con las precipitaciones
##########################################

####Primero vamos a unir los resultados anteriores en un solo archivo
setwd("C:\\Users\\Luis_Romero\\Datos_mun_preci")
lista <- lapply(dir(), read.csv)
data <- do.call(rbind, lista)
data <- select(data,prep_anu:MUNICIPIO)
data <- rename(data,Mpio=MUNICIPIO)
unique(data$Mpio)


Claves<-read.csv("C:\\Users\\Luis_Romero\\Desktop\\Proyecto agua\\clave_municipio.csv",sep=";")
Claves<-mutate(Claves,mun_est=tolower(mun_est),Municipio=tolower(Municipio))
Claves<-mutate(Claves,mun_est=stri_trans_general(mun_est,"Latin-ASCII"),Municipio=stri_trans_general(Municipio,"Latin-ASCII"))

data<-mutate(data,Mpio=tolower(Mpio))
data<-mutate(data,Mpio=stri_trans_general(Mpio,"Latin-ASCII"))
data<-merge(data,select(Claves,Municipio,cve),by.x="Mpio",by.y="Municipio")

names(data)
head(Base_final)

faltantes<-read.csv("C:\\Users\\Luis_Romero\\Desktop\\Proyecto agua\\repetidos.csv",sep=";")
faltantes<-mutate(faltantes,Mpio=tolower(Mpio))
faltantes<-mutate(faltantes,Mpio=stri_trans_general(Mpio,"Latin-ASCII"))

Base_final<-mutate(Base_final,Mpio=tolower(Mpio))
Base_final<-mutate(Base_final,Mpio=stri_trans_general(Mpio,"Latin-ASCII"))

buenos_datos<-filter(data,!(Mpio %in% faltantes[,1]))
buenos_datos<-select(buenos_datos,prep_anu,year,cve)

###Aqui ya se pegan finalmente las dos con el echo de que tiene RHA
BASE_FINAL<-rbind(buenos_datos,rename(base_aux1,cve=MUNICIPIO))
write.csv(BASE_FINAL,"C:\\Users\\Luis_Romero\\Desktop\\Proyecto agua\\precipitacion_fin.csv")
Base_final1<-select(Base_final,Anual,Año,Cve_Mpio,RHA)
BASE_FINAL_1<-unique(merge(unique(BASE_FINAL),select(Base_final1,Cve_Mpio,RHA),catalogo,by.x="cve",by.y="Cve_Mpio"))
BASE_FINAL_1<-rename(BASE_FINAL_1,Cve_Mpio=cve,Año=year,Anual=prep_anu)
w2<-rbind(BASE_FINAL_1,Base_final1)
write.csv(w2,"C:\\Users\\Luis_Romero\\Desktop\\Proyecto agua\\precipitacion_fin1.csv")


###Enlaces entre RH y RHA
z<-XML::xmlToDataFrame("http://201.116.60.29/servicios/api/disponibilidadcuencashidrologicas/2018")
head(z);names(z)
catalogo<-select(z,Id_rh,nom_rh,Id_RHA,RHA)
catalogo<-catalogo[!duplicated(catalogo), ]
write.csv(catalogo,"C:\\Users\\Luis_Romero\\Desktop\\Proyecto agua\\RH-RHA.csv",fileEncoding="latin1")
?write.csv


##############################################
########Desarrollo de los datos R#############
#############################################
library(dplyr)
#setwd("C:\\Users\\Luis_Romero\\Documents\\GitHub\\Programacion-con-R-Santander")
setwd("C:\\Users\\Luis_Romero\\Desktop\\Proyecto agua\\Bases_finales")
#datos Cuenca
datos_agua<-read.csv("Cuencas con disponibilidad (2010-2020).csv",sep=";")
#Seleccion de los datos Cuenca con disponibilad 
datos_agua_1<-select(datos_agua,n,clv,nom_cue,vmae,vaeas,dma,a,year,RHA)
datos_agua_1<-na.omit(datos_agua_1)
unique(datos_agua_1$year)
setwd("C:\\Users\\Luis_Romero\\Desktop\\Proyecto agua\\Municipios")
#Establecer el directorio donde estan los archivos
lista <- lapply(dir(), read.csv)

#renombreamos la columna nom_cue
datos_agua_1<-rename(datos_agua_1,CUENCA=nom_cue)
names(datos_agua_1)
unique(datos_agua_1$year)
#########################
####Estimaciones a futuro
########################
library(tidyverse)
library(rlang)
i<-92
CUENCAS<-unique(datos_agua_1$CUENCA)
CUENCAS[i]
str(aux)
#Preci
datos_agua_11<-data.frame()
for (i in 1:length(CUENCAS)){
  aux<-filter(datos_agua_1,CUENCA==CUENCAS[i])
  aux<-aux[order(-aux$year),]
  col<-c("vmae","dma","a","vaeas")
  #str(aux)
  
  #mutate(aux,!!sym("CUENCA") := as.character(!!sym("CUENCA")))
  
  
  #for (j in (1:length(col))){
  #  var<-col[j]
  #  me<-mean(filter(aux,!!sym(var())!="-")))
  #  aux<-mutate(aux,!!sym(var)=gsub("-",as.character(me),))
  #  aux<-mutate(aux,all_of(col[j])=gsub(",",".",all_of(col[j])))
  #  }
  #library(dplyr)
  #aux[,"a"]
  #names(aux)
  #select(aux,a)
  if (dim(filter(aux,vmae=="-"))[1]>0){
    me<-mean((aux %>% filter(vmae!="-") %>% mutate(vmae=as.double(as.character(vmae))) %>% select(vmae))[,1])
    aux<-mutate(aux,vmae=as.double(gsub(",","",gsub("-",as.character(me),vmae))))
  }
  if (dim(filter(aux,vaeas=="-"))[1]>0){
      
      me<-mean((aux %>% filter(vaeas!="-") %>% mutate(vaeas=as.double(as.character(vaeas))) %>% select(vaeas))[,1])
      aux<-mutate(aux,vaeas=as.double(gsub(",","",gsub("-",as.character(me),vaeas))))
  }
  if (dim(filter(aux,dma=="-"))[1]>0){
    me<-mean((aux %>% filter(dma!="-") %>% mutate(dma=as.double(as.character(dma))) %>% select(dma))[,1])
    aux<-mutate(aux,dma=as.double(gsub(",","",gsub("-",as.character(me),dma))))
  }
  if (dim(filter(aux,a=="-"))[1]>0){
    me<-mean((aux %>% filter(a!="-") %>% mutate(a=as.double(as.character(a))) %>% select(a))[,1])
    aux<-mutate(aux,a=as.double(gsub(",","",gsub("-",as.character(me),a))))
  }
  aux<-mutate(aux,vmae=as.double(as.character(vmae)),vaeas=as.double(as.character(vaeas)),dma=as.double(as.character(dma)),a=as.double(as.character(a)))
  #str(aux)
  years<-length(aux$year)
  
  if (years<16){
    year<-2005:(2020-years)
    ult<-select(aux,-year)[years,]            
    datos_extra<-data.frame()
    for (x in year){
      datos_extra<-rbind(ult,datos_extra)
    }
    year<-year[order(year,decreasing = TRUE)]
    datos_extra<-cbind(datos_extra,year)
    aux<-rbind(aux,datos_extra)
  }
  #head(aux)
  aux<-aux[-order(aux$year),]
  datos_agua_11<-rbind(aux,datos_agua_11)  
    
  
  
}
head(datos_agua_11)
#dataframe vacio
datos_finales<-data.frame()
#ciclo para hacer match con cuenca
cve_mun<-read.csv("C:\\Users\\Luis_Romero\\Desktop\\Proyecto agua\\Bases_finales\\clave_municipio.csv",sep=";")
precipitacion<-read.csv("C:\\Users\\Luis_Romero\\Desktop\\Proyecto agua\\Bases_finales\\precipitacion_fin1.csv")





for (i in 1:length(lista)){
  
  municipios<-lista[[i]]
  names(municipios)
  
  #se trabaja con las cuencas para que sean minisculas,eliminar campos vacios, y quitar acentos
  municipios<-mutate(municipios,CUENCA=tolower(CUENCA),
                     MUNICIPIO=tolower(MUNICIPIO),ESTADO=tolower(ESTADO))
  municipios<-filter(municipios,CUENCA!="",MUNICIPIO!="",ESTADO!="")
  municipios<-mutate(municipios,CUENCA=stri_trans_general(CUENCA,"Latin-ASCII"),
                     MUNICIPIO=stri_trans_general(MUNICIPIO,"Latin-ASCII"),
                     ESTADO=stri_trans_general(ESTADO,"Latin-ASCII"))
  municipios<-mutate(municipios,MUNICIPIO=as.character(MUNICIPIO),ESTADO=as.character(ESTADO))
  municipios<-mutate(municipios,mun_est=gsub(" ","",paste(MUNICIPIO,ESTADO)),sep="")
  municipios<-unique(merge(municipios,mutate(cve_mun,mun_est=stri_trans_general(tolower(gsub(" ","",mun_est)),"Latin-ASCII"))))
  
  municipios<-select(municipios,CUENCA,cve)
  merge(municipios,select(precipitacion,)
  head(datos_agua_1)
  names(precipitacion)
  #lo mismo pero para datos_agua_1
  datos_agua_1<-mutate(datos_agua_1,CUENCA=tolower(CUENCA))
  datos_agua_1<-mutate(datos_agua_1,CUENCA=stri_trans_general(CUENCA,"Latin-ASCII"))
  datos_agua_1<-filter(datos_agua_1,CUENCA!="")
  #union muncicipio y cuenca basado en el nombre de la cuenca
  w<-merge(municipios,datos_agua_1,by=c("CUENCA"))
  #cuencas que fueron asignadas a un municipip
  aux<-unique(w$CUENCA)
  #w<-merge(municipios,datos_agua_1,all.y=TRUE)
  #cuencas que no fueron asignadas a ningun municipio
  aux2<-unique(filter(datos_agua_1,!(CUENCA %in% aux))$CUENCA)
  #dejan en datos_agua_1 solo las cuencas que no han sido asiganadas a ningun municipio
  datos_agua_1<-filter(datos_agua_1,CUENCA %in% aux2)
  #guardando los datos de las cuencas que fueron asignadas a municipio en w
  w<-select(w,CUENCA,MUNICIPIO,ESTADO,
            clv,vmae,vaeas,dma,a,year)
  #unindo los datos
  datos_finales<-rbind(datos_finales,w)
  unique(aux2)
  
}

#Aux2
unique(datos_finales$CUENCA)
dim(datos_finales)
dim(unique(datos_finales))
#Datos obtenidos del ultimo for 
datos_finales<-unique(datos_finales)
datos_finales<-mutate(datos_finales,MUNICIPIO=tolower(MUNICIPIO))
datos_finales<-filter(datos_finales,MUNICIPIO!="")
datos_finales<-mutate(datos_finales,MUNICIPIO=stri_trans_general(MUNICIPIO,"Latin-ASCII"))

precipitacion<-read.csv("C:\\Users\\Luis_Romero\\Desktop\\Proyecto agua\\Bases_finales\\precipitacion_fin1.csv")
#DATOS precipitacion Renombrando columnas
precipitacion<-rename(precipitacion,MUNICIPIO=Cve_Mpio,year=Año)
#Precipitacion seleccionando columna que necesitamos
precipitacion1<-select(precipitacion,MUNICIPIO,year,Anual,RHA)

datos_finales
#Miniscula ,acentos y evitar columnas vacias de  estado datos obtenidos de for
datos_finales<-mutate(datos_finales,ESTADO=tolower(ESTADO))
datos_finales<-filter(datos_finales,ESTADO!="")
datos_finales<-mutate(datos_finales,ESTADO=stri_trans_general(ESTADO,"Latin-ASCII"))
#Miniscula ,acentos y evitar columnas vacias de precipitacion estado 
precipitacion1<-mutate(precipitacion1,ESTADO=tolower(ESTADO))
precipitacion1<-filter(precipitacion1,ESTADO!="")
precipitacion1<-mutate(precipitacion1,ESTADO=stri_trans_general(ESTADO,"Latin-ASCII"))


#unir datos de for con precipitacion con un join de MUNICIPIO,year y ESTADOS
datosC<-merge(datos_finales,precipitacion1,by=c("MUNICIPIO","year","ESTADO"))
#eliminando datos duplicados
datosC<-datosC[!duplicated(datosC),]
#los asignanamos a un nuevo dataframe 
datosCR<-datosC
#dataframes vacios
dclFinal<-data.frame()

#function de agrupamiento por año
Agrupb <- function(x) {
  dcl<-datosCR %>% group_by(CUENCA) %>%  filter(year==x) %>%  summarise(year,vmae,dma,a,promPre = mean(Anual), sumPre = sum(Anual), n = n())
  return(dcl)
}
#ciclo for final
for (i in 2005:2020){
  dclFinal<-rbind(dclFinal,Agrupb(i)) 
}

rESP<-dclFinal





Cuencas <-read.csv("https://raw.githubusercontent.com/mnaR99/proyectoCONAGUA/main/data/CUENCAS.csv")
names(Cuencas)
Cuencas<-rename(Cuencas,RegioHidrologica=RegiÃ³n.hidrolÃ³gica)

Cuenca<-mutate(Cuenca,=tolower(Nombre.de.cuenca))
precipitacion1<-filter(precipitacion1,ESTADO!="")
Cuencas<-mutate(Cuencas,RHA=stri_trans_general(Nombre.de.cuenca,"Latin-ASCII"))
#Vas tu base de cuencas y necesitas RH por cuenca 

url<-"http://201.116.60.29/servicios/api/disponibilidadcuencashidrologicas/2020"
Cuenca<-XML::xmlToDataFrame(url)
Cuenca<-read.csv(url)

Cuenca<-mutate(Cuenca,Nombre=tolower(Nombre))
precipitacion1<-filter(precipitacion1,ESTADO!="")
Cuenca<-mutate(Cuenca,Nombre=stri_trans_general(Nombre,"Latin-ASCII"))

cuenca<-select(cuenca,RHA,CUENCA)
cuenca<-mutate(cuenca,CUENCA=tolower(CUENCA))
cuenca<-mutate(Cuenca,CUENCA=stri_trans_general(CUENCA,"Latin-ASCII"))
CCH<-merge(cuenca,dclFinal,by="CUENCA")
unique(Cuenca$CUENCA)
GCCH<-data.frame()
GCCH<-CCH %>% group_by(RHA,year) %>% summarise(year,mean = mean(mean), sum = sum(sum), n = n())




GCCH<-GCCH[!duplicated(datosC),]

listaCuenca <-c("Santo Domingo","El Rosario","Rosarito","San Miguel","El Carrizal","Agua Dulce",
                "San Pedro",
                "San Lucas",
                "Río San Pedro",
                "Río San Juan 1",
                "Río San Juan 2",
                "Río Verde 1",
                "Río Verde 2",
                "Río Santa María 1",
                "Río Santa María 2",
                "Río Sabinas",
                "Río Verde",
                "Río Grande",
                "Río San Antonio",
                "Presa Santa Rosa",
                "Río San Miguel",
                "Río San Juan",
                "Río Salado",
                "Río Blanco",
                "Río Actopan",
                "Río Escondido")
listaCuenca<-tolower(listaCuenca)
listaCuenca<-stri_trans_general(listaCuenca,"Latin-ASCII")
CuencasDobles<-filter(Cuenca,Nombre %in% listaCuenca )
unique(CuencasDobles$nom_rh)
write.csv(CuencasDobles,fileEncoding ="latin1","CuencasRepetidas.csv")
CuencasDobles<-CuencasDobles()
table(CuencasDobles$nom_rh)


precip


###################3
###rEGRESIÓN MUTIPLE POR REGIÓN HIDRICA
######################
#Supongamos que tenemos un vectos con las regiones hidrigas unicas
#r_h
#Y la base de datos con las regiones hidricas pegadas
#b_r_h
as.formula(y~x1+x2)
Preci1<-mutate(Preci,Mpio=as.character(Mpio))
str(Preci1)
unique(Preci1$Año)
z<-table(select(Preci1[1:15,],Año,Mpio))
as.vector(z[1,])
Preci[5,]
for (i in 1:length(r_h)) {
  Datos_re<-filter(b_r_h,región_hidrica=r_h[i])
  measurevar <- "EscurrimientoNaturalMedioSuperficial"
  Aux<-select(Datos_re,a,prep_anu,CUENCA,year)
  Aux<-mutate(Aux,CUENCA=as.character(CUENCA))

  Anos<-unique(Aux$year)
  CUENCAS1<-unique(Aux$CUENCAS)
  for (x in 1:lenght(CUENCAS1)){
    Aux1<-filter(Aux,CUENCA==CUENCAS1[x])
    select 
  } 
  
  
#######Esto esen caso de querer escoger el minimo número de años que tienen en comun la cuenca  
  #tab<-table(select(Aux,year,CUENCA))
  #CUEN<-unique(Aux$CUENCAS)
  #year2<-unique(Aux$year)
  #n<-length(year2)
  
  #y=TRUE
  #while y{
  #  if (sum(as.vector(tab[n,]))==length(CUEN)){
  #    year_min=year2[n]
  #    y=FALSE
  #  }else{
  #    n=n-1
  #    y=TRUE
  #  }
   
  ##Revisar cual es el año más chico que todos coinciden
  #Aux %>% group_by(CUENCA,year) %>% summarise(count=)
  #year_min
  
  groupvars  <- c()
  mutate(Aux,Mul=a*prep_anu)
  cuencas <-unique(Aux$CUENCA)
  datos_regre<-filter(Aux,CUENCA=cuencas[1])
  datos_regre<-select(datos_regre,year,Mul)
  groupvars=c(cuencas[1])
  for (j in 2:length(cuencas)) {
    Aux3<-filter(Aux,CUENCAS=cuencas[j])
    rename(Aux2,j)
    datos_regre<-join(Aux3,datos_regre,by="year")
    groupvars=c(groupvars,j)
            }
}

  # This creates the appropriate string:
  form<-as.formula(paste(measurevar, paste(groupvars, collapse=" + "), sep=" ~ "))
  Model.RH<-lm(form,select(datos_regre,all_of(cuencas)))
  modelCoeffs<-model.RH$coefficients
  for (i in 2021:2022){
    aux4<-filter()
    modelCoeffs %*% C(1,)
  }
  
  ###3Teniendo la base de regiones hidricas se podria hacer 

  
  
?all_of
a<-c(1,2,3)
z<-data.frame(a)
b<-c(1,2)
cbind(z,b)
z<-read.csv("http://201.116.60.29/servicios/api/disponibilidadcuencashidrologicas/2016")
head(z)  
Preci %>% select(all_of(c("Año","Anual")))  
  #> [1] "y ~ x1 + x2 + x3"
  
  # This returns the formula:
  as.formula(paste(measurevar, paste(groupvars, collapse=" + "), sep=" ~ "))
  lm
  
}





#w<-select(w,CUENCA,MUNICIPIO,ESTADO,SUBCUENCA,
#          clv,vmae,vaeas,dma,a,year)
 
func<-function(...){
  #return(as.vector(select(Datos,...)))
  print(...[1])
}
  
func(c("Enero","Diciembre"))

