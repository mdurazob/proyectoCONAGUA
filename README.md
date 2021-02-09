# Proyecto Bedu: Fase 2

* Shiny: https://mnar99.shinyapps.io/proyectoCONAGUA/

---

Uno de los factores que tenemos que tener en cuenta para predecir el vmae es la precipitación , se puede calcular con la siguiente formula, propuesta por la NOM. . 
(es vmae=p*a*ce), así conagua proporciona un historico de 2000 a 2018(mensuales y anuales) de precipitaciones, las cuales se emplearon para entrenar series de tiempo que nos ayudaran a estimar la precipitación anual del 2019 al 2023.

Con ayuda del bucle “for” se calculó las series de tiempo de cada uno de los municipios de la Republica, el cual tomó más de 4 horas en ejecutarse para conseguir las precipitaciones por municipios del   2000 al 2023. Para calcular las precipitaciones por region hidrologica se mide con series de tiempo y los picos observados son casos aislados, todo en meses muy especificos.

se encarga de llevar un registro del consumo y descargas del agua por cuenca, pero lamentablemente la información expuesta presenta grandes problemas para su analisis, ya que cuenta acceso limitado, conceptos confusos y en las regiones no ofrecen el mismo periodo de tiempo en los datos por cada cuenca que forma parte de ella.

Dado estos problemas, se tomó la decisión de completar los años o meses en blanco con el resultado del último registro con el que contaba para que en la gráfica final no presentara caídas por region hidrologica.

Cuando se habla de cuerpos de agua se utiliza la unidad de medida hectómetros cubicos para calcular más fácilmente  capacidades de espacios, el agua localizada en las cuencas se concesionan y se debe respetar para no ponerlas en riesgo, si se excede, la cuenca entra a estado de déficit y la disponibilidad del agua será negativa porque la extraccion del agua esta siendo mayor que la cantidad de agua recopilada durante el proceso de escurrimiento, la precipitacion se mide por milimetros, donde 1 mm de agua caida por lluvia equivale a 1 litro de E(agua) en un metro cuadrado.

Teniendo las predicciones para el volumen anual de extracción de agua superficial(vaea) , para el volumen  anual de escurrimiento natural,y las importanciones y exportaciones( que fueron obtenidas por promedios moviles) pasamos a pensar en un modelo lineal con la siguiente forma :

DMA(Disponibilidad media anual)=VMAE(Volumen medio anual de escurrimiento)+VAEAS(Volumen anual de de extracción de aguas superficiales+importaciones y exportaciones+b0
E( donde b0 va a capturar esa información a la que no tuvimos acceso y así predecir la disponibilidad futura, los datos de entrenamiento son los que tenemos de 2005 al 2020 y ya teniendo los modelos, podemos utilizar los coeficientes para predecir la disponibilidad de los años 2021 a 2023

En el shiny que se desarrolló, observamos el pais de mexico dividido por sus 37 regiones  hidrológicas , estas regiones tiene un color dependiendo la cantidad de cuencas que tiene. para mas detalles es necesario pulsar sobre una región hidrológica para obtener su nombre, la extensión territorial , el número de cuencas y las cuencas con disponibilidad al 2020,al seleccionar la region, aparece la seríe de tiempo de precipitación y su pronóstico hasta 2023,la gráfica de disponibilidad , la disponibilidad media de los años 2005 a 2020 y tambien la disponibilidad estimada hasta 2023.

Para ejemplificar lo mencionado selecciónamos la Región #2 que es Baja California Centro-Oeste, cuenta una extensión territorial de 44,314km ^2 y 16 cuencas, de las cuales todas estaran disponibles para el 2020. En la disponibilidad que presenta, observamos como ha bajado los últimos años y se estima que los próximos que vienen bajará aún más, por lo que se debe estar prevenidos.En la gráfica de precipitación podemos ver que los durante los años no tiene una relación tan linean, pero se estima que se mantenga el mismo nivel los proximos años.

De este shiny podemos identificar algunas cosas clave , como lo son las regiones hidrológicas que carecen de disponibilidad , como son sonora norte ,bravo y conchos y lerma de santiago y balsas al centro.

Por otra parte, revisando las predicciones y tendencias de la disponibilidad media de agua por RH , se puede decir también que por cada 2 RH que se están recuperando en dma hay otras 8 que están decayendo en dma , significando que el agua que consumimos está en grave peligro.

Y aunque en nosotros está en cuidar más el agua , también es necesario que  CONAGUA realice concesiones de manera responsable. Si juntos cuidamos la salud de nuestros acuíferos ,lo cual se traduce en  fuente de vida y desarrollo del resto de los seres vivos, contribuyendo al bienestar general en todas las actividades esenciales de vida.
