# Oppdaterer datoene i tidsplan-H26.xlsx fra H25-datoer til H26.
# Ukenumrene beholdes; kun dato-tokenet foran kolon byttes.
# Kjor med --skriv for a faktisk lagre, ellers er det en torrkjoring.

suppressMessages({library(readxl); library(openxlsx)})

fil    <- "diverse/tidsplan-H26.xlsx"
skriv  <- "--skriv" %in% commandArgs(TRUE)
aar    <- 2026

# Mandag i ISO-uke n: ISO-uke 1 er uken som inneholder 4. januar.
mandag_i_uke <- function(uke, aar) {
  jan4  <- as.Date(sprintf("%d-01-04", aar))
  # ISO-ukedag: mandag = 1 ... sondag = 7
  ukedag <- as.integer(format(jan4, "%u"))
  mandag_uke1 <- jan4 - (ukedag - 1)
  mandag_uke1 + (uke - 1) * 7
}

d <- read_excel(fil)
uker <- as.integer(d[[1]])

man <- mandag_i_uke(uker, aar)
tor <- man + 3

cat(sprintf("%-5s %-12s %-12s\n", "Uke", "Mandag", "Torsdag"))
for (i in seq_along(uker)) {
  cat(sprintf("%-5d %-12s %-12s\n", uker[i],
              format(man[i], "%d.%m.%Y (%a)"),
              format(tor[i], "%d.%m.%Y (%a)")))
}

# Bytt ut ledende "DD.MM" eller "DD:MM" (det finnes en skrivefeil i kilden).
# sub() er ikke vektorisert over replacement, sa dette ma gjores per element.
bytt_dato <- function(tekst, ny) {
  vapply(seq_along(tekst), function(i) {
    if (is.na(tekst[i])) return(NA_character_)
    ut <- sub("^\\s*\\d{2}[.:]\\d{2}\\s*:?\\s*",
              paste0(format(ny[i], "%d.%m"), ": "), tekst[i])
    if (identical(ut, tekst[i]))
      warning("Fant ingen dato a bytte i rad ", i, ": ", tekst[i], call. = FALSE)
    ut
  }, character(1))
}

kol_man <- 3
kol_tor <- 4

nye_man <- bytt_dato(d[[kol_man]], man)
nye_tor <- bytt_dato(d[[kol_tor]], tor)

cat("\n--- Endringer, mandagskolonnen ---\n")
for (i in seq_along(nye_man)) {
  if (!identical(d[[kol_man]][i], nye_man[i]))
    cat(sprintf("  %s\n->%s\n", d[[kol_man]][i], nye_man[i]))
}
cat("\n--- Endringer, torsdagskolonnen ---\n")
for (i in seq_along(nye_tor)) {
  if (!identical(d[[kol_tor]][i], nye_tor[i]))
    cat(sprintf("  %s\n->%s\n", d[[kol_tor]][i], nye_tor[i]))
}

if (skriv) {
  wb <- loadWorkbook(fil)                 # bevarer formatering
  ark <- names(wb)[1]
  writeData(wb, ark, nye_man, startCol = kol_man, startRow = 2, colNames = FALSE)
  writeData(wb, ark, nye_tor, startCol = kol_tor, startRow = 2, colNames = FALSE)
  saveWorkbook(wb, fil, overwrite = TRUE)
  cat("\nLagret", fil, "\n")
} else {
  cat("\nTorrkjoring - ingenting lagret. Kjor med --skriv for a lagre.\n")
}
