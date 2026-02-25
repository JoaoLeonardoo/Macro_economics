# ============================================= #
# === MACROECONOMIC VARIABLES - API DATASET === #
# ============================================= #

# --- Script by Paulo Icaro --- #

# ==================== #
# === 1. Libraries === #
# ==================== #
library(plumber)
library(dplyr)
library(readxl)
library(lubridate)

# ================================ #
# === 2. Macroeconomic Dataset === #
# ================================ #
source('https://raw.githubusercontent.com/paulo-icaro/Macroeconomic_Variables/refs/heads/master/API_Dataset.R')

# ============== #
# === 3. API === #
# ============== #

#* @apiTitle Conjunto de Dados Macroeconômicos
#* @apiDescription A proposta desse API é disponibilizar um conjunto de dados macroeconômicos voltados para fins de pesquisa...
#* @apiVersion 1.0.0

#* @get /macro_series_mensais
#* @serializer json       
#* @tag "Séries Macroeconômicas Mensais"
#* @param series Informe o código da(s) série(s) de dados desejada(s)
#* @param periodo Intervalo de dados (Ex: 2010-2020)
function(series = 'tudo', periodo = 'tudo') {
  macroeconomic_dataset = monthly_macro_series
  if(series != 'tudo') {
    series_vec = unlist(strsplit(series, ","))
    macroeconomic_dataset = macroeconomic_dataset %>% select(data, all_of(series_vec))
  }
  if(periodo != 'tudo') {
    initial_period = as.numeric(substr(periodo, 1, 4))    
    final_period = as.numeric(substr(periodo, 6, 9))
    start_date = as.Date(paste0(initial_period, '-01-01'))
    end_date = as.Date(paste0(final_period, '-12-31'))
    macroeconomic_dataset = macroeconomic_dataset %>% filter(data >= start_date, data <= end_date)
  }
  return(macroeconomic_dataset)
}

#* @get /macro_series_trimestrais
#* @serializer json       
#* @tag "Séries Macroeconômicas Trimestrais"
#* @param series Informe o código da(s) série(s) de dados desejada(s)
#* @param periodo Intervalo de dados (Ex: 2015-2025)
function(series = 'tudo', periodo = 'tudo') {
  macroeconomic_dataset = quartely_macro_series
  if(series != 'tudo') {
    series_vec = unlist(strsplit(series, ","))
    macroeconomic_dataset = macroeconomic_dataset %>% select(data, all_of(series_vec))
  }
  if(periodo != 'tudo') {
    initial_period = as.numeric(substr(periodo, 1, 4))    
    final_period = as.numeric(substr(periodo, 6, 9))
    start_date = as.Date(paste0(initial_period, '-01-01'))
    end_date = as.Date(paste0(final_period, '-12-31'))
    macroeconomic_dataset = macroeconomic_dataset %>% filter(data >= start_date, data <= end_date)
  }
  return(macroeconomic_dataset)
}
