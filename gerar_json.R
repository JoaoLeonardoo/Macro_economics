# ============================== #
# === Gerar JSON para o site === #
# ============================== #

source("API_Dataset.R")
library(jsonlite)

if (!dir.exists("data")) {
  dir.create("data")
}

if (!exists("monthly_macro_series")) {
  stop("Erro: monthly_macro_series não foi criado. Verifique API_Dataset.R")
}

if (!"ipca" %in% colnames(monthly_macro_series)) {
  stop("Erro: Coluna 'ipca' não encontrada em monthly_macro_series")
}

# Extrai os dados do IPCA
ipca_data <- monthly_macro_series %>%
  select(data, ipca) %>%
  mutate(data = as.character(data))

# Data e hora no horário de Brasília (UTC-3)
ultima_atualizacao <- format(Sys.time(), tz = "America/Sao_Paulo", "%Y-%m-%d %H:%M:%S")

# Cria uma lista com os dados e a data/hora da última atualização
output <- list(
  ultima_atualizacao = ultima_atualizacao,
  dados = ipca_data
)

# Salva o JSON
write_json(output, 
           path = "data/ipca.json", 
           pretty = TRUE, 
           auto_unbox = TRUE)

message("Arquivo JSON gerado com sucesso em data/ipca.json")
