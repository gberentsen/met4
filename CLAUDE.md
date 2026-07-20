# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Hva dette er

Kurshjemmesiden til **MET4 – Empiriske metoder** ved NHH: en [bookdown](https://bookdown.org)-nettside skrevet i R Markdown. Dette er ikke en programvarepakke – det finnes ingen tester, ingen linting og ingen pakkestruktur. "Å bygge" betyr å rendre nettsiden; "å endre kode" betyr som regel å endre pensumtekst, regneoppgaver eller løsningsforslag.

Alt innhold er på **norsk**. Filene er UTF-8 med æ/ø/å – pass på at redigeringer ikke ødelegger tegnsettet (tidligere commits har måttet fikse "korrupterte filer").

## Bygging

```sh
Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::gitbook')"   # == ./_build.sh
```

- Output går til `docs/`, som er **sjekket inn i git** og publiseres via GitHub Pages. En innholdsendring er ikke synlig for studentene før `docs/` er bygget på nytt og committet. Historiske commits med meldingen "Build" er nettopp slike rebuilds.
- Siden serveres under stien `/met4/` – `header.html` hardkoder absolutte `/met4/...`-stier til favicon-filene.
- Rendring kjører alle R-chunks med `eval = TRUE`, så byggemaskinen må ha pakkene som brukes i kapitlene installert (mest brukt: `readxl`, `dplyr`, `ggplot2`, `forecast`, `fixest`, `stargazer`, `kableExtra`, `plm`, `AER`, `fpp2`).
- Rendre ett kapittel isolert (raskere ved skriving, gir ufullstendig meny):
  `Rscript -e "bookdown::preview_chapter('04-regresjon.Rmd')"`

## Struktur

- `index.Rmd` – forsiden *og* stedet der bookdown-YAML for hele siten ligger (tittel, semester, forfattere). Inneholder også fremdriftsplanen, som leses fra `diverse/tidsplan-<SEMESTER>.xlsx`. Ved nytt semester: legg inn ny xlsx og oppdater både filnavnet og `row_spec()`-radene (grønne datasal-uker) i chunken.
- `01-`…`06-*.Rmd` – teorimodulene, i rekkefølge. Hver modul følger samme mal: intro → lenker til slides/script → per deltema `### Videoforelesninger` (Vimeo-showcase-iframe) → `### Kommentarer` (kommentarer til Keller-læreboken med kapittelhenvisninger) → sjekkspørsmål → regneoppgaver med løsningsforslag.
- `07-dataøvinger.Rmd`, `08-seminaroppgaver.Rmd`, `09-Eksamensoppgaver.Rmd` – oppgavesamlingene.
- `_output.yml` / `_bookdown.yml` – gitbook-tema, TOC-lenker i sidemenyen, `output_dir: docs`.
- `datasett/`, `genererte_datasett/` – datafiler som Rmd-chunks leser med relativ sti (`readxl::read_excel("datasett/...")`). De kopieres inn i `docs/` ved bygging, så studentene kan laste dem ned via samme relative lenke.
- `script-slides/<modul>/` – ferdigbygde slides (`*-slides.html`) og R-script (`*-script.R`) som modulene lenker til.
- `tidligere-eksamensoppgaver/` – PDF/ZIP-arkiv lenket fra `09-Eksamensoppgaver.Rmd`.
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

Kryssreferanser bruker bookdown-syntaks (`\@ref(seminar)`), og matematikk skrives i `$…$`/`$$…$$`.

## Git

Rotfilene `chap` og `qq` er tilfeldig lagret `git log`-output, ikke innhold – ikke bygg videre på dem.
