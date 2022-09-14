# Indicando o diretório
setwd("~/Dropbox/24 - GitHub/Expressoes Regulares")

# https://www.ibge.gov.br/estatisticas/downloads-estatisticas.html
# Pasta Estimativas_de_Populacao
# estimativa_dou_2021.xls 

# Perceba que o arquivo excel contêm duas planilhas (Estados e Municipios) e em ambas
# a tabela de estimativa de crescimento
# populacional 2021 contêm
# 1) Cabeçalho
# 2) Rodapé
# 3) Indices entre parênteses
# 4) Numeros como caractere e sem padronização

# Instalando os pacotes

if(!require("sf")) install.packages("sf", dep=T); library(sf)
if(!require("dplyr")) install.packages("dplyr", dep=T); library(dplyr)
if(!require("devtools")) install.packages("devtools", dep=T); library(devtools)
if(!require("ggplot2")) install.packages("ggplot2", dep=T); library(ggplot2)
if(!require("readxl")) install.packages("readxl", dep=T); library(readxl)
if(!require("DataExplorer")) install.packages("DataExplorer", dep=T); library(DataExplorer)
if(!require("Hmisc")) install.packages("Hmisc", dep=T); library(Hmisc)
if(!require("tidyverse")) install.packages("tidyverse", dep=T); library(tidyverse)
if(!require("stringr")) install.packages("stringr", dep=T); library(stringr)
if(!require("purrr")) install.packages("purrr", dep=T); library(purrr)
if(!require("DescTools")) install.packages("DescTools", dep=T); library(DescTools)
if(!require("ggimage")) install.packages("ggimage", dep=T); library(ggimage)
if(!require("ggspatial")) install.packages("ggspatial", dep=T); library(ggspatial)

devtools::install_github("ipeaGIT/geobr", subdir = "r-package")
library(geobr)


# Para verificar de qual pacote é determinada função
find ("fortify") # corresponde ao pacote "package:ggplot2"
find("str_replace")

#### DADOS IBGE ######

pop_municipio<- read_excel("estimativa_dou_2021.xls", sheet = 2, skip = 1) # lê a 2 planilha e sem o cabeçalho
head(pop_municipio)
names(pop_municipio)

# alterando nomes de colunas (retirando acentos das palavras e padronizando nomes para unir as bases)
colnames(pop_municipio)[2]<- "COD.UF"
colnames(pop_municipio)[3]<- "COD.MUNIC"
colnames(pop_municipio)[4]<-"MUNICIPIO"
colnames(pop_municipio)[5]<-"ESTIMATIVA_2021" # substituir o nome por est_2021 (POPULAÇÃO ESTIMADA)

# Visualisando a base de dados
View(pop_municipio)

# Casos a serem resolvidos na coluna 'ESTIMATIVA_2021'

# retirar (1) do final do numero 548.952(1) 
knitr::kable(pop_municipio[17, 5], caption = 'ESTIMATIVA_2021')

# padronizar as contagens de 16.007(11) para 16007
knitr::kable(pop_municipio[135, 5], caption = 'ESTIMATIVA_2021')

# Utilizando expressões regulares
pop_municipio <- pop_municipio %>%
    mutate(ESTIMATIVA_2021 = str_replace(ESTIMATIVA_2021,
                                         pattern = "^([0-9.]+)\\(\\d+\\)$",
                                         replacement = "\\1"))   # retira as obsevções ()
# Verifica
pop_municipio[135,5]



pop_municipio<- pop_municipio %>%
    mutate(ESTIMATIVA_2021 = str_remove_all(ESTIMATIVA_2021,
                                            pattern = "\\D")) # retira os pontos
# Verifica
pop_municipio[135,5] # modificado 

# Transforma de character para integer
pop_municipio$ESTIMATIVA_2021<- as.integer(pop_municipio$ESTIMATIVA_2021) 

pop_municipio[135,5] # padronizado 

# Verificando o inicio e o final da tabela IBGE
head(pop_municipio)
tail(pop_municipio)

# Para remover essas observações do final da tabela
pop_municipio<- pop_municipio[complete.cases(pop_municipio), ]  # Mantem as linhas com valores em todas as colunas 
dim(pop_municipio) # 5570 municipios brasileiros
tail(pop_municipio) # o último municipio deve ser Brasília

# Salvando o arquivo 
pop_municipio <- write.csv(pop_municipio, "pop_municipio_corrigida.csv", row.names = FALSE)
