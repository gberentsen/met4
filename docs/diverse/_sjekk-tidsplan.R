# Kontrollerer tidsplanen: at hver dato faller pa mandag/torsdag i den
# oppgitte ISO-uken, og hvilke rader som blir gronne (dataoving).
suppressMessages(library(readxl))

fil <- "diverse/tidsplan-H26.xlsx"
aar <- 2026
d   <- read_excel(fil)

# Godtar bade "DD.MM" og skrivefeilen "DD:MM"
les_dato <- function(s) {
  m <- regmatches(s, regexpr("^\\s*(\\d{2})[.:](\\d{2})", s))
  if (length(m) == 0) return(as.Date(NA))
  dm <- as.integer(strsplit(trimws(m), "[.:]")[[1]])
  as.Date(sprintf("%d-%02d-%02d", aar, dm[2], dm[1]))
}

feil <- 0
cat(sprintf("%-4s %-14s %-14s\n", "Uke", "Mandag", "Torsdag"))
for (i in seq_len(nrow(d))) {
  uke <- as.integer(d[[1]][i])
  md  <- les_dato(d[[3]][i]); td <- les_dato(d[[4]][i])
  begge_na <- is.na(md) && is.na(td)

  sjekk <- function(dato, forventet_ukedag) {
    if (is.na(dato)) return("tom")
    ud  <- format(dato, "%u"); iso <- as.integer(format(dato, "%V"))
    if (ud == forventet_ukedag && iso == uke) "ok" else
      sprintf("FEIL(%s uke%d)", c("man","tir","ons","tor","fre","lor","son")[as.integer(ud)], iso)
  }
  sm <- sjekk(md, "1"); st <- sjekk(td, "4")
  if (!begge_na && (grepl("FEIL", sm) || grepl("FEIL", st) ||
                    (is.na(md) && !is.na(td)) || (!is.na(md) && is.na(td)))) feil <- feil + 1

  cat(sprintf("%-4s %-14s %-6s %-14s %-6s\n", uke,
              if (is.na(md)) "<tom>" else format(md, "%d.%m.%Y"), sm,
              if (is.na(td)) "<tom>" else format(td, "%d.%m.%Y"), st))
}

cat("\n--- Gronne rader (dataoving) ---\n")
gronne <- which(grepl("dataøving", d[["Jobbe med"]], ignore.case = TRUE))
for (i in gronne) cat(sprintf("  rad %-2d uke %-2s  %s\n", i, d[[1]][i], d[["Jobbe med"]][i]))
cat("  Antall:", length(gronne), "\n")

cat("\n--- Eksamensuke ---\n")
eks <- which(grepl("eksamen", d[["Jobbe med"]], ignore.case = TRUE) &
             !grepl("[Ff]orberedelse", d[["Jobbe med"]]))
for (i in eks) {
  cat(sprintf("  rad %d, uke %s: '%s' - mandag=%s torsdag=%s\n", i, d[[1]][i],
              d[["Jobbe med"]][i],
              ifelse(is.na(d[[3]][i]), "<tom>", d[[3]][i]),
              ifelse(is.na(d[[4]][i]), "<tom>", d[[4]][i])))
}
