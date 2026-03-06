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

# Pega todas as colunas disponíveis (data + todas as séries mensais)
dados_completos <- monthly_macro_series %>%
  mutate(data = as.character(data))  # converte Date para string

# Data/hora de Brasília
ultima_atualizacao <- format(Sys.time(), tz = "America/Sao_Paulo", "%Y-%m-%d %H:%M:%S")

# Estrutura final com metadados
output <- list(
  ultima_atualizacao = ultima_atualizacao,
  dados = dados_completos
)

# Salva o JSON
write_json(output, 
           path = "data/dados_macro.json", 
           pretty = TRUE, 
           auto_unbox = TRUE)

message("Arquivo JSON gerado com sucesso em data/dados_macro.json")
