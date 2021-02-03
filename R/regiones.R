library("XML")
    # Hay información de 2006-2019
reg19 <- xmlToDataFrame("http://201.116.60.29/servicios/api/CaracteristicasRegionesHidrologicas/2019")
reg18 <- xmlToDataFrame("http://201.116.60.29/servicios/api/CaracteristicasRegionesHidrologicas/2018")
reg17 <- xmlToDataFrame("http://201.116.60.29/servicios/api/CaracteristicasRegionesHidrologicas/2017")
reg16 <- xmlToDataFrame("http://201.116.60.29/servicios/api/CaracteristicasRegionesHidrologicas/2016")
reg15 <- xmlToDataFrame("http://201.116.60.29/servicios/api/CaracteristicasRegionesHidrologicas/2015")
reg14 <- xmlToDataFrame("http://201.116.60.29/servicios/api/CaracteristicasRegionesHidrologicas/2014")
reg13 <- xmlToDataFrame("http://201.116.60.29/servicios/api/CaracteristicasRegionesHidrologicas/2013")
reg12 <- xmlToDataFrame("http://201.116.60.29/servicios/api/CaracteristicasRegionesHidrologicas/2012")
reg11 <- xmlToDataFrame("http://201.116.60.29/servicios/api/CaracteristicasRegionesHidrologicas/2011")
reg10 <- xmlToDataFrame("http://201.116.60.29/servicios/api/CaracteristicasRegionesHidrologicas/2010")
reg09 <- xmlToDataFrame("http://201.116.60.29/servicios/api/CaracteristicasRegionesHidrologicas/2009")
reg08 <- xmlToDataFrame("http://201.116.60.29/servicios/api/CaracteristicasRegionesHidrologicas/2008")
reg07 <- xmlToDataFrame("http://201.116.60.29/servicios/api/CaracteristicasRegionesHidrologicas/2007")
reg06 <- xmlToDataFrame("http://201.116.60.29/servicios/api/CaracteristicasRegionesHidrologicas/2006")

reg19$anio <- 2019; reg18$anio <- 2018; reg17$anio <- 2017; reg16$anio <- 2016; reg15$anio <- 2015;
reg14$anio <- 2014; reg13$anio <- 2013; reg12$anio <- 2012; reg11$anio <- 2011; reg10$anio <- 2010;
reg09$anio <- 2009; reg08$anio <- 2008; reg07$anio <- 2007; reg06$anio <- 2006;
View(reg10)

regiones0519 <- list(reg19,reg18,reg17,reg16,reg15,reg14,reg13,reg12,reg11,reg10,reg09,reg08,reg07,reg06)
regiones <- do.call(rbind, regiones0519)
View(regiones)

readr::write_csv(x = regiones, file = "data/regionesHidrologicas.csv")

