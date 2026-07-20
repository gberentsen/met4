# Kontrollerer at datoene i tidsplanen faktisk faller pa mandag og torsdag
# i den ukenummeret raden oppgir.
suppressMessages(library(readxl))

fil <- "diverse/tidsplan-H26.xlsx"
aar <- 2026
d   <- read_excel(fil)

les_dato <- function(s) {
  m <- regmatches(s, regexpr("^\\s*(\\d{2})[.](\\d{2})", s))
  if (length(m) == 0) return(as.Date(NA))
  dm <- as.integer(strsplit(trimws(m), "[.]")[[1]])
  as.Date(sprintf("%d-%02d-%02d", aar, dm[2], dm[1]))
}

feil <- 0
cat(sprintf("%-5s %-22s %-22s\n", "Uke", "Mandag", "Torsdag"))
for (i in seq_len(nrow(d))) {
  uke <- as.integer(d[[1]][i])
  md  <- les_dato(d[[3]][i])
  td  <- les_dato(d[[4]][i])

  ukedag_m <- format(md, "%u"); ukedag_t <- format(td, "%u")
  iso_m <- as.integer(format(md, "%V")); iso_t <- as.integer(format(td, "%V"))

  ok_m <- !is.na(md) && ukedag_m == "1" && iso_m == uke
  ok_t <- !is.na(td) && ukedag_t == "4" && iso_t == uke
  if (!ok_m || !ok_t) feil <- feil + 1

  cat(sprintf("%-5d %-12s uke %-2d %-3s %-12s uke %-2d %-3s\n",
              uke, format(md, "%d.%m.%Y"), iso_m, if (ok_m) "ok" else "FEIL",
              format(td, "%d.%m.%Y"), iso_t, if (ok_t) "ok" else "FEIL"))
}
cat("\n", if (feil == 0) "Alle datoer stemmer med ukenummer og ukedag." else
    paste(feil, "rad(er) stemmer ikke."), "\n")
