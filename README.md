# The Local Human Capital Costs of Oil Exploitation





# Abstract

This paper explores the impacts of oil exploitation on human capital accumulation at the local level in Colombia, a resource-rich developing country. We provide evidence based on detailed spatial and temporal data on oil exploitation and education, using the number of wells drilled as an intensity treatment at the school level. To find causal estimates we rely on an instrumental variable approach that exploits the exogeneity of international oil prices and a proxy of oil endowments at the local level. Our results indicate that oil has a negative impact on human capital since it reduces enrollment in higher education. Furthermore, it generates a delay in the decision to enroll in higher education and leads students to prefer technical areas of study and programs in social science, business, and law. However, we do not find any effects on quality or tertiary education completion. Our results are robust to a number of relevant specification changes and we stress the role of local markets and spillovers as the main transmission channel. In particular, we find that higher oil production causes an increase in formal wages but that there is no premium to tertiary education enrollment. 


## Data files





## Software:

- The analysis was conducted using Stata-16 version 16.1 and R version 4.0.2 (2020-06-22)


## Code files:

	- `Human_Capital.do` Limpia y crea las variables sobre educación/capital humano que usa el paper.
	- `schools_buffers.R` Crea las variables de pozos alrededor de todos los colegios usando los archivos de pozos y human capital.
	- `mins_schools.R` Crea las variables de minas antipersonas alrededor de todos los colegios usando los archivos de Minas Antipersona y human capital.
	- `wells_schools_mpio.do` limpia los datos creados en R a nivel de individuo, colegio y municipio
	- `creating_bases_torun.do` crea las bases necesarias para correr los resultados. 






* tp dp

descriptives dividida (mediana/media/una dev std encima/debajo de la media)
municipio tiempo solo. 
clusteriar
suitabiloity entre el 85 y el 2000 -> atenuación en primera etapa

number of students con trends mt

hist numb students
testear mas el numb students
balance entre reporte y no reporte de wage























