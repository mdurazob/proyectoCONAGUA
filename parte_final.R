
library(tidyverse)
library(stringi)

#datos Cuenca
datos_agua <- read.csv("data/Cuencas con disponibilidad (2010-2020).csv", sep=";") %>% 
  as_tibble()

#Seleccion de los datos Cuenca con disponibilad 
datos_agua_1<-
  datos_agua %>% 
  select(n,clv,nom_cue,vmae,vaeas,dma,a,year,RHA) %>% 
  na.omit() %>% 
  rename(CUENCA = nom_cue)

# ---------------------------------------------------------------------------------------------

na_impute <- function(x){
  ifelse(is.na(x), mean(x, na.rm = T), x)
}

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
  complete(year = 2005:2020) %>% 
  fill(vmae:a, .direction = "up") %>% 
  ungroup()

# ---------------------------------------------------------------------------------------------

cve_mun <- read.csv("data/clave_municipio.csv",sep=";") %>% 
  as_tibble()

precipitacion <- read.csv("data/precipitacion_fin1.csv") %>% 
  as_tibble()

municipios <- read.csv("data/datos11/Catalogo_CLICOM_Precipitacion (2).csv") %>% 
  as_tibble()

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

municipiosRH <- cve_mun %>% 
  mutate(
    mun_est = stri_trans_general(tolower(gsub(" ","",mun_est)),"Latin-ASCII")
  ) %>% 
  inner_join(municipios) %>% 
  distinct(CUENCA, Cve_Mpio = cve) %>% 
  inner_join(precipitacion)

# ---------------------------------------------------------------------------------------------

datos_agua_2 <- municipiosRH %>% 
  left_join(datos_agua_11, by = c("RHA", "CUENCA", "Año" = "year"))

cuencas_rh <- XML::xmlToDataFrame("http://201.116.60.29/servicios/api/disponibilidadcuencashidrologicas/2017") %>% 
  as_tibble() %>% 
  select(Id_RHA, RHA, Id_rh, nom_rh, CUENCA = Nombre) %>% 
  mutate(
    across(CUENCA, ~stri_trans_general(.,id = "Latin-ASCII") %>% tolower() %>% str_remove_all("\\.") %>% str_squish())
  )

datos_agua_21 <- datos_agua_2 %>% 
  left_join(cuencas_rh) %>% 
  arrange(RHA, CUENCA, Año) %>% 
  filter(Año >= 2005) %>% 
  group_by(RHA, CUENCA, Año)

precipitacion_total <- datos_agua_21 %>% 
  summarise(Anual = mean(Anual))

datos_aguaF <- datos_agua_21 %>% 
  slice(1) %>% 
  select(-(Cve_Mpio:Anual)) %>% 
  left_join(precipitacion_total)

# ---------------------------------------------------------------------------------------------

RHF <- datos_aguaF %>%
  ungroup() %>%
  filter(!is.na(Id_rh)) %>% 
  fill(vaeas, clv) %>% 
  group_by(RHA, CUENCA) %>% 
  mutate(
    a = imputeTS::na_ma(a, 1, weighting = "simple"),
    k = a * Anual,
    c = vmae / k * 100,
    c = imputeTS::na_ma(c, 1, weighting = "simple"),
    vmae = k * c /100
  ) %>% 
  group_by(id_rh = as.numeric(Id_rh), anio = Año) %>% 
  summarise(
    across(vmae:dma, sum)
  ) %>% 
  ungroup()

rhs <- read_csv("data/regionesHidrologicas.csv")

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
  write_csv("data/predicciones.csv")
