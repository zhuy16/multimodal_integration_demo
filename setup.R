# setup.R
# Run once after `conda env create -f environment.yml` to install all
# Bioconductor packages. These are built from source by BiocManager
# because bioconda does not ship ARM binaries for all of them.
#
# Usage:
#   conda activate multiomics-demo
#   Rscript setup.R

message("=== Bioconductor package setup ===\n")

# ── CRAN packages not available as pre-built conda binaries ──────────────────
# psych:      required by MOFA2::correlate_factors_with_covariates
# NOTE: r-psych and r-data.table are also listed in environment.yml so conda
#       installs them first; this block is a safety net for bare-R installs.
cran_pkgs <- c("psych", "data.table")
cran_missing <- cran_pkgs[!cran_pkgs %in% rownames(installed.packages())]
if (length(cran_missing) > 0) {
  message("Installing CRAN packages: ", paste(cran_missing, collapse = ", "), "\n")
  install.packages(cran_missing, repos = "https://cloud.r-project.org", Ncpus = 2)
}

# ── Bioconductor packages ─────────────────────────────────────────────────────
# NOTE: fgsea requires R >= 4.4 for binary installs and fails to compile from
# source on R 4.3 (BH/Rcpp C++14 incompatibility). The notebooks call
# requireNamespace("fgsea", quietly=TRUE) and skip the GSEA section gracefully.
# Upgrade to R >= 4.4 to enable fgsea.
bioc_pkgs <- c(
  "BiocParallel",  # parallel backend (dependency of MOFA2 + mixOmics)
  "MOFAdata",      # contains CLL_data and CLL_covariates
  "MOFA2",         # multi-omics factor analysis
  "mixOmics",      # DIABLO and breast.TCGA dataset
  "limma",         # used internally by mixOmics
  "org.Hs.eg.db"   # Ensembl ID → gene symbol mapping for mRNA annotation
)

missing <- bioc_pkgs[!bioc_pkgs %in% rownames(installed.packages())]

if (length(missing) == 0) {
  message("All Bioconductor packages already installed.")
} else {
  message("Installing: ", paste(missing, collapse = ", "), "\n")
  # Ncpus=2 speeds up source compilation on multi-core machines
  BiocManager::install(missing, update = FALSE, ask = FALSE, Ncpus = 2)
}

# Verify everything loads
message("\nVerifying package loads...")
ok <- sapply(bioc_pkgs, requireNamespace, quietly = TRUE)

if (all(ok)) {
  message("All packages OK. Environment is ready.\n")
  message("Next step: run the notebooks in order:")
  message("  Rscript -e \"rmarkdown::render('rmd/01_mofa_cll/01_data_loading_eda.Rmd')\"")
} else {
  stop("Failed to load: ", paste(bioc_pkgs[!ok], collapse = ", "),
       "\nCheck error messages above and retry.")
}

# ── Register R kernel with Jupyter ────────────────────────────────────────────
# Makes the "R" kernel appear in JupyterLab / Jupyter Notebook.
# Safe to run multiple times; silently skips if IRkernel is not installed.
if (requireNamespace("IRkernel", quietly = TRUE)) {
  message("\nRegistering R Jupyter kernel...")
  try(
    IRkernel::installspec(name = "ir", displayname = "R (multiomics-demo)"),
    silent = TRUE
  )
  message("R kernel registered. Run `jupyter kernelspec list` to verify.")
} else {
  message("\nIRkernel not found — skipping kernel registration.",
          "\nInstall it with: conda install -c conda-forge r-irkernel")
}
