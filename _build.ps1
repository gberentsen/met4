# Bygger bookdown-siten til docs/.
#
# Finnes fordi hverken R eller pandoc ligger på PATH på en typisk NHH-maskin:
# RStudio setter opp begge deler internt, så _build.sh fungerer bare når den
# kjøres fra RStudio. Dette skriptet finner verktøyene selv.
#
# Bruk:  .\_build.ps1              (bygg hele siten)
#        .\_build.ps1 -Sjekk       (bygg til temp-mappe, la docs/ være i fred)

param([switch]$Sjekk)

$ErrorActionPreference = "Stop"

function Finn-Fil($stier, $navn) {
    foreach ($s in $stier) { if (Test-Path $s) { return $s } }
    throw "Fant ikke $navn. Sjekk stiene øverst i _build.ps1."
}

$rscript = Finn-Fil @(
    "C:\Program Files\R\R-4.3.1\bin\x64\Rscript.exe"
    "C:\Program Files\R\R-4.4.0\bin\x64\Rscript.exe"
    "C:\Program Files\R\R-4.5.0\bin\x64\Rscript.exe"
) "Rscript.exe"

$pandocDir = Finn-Fil @(
    "C:\Program Files\RStudio\resources\app\bin\quarto\bin\tools"
    "C:\Program Files\RStudio\bin\pandoc"
    "$env:LOCALAPPDATA\Pandoc"
) "pandoc"

$env:RSTUDIO_PANDOC = $pandocDir

# Innsjekket docs/ er bygget med bookdown >= 0.46. Bygger du med en eldre
# versjon, nedgraderes den genererte HTML-en og du får ~110 filers diff-stoy
# som skjuler de faktiske innholdsendringene. Derfor stopper vi her.
$minBookdown = "0.46"
$ver = (& $rscript -e "cat(as.character(packageVersion('bookdown')))")
if ([version]$ver -lt [version]$minBookdown) {
    throw "bookdown $ver er for gammel (krever >= $minBookdown). " +
          "Kjor: install.packages(c('knitr','rmarkdown','bookdown'))"
}
Write-Host "bookdown $ver" -ForegroundColor DarkGray

if ($Sjekk) {
    $ut = Join-Path $env:TEMP "met4-byggsjekk"
    Write-Host "Sjekkbygg til $ut (docs/ røres ikke)" -ForegroundColor Cyan
    & $rscript -e "bookdown::render_book('index.Rmd', 'bookdown::gitbook', output_dir = '$($ut -replace '\\','/')')"
} else {
    Write-Host "Bygger til docs/" -ForegroundColor Cyan
    & $rscript -e "bookdown::render_book('index.Rmd', 'bookdown::gitbook')"
}

if ($LASTEXITCODE -ne 0) { throw "Bygget feilet med kode $LASTEXITCODE" }
Write-Host "Ferdig." -ForegroundColor Green
