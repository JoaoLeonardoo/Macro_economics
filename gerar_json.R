# ============================== #
# === Gerar JSON para o site === #
# ============================== #

# Carrega o dataset (executa todo o script API_Dataset.R)
source("API_Dataset.R")

# Carrega pacote para escrever JSON
library(jsonlite)

# Garante que a pasta data existe (se não, cria)
if (!dir.exists("data")) {
  dir.create("data")
}

# Verifica se o objeto monthly_macro_series existe e tem a coluna ipca
if (!exists("monthly_macro_series")) {
  stop("Erro: monthly_macro_series não foi criado. Verifique API_Dataset.R")
}

if (!"ipca" %in% colnames(monthly_macro_series)) {
  stop("Erro: Coluna 'ipca' não encontrada em monthly_macro_series")
}

# Extrai apenas a série IPCA (mensal) e formata a data como string ISO
ipca_data <- monthly_macro_series %>%
  select(data, ipca) %>%
  mutate(data = as.character(data))  # converte Date para string

# Salva como JSON bonito (pretty) com auto_unbox para evitar listas desnecessárias
write_json(ipca_data, 
           path = "data/ipca.json", 
           pretty = TRUE, 
           auto_unbox = TRUE)

message("Arquivo JSON gerado com sucesso em data/ipca.json")
