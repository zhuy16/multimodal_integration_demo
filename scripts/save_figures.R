# scripts/save_figures.R
# Generates and saves key summary figures to results/*/figures/.
# Run after all notebooks have been executed:
#   conda activate multiomics-demo
#   Rscript scripts/save_figures.R

suppressPackageStartupMessages({
  library(MOFA2)
  library(mixOmics)
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(RColorBrewer)
})

theme_set(theme_bw(base_size = 12))
dir.create("results/mofa/figures",   showWarnings = FALSE, recursive = TRUE)
dir.create("results/diablo/figures", showWarnings = FALSE, recursive = TRUE)

# ── MOFA+ figures ─────────────────────────────────────────────────────────────

mofa  <- readRDS("results/mofa/CLL_MOFA_annotated.RDS")
meta  <- samples_metadata(mofa)
fs    <- read.csv("results/mofa/all_factor_scores.csv") |>
           rename(sample = X)

rv    <- get_variance_explained(mofa)$r2_per_factor[[1]]

# 1. Variance explained heatmap
r2_df <- as.data.frame(rv) |>
  tibble::rownames_to_column("Factor") |>
  tidyr::pivot_longer(-Factor, names_to = "View", values_to = "R2") |>
  dplyr::filter(!is.na(R2)) |>
  dplyr::mutate(Factor = factor(Factor, levels = rev(rownames(rv))))

p1 <- ggplot(r2_df, aes(x = View, y = Factor, fill = R2)) +
  geom_tile(colour = "white", linewidth = 0.5) +
  geom_text(aes(label = round(R2, 1)), size = 3.5) +
  scale_fill_distiller(palette = "YlOrRd", direction = 1,
                       name = "R² (%)") +
  labs(title = "MOFA+: Variance explained per factor per view",
       x = NULL, y = NULL) +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

ggsave("results/mofa/figures/variance_explained_heatmap.png",
       p1, width = 6, height = 5, dpi = 150)
message("Saved: variance_explained_heatmap.png")

# 2. Factor 1 vs Factor 2 scatter — coloured by IGHV status
fs_meta <- merge(fs, meta, by = "sample")

p2 <- ggplot(fs_meta, aes(x = Factor1, y = Factor2,
                           colour = IGHV, shape = IGHV)) +
  geom_point(size = 2.5, alpha = 0.85) +
  scale_colour_manual(values = c("M" = "#2166ac", "U" = "#d73027"),
                      na.value = "grey70") +
  scale_shape_manual(values = c("M" = 16, "U" = 17)) +
  labs(title = "MOFA+: Factor 1 vs Factor 2",
       subtitle = sprintf(
         "Factor 1 strongly separates IGHV status (Spearman r = -0.80)"),
       x = "Factor 1", y = "Factor 2",
       colour = "IGHV", shape = "IGHV") +
  theme(legend.position = "right")

ggsave("results/mofa/figures/factor1_vs_factor2_IGHV.png",
       p2, width = 6, height = 5, dpi = 150)
message("Saved: factor1_vs_factor2_IGHV.png")

# 3. Total variance explained per view (bar chart)
p3 <- as.data.frame(rv) |>
  tibble::rownames_to_column("factor") |>
  tidyr::pivot_longer(-factor, names_to = "view", values_to = "r2") |>
  dplyr::filter(!is.na(r2)) |>
  dplyr::group_by(view) |>
  dplyr::summarise(total_r2 = sum(r2), .groups = "drop") |>
  ggplot(aes(x = reorder(view, total_r2), y = total_r2, fill = view)) +
  geom_col(show.legend = FALSE, alpha = 0.85) +
  coord_flip() +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "MOFA+: Total variance explained per view (all factors)",
       x = NULL, y = "Cumulative R² (%)")

ggsave("results/mofa/figures/total_variance_per_view.png",
       p3, width = 5, height = 3.5, dpi = 150)
message("Saved: total_variance_per_view.png")

# ── DIABLO figures ─────────────────────────────────────────────────────────────

res       <- readRDS("results/diablo/DIABLO_final_model.RDS")
bl_res    <- readRDS("results/diablo/single_omics_results.RDS")
data_obj  <- readRDS("results/diablo/breast_TCGA_processed.RDS")
Y_test    <- data_obj$Y_test

subtype_colors <- c(Basal = "#E41A1C", Her2 = "#FF7F00", LumA = "#4DAF4A")
ncomp <- res$optimal_ncomp

# 4. Test accuracy: DIABLO vs single-omics
single_acc <- bl_res$test_results |>
  select(block, overall_acc) |>
  filter(!is.na(overall_acc))

acc_df <- bind_rows(
  single_acc,
  data.frame(block = "DIABLO (mRNA + miRNA)", overall_acc = res$overall_acc)
)

p4 <- ggplot(acc_df, aes(x = reorder(block, overall_acc), y = overall_acc,
                          fill = block == "DIABLO (mRNA + miRNA)")) +
  geom_col(show.legend = FALSE, alpha = 0.85) +
  geom_text(aes(label = sprintf("%.1f%%", 100 * overall_acc)),
            hjust = -0.1, size = 4) +
  coord_flip() +
  scale_y_continuous(labels = scales::percent, limits = c(0, 1.15)) +
  scale_fill_manual(values = c("FALSE" = "#4393c3", "TRUE" = "#d73027")) +
  labs(title = "DIABLO: Test accuracy vs single-omics baselines",
      subtitle = paste0("Weighted vote over available test blocks (mRNA + miRNA)"),
       x = NULL, y = "Test accuracy")

ggsave("results/diablo/figures/test_accuracy_comparison.png",
       p4, width = 6.5, height = 3.5, dpi = 150)
message("Saved: test_accuracy_comparison.png")

# 5. Confusion matrix
conf_df <- as.data.frame(res$conf_mat)
p5 <- ggplot(conf_df, aes(x = Actual, y = Predicted, fill = Freq)) +
  geom_tile(colour = "white") +
  geom_text(aes(label = Freq), size = 6, fontface = "bold") +
  scale_fill_gradient(low = "white", high = "#2c7bb6") +
  scale_x_discrete(position = "top") +
  labs(title = sprintf("DIABLO confusion matrix — test set (acc = %.1f%%)",
                       100 * res$overall_acc),
       x = "True subtype", y = "Predicted", fill = "Count")

ggsave("results/diablo/figures/confusion_matrix.png",
       p5, width = 5, height = 4, dpi = 150)
message("Saved: confusion_matrix.png")

message("\nAll figures saved to results/mofa/figures/ and results/diablo/figures/")
