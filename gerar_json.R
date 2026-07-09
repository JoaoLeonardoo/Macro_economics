source("API_Dataset.R")
library(dplyr)
library(jsonlite)

if (!dir.exists("data")) dir.create("data")

# final_dataset é criado dentro do API_Dataset.R que foi carregado no topo
if (!exists("final_dataset")) stop("final_dataset não encontrado. Verifique se o API_Dataset.R rodou corretamente.")

# A coluna 'data' está no formato "Ano_QTrimestre" (ex: "2010_Q1")
# Converter para ISO (YYYY-MM-DD) para o front-end
dados_export <- final_dataset %>%
  mutate(
    data = as.Date(paste0(substr(data, 1, 4), "-", 
                          as.numeric(substr(data, 7, 7)) * 3 - 2, "-01"))
  ) %>%
  # Remove colunas auxiliares se existirem
  # Usamos dplyr::select explicitamente para evitar conflitos com outros pacotes (como MASS ou plyr)
  # any_of garante que o script não falhe se a coluna não existir
  dplyr::select(-any_of(c("Ano", "Trimestre")))

# Timestamp em Brasília
ultima_atualizacao <- format(Sys.time(), tz = "America/Sao_Paulo", "%Y-%m-%d %H:%M:%S")

output <- list(
  ultima_atualizacao = ultima_atualizacao,
  dados = dados_export
)

write_json(output, path = "data/dados_macro.json", pretty = TRUE, auto_unbox = TRUE)
message("JSON gerado com sucesso em data/dados_macro.json")
