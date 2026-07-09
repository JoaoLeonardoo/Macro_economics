# ============================== #
# === Gerar JSON para o site === #
# ============================== #

source("API_Dataset.R")
library(jsonlite)
library(dplyr)

if (!dir.exists("data")) dir.create("data")

if (!exists("final_dataset")) stop("final_dataset não encontrado")

# O dataset final já tem a coluna 'data' no formato "Ano_QTrimestre" (ex: "2010_Q1")
# Vamos converter para o formato ISO (YYYY-MM-DD) para compatibilidade com o front-end
dados_export <- final_dataset %>%
  mutate(
    data = as.Date(paste0(substr(data, 1, 4), "-", 
                          as.numeric(substr(data, 7, 7)) * 3 - 2, "-01"))
  ) %>%
  # Remover colunas auxiliares se existirem (mas não tente remover Ano/Trimestre se não existirem)
  select(-any_of(c("Ano", "Trimestre")))  # usa any_of para não falhar se não existirem

# Adiciona timestamp de Brasília
ultima_atualizacao <- format(Sys.time(), tz = "America/Sao_Paulo", "%Y-%m-%d %H:%M:%S")

output <- list(
  ultima_atualizacao = ultima_atualizacao,
  dados = dados_export
)

write_json(output, path = "data/dados_macro.json", pretty = TRUE, auto_unbox = TRUE)
message("JSON gerado com sucesso em data/dados_macro.json")
