# Biological Context

Background reading for the two analyses in this repository.

---

## Analysis 1: Chronic Lymphocytic Leukemia (CLL)

### What is CLL?

Chronic lymphocytic leukemia is a malignancy of mature B lymphocytes. It is the most
common adult leukemia in Western countries, with ~20,000 new diagnoses per year in the USA.
Despite a single diagnostic category, CLL encompasses at least two biologically distinct
diseases with very different prognoses.

### The IGHV Paradox

The strongest prognostic factor in CLL is the **mutational status of the immunoglobulin
heavy chain variable (IGHV) region** — a genomic scar left by the normal B-cell maturation
process called somatic hypermutation:

| IGHV status | B-cell origin | Clinical course | First treatment |
|-------------|--------------|-----------------|----------------|
| Mutated (M) | Memory B cell (post-germinal centre) | Indolent; watch-and-wait for years | Median >10 years after diagnosis |
| Unmutated (U) | Naïve B cell (pre-germinal centre) | Aggressive; early relapse | Often within 2-3 years |

This single molecular distinction has genome-wide consequences:
- **mRNA**: Unmutated CLL overexpresses ZAP70, LPL, and BCR signalling genes
- **Methylation**: Different methylation patterns reflecting naïve vs memory B-cell developmental programmes (the "CLL methylation clock")
- **Drug response**: Unmutated CLL shows greater sensitivity to BCR pathway inhibitors (ibrutinib, idelalisib) due to constitutive BCR signalling

### Other Major Molecular Drivers

| Alteration | Frequency | Clinical impact |
|-----------|-----------|----------------|
| del(13q14) | ~55% | Favourable prognosis; miR-15a/16-1 deleted |
| Trisomy 12 | ~15% | Intermediate; distinct transcriptional programme |
| del(11q22) | ~15% | Aggressive; ATM gene deleted |
| del(17p13) / TP53 mutation | ~7–10% | Poor; resistant to chemotherapy |
| SF3B1 mutation | ~10% | Aggressive; splicing dysregulation |
| NOTCH1 mutation | ~10% | Aggressive; enriched in unmutated IGHV |

### Multi-Omics Rationale

No single molecular layer fully explains CLL heterogeneity:
- **mRNA alone**: Captures IGHV-driven transcriptional differences but not epigenetic state
- **Methylation alone**: Captures developmental origin but not current signalling activity
- **Drug response alone**: Captures functional phenotype but not causal molecular mechanism
- **Mutations alone**: Captures driver alterations but not the full molecular consequence

MOFA+ integrates all four layers to find the major axes of variation that are consistent
across platforms — these represent robust, multi-evidence biological signals.

### Therapeutic Landscape

| Drug class | Target | Relevant CLL biology |
|-----------|--------|---------------------|
| Ibrutinib | BTK | BCR signalling; constitutive in unmutated IGHV |
| Venetoclax | BCL-2 | Apoptosis evasion; effective in del(17p), TP53-mutated |
| Idelalisib | PI3Kδ | BCR pathway; combined with rituximab |
| Bendamustine | DNA alkylation | Classical chemotherapy; less effective in TP53-mutated |
| Fludarabine | Purine analogue | Standard regimen; poor outcome in del(17p) |

The drug response view in the CLL MOFA+ analysis directly maps molecular factors to
differential drug sensitivity — the translational bridge between biology and treatment.

---

## Analysis 2: Breast Cancer PAM50 Subtypes

### The PAM50 Classification

The PAM50 gene expression signature classifies breast tumours into five intrinsic subtypes,
each representing a distinct biological programme with different prognosis and treatment:

#### Luminal A (~35–40% of breast cancers)
- **Molecular features**: ER+, PR+/−, HER2−; low Ki67; FOXA1/GATA3/ESR1-driven
- **Prognosis**: Best among all subtypes; 10-year survival >80%
- **Treatment**: Endocrine therapy (tamoxifen or aromatase inhibitors); chemotherapy often not needed
- **Key biology**: Oestrogen receptor acts as master transcription factor; low proliferation rate

#### Luminal B (~20–25% of breast cancers)
- **Molecular features**: ER+, PR−/+, HER2+/−; high Ki67; CDK4/6 pathway activated
- **Prognosis**: Intermediate; higher proliferation than Luminal A
- **Treatment**: Endocrine therapy + CDK4/6 inhibitors (palbociclib, ribociclib); sometimes chemo
- **Key biology**: PI3K/AKT pathway activation; cyclin D1 overexpression

#### HER2-enriched (~15% of breast cancers)
- **Molecular features**: ER−, PR−, HER2+; ERBB2 gene amplification at 17q12
- **Prognosis**: Historically poor; dramatically improved with HER2-targeted therapy
- **Treatment**: Trastuzumab, pertuzumab, T-DM1, or tucatinib ± chemotherapy
- **Key biology**: ERBB2 amplification → constitutive kinase activity → PI3K/MAPK/mTOR activation

#### Basal-like (~15% of breast cancers)
- **Molecular features**: ER−, PR−, HER2−; high Ki67; TP53 mutations (>80%); BRCA1-associated
- **Prognosis**: Worst 5-year survival; some long-term survivors after complete chemo response
- **Treatment**: Platinum-based chemotherapy; immunotherapy (pembrolizumab in TNBC); PARP inhibitors (BRCA1/2-mutated)
- **Key biology**: Basal/myoepithelial cell origin; activation of proliferation, DNA damage response, immune pathways

#### Normal-like (~5% of breast cancers)
- **Molecular features**: Similar to normal breast tissue; technical contamination suspected
- **Note**: Not included in the breast.TCGA subset used here

### Multi-Omics Rationale for Subtyping

Current clinical subtyping uses IHC for ER, PR, HER2, and Ki67 — a simplified proxy for
the underlying molecular programmes. Multi-omics integration adds:

**mRNA** captures the transcriptional programme:
- Luminal programme: ESR1, FOXA1, GATA3, TFF1, AGR2
- Basal programme: KRT5, KRT17, FOXM1, CCNB1, MKI67
- HER2 programme: ERBB2, GRB7, STARD3, PERLD1

**miRNA** adds regulatory logic:
- miR-200 family: maintain epithelial identity by suppressing ZEB1/ZEB2 (EMT drivers)
  → high in Luminal A, defines the luminal–basal boundary
- let-7 family: target HMGA2, KRAS; enriched in luminal subtypes
- miR-21: target PTEN and PDCD4; enriched in aggressive subtypes
- miR-155: immune/inflammatory signalling; elevated in HER2

**Proteomics (RPPA)** captures functional pathway activity:
- ER protein: post-translationally regulated; captures true receptor positivity
- Phospho-HER2: activated receptor, therapeutic target confirmation
- Phospho-AKT, phospho-mTOR: PI3K pathway activity → CDK4/6 inhibitor sensitivity
- Cyclin B1/CDK1: proliferation complex, elevated in Basal

### Why Multi-Omics Improves Classification

Each regulatory layer adds orthogonal discriminant information:
1. mRNA → what genes are transcribed
2. miRNA → which mRNAs are post-transcriptionally suppressed
3. Proteomics → which proteins are actually present and functionally active

A tumour that looks Luminal A by mRNA but has aberrant miR-200 loss and low ER protein
may behave more aggressively — information missed by mRNA alone.

DIABLO's design matrix explicitly models the correlation between these layers,
building a classifier that leverages their joint signal rather than treating them independently.

### Clinical Translation

| Assay type | Current standard | Multi-omics future |
|-----------|-----------------|------------------|
| Primary subtyping | IHC (ER, PR, HER2, Ki67) | Integrated mRNA/miRNA/protein panel |
| Treatment selection | Oncotype DX / MammaPrint (mRNA only) | Multi-omics recurrence predictor |
| Minimal residual disease | Circulating tumour DNA | ctDNA + proteomic biomarkers |
| Drug sensitivity prediction | Histological grade | DIABLO-style classifier from biopsy |

The DIABLO analysis in this repository demonstrates the feasibility of such a multi-omics
classifier, identifying a minimal panel that outperforms any single-omic approach.
