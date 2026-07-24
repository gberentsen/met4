# Genererer datasettet til den obligatoriske kursgodkjenningen.
# Kjør dette scriptet på nytt bare hvis datasettet skal endres; da må alle
# fasitverdiene i kursgodkjenning.qmd oppdateres tilsvarende (se utskriften nederst).
#
#   Rscript lag-boligdata.R
#
# Skriver: boliger.RData (objektene `boliger` og `nye`)

set.seed(2026)

n <- 900

bydel <- sample(
  c("Bergenhus", "Årstad", "Fana", "Åsane"),
  n, replace = TRUE, prob = c(0.35, 0.25, 0.20, 0.20)
)

# Sentrumsboliger er systematisk mindre enn boliger lenger ut.
areal_snitt <- c(Bergenhus = 52, Årstad = 63, Fana = 80, Åsane = 76)[bydel]
areal_sd    <- c(Bergenhus = 17, Årstad = 20, Fana = 26, Åsane = 24)[bydel]
areal <- round(pmin(pmax(rnorm(n, areal_snitt, areal_sd), 22), 165))

soverom <- pmin(pmax(1 + floor((areal - 25) / 27), 1), 4)

byggeaar_snitt <- c(Bergenhus = 1948, Årstad = 1968, Fana = 1988, Åsane = 1985)[bydel]
byggeaar <- round(pmin(pmax(rnorm(n, byggeaar_snitt, 22), 1890), 2023))

avstand_snitt <- c(Bergenhus = 0.9, Årstad = 2.8, Fana = 9.5, Åsane = 11.5)[bydel]
avstand <- round(pmax(rnorm(n, avstand_snitt, avstand_snitt * 0.25), 0.2), 1)

balkong <- ifelse(runif(n) < ifelse(byggeaar > 1970, 0.72, 0.34), "Ja", "Nei")

# Møblering henger sammen med både bydel og størrelse: små sentrumsleiligheter
# leies i stor grad ut møblert. Dette er den utelatte variabelen i oppgave 3.
p_mob <- plogis(-0.4 + 1.5 * (bydel == "Bergenhus") - 0.055 * (areal - 60))
mobelert <- ifelse(runif(n) < p_mob, "Ja", "Nei")

er_mob <- mobelert == "Ja"

# Møbleringspremie: 1300 kr, og ytterligere 2300 kr i Bergenhus.
premie <- ifelse(er_mob, 1300 + 2300 * (bydel == "Bergenhus"), 0)

# Møblerte boliger har mer spredning i pris (F-testen i oppgave 2a).
stoy <- rnorm(n, 0, ifelse(er_mob, 3300, 2100))

pris <- 4200 +
  168 * areal +
  850 * soverom -
  185 * avstand +
  9 * (byggeaar - 1900) +
  700 * (balkong == "Ja") +
  premie +
  stoy

pris <- round(pmax(pris, 4500), -1)

boliger <- data.frame(
  id = 1:n,
  pris = pris,
  areal = areal,
  soverom = soverom,
  bydel = factor(bydel, levels = c("Bergenhus", "Årstad", "Fana", "Åsane")),
  mobelert = factor(mobelert, levels = c("Nei", "Ja")),
  balkong = factor(balkong, levels = c("Nei", "Ja")),
  byggeaar = byggeaar,
  avstand = avstand,
  stringsAsFactors = FALSE
)

# Fem boliger som skal legges ut for utleie, uten observert pris.
nye <- data.frame(
  id = 901:905,
  areal = c(45, 68, 95, 55, 110),
  soverom = c(1, 2, 3, 2, 4),
  bydel = factor(
    c("Bergenhus", "Årstad", "Fana", "Bergenhus", "Åsane"),
    levels = levels(boliger$bydel)
  ),
  mobelert = factor(c("Ja", "Nei", "Nei", "Ja", "Nei"), levels = levels(boliger$mobelert)),
  balkong = factor(c("Nei", "Ja", "Ja", "Nei", "Ja"), levels = levels(boliger$balkong)),
  byggeaar = c(1935, 1972, 1996, 1958, 2004),
  avstand = c(0.6, 2.9, 8.8, 1.2, 12.4)
)

save(boliger, nye, file = "boliger.RData")

# ---------------------------------------------------------------------------
# Fasitverdier til check-cellene i kursgodkjenning.qmd
# ---------------------------------------------------------------------------
cat("\n===== FASIT =====\n")

cat("1a antall møblert i Bergenhus :",
    sum(boliger$mobelert == "Ja" & boliger$bydel == "Bergenhus"), "\n")

med <- tapply(boliger$pris, boliger$bydel, median)
cat("1c medianpris per bydel      :", paste(names(med), med, collapse = " | "), "\n")
cat("1c spenn (maks - min median) :", max(med) - min(med), "\n")

cat("1d korrelasjon pris/areal    :", round(cor(boliger$pris, boliger$areal), 6), "\n")

ft <- var.test(pris ~ mobelert, data = boliger)
cat("2a F-test p-verdi            :", format(ft$p.value, digits = 6),
    " F =", round(ft$statistic, 4), "\n")

tt <- t.test(pris ~ mobelert, data = boliger)
cat("2c Welch t-test p-verdi      :", round(tt$p.value, 6),
    " t =", round(tt$statistic, 4), "\n")
cat("   snitt Nei / Ja            :", round(tt$estimate, 1), "\n")

kj <- chisq.test(table(boliger$bydel, boliger$mobelert))
cat("2d kjikvadrat X2             :", round(kj$statistic, 4),
    " p =", format(kj$p.value, digits = 6), " df =", kj$parameter, "\n")

m1 <- lm(pris ~ mobelert, data = boliger)
cat("3a enkel modell, mobelertJa  :", round(coef(m1)[2], 4),
    " p =", round(summary(m1)$coefficients[2, 4], 5), "\n")

m2 <- lm(pris ~ mobelert + areal + soverom + bydel + byggeaar + balkong, data = boliger)
cat("3b multippel, mobelertJa     :", round(coef(m2)[2], 4),
    " p =", format(summary(m2)$coefficients[2, 4], digits = 4), "\n")
cat("3e justert R2 (m2)           :", round(summary(m2)$adj.r.squared, 6), "\n")

pred <- predict(m2, newdata = nye)
cat("3d prediksjoner nye          :", paste(round(pred, 1), collapse = " | "), "\n")
cat("3d høyeste predikerte pris   :", round(max(pred), 4), "\n")

m3 <- lm(pris ~ mobelert * bydel + areal + soverom + byggeaar + balkong, data = boliger)
ko <- summary(m3)$coefficients
cat("4a interaksjonsledd          :\n")
print(round(ko[grepl(":", rownames(ko)), c(1, 2, 4)], 4))
cat("4a mobelertJa (hovedeffekt)  :", round(ko["mobelertJa", 1], 4),
    " p =", format(ko["mobelertJa", 4], digits = 4), "\n")

cat("\nantall rader:", nrow(boliger), " kolonner:", ncol(boliger), "\n")
cat("andel møblert:", round(mean(boliger$mobelert == "Ja"), 3), "\n")
print(summary(boliger$pris))
