# Reglas internas de la biblioteca

`biblioteca.bib` es la fuente única: su cabecera define cada campo, y `refs.R` detiene el render si una entrada no la cumple. Estas reglas cubren lo que la cabecera no dice: cómo se decide y cómo se comprueba un **alta**.

## Alta en el área secundaria

Una obra propuesta, por el responsable o por cualquiera, sigue estos pasos. El alta está hecha cuando `refs.R` la carga sin error y la entrada está en `propuesta`.

1. **Duplicados.** Busca el apellido y una palabra del título en `biblioteca.bib`. Si la obra ya está, en el núcleo o en el área secundaria, dilo y no la añadas.
2. **Cuelga.** Elige la obra del núcleo cuyo mecanismo amplía, contrasta o precede la nueva. Entre dos candidatas, la que deja el motivo más concreto. Las obras del área secundaria no tienen ficha propia: se cuelga siempre del núcleo.
3. **Papel.** El que describe la relación con la obra de la que cuelga:
   - *Fuente original* solo si es el texto donde nació la idea. Un caso célebre posterior es *especialización aplicada*: Berkeley no es la fuente de la paradoja de Simpson.
   - *Contraste y crítica* sostiene una posición opuesta a la de la obra de la que cuelga, o critica otra obra de su misma rama, aunque no la discuta directamente: Friedman (1953) bajo Hedström, o Sánchez-Villagra y van Schaik, que discuten a Wrangham, bajo Boehm. Una crítica a algo ajeno a la rama es *especialización aplicada*.
   - *Profundización técnica* cubre el mismo terreno con más aparato; *introducción*, con menos.
   - El idioma nunca decide el papel.
4. **Motivo.** Una frase en castellano con la relación concreta, nombrando la obra del núcleo cuando aclara: «Gat explica por qué hay guerras, y Kalyvas, cómo se reparte la violencia dentro de ellas». Escribe solo texto plano: el lector de `refs.R` y BibTeX no admiten `{ } % $ # &` sueltos.
5. **Edición e identificador.** La edición más reciente de la versión que se recomienda; comprueba si hay una posterior a la propuesta. Verifica cada identificador en la fuente, nunca de memoria:
   - doi en Crossref: `curl -s https://api.crossref.org/works/<doi>`, y que título, año y autores coincidan.
   - Si no hay doi, isbn en Open Library: `curl -sL https://openlibrary.org/isbn/<isbn>.json`.
   - Sin ninguno, la entrada va sin enlace, y el registro de cambios lo dice.
6. **Forma.** Clave al estilo de Better BibTeX. Un campo por línea, alineado como las entradas vecinas. Nombres con sufijo: `Moore, Jr., Barrington`. `\&` en editoriales y revistas. Las traducciones llevan `origlanguage`, `origtitle` y `origdate` solo si difiere de `year`; una lengua nueva se añade a `idiomas` en `refs.R` y a la cabecera.
7. **Nivel y descriptor.** Nivel de 1 a 3 por exigencia analítica. Reutiliza un descriptor existente si encaja; uno nuevo, en mayúsculas de título.
8. **Estado `propuesta`.** Siempre, aunque la obra sea excelente: solo una sesión de revisión la pasa a `curada`.
9. **Comprobación.** `Rscript biblioteca-secundaria/obras.R && Rscript -e 'source("refs.R")'` termina sin error.

Las propuestas no van al registro de cambios ni a las rutas: entran en ellos al curarse.

## Sesión de revisión

El responsable la abre de forma explícita. Lista las propuestas:

```bash
Rscript -e 'source("refs.R"); for (o in Filter(function(o) o[["estado"]] == "propuesta", secundarias)) cat(o[["clave"]], "|", o[["cuelga"]], "|", o[["papel"]], "|", o[["motivo"]], "\n")'
```

Cada propuesta queda en uno de tres destinos: `curada`, corregida y `curada`, o borrada del archivo. Por cada curada, una viñeta en «Desde v1.1» de `biblioteca-cambios.qmd`, que dice de qué cuelga, con qué papel y por qué, y el recuento de su primera línea igual a `n_secundarias`. La sesión está cerrada cuando no queda ninguna propuesta sin destino.

## Rutas

Una ruta merece existir cuando un tema reparte al menos tres obras curadas entre al menos tres ramas. Es una lista de claves en orden de lectura en `biblioteca-rutas.qmd`, con un párrafo que dice qué recorre; `ruta()` rechaza claves que no estén en el núcleo o entre las curadas.

Cada ruta va, como `###`, en uno de los tres grupos de la página: *para saber de algo* (un tema o un autor), *para saber hacer algo* (un oficio o un método) y *para saber qué vale lo que se sabe* (causalidad, predicción, medida). Tras la lista, una línea «**Para simularlo:**» enlaza los laboratorios que ponen a funcionar sus obras y dice qué mecanismo simula cada uno; si ninguno encaja, la ruta va sin ella. Un laboratorio nuevo se añade a la línea de las rutas cuyas obras simula.

## Laboratorios

Las lecturas de [laboratorios-y-simulaciones](https://github.com/nuevasomosaguas/laboratorios-y-simulaciones) enlazan `https://nuevasomosaguas.github.io/biblioteca.html#<clave>` con la clave de una obra del núcleo: solo el núcleo tiene ancla. Una lectura del área secundaria enlaza la ficha de la que cuelga.

## Render y commits

- Quarto no está en el PATH: añade el de RStudio, `PATH=/usr/lib/rstudio/resources/app/bin/quarto/bin:$PATH quarto render`, porque `biblioteca.qmd` llama a `quarto pandoc` desde R.
- `_site/` lo genera y publica GitHub Actions: restáuralo con `git checkout -- _site && git clean -fdq _site` tras un render local.
- Un commit por alta o por tanda, con un mensaje en castellano que diga qué cuelga de qué. Sin firma ni `Co-Authored-By`.
- Push solo cuando el responsable lo pida.
- El núcleo tiene 150 obras y su tope lo fija el responsable: un alta nunca entra en él.
