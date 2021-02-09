
#El objetivo final de esto es poder estimar la disponibilidad media de agua pro región hidrica deacuerdo a valores
#como volumen anual de escurrimiento volumen anual de extracción de aguas superficiales y de importaciones y exportaciones

#Hipotesis: 
#1.-Existe esa relación linead entre la disponibilidad de agua y las mencionadas en el parrafo anterior. 
#2.-Existe una relación lineal entre el volumen medio anual de escurrimiento natural  y la precipitación por 
#el área.
#3.-Se podra sin problema alguno realizar las series de tiempo para los municipios de todo el país aplicado a las precipitaciones. 
#

library(tidyverse)
library(stringi)

#datos las Cuencas , los cuales vienen de CONAGUA donde cada variable significa lo siguiente
#clv=Clave de la cuenca
#nom_cue=Nombre de la cuenca
#vmae=volumen medio anual de escurrimiento natural
#vaeas= Volumen anual de extracción de aguas superficiales
#RHA=Región hidrico adminsitrativa
#http://sina.conagua.gob.mx/sina/tema.php?tema=cuencas&ver=mapa&o=0&n=nacional
datos_agua <- read.csv("data/Cuencas con disponibilidad (2010-2020).csv", sep=";") %>% 
  as_tibble()

#Seleccion de los datos Cuenca con disponibilad , omitimos los valores nulos y
#cambiamos el nombre a CUENCA
datos_agua_1<-
  datos_agua %>% 
  select(n,clv,nom_cue,vmae,vaeas,dma,a,year,RHA) %>% 
  na.omit() %>% 
  rename(CUENCA = nom_cue)

# ---------------------------------------------------------------------------------------------
#Esta función lo que hara es poner la media para ciertos datos que tienen "-"

na_impute <- function(x){
  ifelse(is.na(x), mean(x, na.rm = T), x)
}

#Aquí primero estandarizamos los datos de CUENCA poniendolos en minusculas,
#sin acentos, sin espacios de más , sin puntos, luego por RHA CUENCA Y CLV 
#se imputa la media en los "-" que despues de haber sido convertidos a NA 
#se podran cambiar con facilidad con ayuda de la función, completamos la base de datos
#para homogeneisar los datos ,para que al final no se presenten caidas en las graficas
#por región hidrologica,  pueden estar disponibles lod datos del 2005 al 2020 
# y al menos lo estan del 2005 al 2020
datos_agua_11 <- datos_agua_1 %>% 
  select(-n) %>% 
  mutate(
    across(CUENCA, ~stri_trans_general(.,id = "Latin-ASCII") %>% tolower() %>% str_remove_all("\\.") %>% str_squish()),
    across(vmae:a, as.numeric)
  ) %>% 
  group_by(RHA, CUENCA, clv) %>%
  mutate(
    across(vmae:a, na_impute)
  ) %>% 
  complete(year = 2005:2023) %>% 
  fill(vmae:a, .direction = "up") %>% 
  ungroup()

# ---------------------------------------------------------------------------------------------
#Esta base lo que contiene es un catalogo de clave municipal con 
#municipios y paises, esto es para evitar duplicados más adelante
#ya que hay cuencas con el mismo nombre pero diferente región hidrica
cve_mun <- read.csv("data/clave_municipio.csv",sep=";") %>% 
  as_tibble()

#Esta tabla lo que tiene es la precipitación anual que se obtuvo en el archivo 
#Proyecto_agua1.R, que además viene por clave municipal y la RHA
precipitacion <- read.csv("data/precipitacion_fin1.csv") %>% 
  as_tibble()

#Esta tabla es un catalogo que conecta lo que es los municipios por cuenca, lo cual 
#nos ayudara a asociar una "verdadera precipitación" por cuenca(aunque despues se 
#va a tener que sacar la media por cuenca y RHA)
municipios <- read.csv("data/Catalogo_CLICOM_Precipitacion (2).csv") %>% 
  as_tibble()

#En esta parte empezamso normalizando los nombres de las cuencas por acentos, puntos , poner todo en minusculas
#sin espaccios de más,quitando vacios.
municipios <- 
  municipios %>% 
  mutate(
    across(CUENCA, ~stri_trans_general(.,id = "Latin-ASCII") %>% tolower() %>% str_remove_all("\\.") %>% str_squish()),
    MUNICIPIO=tolower(MUNICIPIO),
    ESTADO=tolower(ESTADO)
  ) %>% 
  filter(CUENCA!="",MUNICIPIO!="",ESTADO!="") %>% 
  mutate(
    CUENCA = stri_trans_general(CUENCA,"Latin-ASCII"),
    MUNICIPIO=stri_trans_general(MUNICIPIO,"Latin-ASCII"),
    ESTADO=stri_trans_general(ESTADO,"Latin-ASCII")
  ) %>% 
  mutate(
    mun_est=gsub(" ","",paste(MUNICIPIO,ESTADO)),
    sep = ""
  )

#Ahora a estos municipios les vamos a pegar la región hidrológica administrativa, además de pegarle 
# las precipitaciones anuales por año
municipiosRH <- cve_mun %>% 
  mutate(
    mun_est = stri_trans_general(tolower(gsub(" ","",mun_est)),"Latin-ASCII")
  ) %>% 
  inner_join(municipios) %>% 
  distinct(CUENCA, Cve_Mpio = cve) %>% 
  inner_join(precipitacion)

# ---------------------------------------------------------------------------------------------
#Aquí ya se le pega como tal las precipitaciones anuales por municipio por año asociada a cada cuenca 
#que hay en la base de datos , siendo lo más importante hasta el momento las variables
#anual, vmea,vaeas,a, pero este anual esta por municipio no por cuenca.
datos_agua_2 <- municipiosRH %>% 
  right_join(datos_agua_11, by = c("RHA", "CUENCA", "Año" = "year"))


#Esta base de datos servira para pregarle la región hidrologica=RH
cuencas_rh <- XML::xmlToDataFrame("http://201.116.60.29/servicios/api/disponibilidadcuencashidrologicas/2017") %>% 
  as_tibble() %>% 
  select(Id_RHA, RHA, Id_rh, nom_rh, CUENCA = Nombre) %>% 
  mutate(
    across(CUENCA, ~stri_trans_general(.,id = "Latin-ASCII") %>% tolower() %>% str_remove_all("\\.") %>% str_squish())
  )

#Con esta base de datos lo que queremos es pegarle la región hidrológica administrativa a cada cuenca, ya que es 
#necesaria para lo que finalmente se va a reportar, además de calculas las precipitaciones asociadas a cada cuenca 
#de la siguiente manera , si una cuenca esta relacionada a tres municipios , su precipitación anual sera la mediana
#de los datos por año
datos_agua_21 <- datos_agua_2 %>% 
  left_join(cuencas_rh) %>% 
  arrange(RHA, CUENCA, Año) %>% 
  filter(Año >= 2005) %>% 
  group_by(Id_rh, Año) %>% 
  mutate(
    Anual = ifelse(is.na(Anual), median(Anual, na.rm = T), Anual)
  ) %>% 
  group_by(RHA, CUENCA, Año)

precipitacion_total <- datos_agua_21 %>% 
  summarise(Anual = median(Anual, na.rm = T))

#Aquí es donde ya tenemos ese concentrado de variables Anual,vmea,vaeas,a, donde ahora si la precipitación es por cuenca
datos_aguaF <- datos_agua_21 %>% 
  slice(1) %>% 
  select(-(Cve_Mpio:Anual)) %>% 
  left_join(precipitacion_total)

# Datos necesarios para las predicciones-------------
#http://siga.jalisco.gob.mx/Assets/documentos/normatividad/nom011cna2000.htm#:~:text=NORMA%20Oficial%20Mexicana%20NOM%2D011%2DCNA%2D2000&text=Conservaci%C3%B3n%20del%20recurso%20agua%2DQue,dice%3A%20Comisi%C3%B3n%20Nacional%20del%20Agua.
#Aquí fue donde tomamos muchas decisiones , primero para el área=a que tendria asociada una cuenca de los años 2021 a 2023 se utilizo medias moviles 
#luego se calculo un coeficiente k=a*Anual donde Anual es la precipitación anual por cuenca , ya que este coeficiente nos ayudara a calcular 
#la el coeficiente vmae=a*Anual*ce donde ce es un coeficiente afectado por el terreno donde esta la cuenca 
#y además de capturar cosas que quiza no consideramos .
#Aquí sucede una de nuestras hipotesis y es que pensabamos que para poder calcular ese coeficiente ce podriamos 
#hacer una regresión lineal donde el objetivo sea la suma de vmae por RH y las variables que explicarian 
#serian las k asociadas a cada cuenca siendo los coeficientes estimados esas ce , sin embargo al realizarlo no salio para nada significativo d
#debido a la gran relación que tienen entre las cuencas de la RH , por eso obtamos por este metodo de calcular la ce=c.
#Por otra parte tambien calculamos los valores futuros con medias moviles y por ultimo el valor de vmae se calculo 
#mediante la multiplicación de k por c de los periodo de 2021 a 2023. Por ultimo teniendo estos valores se calcularón.
#sumas por región hidrica de dma,vmae,y de la precipitación.
RHF <- datos_aguaF %>%
  ungroup() %>%
  filter(!is.na(Id_rh), Id_rh != 32) %>% 
  fill(vaeas, clv) %>% 
  mutate(
    vmae = ifelse(Id_rh == 24 & Año == 2020, NA_real_, vmae)
  ) %>% 
  group_by(RHA, CUENCA) %>% 
  mutate(
    a = imputeTS::na_ma(a, 2, weighting = "simple"),
    k = a * Anual,
    c = vmae / k * 100,
    c = imputeTS::na_ma(c, 2, weighting = "simple"),
    vmae = k * c /100,
    vmae = imputeTS::na_ma(vmae, 2, weighting = "simple")
  ) %>% 
  group_by(id_rh = as.numeric(Id_rh), anio = Año) %>% 
  summarise(
    across(vmae:dma, sum),
    prec = median(Anual, na.rm = T)
  ) %>% 
  ungroup()

#Auí vienen las importaciones y exportaciones por región hidrologica.
rhs <- read_csv("data/regionesHidrologicas.csv")

#Por ultimo le pegegamos este valor de importaciones y exportaciones , para despues realizar una regresión lineal
#para predecir la disponibilidad media anual de agua con ayuda de vmae ,vaeas y las importaciones y exportaciones
#b0 capturaria todo esa información que no esta disponible al publico . Ya con el modelo hariamos predicciones
#las cuales se ven reflejadas en el shiny adjunto
RHF %>% 
  left_join(rhs) %>% 
  replace_na(list(ImportacionesExportacionesOtrosPaises = 0)) %>% 
  nest_by(id_rh) %>% 
  mutate(
    model = list(lm(dma ~ vmae + vaeas + ImportacionesExportacionesOtrosPaises, data)),
    data = list(data %>% mutate(p = predict(model, data)))
  ) %>% 
  select(-model) %>% 
  unnest(data) %>% 
  relocate(p, .after = dma) %>% 
  write_csv("shiny/data/predicciones.csv")
