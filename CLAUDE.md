# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Hva dette er

Kurshjemmesiden til **MET4 – Empiriske metoder** ved NHH: et [Quarto](https://quarto.org)-nettsted (Quarto Book) skrevet i `.qmd`. (Migrert fra bookdown til Quarto i 2026.) Dette er ikke en programvarepakke – det finnes ingen tester, ingen linting og ingen pakkestruktur. "Å bygge" betyr å rendre nettsiden; "å endre kode" betyr som regel å endre pensumtekst, regneoppgaver eller løsningsforslag.

Alt innhold er på **norsk**. Filene er UTF-8 med æ/ø/å – pass på at redigeringer ikke ødelegger tegnsettet (tidligere commits har måttet fikse "korrupterte filer").

## Bygging

```sh
quarto render                          # hele boken -> docs/
quarto render 03-hypotesetesting.qmd   # ett kapittel isolert (raskere)
quarto preview                         # lokal server (kjørbar kode via WebR kun i kursgodkjenning-prototypen)
```

Bruk Quarto fra RStudio-installasjonen på byggemaskinen:
`"C:\Program Files\RStudio\resources\app\bin\quarto\bin\quarto.exe"` (kall via PowerShell med `& "..."`).

- Output går til `docs/` (`output-dir: docs` i `_quarto.yml`), som er **sjekket inn i git** og publiseres via GitHub Pages under stien `/met4/`. En innholdsendring er ikke synlig for studentene før `docs/` er bygget på nytt og committet. Historiske commits med meldingen "Build" er slike rebuilds.
- `freeze: auto` cacher chunk-kjøring i `_freeze/`, så re-bygg går fort. Byggemaskinen må ha R-pakkene som brukes i kapitlene installert (mest brukt: `readxl`, `dplyr`, `ggplot2`, `forecast`, `fixest`, `stargazer`, `kableExtra`, `plm`, `AER`, `fpp2`).
- **Kryssreferanser** bruker Quarto-syntaks: `@sec-<id>` (seksjoner; målet trenger `{#sec-...}` på overskriften), `@fig-<label>` (figurer; chunk-label må starte med `fig-`), `@eq-<label>` (ligninger; `$$…$$ {#eq-...}`). Unummererte overskrifter: `{.unnumbered}` (ikke bookdowns `{-}`).

## Struktur

- `_quarto.yml` – Quarto Book-config: tittel/forfattere, kapittellista (gruppert i `parts`), tema (cosmo), `output-dir: docs`, `resources:` (datasett/eksamensarkiv/slides/bilder kopieres til `docs/`), favicon og `include-in-header` (NHH-logo i sidebaren, se `nhh-sidebar.html`).
- `index.qmd` – forsiden. Inneholder fremdriftsplanen, som leses fra `diverse/tidsplan-<SEMESTER>.xlsx`. Ved nytt semester: legg inn ny xlsx og oppdater både filnavnet og `row_spec()`-radene (grønne datasal-uker) i chunken.
- `01-`…`06-*.qmd` – teorimodulene, i rekkefølge. Mal per deltema: `### Videoforelesninger {.unnumbered}` (skal *ikke* ha kapittelnummer) → teoritekst delt i vanlige `###`-underseksjoner (bruk *ikke* en egen «Teori»-overskrift, slik at første underseksjon blir f.eks. 2.2.1) → `### Kontrollspørsmål` helt til slutt i deltemaet. Oppgavene samles i en egen `## Oppgaver`-seksjon per modul, delt i tre `###`-kategorier: **Teorioppgaver** (uten R, relativt enkle), **Nøtter** (vanskeligere) og **R-oppgaver**. Modul 2 og 3 er ryddet til denne malen; modul 4–6 har foreløpig eldre struktur (`### Kommentarer` med lærebok-henvisninger) og skal ryddes på samme måte.
- `07-dataøvinger.qmd`, `08-seminaroppgaver.qmd`, `10-Eksamensoppgaver.qmd` – oppgavesamlingene. (Eksamen ble renummerert 09→10 i Quarto-migreringen; kapittel 9 er reservert til en kommende obligatorisk kursgodkjenning, se `kursgodkjenning/`-prototypen.)
- Hver modul-`.qmd` har `aliases:` i frontmatteren som redirigerer de gamle bookdown-URL-ene (f.eks. `oppgaver.html`, `seminar.html`) til den nye modulsiden.
- `datasett/`, `genererte_datasett/` – datafiler som qmd-chunks leser med relativ sti (`readxl::read_excel("datasett/...")`). Listet under `resources:` så de kopieres inn i `docs/` ved bygging, så studentene kan laste dem ned via samme relative lenke.
- `script-slides/<modul>/` – ferdigbygde slides (`*-slides.html`) og R-script (`*-script.R`) som modulene lenker til.
- `tidligere-eksamensoppgaver/` – PDF/ZIP-arkiv lenket fra `10-Eksamensoppgaver.qmd` (via `skoleeksamen.xlsx`/`hjemmeeksamen.xlsx`; cellene inneholder markdown-lenker som gjøres om til HTML i chunken).
- `docs/` – generert; rediger aldri direkte.

## Innholdskonvensjoner

**Løsningsforslag** legges i en sammenklappbar blokk rett etter oppgaveteksten:

```md
<details><summary>Løsning</summary>

**a)**
```{r, eval=T}
...
```
Forklarende tekst.

</details>
```

**Chunk-valg** bærer mening her:
- `eval = FALSE` – R-kode som studenten skal skrive selv, eller som leser en fil de laster ned. Vises, kjøres ikke.
- `eval = TRUE` / `{r}` – kode som faktisk skal produsere output (figurer, regresjonsutskrifter) i løsningsforslag og eksempler.
- `echo = FALSE` – kode som bare genererer en figur/tabell for teksten.

Kryssreferanser bruker Quarto-syntaks (`@sec-`/`@fig-`/`@eq-`, se Bygging), og matematikk skrives i `$…$`/`$$…$$`.

## Notasjonsstandard

`MET4-formelark.qmd` er **fasit for notasjon**. Er du i tvil, sjekk der før du skriver.

| Størrelse | Skriv | Ikke |
|---|---|---|
| Alternativhypotese | `H_A` | `H_1`, `H_a` |
| Feilledd, regresjon | `\epsilon` (ϵ) | `\varepsilon` (ε) – rendres synlig ulikt |
| Residual, regresjon | `\hat{\epsilon}_i` | `e_i` |
| Hvit støy / innovasjon, tidsrekke | `u_t` | `\epsilon_t`, `Z_t` |
| Residual, tidsrekke | `\hat{u}_t` | |
| Individuell fast effekt | `\alpha_i` | |
| Tidseffekt, paneldata | `\nu_t` (gresk nu) | `v_t` (latinsk v) |
| Sammensatt feilledd | `\xi_i` | |
| Autokorrelasjon ved lag *k* | `\rho_k` | `\gamma_k` (det er autokovariansen) |
| Variabler, klassisk regresjon (kap. 2–5) | stor `Y_i`, `X_i` | |
| Variabler, paneldata og kausalitet (kap. 6, 8) | liten `y_{it}`, `x_{it}` | |

To ting som ser ut som inkonsistens, men ikke er det:

- **Regresjon bruker `\epsilon`, tidsrekker bruker `u_t`.** Dette er et bevisst skille som følger
  formelarket. Ikke sveip dem sammen.
- **`\xi` i `06-avansert-regresjon-og-maskinlaering.qmd`** er et *sammensatt* feilledd
  (`\xi_i = \beta_2 A_i + \epsilon_i`) i utelatt-variabel-argumentet, ikke en skrivefeil for `\epsilon`.

Bokstavstørrelse koder **ikke** stokastisk variabel vs. observert realisasjon på denne siden.
Distinksjonen er bare nyttig hvis den holdes hundre prosent konsekvent, og MET4 tester den ikke.

Det som *derimot* skiller stor og liten bokstav her, er sjanger: klassisk regresjon (kap. 2–5)
bruker stor `Y`/`X`, mens paneldata og kausal identifikasjon (kap. 6 og 8) bruker liten
`y_{it}`/`x_{it}`. Det siste følger økonometrilitteraturen studentene går videre til
(Stock & Watson, Wooldridge), og begge kapitlene er interne konsekvente. Ikke «rett opp» det ene
til det andre – skillet er tilsiktet.

## Terminologi

Fast norsk term for hvert begrep, så kurset er konsekvent på tvers av moduler. `MET4-formelark.qmd`
er fasit for *notasjon*; denne lista er fasit for *ord*.

**Utvalgs- vs. populasjonsstørrelser.** Nesten alle størrelser finnes i to varianter — én sann
(populasjon) og én beregnet (utvalg). Bruk prefiksene `populasjons-` og `utvalgs-` konsekvent, og
hold symbolene fra hverandre:

| Begrep | Populasjon (sann, ukjent) | Utvalg (beregnet fra data) |
|---|---|---|
| Gjennomsnitt | populasjonsgjennomsnitt `\mu` | utvalgsgjennomsnitt `\overline{X}` |
| Standardavvik | populasjonsstandardavvik `\sigma` | utvalgsstandardavvik `s` |
| Varians | populasjonsvarians `\sigma^2` | utvalgsvarians `s^2` |
| Andel | populasjonsandel `p` | utvalgsandel `\widehat{p}` |

Andre faste valg (bruk venstre, unngå høyre):

| Bruk | Ikke | Merknad |
|---|---|---|
| sentralgrenseteoremet | sentralgrensesetningen | begge fantes i teksten; teoremet er valgt |
| estimator | observator | «observator» henger fortsatt igjen enkelte steder |
| estimat | | den konkrete tallverdien en estimator gir på et datasett |
| standardfeil | | *estimert* standardavvik til en estimator – ikke synonymt med standardavvik |
| samplingfordeling | utvalgsfordeling | |
| spredningsplott | spredningsdiagram | besluttet; begge fantes i teksten |

Utvalgsstandardavviket skrives med **liten `s`** (matcher forelesningsvideoen; besluttet). Åpne
inkonsekvenser å rydde:

- `MET4-formelark.qmd` bruker fortsatt stor `S` og ordet «empirisk standardavvik». Bør endres til
  liten `s` og «utvalgsstandardavvik» så det matcher videoen og modul 2.

## Pedagogiske føringer

- Intuisjon før formalisme. Formelen skal begrunnes, ikke bare presenteres.
- **Løsningsforslag skal forklare hvorfor, ikke bare vise kode.** En chunk med output er ikke et
  løsningsforslag; studenten trenger tolkningen.
- Norsk fagterminologi der den finnes: feilledd, forkastningsområde, signifikansnivå, forventningsrett.
- **Ikke bruk tankestrek (— eller –) som skilletegn i brødtekst.** Bruk komma, kolon, parentes eller
  punktum i stedet. (Tallintervaller som `1–5` og `50–100` er greit.)
- Skillet korrelasjon/kausalitet er et eksplisitt læringsutbytte i kursbeskrivelsen. Skriv «henger
  sammen med», ikke «fører til», når modellen ikke gir kausal tolkning.
- **Alle henvisninger til læreboken (Keller) fjernes.** Sidene skal stå på egne ben, og eksempler
  skal være selvstendige. Simulerte datasett er greit (bruk alltid `set.seed()` for reproduserbart
  bygg). Modul 2 er ryddet; 3–6, seminar (08) og eksamen (09) gjenstår, se åpne punkter.
- Ikke stryk en oppgave uten å sjekke om den er lenket fra `08-seminaroppgaver.qmd` eller
  `10-Eksamensoppgaver.qmd`.

## Kapittelstatus og åpne punkter

Oppdateres løpende. Holdes kort – vokser den forbi ~10 linjer, flytt den ut av denne filen.

| Kapittel | Status |
|---|---|
| 01 Introduksjon til R | språkvasket; `summarise()` lagt til i pipe-seksjonen |
| 02 Grunnleggende statistikk | teoritekst skrevet for 2.1 og 2.2; Kommentarer integrert i hovedtekst; lærebok-henvisninger fjernet; egne (simulerte) eksempler; utvalg/populasjon-distinksjon innført |
| 03 Hypotesetesting | 3.1–3.4 skrevet som egen teori (femstegsmal, eksempler i økonomi/finans, lærebok-ref fjernet); 3.4 Kjikvadrattester dekker goodness-of-fit (to selskaper) og uavhengighet; Oppgaver ryddet til Teorioppgaver/Nøtter/R-oppgaver med eksamensoppgaver (24v, 25v) og simuleringsoppgave; Relevante R-kommandoer harmonisert med eksemplene |
| 04–09 | ikke gjennomgått; lærebok-henvisninger gjenstår |

Åpne punkter:

- Notasjon i `script-slides/` er ikke harmonisert (hypotesetesting-slides bruker `H_1`,
  regresjon-slides bruker `H_A`). Krever separat rendring; kilde og publisert HTML kan komme i utakt.
- `MET4-formelark.qmd` er ikke lenket fra nettsiden ennå. Bør bygges til PDF og lenkes fra
  `index.qmd` og `10-Eksamensoppgaver.qmd`. Avklar først om det er tillatt eksamenshjelpemiddel.
- **Lærebok-henvisninger gjenstår** i `04`–`06`, `08`, `10` og `index.qmd` (Keller, kapittel-/
  seksjons-/eksempelnumre). Skal fjernes som i modul 2.
- Formelarket sier «empirisk standardavvik»; kurset går over til «utvalgsstandardavvik» (se Terminologi).
- Videoforelesningene bruker `<iframe>` med hardkodet `width="640" height="388"` (ikke responsive, flyter utenfor på mobil). Bør pakkes i en responsiv wrapper. Gjelder alle moduler.
- Tre-kategori oppgavestruktur (Teorioppgaver/Nøtter/R-oppgaver, se Struktur) er innført i modul 2 og 3; anvend samme struktur på oppgavene i modul 4–6.

## Git

Innhold og bygg er **alltid separate commits**. Flere innholdscommits kan samles under ett `Build`.
Blandes de, mister du evnen til å lese en innholdsdiff – `docs/` er 700+ filer.
