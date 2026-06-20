# ============================================================
# ADMIXTURE map + barplot plots for Reducta K=2 to K=10
# Final version using PLINK .fam-order metadata
# ============================================================

packages <- c(
  "ggplot2",
  "dplyr",
  "tidyr",
  "scatterpie",
  "maps",
  "patchwork",
  "scales"
)

for (p in packages) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p)
  }
}

library(ggplot2)
library(dplyr)
library(tidyr)
library(scatterpie)
library(maps)
library(patchwork)
library(scales)

# Run this script from the main repository folder:
# BachelorThesis_USB/

input_dir <- "results/pca_admixture"
metadata_file <- "metadata/sample_lists/admixture_plot_metadata_fam_order.txt"
output_dir <- "results/pca_admixture"

# ------------------------------------------------------------
# Read metadata in PLINK .fam order
# ------------------------------------------------------------

meta <- read.table(
  metadata_file,
  header = FALSE,
  stringsAsFactors = FALSE
)

colnames(meta) <- c("Sample", "Population", "Latitude", "Longitude")

meta$Population <- factor(
  meta$Population,
  levels = c("West", "Italy", "Balkans", "East")
)

stopifnot(nrow(meta) == 98)

# Save final plotting order
meta_ordered <- meta %>%
  arrange(Population, Longitude, Latitude)

write.table(
  meta_ordered,
  file.path("metadata/sample_lists", "FINAL_plotting_order_population_longitude.txt"),
  quote = FALSE,
  row.names = FALSE,
  sep = "\t"
)

# ------------------------------------------------------------
# Check required input files
# ------------------------------------------------------------

required_files <- c(
  file.path(input_dir, paste0("reducta_4pop.K", 2:10, ".Q"))
)

missing_files <- required_files[!file.exists(required_files)]

if (length(missing_files) > 0) {
  stop(
    paste(
      "Missing required Q files:",
      paste(missing_files, collapse = "\n")
    )
  )
}

# ------------------------------------------------------------
# World map background
# ------------------------------------------------------------

world <- map_data("world")

# ------------------------------------------------------------
# Plot function: map + barplot
# ------------------------------------------------------------

make_admixture_map_barplot <- function(K) {
  
  qfile <- file.path(input_dir, paste0("reducta_4pop.K", K, ".Q"))
  q <- read.table(qfile, header = FALSE)
  
  if (nrow(q) != nrow(meta)) {
    stop(paste("Row mismatch in", qfile))
  }
  
  cluster_cols <- paste0("C", 1:K)
  colnames(q) <- cluster_cols
  
  # Important: do not sort before cbind.
  # This keeps Q rows matched to the PLINK .fam-order metadata.
  dat <- cbind(meta, q)
  
  # Map data
  map_dat <- dat
  
  # Barplot data: sort only for display
  bar_dat <- dat %>%
    arrange(Population, Longitude, Latitude)
  
  bar_dat$Sample <- factor(bar_dat$Sample, levels = bar_dat$Sample)
  
  bar_long <- bar_dat %>%
    pivot_longer(
      cols = all_of(cluster_cols),
      names_to = "Cluster",
      values_to = "Ancestry"
    )
  
  bar_long$Cluster <- factor(bar_long$Cluster, levels = cluster_cols)
  
  cluster_palette <- scales::hue_pal()(K)
  names(cluster_palette) <- cluster_cols
  
  # Map with ancestry pie charts
  p_map <- ggplot() +
    geom_polygon(
      data = world,
      aes(x = long, y = lat, group = group),
      fill = "grey90",
      colour = "white",
      linewidth = 0.2
    ) +
    geom_scatterpie(
      data = map_dat,
      aes(x = Longitude, y = Latitude),
      cols = cluster_cols,
      pie_scale = 0.45,
      colour = "black",
      linewidth = 0.25
    ) +
    scale_fill_manual(values = cluster_palette, name = "Ancestry") +
    coord_quickmap(
      xlim = c(-10, 50),
      ylim = c(35, 52),
      expand = FALSE
    ) +
    labs(
      title = paste0("K = ", K),
      x = "Longitude",
      y = "Latitude"
    ) +
    theme_bw(base_size = 10) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0),
      legend.position = "bottom",
      panel.grid = element_blank()
    )
  
  # ADMIXTURE barplot
  p_bar <- ggplot(bar_long, aes(x = Sample, y = Ancestry, fill = Cluster)) +
    geom_bar(stat = "identity", width = 1) +
    facet_grid(. ~ Population, scales = "free_x", space = "free_x") +
    scale_fill_manual(values = cluster_palette, name = "Cluster") +
    scale_y_continuous(expand = c(0, 0)) +
    coord_cartesian(ylim = c(0, 1)) +
    labs(
      x = "Individuals",
      y = "Ancestry proportion"
    ) +
    theme_bw(base_size = 10) +
    theme(
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank(),
      panel.spacing.x = unit(0.12, "lines"),
      strip.background = element_rect(fill = "grey90"),
      strip.text.x = element_text(size = 8),
      legend.position = "bottom"
    )
  
  combined <- p_map / p_bar +
    plot_layout(heights = c(1, 2)) +
    plot_annotation(
      title = paste0("ADMIXTURE Analysis – Reducta (K = ", K, ")")
    )
  
  return(combined)
}

# ------------------------------------------------------------
# Save individual map + barplot PDFs
# ------------------------------------------------------------

for (K in 2:10) {
  p <- make_admixture_map_barplot(K)
  
  ggsave(
    filename = file.path(output_dir, paste0("ADMIXTURE_map_barplot_K", K, ".pdf")),
    plot = p,
    width = 11,
    height = 8.5
  )
}

# ------------------------------------------------------------
# Save combined multi-page PDF
# ------------------------------------------------------------

pdf(
  file.path(output_dir, "ADMIXTURE_map_barplots_K2_to_K10.pdf"),
  width = 11,
  height = 8.5
)

for (K in 2:10) {
  print(make_admixture_map_barplot(K))
}

dev.off()

cat("\nDone. Created ADMIXTURE map + barplot PDFs for K=2 to K=10.\n")

