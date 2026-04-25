# Data

All datasets used in this repository are **bundled in their respective R packages**
and are loaded directly in the analysis notebooks. No external downloads are required.

---

## Analysis 1: CLL Dataset (MOFA+)

**Source**: `MOFA2` R package (Bioconductor)

```r
library(MOFA2)
data("CLL_data")       # multi-omics data
data("CLL_covariates") # clinical metadata
```

**Description**:
- **CLL_data**: Named list with four omics views (features × samples orientation)
  - `$mRNA`: RNA-seq log2(CPM+1), 5,000 genes, up to 136 patients
  - `$Methylation`: 450k array beta-values, 4,248 CpGs, up to 149 patients
  - `$Drugs`: ex vivo drug viability AUC, 310 compounds, up to 184 patients
  - `$Mutations`: binary WES somatic calls, 69 driver genes, up to 200 patients
- **CLL_covariates**: Clinical metadata including IGHV status, trisomy12, gender, treatment, survival

**Original publication**:
Dietrich S et al. (2018). Drug-perturbation-based stratification of blood cancer.
*Journal of Clinical Investigation*, 128(1):427-445.

**Data access**: Included in MOFA2 ≥ 1.0 via `data("CLL_data")`.

**Missing data**: Not all patients have all four views profiled. MOFA+ handles
this natively via variational inference over missing observations.

---

## Analysis 2: Breast TCGA Dataset (DIABLO)

**Source**: `mixOmics` R package (Bioconductor)

```r
library(mixOmics)
data(breast.TCGA)
```

**Description**:
- **breast.TCGA$data.train**: Training set (150 samples × 3 omics, samples × features orientation)
  - `$mrna`: RNA-seq expression, 200 most discriminant transcripts
  - `$mirna`: miRNA expression, 184 mature microRNAs
  - `$proteomics`: RPPA protein abundance, 142 measurements
  - `$subtype`: PAM50 label (factor: Basal, Her2, LumA)
- **breast.TCGA$data.test**: Test set (70 samples, same structure)
  - The train/test split is pre-defined by mixOmics to prevent data leakage

**Original data source**: The Cancer Genome Atlas (TCGA) Breast Invasive Carcinoma
(BRCA) project. Data downloaded and pre-processed by the mixOmics team.

**Data access**: Included in mixOmics ≥ 6.0 via `data(breast.TCGA)`.

**Note**: The original TCGA BRCA cohort contains all five PAM50 subtypes.
This pre-selected subset retains Basal, Her2, and LumA for demonstration purposes.

---

## Results Directory Structure

```
results/
├── mofa/
│   ├── cll_data_preprocessed.RDS     # Saved list from Notebook 01
│   ├── CLL_MOFA_trained.hdf5         # Trained MOFA+ model (HDF5 format)
│   ├── CLL_MOFA_annotated.RDS        # Trained model with clinical metadata
│   ├── factor_analysis_results.RDS   # Factor scores and variance explained
│   ├── ranked_genes_Factor1.csv      # Ranked gene list for GSEA
│   ├── all_weights.csv               # All feature weights per factor per view
│   ├── all_factor_scores.csv         # Z matrix (patients × factors)
│   └── figures/                      # Plots saved by notebooks
└── diablo/
    ├── breast_TCGA_processed.RDS     # Saved list from Notebook 01
    ├── single_omics_baselines.RDS    # Single-omic sPLS-DA models
    ├── single_omics_results.RDS      # Baseline performance metrics
    ├── perf_ncomp.RDS                # ncomp tuning CV results
    ├── tune_keepX.RDS                # keepX tuning CV results
    ├── cv_final.RDS                  # Final model CV results
    ├── DIABLO_final_model.RDS        # Final DIABLO model + test predictions
    ├── biomarker_panel.csv           # Selected features per block
    ├── auc_results.csv               # Per-class AUC on test set
    └── figures/                      # Plots saved by notebooks
```

All `.hdf5` and large `.RDS` files are listed in `.gitignore`.
To regenerate them, run the notebooks in sequential order.
