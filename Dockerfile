# ── Multiomics Integration Demo ───────────────────────────────────────────────
# Strategy: environment.yml is the SINGLE SOURCE OF TRUTH for all dependencies.
# Docker just installs Miniconda and runs `conda env create -f environment.yml`.
# To add/update a package: edit environment.yml only — both conda and Docker
# will automatically pick up the change.
#
# Build:  docker build -t multiomics-demo .
# Run:    docker run -p 8888:8888 multiomics-demo
#         # or mount your local notebooks:
#         docker run -p 8888:8888 -v $(pwd):/workspace multiomics-demo

FROM continuumio/miniconda3:24.1.2-0

LABEL maintainer="multiomics-demo"
LABEL description="MOFA+ (CLL) and DIABLO (breast.TCGA) multi-omics integration demo"

# ── System libraries required by R/Bioc packages ─────────────────────────────
# These are needed even inside conda because some R packages call system libs.
RUN apt-get update && apt-get install -y --no-install-recommends \
    libhdf5-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libcairo2-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

# ── Copy environment spec ─────────────────────────────────────────────────────
WORKDIR /workspace
COPY environment.yml .

# ── Create conda environment from environment.yml ────────────────────────────
# This is the ONLY place dependencies are installed.
# Any change to environment.yml is automatically reflected here.
RUN conda env create -f environment.yml \
    && conda clean -afy

# ── Activate environment for all subsequent RUN commands ─────────────────────
SHELL ["conda", "run", "-n", "multiomics-demo", "/bin/bash", "-c"]

# ── Copy project files ────────────────────────────────────────────────────────
COPY . .

# ── Install Bioconductor packages via setup.R ─────────────────────────────────
# MOFA2, mixOmics, MOFAdata, limma, BiocParallel are not available as
# pre-built ARM binaries in conda; setup.R builds them from source via
# BiocManager. r-psych and r-data.table are already installed by conda above.
# NOTE: fgsea is skipped on R 4.3 (BH/Rcpp C++14 incompatibility); notebooks
# handle this gracefully with requireNamespace() guards.
RUN Rscript setup.R

# ── Verify key packages load correctly ───────────────────────────────────────
RUN Rscript -e "library(MOFA2); library(mixOmics); library(psych); cat('R packages OK\n')" \
    && python -c "import mofapy2; print('mofapy2 OK')" \
    && python -c "import papermill; print('papermill OK')"

# ── Default command: launch Jupyter with R kernel ────────────────────────────
# Notebooks can be rendered from the terminal or viewed interactively.
EXPOSE 8888
CMD ["conda", "run", "--no-capture-output", "-n", "multiomics-demo", \
     "jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", \
     "--no-browser", "--allow-root", "--notebook-dir=/workspace"]

# ── Alternative: batch execution via papermill ───────────────────────────────
# Run all notebooks non-interactively, writing outputs to notebooks/executed/:
#
#   docker run -v $(pwd)/notebooks/executed:/workspace/notebooks/executed \
#     multiomics-demo bash -c '
#       mkdir -p notebooks/executed
#       for nb in notebooks/01_mofa_cll/0{1,2,3,4}_*.ipynb \
#                  notebooks/02_diablo_brca/0{1,2,3,4}_*.ipynb; do
#         papermill "$nb" "notebooks/executed/$(basename $nb)"
#       done
#     '
#
# Or render R Markdown sources:
#   docker run multiomics-demo Rscript -e \
#     "purrr::walk(list.files('rmd', '\\.Rmd$', recursive=TRUE, full.names=TRUE), rmarkdown::render)"
