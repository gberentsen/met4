# Tester at dplyr-løsningene i hint- og løsningsblokkene gir svar som
# rettelogikken i kursgodkjenning.qmd godtar, inkludert 1x1-tabeller fra
# summarise(). Speiler koden i check-cellene.
#
#   Rscript test-dplyr.R

suppressMessages(library(dplyr))
load("boliger.RData")

feil <- 0

# Nøyaktig samme normalisering som i check-cellene.
normaliser <- function(res) {
  verdi <- res
  if (is.data.frame(verdi) && nrow(verdi) == 1 && ncol(verdi) == 1) verdi <- verdi[[1]]
  suppressWarnings(tryCatch(as.numeric(verdi), error = function(e) NA_real_))
}

sjekk <- function(navn, res, fasit, toleranse) {
  verdi <- normaliser(res)
  gyldig <- length(verdi) == 1 && !is.na(verdi)
  ok <- gyldig && abs(verdi - fasit) < toleranse
  cat(sprintf("%-16s %-14s %-28s %s\n",
              navn,
              if (gyldig) format(round(verdi, 4)) else "ikke ett tall",
              paste0("(", class(res)[1], ", fasit ", fasit, ")"),
              if (ok) "OK" else "FEIL"))
  if (!ok) feil <<- feil + 1
}

cat("-- dplyr-løsningene --\n")

sjekk("1a dplyr",
      boliger %>% filter(bydel == "Bergenhus", mobelert == "Ja") %>% summarise(antall = n()),
      248, 0.5)

sjekk("1d dplyr",
      boliger %>%
        group_by(bydel) %>%
        summarise(median_pris = median(pris)) %>%
        summarise(spenn = max(median_pris) - min(median_pris)),
      2425, 1)

# Varianter studenter realistisk kan ende opp med
sjekk("1a count()",
      boliger %>% filter(bydel == "Bergenhus", mobelert == "Ja") %>% count(),
      248, 0.5)

sjekk("1a nrow()",
      boliger %>% filter(bydel == "Bergenhus", mobelert == "Ja") %>% nrow(),
      248, 0.5)

sjekk("1a pull()",
      boliger %>% filter(bydel == "Bergenhus", mobelert == "Ja") %>% summarise(n = n()) %>% pull(n),
      248, 0.5)

sjekk("1b dplyr",
      boliger %>% summarise(r = cor(pris, areal)),
      0.7697, 0.002)

cat("\n-- hintet i 3c --\n")
print(boliger %>% group_by(mobelert) %>% summarise(snitt_areal = mean(areal)))

cat("\n-- svar som fortsatt skal avvises --\n")
flerkolonne <- boliger %>% group_by(bydel) %>% summarise(median_pris = median(pris))
v <- normaliser(flerkolonne)
cat("fire medianer (skal avvises):", if (length(v) != 1 || anyNA(v)) "OK, avvises" else "FEIL, godtas", "\n")
v <- normaliser("b")
cat("tekststreng   (skal avvises):", if (length(v) != 1 || is.na(v)) "OK, avvises" else "FEIL, godtas", "\n")
v <- normaliser(t.test(pris ~ mobelert, data = boliger))
cat("hele t.test   (skal avvises):", if (length(v) != 1 || is.na(v)) "OK, avvises" else "FEIL, godtas", "\n")
v <- normaliser(lm(pris ~ mobelert, data = boliger))
cat("hele lm       (skal avvises):", if (length(v) != 1 || is.na(v)) "OK, avvises" else "FEIL, godtas", "\n")
v <- normaliser(summary(lm(pris ~ mobelert, data = boliger)))
cat("hele summary  (skal avvises):", if (length(v) != 1 || is.na(v)) "OK, avvises" else "FEIL, godtas", "\n")
v <- normaliser(coef(lm(pris ~ mobelert, data = boliger)))
cat("begge koeff.  (skal avvises):", if (length(v) != 1 || anyNA(v)) "OK, avvises" else "FEIL, godtas", "\n")

cat("\n", if (feil == 0) "Alle sjekker OK.\n" else paste(feil, "SJEKKER FEILET.\n"))
