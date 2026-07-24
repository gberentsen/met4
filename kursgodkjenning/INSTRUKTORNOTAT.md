# Instruktørnotat: obligatorisk kursgodkjenning

Denne filen skal **ikke** publiseres. Den rendres ikke av Quarto og er ikke lenket
fra nettsiden, men ligger i git. Vurder om den heller bør ligge utenfor repoet.

## Fullføringskoden

Koden har formen `MET4-KG-<n>-<c>`, der `n` er kandidatnummeret og

    c = (n * 7919 + 12345) mod 100000

nullpolstret til fem sifre. Verifiser en innlevering ved å regne ut `c` fra
kandidatnummeret studenten oppgir, og sjekke at det stemmer med koden.

I R:

```r
lag_kode <- function(n) sprintf("MET4-KG-%d-%05d", n, (n * 7919 + 12345) %% 100000)
lag_kode(42)
```

### Hvor mye koden er verdt

Ikke mye, og det er et bevisst valg. Hele rettingen skjer klientside i WebR, og
kodegenereringen ligger i en OJS-celle i den publiserte HTML-en. En student som
åpner utviklerverktøyene i nettleseren kan lese funksjonen `lagKode()` direkte og
regne ut en gyldig kode uten å løse en eneste oppgave. Det er ingen server å
skjule noe bak.

Koden er derfor en **kvittering, ikke en eksamensvakt**: den gjør det enkelt for
den ærlige studenten å dokumentere at hen har vært gjennom oppgavene, og den
gjør juks til en bevisst handling i stedet for en forglemmelse. Kursgodkjenningen
hviler på æresprinsippet.

Vil du ha en reell kontroll, er alternativene:

1. **Canvas-quiz i tillegg.** Legg to eller tre av tolkningsspørsmålene inn som en
   Canvas-quiz med tilfeldig trekning. Da ligger fasiten på serversiden.
2. **Kandidatspesifikke data.** La datasettet avhenge av kandidatnummeret, slik at
   svarene blir ulike per student. Krever at rettingen også blir parametrisert, og
   at fasiten regnes ut i nettleseren. Betydelig mer arbeid, og fortsatt lesbart
   for den som graver.
3. **Godta som det er.** For en obligatorisk øvelse uten karakter er dette normalt
   godt nok, og det er det oppsettet vi har nå.

## Datasettet

`boliger.RData` genereres av `lag-boligdata.R` med `set.seed(2026)`. Kjøres det
scriptet på nytt, endres **alle** fasitverdiene i check-cellene i
`kursgodkjenning.qmd`. Scriptet skriver ut fasiten, og

    Rscript test-fasit.R
    Rscript test-dplyr.R

verifiserer at løsningskoden treffer toleransene i rettecellene, og at svar som
skal avvises fortsatt avvises. Kjør begge etter enhver endring i datasettet.

## Oppgavesettets oppbygning

Bygget etter malen fra Del 1 på skoleeksamen (25v, 25h, 26v): ett sammenhengende
datasett, deskriptiv statistikk, så hypotesetesting, så regresjon.

Den bærende ideen er at møblerte boliger *ser* billigere ut, fordi de systematisk
er mindre, men er dyrere når areal holdes fast. Oppgave 2c, 3a og 3b er de tre
trinnene i det poenget, og 3c er tolkningen. Fjerner du en av dem, faller
argumentet fra hverandre.

To detaljer som er tilsiktet:

- **F-testen i 2a gir p = 0,29**, altså like varianser. Da er `var.equal = TRUE`
  riktig, og det er *ikke* standardvalget i R. En student som kjører `t.test()`
  uten å tenke får Welch. Rettecellen godkjenner begge, men med ulik
  tilbakemelding, siden begge er faglig forsvarlige.
- **Tolkningsoppgavene rettes som flervalg.** Distraktorene er reelle
  feiltolkninger, og hver av dem har sin egen forklarende tilbakemelding. Se
  `kursgodkjenning-losningsforslag.qmd` for begrunnelsene.
