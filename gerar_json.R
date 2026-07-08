source("API_Dataset.R")  # ou o caminho correto
library(jsonlite)

if (!dir.exists("data")) dir.create("data")

# O novo dataset se chama 'final_dataset'
if (!exists("final_dataset")) stop("final_dataset não encontrado")

# Converte a data para formato ISO (YYYY-MM-DD)
# O formato atual é "Ano_QTrimestre" (ex: "2010_Q1")
# Vamos transformar para o primeiro dia do trimestre
dados_export <- final_dataset %>%
  mutate(
    data = as.Date(paste0(substr(data, 1, 4), "-", 
                          as.numeric(substr(data, 7, 7))*3 - 2, "-01"))
  ) %>%
  select(-Ano, -Trimestre)  # remove colunas auxiliares se existirem

# Adiciona timestamp de Brasília
ultima_atualizacao <- format(Sys.time(), tz = "America/Sao_Paulo", "%Y-%m-%d %H:%M:%S")

# Estrutura final
output <- list(
  ultima_atualizacao = ultima_atualizacao,
  dados = dados_export
)

write_json(output, path = "data/dados_macro.json", pretty = TRUE, auto_unbox = TRUE)
message("JSON gerado com sucesso!")
