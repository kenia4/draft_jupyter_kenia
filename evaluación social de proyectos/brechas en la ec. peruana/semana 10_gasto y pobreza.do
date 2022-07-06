clear all
cd "D:/Kenia/Documents/evaluación soc. de proy/semana 10"

u sumaria-2019.dta, clear

* Convertir a numérico
destring conglome, gen(conglome1)
drop conglome1

* reducir el número de columnas
keep aÑo mes conglome vivienda hogar ubigeo dominio estrato mieperho gashog2d ld linpe linea pobreza factor07 gashog1d inghog1d ingmo1hd

save sum_19.dta, replace

********************************************

clear all
cd "D:/Kenia/Documents/evaluación soc. de proy/semana 10"

u sum_19.dta, clear

* Departamento
	g dpto1= real(substr(ubigeo,1,2))
	lab var dpto1 "Departamentos"
	
	
	* Etiquetas
	label define dpto 1"Amazonas" 2"Ancash" 3"Apurimac" 4"Arequipa" 5"Ayacucho" 6"Cajamarca" 7 "Callao" 8"Cusco" 9"Huancavelica" 10"Huanuco" 11"Ica" 12"Junin" 13"La Libertad" 14"Lambayeque" 15"Lima" 16"Loreto" 17"Madre de Dios" 18"Moquegua" 19"Pasco" 20"Piura" 21"Puno" 22"San Martin" 23"Tacna" 24"Tumbes" 25"Ucayali"

	lab val dpto1 dpto
	
	* Redondeo del factorprobabilida
	g factornd07=round(factor07*mieperho,1)


	
* Variables deflactadas a nivel de personas

g ipcmr_pl=inghog1d/(12*ld*mieperho)
g gpcmr_pl=gashog2d/(12*ld*mieperho)
g linear_pl=linea/ld


* Análisis quintiles
xtile quintil = gpcmr_pl [fw=factornd07], nq(5) // Indicador categórico


* Tablas
table dpto quintil [iw = factornd07], c(m gpcmr_pl)



******************************************************
* Cálculo de pobreza	
******************************************************


* Tasa de pobreza
g pobre = (gpcmr_pl < linear_pl)

* Brecha pobreza
g brecha = (linear_pl-gpcmr_pl)/linear_pl if pobre==1
replace brecha = 0 if pobre==0 

* Severidad
g severidad = ((linear_pl-gpcmr_pl)/linear_pl)^2 if pobre==1
replace severidad = 0 if pobre==0

* Tablas por departamentos
table dpto1 [iw=factornd07], c(m pobre m brecha m severidad)
	