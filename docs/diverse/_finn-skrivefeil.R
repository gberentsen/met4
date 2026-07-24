# Leter etter skrivefeil og innholdsproblemer i tidsplanen.
suppressMessages(library(readxl))
d <- read_excel("diverse/tidsplan-H26.xlsx")

celler <- data.frame(
  rad  = rep(seq_len(nrow(d)), 2),
  kol  = rep(c("man","tor"), each = nrow(d)),
  txt  = c(d[[3]], d[[4]]),
  stringsAsFactors = FALSE
)

cat("--- Dato med kolon i stedet for punktum ---\n")
for (i in seq_len(nrow(celler))) {
  t <- celler$txt[i]; if (is.na(t)) next
  if (grepl("^\\s*\\d{2}:\\d{2}", t))
    cat(sprintf("  rad %d %s: %s\n", celler$rad[i], celler$kol[i], t))
}

cat("\n--- Doble mellomrom ---\n")
for (i in seq_len(nrow(celler))) {
  t <- celler$txt[i]; if (is.na(t)) next
  if (grepl("  ", t)) cat(sprintf("  rad %d %s: %s\n", celler$rad[i], celler$kol[i], t))
}

cat("\n--- Mellomrom foran skilletegn ---\n")
for (i in seq_len(nrow(celler))) {
  t <- celler$txt[i]; if (is.na(t)) next
  if (grepl("\\s+[.,]", t)) cat(sprintf("  rad %d %s: %s\n", celler$rad[i], celler$kol[i], t))
}

cat("\n--- Dupliserte aktiviteter (samme forelesning flere ganger) ---\n")
akt <- celler$txt[!is.na(celler$txt)]
# Trekk ut forelesnings-/seminarnavn (fet tekst)
navn <- unlist(regmatches(akt, gregexpr("\\*\\*[^*]+\\*\\*", akt)))
navn <- trimws(gsub("\\*", "", navn))
tab <- table(navn)
for (n in names(tab)) if (tab[n] > 1) cat(sprintf("  %dx: %s\n", tab[n], n))

cat("\n--- Alle fete aktivitetsnavn (for oversikt) ---\n")
for (n in sort(unique(navn))) cat("  ", n, "\n")
