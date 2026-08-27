library(ggplot2)

het <- read.delim(
  "reducta_4pop_heterozygosity.tsv",
  header = TRUE
)

het$Population <- factor(
  het$Population,
  levels = c("West", "Italy", "Balkans", "East")
)

het_long <- rbind(
  data.frame(
    Population = het$Population,
    Heterozygosity = het$Observed_Heterozygosity,
    Type = "Observed heterozygosity"
  ),
  data.frame(
    Population = het$Population,
    Heterozygosity = het$Expected_Heterozygosity,
    Type = "Expected heterozygosity"
  )
)

het_long$Type <- factor(
  het_long$Type,
  levels = c(
    "Observed heterozygosity",
    "Expected heterozygosity"
  )
)

ggplot(
  het_long,
  aes(x = Population, y = Heterozygosity)
) +
  geom_col(width = 0.65) +
  facet_wrap(~Type, ncol = 2) +
  labs(
    x = "Population",
    y = "Heterozygosity"
  ) +
  theme_classic(base_size = 14)