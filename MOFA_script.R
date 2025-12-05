#!/usr/bin/env Rscript
# ======================================================================
# MOFA FINAL PIPELINE (NO FILTER): CARICAMENTO INTEGRALE E TRAINING
# ======================================================================

# --- 1. LIBRERIE ---
library(MOFA2)
library(readr)
library(basilisk)

print("--- Inizio Pipeline MOFA (Dataset Completo) ---")

# --- 2. CONFIGURAZIONE UTENTE ---
DATA_DIR <- "C:/Users/Federico Fontana/Downloads/scaled_data" 
setwd(DATA_DIR)
N_FACTORS <- 15 

# --- 3. CARICAMENTO DATI ---
print(paste("Caricamento dati da:", DATA_DIR))
files <- list.files(pattern = "_scaled.csv") 

if (length(files) == 0) {
  stop("ERRORE FATALE: Nessun file '_scaled.csv' trovato.")
}

data_list <- list()
for (f in files) {
  view_name <- strsplit(f, "_")[[1]][1]
  df <- read.csv(f, row.names = 1)
  
  cat(paste(" > Caricato:", view_name, "| Features:", ncol(df), "| Pazienti:", nrow(df), "\n"))
  
  # Trasponi per MOFA: Righe=Features, Colonne=Pazienti
  mat <- t(as.matrix(df))
  data_list[[view_name]] <- mat
}

# --- 4. CREAZIONE OGGETTO MOFA ---
print("\nCreazione oggetto MOFA...")
MOFAobject <- create_mofa(data_list)
print(MOFAobject) 

# --- 5. CONFIGURAZIONE CORRETTA ---
# IMPORTANTE: Chiama get_default_training_options SENZA argomenti
data_opts  <- get_default_data_options(MOFAobject)
model_opts <- get_default_model_options(MOFAobject)
train_opts <- get_default_training_options(MOFAobject)

# Modifica solo i parametri necessari
model_opts$num_factors <- N_FACTORS

# Configurazione training con basilisk
train_opts$maxiter <- 1000
train_opts$convergence_mode <- "fast"
train_opts$verbose <- TRUE
train_opts$seed <- 42

# --- 6. PREPARAZIONE MOFA ---
print("Preparazione MOFA per il training...")
MOFAobject <- prepare_mofa(
  MOFAobject, 
  data_options = data_opts, 
  model_options = model_opts, 
  training_options = train_opts
)

# --- 7. ADDESTRAMENTO ---
print(paste("\nAvvio Training (K =", N_FACTORS, ")..."))
model <- run_mofa(
  MOFAobject, 
  outfile = "mofa_result.hdf5",
  use_basilisk = TRUE  # Specifica qui basilisk
)

print("Training Completato!")

# --- 8. EXPORT RISULTATI ---
print("\nEsportazione risultati...")

# Fattori Latenti
factors_list <- get_factors(model, factors = "all", as.data.frame = FALSE)
Z_matrix <- factors_list[["group1"]] 
write.csv(Z_matrix, "mofa_factors_R.csv", row.names = TRUE)
print(paste(" -> Salvato: mofa_factors_R.csv (", nrow(Z_matrix), "x", ncol(Z_matrix), ")"))

# Pesi
weights_df <- get_weights(model, as.data.frame = TRUE)
write.csv(weights_df, "mofa_weights_R.csv", row.names = FALSE)
print(" -> Salvato: mofa_weights_R.csv")

# Varianza spiegata
r2_df <- calculate_variance_explained(model)
write.csv(r2_df$r2_per_factor[[1]], "mofa_variance_explained.csv", row.names = TRUE)
print(" -> Salvato: mofa_variance_explained.csv")

print("\n=======================================================")
print("COMPLETATO! File pronti per l'analisi Python.")
print("=======================================================")