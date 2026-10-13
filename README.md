# Nueva Somosaguas

## Grado en ciencias sociales analíticas y cuantitativas

> *«If you didn't grow it, you didn't explain it.»* — Joshua Epstein
>
> *«Every social fact is the aggregate outcome of individual actions, beliefs, and opportunities.»* — Peter Hedström

[![Quarto](https://img.shields.io/badge/Compilado%20con-Quarto-blue.svg)](https://quarto.org/)
[![Stack](https://img.shields.io/badge/Stack-Julia%20%7C%20R%20%7C%20SQL-purple.svg)]()
[![Consiliencia](https://img.shields.io/badge/Epistemolog%C3%ADa-Consiliencia%20de%20E.%20O.%20Wilson-success.svg)]()

**Portal:** [nuevasomosaguas.github.io](https://nuevasomosaguas.github.io/)

---

## Qué es esto

La **Nueva Somosaguas** es una facultad libre de ciencias sociales analíticas y cuantitativas: un plan de estudios completo, abierto y publicado en código, construido sobre el principio de **consiliencia** de E. O. Wilson —la compatibilidad vertical entre las matemáticas, la biología evolutiva, los micro-mecanismos de decisión y la historia cuantitativa de gran escala.

No es un borrador pedagógico. Son **cuatro cursos y 20 asignaturas**, cada una con pocos textos matriz, al menos uno de los cuales se lee entero, y un cuaderno reproducible, más un bootcamp propedéutico de doce semanas y un itinerario autodidacta con presupuesto de horas declarado.

El criterio de admisión de cualquier contenido es el mismo en todo el sitio: si un modelo no se deriva en la pizarra y no compila en la terminal, no entra.

---

## Los cuatro pilares

1. **Cimientos formales e inferencia rigurosa**
   * Probabilidad axiomática e inferencia estadística (*Harvard Stat 110*, Blitzstein y Hwang; Evans y Rosenthal).
   * Identificación causal por grafos acíclicos dirigidos y resultados potenciales (Pearl; Angrist y Pischke; Imbens y Rubin).
   * Álgebra lineal matricial y sus descomposiciones: QR, SVD, matrices de Markov (Strang).
   * Cálculo multivariante y optimización con restricciones (Simon y Blume).
   * Medición de lo latente e invariancia de la medida (Beaujean), e inferencia no paramétrica por *bootstrap* (Efron y Hastie).

2. **Sustrato biológico y genómica cuantitativa**
   * Genética de la conducta y puntuaciones poligénicas (Plomin; Falconer y Mackay; Mills, Barban y Tropf).
   * Paleogenómica y migraciones históricas (Reich).
   * Antropología evolutiva y etología comparada (Boehm, Hrdy, Buss, Tomasello).

3. **Mecanismos micro e interacción estratégica**
   * Sociología analítica DBO y el bote micro-macro: deseos, creencias y oportunidades (Coleman, Hedström, Elster, Boudon).
   * Estratificación y movilidad social (Erikson y Goldthorpe; Breen y Goldthorpe).
   * Teoría de juegos y acción colectiva (Gibbons, Binmore, Olson, Ostrom).

4. **Síntesis generativa y macrohistoria biofísica**
   * Modelos basados en agentes y contagio complejo (Joshua Epstein, Schelling, Smaldino, Railsback y Grimm, Centola).
   * Cliodinámica, sobreproducción de élites y compresiones de la desigualdad (Turchin y Nefedov; Scheidel).
   * Historia económica cuantitativa y contabilidad biofísica (Smil, Wrigley, Galor, Clark).

Los pilares son los estratos de la biblioteca: el pilar 1 es el Estrato 3 con el núcleo instrumental de cómputo, el 2 es el Estrato 0, el 3 el Estrato 1 y el 4 el Estrato 2. Los artículos seminales y de frontera atraviesan los cuatro.

---

## Estructura del repositorio

El sitio se compila con **Quarto** y una hoja de estilos propia de inspiración tufteana.

```text
nuevasomosaguas/
├── index.qmd               Portada: los cuatro pilares y el mapa del dominio
├── curriculo.qmd           Plan de estudios: 4 cursos, 20 asignaturas
├── bootcamp.qmd            Bootcamp propedéutico: 3 fases, 12 semanas
├── guia_autodidacta.qmd    Itinerario en solitario: 4 hitos con gates de validación
├── laboratorios.qmd        Cinco laboratorios ejecutables en Julia y SQL
├── entorno.qmd             La terminal, los entornos congelados y el estándar gráfico
├── politica_ia.qmd         Política de inteligencia artificial: los cuatro principios
├── manual_bolsillo.qmd     Diez reglas para el debate cotidiano
├── biblioteca.qmd          El núcleo: 4 estratos causales, artículos seminales y frontera, y cómputo
├── biblioteca-secundaria/  Catálogo del área secundaria, generado del .bib antes de cada render
├── biblioteca-cambios.qmd  Registro de cambios del núcleo: qué entra, qué sale y por qué
├── biblioteca.bib          Fuente única del corpus: núcleo y área secundaria, con fichas, niveles,
│                           modos de lectura, originales traducidos, DOI, ISBN y copias libres
├── faq.qmd                 Preguntas frecuentes
├── about.qmd               Declaración institucional
├── refs.R                  Lee y valida biblioteca.bib: recuentos, fichas y listas de la biblioteca
├── _quarto.yml             Configuración del sitio, menú e idioma
├── styles.css              Estilos: tipografía, medida de 80ch y ajustes de Mermaid
└── .github/workflows/      Compilación y publicación en GitHub Pages
```

La bibliografía vive en `biblioteca.bib`, que es a la vez la descarga para el lector y la fuente de las páginas: `refs.R` lo lee para componer las listas, las fichas y los recuentos que citan las demás páginas, y cada render deriva de él la versión en CSL-JSON. El archivo tiene dos capas. El **núcleo**, de 150 obras, se ordena por estratos, y cada obra lleva su nivel y su **modo de lectura** (completa con ejercicios, completa o consulta). El **área secundaria** no tiene tope, y cada una de sus obras cuelga de una del núcleo con un papel: profundización técnica, contraste y crítica, especialización aplicada, fuente original, historia y contexto, divulgación o introducción. `refs.R` detiene el render ante una línea ilegible, un papel o un modo desconocidos o una obra que cuelgue de otra que no esté en el núcleo.

Incorporar o retirar una obra es editar ese archivo. Cada revisión del núcleo lleva una etiqueta (`v1.0`, `v1.1`) y una entrada en `biblioteca-cambios.qmd` con lo que entra, lo que sale y por qué, y `git diff v1.0 v1.1 -- biblioteca.bib` da el detalle.

---

## Entorno computacional

Julia y R, cada uno en su terreno:

* **Julia** — cálculo matricial, simulación basada en agentes, ecuaciones diferenciales y optimización. Es el lenguaje vehicular desde el primer curso.
* **R** — estadística aplicada, econometría tabular, bioestadística y psicometría, donde están sus textos y su ecosistema. Los problemas interactivos también, porque webR los ejecuta en el navegador.
* **SQL** — extracción relacional pura, funciones de ventana y agregación censal en PostgreSQL o SQLite.
* **Bash, Git y Quarto o Typst** — consola de Unix, canalizaciones reproducibles y publicación determinista.

Python se conserva como herramienta auxiliar de ingesta y manipulación de datos tabulares.

---

## Política de inteligencia artificial

La IA no se prohíbe ni se padece: se gobierna. Cuatro principios, desarrollados en `politica_ia.qmd`:

* **Principio socrático.** El modelo actúa como interlocutor dialéctico, no resuelve ejercicios ni redacta memorandos evaluables.
* **Asimetría epistemológica.** Los modelos de lenguaje manejan asociaciones, no estructuras generativas: tienen prohibido decidir la identificación causal.
* **Trazabilidad.** Toda función de origen algorítmico entra con la traza del *prompt*, la semilla declarada y una prueba de regresión escrita por el estudiante.
* **Prueba de la pizarra.** Los exámenes son a terminal abierta, con la IA asumida; ninguna calificación es firme hasta defenderla a mano alzada.

---

## Compilación local

```bash
git clone https://github.com/nuevasomosaguas/nuevasomosaguas.github.io.git
cd nuevasomosaguas.github.io
quarto render     # compila el sitio en _site/
quarto preview    # servidor local con recarga automática
```

Hace falta [Quarto](https://quarto.org/) y una instalación de R con `knitr` y `rmarkdown`: tres páginas evalúan fragmentos de R para leer el recuento de la biblioteca, y antes de cada render `biblioteca-secundaria/obras.R` genera el catálogo del área secundaria.

Cada empuje a `master` compila y publica en GitHub Pages mediante el flujo de trabajo de `.github/workflows/`.

---

## Autoría

Diseño y dirección pedagógica de un científico de datos. Las correcciones, refutaciones y erratas metodológicas se agradecen en el propio repositorio.
