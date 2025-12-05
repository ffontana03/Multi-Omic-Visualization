# --- INSTALLAZIONE LIBRERIE ---
print("Installazione in corso... porta pazienza, ci vorrà un minuto o due.")

# 1. Installa il gestore dei pacchetti se manca
if (!require("devtools")) install.packages("devtools")

# 2. Installa le librerie principali da CRAN
install.packages("SNFtool")
install.packages("survival")
install.packages("survminer")
install.packages("readr")
install.packages("ggplot2") # Utile per i grafici

# 3. Carica le librerie per verificare che sia tutto ok
library(SNFtool)
library(survival)
library(survminer)
library(readr)
library(ggplot2)

print("✅ Tutte le librerie sono installate e pronte!")

library(SNFtool)
library(readr)

print("--- CARICAMENTO DATI IN R ---")

# 1. Carica TUTTI i file salvati da Python
mrna <- read.csv("mrna_scaled.csv", row.names = 1)
prot <- read.csv("prot_scaled.csv", row.names = 1)
fosfo <- read.csv("fosfo_scaled.csv", row.names = 1)
circrna <- read.csv("circrna_scaled.csv", row.names = 1)
mut <- read.csv("mut_scaled.csv", row.names = 1)

# 2. Crea la lista completa per SNF
# Nota: SNF funziona bene anche con dati discreti (mutazioni) se trattati come numerici
data_list <- list(
  as.matrix(mrna),
  as.matrix(prot),
  as.matrix(fosfo),
  as.matrix(circrna),
  as.matrix(mut)
)

print(paste("Sto fondendo", length(data_list), "omiche: mRNA, Prot, Fosfo, CircRNA, Mut"))

# 3. Esegui SNF (Solo la fusione!)
K <- 20; alpha <- 0.5; T_iter <- 20

W_list <- list()
for(i in 1:length(data_list)) {
  # Calcola la distanza e poi l'affinità per ogni omica
  Dist <- dist2(data_list[[i]], data_list[[i]])
  W_list[[i]] <- affinityMatrix(Dist, K, alpha)
}

# 4. Fusione Finale
W_fused <- SNF(W_list, K, T_iter)

# 5. SALVA LA MATRICE FUSA
write.csv(W_fused, "snf_fused_matrix_R.csv", row.names = TRUE)
print("Fatto! Matrice salvata come: snf_fused_matrix_R.csv")