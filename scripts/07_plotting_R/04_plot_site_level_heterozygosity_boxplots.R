library(ggplot2)

d <- read.table(
  "populations.sumstats.tsv",
  header = FALSE,
  comment.char = "#",
  stringsAsFactors = FALSE,
  fill = TRUE
)

d <- d[, 1:21]

colnames(d) <- c(
  "Locus_ID",
  "Chr",
  "BP",
  "Col",
  "Population",
  "P_Nuc",
  "Q_Nuc",
  "N",
  "P",
  "Obs_Het",
  "Obs_Hom",
  "Exp_Het",
  "Exp_Hom",
  "Pi",
  "Smoothed_Pi",
  "Smoothed_Pi_Pvalue",
  "Fis",
  "Smoothed_Fis",
  "Smoothed_Fis_Pvalue",
  "HWE_Pvalue",
  "Private"
)

d$Obs_Het <- as.numeric(d$Obs_Het)
d$Exp_Het <- as.numeric(d$Exp_Het)

d$Obs_Het[d$Obs_Het < 0] <- NA
d$Exp_Het[d$Exp_Het < 0] <- NA

d$Population <- factor(
  d$Population,
  levels = c("West", "Italy", "Balkans", "East")
)

summary(d$Obs_Het)
summary(d$Exp_Het)

tapply(d$Obs_Het, d$Population, median, na.rm = TRUE)
tapply(d$Exp_Het, d$Population, median, na.rm = TRUE)

tapply(d$Obs_Het, d$Population, mean, na.rm = TRUE)
tapply(d$Exp_Het, d$Population, mean, na.rm = TRUE)

het <- rbind(
  data.frame(
    Population = d$Population,
    Heterozygosity = d$Obs_Het,
    Type = "Observed heterozygosity"
  ),
  data.frame(
    Population = d$Population,
    Heterozygosity = d$Exp_Het,
    Type = "Expected heterozygosity"
  )
)

het$Type <- factor(
  het$Type,
  levels = c(
    "Observed heterozygosity",
    "Expected heterozygosity"
  )
)

ggplot(
  het,
  aes(x = Population, y = Heterozygosity)
) +
  geom_boxplot(outlier.shape = NA) +
  facet_wrap(
    ~Type,
    ncol = 2,
    scales = "free_y"
  ) +
  labs(
    x = "Population",
    y = "Heterozygosity"
  ) +
  theme_classic(base_size = 14)
