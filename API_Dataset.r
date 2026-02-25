# ========================================= #
# === MACROECONOMIC VARIABLES - DATASET === #
# ========================================= #

# --- Script by Diego Lima and Paulo Icaro --- #

# ====================== #
# === 1. Series Info === #
# ====================== #

# ------------------------- #
# --- Monthly Databases --- #
# ------------------------- #

# PIB Nominal (R$ Milhões) 
# Exportações FOB (R$ Milhões)
# Importações FOB (R$ Milhões)
# Taxa de Câmbio Comercial (R$/US$) 
# Índice de Preços (IPCA) 
# Taxa de Juros Nominal (SELIC)
# Utilização da Capacidade Instalada (Indústria)
# Superávit Primário do Governo Consolidado (R$ Milhões)

# -------------------------- #
# --- Quartely Databases --- #
# -------------------------- #

# ======================================= #
# === 1. Source Scripts and Libraries === #
# ======================================= #
source('https://raw.githubusercontent.com/paulo-icaro/Bacen_API/main/Bacen_Query.R')
source('https://raw.githubusercontent.com/paulo-icaro/Ipeadata_API/refs/heads/main/Ipeadata_Query.R')

library(dplyr)

# ========================== #
# === 2. Data Extraction === #
# ========================== #

# --------------- #
# --- Monthly --- #
# --------------- #

# --- Previous Info --- #
cod_ipeadata_monthly_series = c('BM12_PIB12', 'FUNCEX12_XVT12', 'SECEX12_MVTOT12', 'BM12_ERV12', 'PRECOS12_IPCA12', 'PAN12_TJOVER12')
name_ipeadata_monthly_series = c('pib', 'export', 'import', 'tx_cambio', 'ipca', 'tx_jur')

cod_bacen_monthly_series = c('28561', '4649')
name_bacen_monthly_series = c('uci', 'res_prim')

# --- Extraction --- #
ipeadata_monthly_dataset = ipeadata_query(cod_ipeadata_monthly_series, name_ipeadata_monthly_series, as.character(2010:2025))
bacen_monthly_dataset = bacen_query(cod_bacen_monthly_series, name_bacen_monthly_series, '01/01/2010', '31/12/2025')

# --- Date Adjustment --- #
ipeadata_monthly_dataset = ipeadata_monthly_dataset %>% mutate(data = as.Date(data))
bacen_monthly_dataset = bacen_monthly_dataset %>% mutate(data = as.Date(data, tryFormats = c('%d/%m/%Y')))

# ---------------- #
# --- Quartely --- #
# ---------------- #

# --- Previous Info --- #
cod_ipeadata_quartely_series = c('SCN104_CFPPN104', 'SCN104_CFGGN104', 'SCN104_FBKFN104')
name_ipeadata_quartely_series = c('cons_familias', 'cons_governo', 'fbcf')

# --- Extraction --- #
ipeadata_quartely_dataset = ipeadata_query(cod_ipeadata_quartely_series, name_ipeadata_quartely_series, as.character(2010:2025))

# --- Date Adjustment --- #
ipeadata_quartely_dataset = ipeadata_quartely_dataset %>% mutate(data = as.Date(data))

# ========================================= #
# === 3. Combining Series by Frequency  === #
# ========================================= #

# --- Monthly --- #
monthly_macro_series = left_join(x = ipeadata_monthly_dataset[c(1:7)], y = bacen_monthly_dataset[c(1:3)], by = 'data')

# --- Quartely --- #
quartely_macro_series = ipeadata_quartely_dataset

# =================== #
# === 4. Cleasing === #
# =================== #
patterns = c('^cod', '^name', '^ipeadata', '^bacen')
for(i in seq_along(patterns)){
  rm(list = ls(pattern = patterns[i]))
}
rm(patterns, i)