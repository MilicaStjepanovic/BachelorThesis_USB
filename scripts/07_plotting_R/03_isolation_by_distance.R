library(geosphere)
library(vegan)

packageVersion("geosphere")
packageVersion("vegan")

coordinates <- read.table(
  "coordinates_98_reducta.txt",
  header = FALSE,
  stringsAsFactors = FALSE
)

colnames(coordinates) <- c(
  "Sample",
  "Population",
  "Latitude",
  "Longitude"
)

genetic_ids <- read.table(
  "reducta_individual_1minusIBS.mdist.id",
  header = FALSE,
  stringsAsFactors = FALSE
)

genetic_distance_matrix <- as.matrix(
  read.table(
    "reducta_individual_1minusIBS.mdist",
    header = FALSE
  )
)

cat("=== DIMENSIONS ===\n")
cat("Coordinates:", nrow(coordinates), "rows\n")
cat("Genetic IDs:", nrow(genetic_ids), "rows\n")
cat(
  "Genetic matrix:",
  nrow(genetic_distance_matrix),
  "x",
  ncol(genetic_distance_matrix),
  "\n"
)

cat("\n=== SAMPLE ORDER CHECK ===\n")
cat(
  "IDs identical:",
  identical(coordinates$Sample, genetic_ids$V2),
  "\n"
)

cat("\n=== FIRST 6 COORDINATES ===\n")
print(head(coordinates))

cat("\n=== GENETIC MATRIX QC ===\n")
cat(
  "Diagonal all zero:",
  all(diag(genetic_distance_matrix) == 0),
  "\n"
)

cat(
  "Symmetric:",
  isTRUE(all.equal(
    genetic_distance_matrix,
    t(genetic_distance_matrix)
  )),
  "\n"
)

cat(
  "Genetic distance range:",
  range(genetic_distance_matrix),
  "\n"
)

difference_matrix <- abs(
  genetic_distance_matrix - t(genetic_distance_matrix)
)

cat("=== SYMMETRY DIAGNOSTICS ===\n")

cat(
  "Maximum absolute difference:",
  max(difference_matrix),
  "\n"
)

cat(
  "Mean absolute difference:",
  mean(difference_matrix),
  "\n"
)

cat(
  "Number of unequal cells:",
  sum(difference_matrix != 0),
  "\n"
)

cat(
  "Number differing by > 1e-10:",
  sum(difference_matrix > 1e-10),
  "\n"
)

cat(
  "Number differing by > 1e-6:",
  sum(difference_matrix > 1e-6),
  "\n"
)

which(
  difference_matrix == max(difference_matrix),
  arr.ind = TRUE
)

coordinate_matrix <- as.matrix(
  coordinates[, c("Longitude", "Latitude")]
)

geographic_distance_matrix <- geosphere::distm(
  coordinate_matrix,
  fun = geosphere::distGeo
) / 1000

rownames(geographic_distance_matrix) <- coordinates$Sample
colnames(geographic_distance_matrix) <- coordinates$Sample

diag(geographic_distance_matrix) <- 0

cat("=== GEOGRAPHIC MATRIX QC ===\n")

cat(
  "Dimensions:",
  nrow(geographic_distance_matrix),
  "x",
  ncol(geographic_distance_matrix),
  "\n"
)

cat(
  "Diagonal all zero:",
  all(diag(geographic_distance_matrix) == 0),
  "\n"
)

cat(
  "Maximum asymmetry:",
  max(abs(
    geographic_distance_matrix -
      t(geographic_distance_matrix)
  )),
  "\n"
)

cat(
  "Geographic distance range (km):",
  range(geographic_distance_matrix),
  "\n"
)

cat(
  "Any NA values:",
  anyNA(geographic_distance_matrix),
  "\n"
)

cat(
  "Row IDs identical to genetic IDs:",
  identical(
    rownames(geographic_distance_matrix),
    genetic_ids$V2
  ),
  "\n"
)

cat("\n=== FIRST 5 x 5 DISTANCES (km) ===\n")
print(round(geographic_distance_matrix[1:5, 1:5], 1))

write.csv(
  geographic_distance_matrix,
  file = "Geographic_distance_matrix_km.csv",
  row.names = TRUE
)

rownames(genetic_distance_matrix) <- genetic_ids$V2
colnames(genetic_distance_matrix) <- genetic_ids$V2

cat("=== FINAL CROSS-MATRIX QC ===\n")

cat(
  "Same dimensions:",
  identical(
    dim(genetic_distance_matrix),
    dim(geographic_distance_matrix)
  ),
  "\n"
)

cat(
  "Same row IDs:",
  identical(
    rownames(genetic_distance_matrix),
    rownames(geographic_distance_matrix)
  ),
  "\n"
)

cat(
  "Same column IDs:",
  identical(
    colnames(genetic_distance_matrix),
    colnames(geographic_distance_matrix)
  ),
  "\n"
)

cat(
  "Genetic diagonal zero:",
  all(diag(genetic_distance_matrix) == 0),
  "\n"
)

cat(
  "Geographic diagonal zero:",
  all(diag(geographic_distance_matrix) == 0),
  "\n"
)

cat(
  "Genetic symmetric:",
  max(abs(
    genetic_distance_matrix -
      t(genetic_distance_matrix)
  )) == 0,
  "\n"
)

cat(
  "Geographic symmetric:",
  max(abs(
    geographic_distance_matrix -
      t(geographic_distance_matrix)
  )) == 0,
  "\n"
)

set.seed(123)

mantel_pairwise <- vegan::mantel(
  as.dist(genetic_distance_matrix),
  as.dist(geographic_distance_matrix),
  method = "spearman",
  permutations = 9999
)

mantel_pairwise

geo_values <- geographic_distance_matrix[
  lower.tri(geographic_distance_matrix)
]

genetic_values <- genetic_distance_matrix[
  lower.tri(genetic_distance_matrix)
]

ibd_lm <- lm(genetic_values ~ geo_values)

cat("=== PAIRWISE OBSERVATIONS ===\n")
cat("Number of pairs:", length(geo_values), "\n")

cat("\n=== LINEAR REGRESSION ===\n")
cat("Intercept:", coef(ibd_lm)[1], "\n")
cat("Slope per km:", coef(ibd_lm)[2], "\n")
cat("R-squared:", summary(ibd_lm)$r.squared, "\n")

cat("\n=== FULL REGRESSION SUMMARY ===\n")
summary(ibd_lm)

plot(
  geo_values,
  genetic_values,
  pch = 19,
  cex = 0.45,
  xlab = "Geographic distance (km)",
  ylab = "Genetic distance (1 - IBS)",
  main = "Isolation by distance in Limenitis reducta"
)

abline(
  ibd_lm,
  lwd = 2
)

legend(
  "bottomright",
  legend = c(
    "Mantel r = 0.705",
    "p = 0.0001",
    "Slope = 8.69 × 10^-5 per km"
  ),
  bty = "n"
)
