# Verifiserer at løsningsforslagene i kursgodkjenning.qmd faktisk treffer
# fasitverdiene i check-cellene. Kjør etter enhver endring i lag-boligdata.R.
#
#   Rscript test-fasit.R

load("boliger.RData")

feil <- 0

sjekk <- function(navn, svar, fasit, toleranse) {
  ok <- is.numeric(svar) && length(svar) == 1 && abs(as.numeric(svar) - fasit) < toleranse
  cat(sprintf("%-5s %-12s fasit %-12s %s\n",
              navn,
              format(round(as.numeric(svar), 4), nsmall = 0),
              format(fasit),
              if (ok) "OK" else "FEIL"))
  if (!ok) feil <<- feil + 1
}

# --- Oppgave 1 --------------------------------------------------------------
sjekk("1a", sum(boliger$bydel == "Bergenhus" & boliger$mobelert == "Ja"), 248, 0.5)

sjekk("1b", cor(boliger$pris, boliger$areal), 0.7697, 0.002)

medianer <- tapply(boliger$pris, boliger$bydel, median)
sjekk("1d", max(medianer) - min(medianer), 2425, 1)

# --- Oppgave 2 --------------------------------------------------------------
sjekk("2a", var.test(pris ~ mobelert, data = boliger)$p.value, 0.2875, 0.002)

sjekk("2c", t.test(pris ~ mobelert, data = boliger, var.equal = TRUE)$statistic, 7.3167, 0.01)
# Welch-varianten skal også godkjennes
sjekk("2c*", t.test(pris ~ mobelert, data = boliger)$statistic, 7.3472, 0.01)

# 2d: ensidig test av selskapets hypotese (møblert dyrere). Nivåene er Nei, Ja,
# så R regner Nei - Ja, og "møblert dyrere" betyr at differansen er negativ.
sjekk("2d", t.test(pris ~ mobelert, data = boliger,
                   var.equal = TRUE, alternative = "less")$p.value, 1, 0.001)

sjekk("2f", chisq.test(table(boliger$bydel, boliger$mobelert))$statistic, 217.7436, 0.05)

# --- Oppgave 3 --------------------------------------------------------------
m1 <- lm(pris ~ mobelert, data = boliger)
sjekk("3a", coef(m1)[2], -2353.387, 1)

m2 <- lm(pris ~ mobelert + areal + soverom + bydel + byggeaar + balkong, data = boliger)
sjekk("3b", coef(m2)["mobelertJa"], 1905.24, 1)

sjekk("3d", max(predict(m2, newdata = nye)), 25644.05, 5)

# --- Oppgave 4 --------------------------------------------------------------
m3 <- lm(pris ~ mobelert * bydel + areal + soverom + byggeaar + balkong, data = boliger)
sjekk("4a", coef(m3)["mobelertJa"], 2976.09, 1)

# --- Distraktorene i check-cellene ------------------------------------------
# Disse skal treffe de forklarende feilmeldingene, ikke godkjennes.
cat("\n-- verdier som utløser målrettet feilmelding --\n")
sjekk("1a-A", sum(boliger$bydel == "Bergenhus"), 319, 0.5)
sjekk("1a-B", sum(boliger$mobelert == "Ja"), 413, 0.5)
mn <- tapply(boliger$pris, boliger$bydel, mean)
sjekk("1d-A", max(mn) - min(mn), 2184, 1)
sjekk("2c-A", abs(diff(as.numeric(t.test(pris ~ mobelert, data = boliger)$estimate))), 2353.4, 5)
sjekk("2d-A", t.test(pris ~ mobelert, data = boliger,
                     var.equal = TRUE, alternative = "greater")$p.value, 2.817e-13, 1e-14)
sjekk("2d-B", t.test(pris ~ mobelert, data = boliger, var.equal = TRUE)$p.value, 5.633e-13, 1e-14)
sjekk("2f-A", chisq.test(table(boliger$bydel, boliger$mobelert))$parameter, 3, 0.001)
sjekk("3a-A", coef(m1)[1], 19201.2, 5)
pr <- sort(predict(m2, newdata = nye), decreasing = TRUE)
sjekk("3d-A", pr[2], 22528.2, 5)
sjekk("3d-B", predict(m2, newdata = nye)[1], 15834.4, 5)

# --- Tall som er sitert i tilbakemeldingstekstene ----------------------------
cat("\n-- tall sitert i rettemeldingene --\n")
cat("sd(pris)                :", round(sd(boliger$pris), 1), "(omtalt som 'nesten 5 000')\n")
cat("gj.snitt Nei/Ja         :", round(tapply(boliger$pris, boliger$mobelert, mean), 1), "\n")
cat("areal Nei/Ja            :", round(tapply(boliger$areal, boliger$mobelert, mean), 1), "\n")
tb <- table(boliger$bydel, boliger$mobelert)
cat("andel møblert per bydel :", paste(rownames(tb), paste0(round(100 * tb[, "Ja"] / rowSums(tb)), "%"), collapse = " | "), "\n")
ko <- summary(m3)$coefficients
cat("interaksjonsledd        :", paste(round(ko[grepl(":", rownames(ko)), 1]), collapse = " | "), "\n")
cat("interaksjon p-verdier   :", paste(round(ko[grepl(":", rownames(ko)), 4], 4), collapse = " | "), "\n")
cat("premie Årstad           :", round(ko["mobelertJa", 1] + ko[grepl("Årstad", rownames(ko)) & grepl(":", rownames(ko)), 1]), "\n")
cat("se og p for 3b          :", round(summary(m2)$coefficients["mobelertJa", 2], 1),
    format(summary(m2)$coefficients["mobelertJa", 4], digits = 3), "\n")

cat("\n", if (feil == 0) "Alle sjekker OK.\n" else paste(feil, "SJEKKER FEILET.\n"))
