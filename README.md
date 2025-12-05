# Multi-Omic Data Integration & Analysis Pipeline

This repository contains a hybrid Python/R pipeline for the preprocessing, integration, and visualization of multi-omic cancer data. The workflow combines the statistical power of R (for **MOFA** and **SNF** algorithms) with the versatility of Python (for data engineering, machine learning, and interactive visualization).

## 📂 Project Structure

The pipeline consists of three main scripts. **`multi_omic_data_visualization.py`** is the master orchestrator, while the R scripts are used to compute complex intermediate matrices.

| File Name | Language | Description |
| :--- | :--- | :--- |
| **`multi_omic_data_visualization.py`** | Python | **Main Controller.** Handles data downloading, preprocessing (imputation/scaling), and downstream analysis (Survival Analysis, UMAP/t-SNE, Clustering, SHAP/Random Forest). |
| **`mofa.R`** | R | **Multi-Omics Factor Analysis.** Takes scaled data from Python, computes latent factors and weights using `MOFA2`, and exports results to CSV. |
| **`SNF_script.R`** | R | **Similarity Network Fusion.** Takes scaled data from Python, fuses patient similarity networks using `SNFtool`, and exports the fused matrix to CSV. |

---

## 🔄 Workflow Architecture

The pipeline operates in a circular workflow:

1.  **Python (Phase 1):** Loads raw data, performs cleaning, imputation, and scaling. Exports `_scaled.csv` files.
2.  **R (Computation):** Reads `_scaled.csv` files, performs computationally intensive integration (MOFA/SNF), and exports results (Factors/Weights/Fused Matrix).
3.  **Python (Phase 2):** Loads the R outputs to perform clustering, survival analysis, biological characterization, and visualization.

-----

## 🛠️ Prerequisites

### Python Dependencies

The main script is optimized for Google Colab but can run locally. You will need:

  * `pandas`, `numpy`, `matplotlib`, `seaborn`
  * `scikit-learn` (PCA, t-SNE, Clustering, Random Forest)
  * `lifelines` (Survival Analysis)
  * `shap` (Model Explainability)
  * `plotly` (Interactive plots)
  * `snfpy`, `umap-learn`, `networkx`
  * See `multi_omic_data_visualization.py` for full import list.

### R Dependencies

If you intend to reproduce the R outputs locally, you require:

  * **MOFA2** (`BiocManager::install("MOFA2")`)
  * **SNFtool** (`install.packages("SNFtool")`)
  * `survival`, `survminer`, `readr`, `basilisk`, `ggplot2`.

-----

## 🚀 Usage Instructions

### Mode A: Running the Visualization (Default)

The provided Python script (`multi_omic_data_visualization.py`) is currently configured to **download pre-computed R results** from Google Drive via `gdown`.

1.  Open `multi_omic_data_visualization.py` (or load it into Google Colab).
2.  Run the cells sequentially.
3.  The script will automatically download the necessary CSVs (Raw data + MOFA/SNF results) and generate all visualizations.

### Mode B: Reproducing the Full Pipeline (Local Generation)

If you wish to re-calculate the MOFA or SNF models using your own parameters:

**Step 1: Data Preprocessing**

1.  Run the first half of `multi_omic_data_visualization.py` (up to the "Final Data Export" section).
2.  Ensure the script saves the `_scaled.csv` files to a local directory (e.g., `/content/processed_data` or a local folder).

**Step 2: MOFA Computation**

1.  Open `mofa.R`.
2.  Update the `DATA_DIR` variable to point to the folder containing your `_scaled.csv` files.
3.  Run the script. It will generate:
      * `mofa_factors_R.csv`
      * `mofa_weights_R.csv`
      * `mofa_variance_explained.csv`

**Step 3: SNF Computation**

1.  Open `SNF_script.R`.
2.  Ensure it points to the same `_scaled.csv` files.
3.  Run the script. It will generate:
      * `snf_fused_matrix_R.csv`

**Step 4: Downstream Analysis**

1.  Return to `multi_omic_data_visualization.py`.
2.  **Comment out** the `!gdown` commands in the MOFA and SNF sections.
3.  Update the file paths to load your locally generated CSV files instead of the downloaded ones.
4.  Run the remainder of the script to visualize your new results.

-----

## 📊 Key Outputs

### 1\. MOFA Analysis

  * **Variance Explained:** Bar plots showing how much variance each latent factor captures.
  * **Cluster Discovery:** K-Means and Hierarchical clustering on latent factors.
  * **Biological Interpretation:** Feature importance ranking (Weights) and SHAP values identifying molecular drivers (genes/proteins) for each cluster.

### 2\. SNF Analysis

  * **Patient Similarity:** Heatmaps of the fused similarity network.
  * **Spectral Clustering:** Identification of patient subtypes based on network topology.
  * **UMAP/t-SNE:** 2D projection of the fused network.
  * **Biological Interpretation:** SHAP values identifying molecular drivers (genes/proteins) for each cluster.

### 3\. Clinical Validation

  * **Survival Analysis:** Kaplan-Meier curves and Log-Rank tests comparing patient survival across identified clusters.
  * **Phenotype Association:** Chi-square and Kruskal-Wallis tests linking clusters to clinical variables (e.g., Tumor Stage, Age, Gender).

<!-- end list -->

```
```
