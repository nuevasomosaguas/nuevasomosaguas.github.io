# Single source of truth for the library: biblioteca.bib. The page lists, the
# counts quoted across the site and both downloads are all read from it.

# The file is kept to one field per line, so a line reader is enough; any line
# inside an entry that is not a field stops the render instead of being lost.
lee_bib <- function(path = "biblioteca.bib") {
  lineas <- readLines(path, encoding = "UTF-8", warn = FALSE)
  obras <- list()
  actual <- NULL
  for (l in lineas) {
    if (grepl("^@\\w+\\{", l)) {
      m <- regmatches(l, regexec("^@(\\w+)\\{([^,]+),$", l))[[1]]
      stopifnot(length(m) == 3)
      actual <- c(tipo = m[2], clave = m[3])
    } else if (!is.null(actual)) {
      if (l == "}") {
        obras[[actual[["clave"]]]] <- actual
        actual <- NULL
      } else {
        m <- regmatches(l, regexec("^  ([a-z]+) *= \\{(.*)\\},?$", l))[[1]]
        if (length(m) != 3) stop("biblioteca.bib: línea ilegible: ", l)
        actual[[m[2]]] <- m[3]
      }
    }
  }
  obras
}

# Two layers in one file: the core, ordered by strata, and the secondary area, where
# every work hangs from a core work. The counts quoted across the site are the core's.
todas <- lee_bib()
stopifnot(!anyDuplicated(names(todas)))
es_secundaria <- function(o) "capa" %in% names(o) && o[["capa"]] == "secundaria"
obras <- Filter(Negate(es_secundaria), todas)
secundarias <- Filter(es_secundaria, todas)
papeles <- c("Profundización técnica", "Contraste y crítica", "Especialización aplicada",
             "Fuente original", "Historia y contexto", "Divulgación")
for (o in obras) if (!"estrato" %in% names(o)) stop("biblioteca.bib: ", o[["clave"]], " no tiene estrato")
# How each core work is read: the time budget of the corpus, checkable from the counts.
lecturas <- c("Completa con ejercicios", "Completa", "Consulta")
for (o in obras) if (!isTRUE(o["lectura"] %in% lecturas)) stop("biblioteca.bib: ", o[["clave"]], " no tiene un modo de lectura válido")
n_lectura <- table(factor(vapply(obras, `[[`, "", "lectura"), levels = lecturas))
for (o in secundarias) {
  falta <- setdiff(c("cuelga", "papel", "estado"), names(o))
  if (length(falta) > 0) stop("biblioteca.bib: a ", o[["clave"]], " le falta ", toString(falta))
  if (!o[["cuelga"]] %in% names(obras)) stop("biblioteca.bib: ", o[["clave"]], " cuelga de ", o[["cuelga"]], ", que no está en el núcleo")
  if (!o[["papel"]] %in% papeles) stop("biblioteca.bib: papel desconocido en ", o[["clave"]], ": ", o[["papel"]])
  if (!o[["estado"]] %in% c("curada", "propuesta")) stop("biblioteca.bib: estado desconocido en ", o[["clave"]])
}
curadas <- Filter(function(o) o[["estado"]] == "curada", secundarias)  # the web shows only these
n_obras <- length(obras)
n_secundarias <- length(curadas)
n_referencias <- length(todas)

# The corpus is ordered by causal function, in ascending strata.
n_estratos <- length(grep("^## Estrato ", readLines("biblioteca.qmd", warn = FALSE)))

# Prose spells out small counts; fall back to the numeral beyond ten.
estratos_txt <- if (n_estratos <= 10) {
  c("uno", "dos", "tres", "cuatro", "cinco", "seis",
    "siete", "ocho", "nueve", "diez")[n_estratos]
} else as.character(n_estratos)

stopifnot(n_obras > 0, n_estratos > 0)

# BibTeX text as it reads: no braces, no escapes.
llano <- function(s) gsub("\\\\([&%$#_])", "\\1", gsub("[{}]", "", s))

# The authors (or editors) as a list of "Surname, Name", and whether it ends in "and others".
personas <- function(o) {
  p <- strsplit(llano(if ("author" %in% names(o)) o[["author"]] else o[["editor"]]), " and ")[[1]]
  list(nombres = p[p != "others"], et_al = p[length(p)] == "others")
}

# The authors in full, as the page prints them.
autores <- function(o) {
  p <- personas(o)
  n <- length(p$nombres)
  texto <- if (n == 1) p$nombres else paste0(paste(p$nombres[-n], collapse = "; "), " & ", p$nombres[n])
  if (p$et_al) paste(texto, "et al.") else texto
}

# The authors by surname, for a short citation: "Wasserman", "Casella y Berger", "Harrer et al.".
apellidos <- function(o) {
  p <- personas(o)
  s <- sub(",.*", "", p$nombres)
  if (length(s) > 2 || p$et_al) paste(s[1], "et al.") else paste(s, collapse = " y ")
}

# Where the link goes. The URL, to the authors' own copy when the book is free online,
# comes first: open material over the publisher's paywall. Otherwise the DOI resolves to
# the work itself, and the ISBN, to the libraries that hold it.
destino <- function(o) {
  if ("url" %in% names(o)) c(texto = sub("^https?://", "", o[["url"]]), url = o[["url"]])
  else if ("doi" %in% names(o)) c(texto = paste0("doi:", o[["doi"]]), url = paste0("https://doi.org/", o[["doi"]]))
  else if ("isbn" %in% names(o)) c(texto = paste("ISBN", o[["isbn"]]), url = paste0("https://search.worldcat.org/isbn/", o[["isbn"]]))
}

# One reference as a line of Markdown: authors, year, title, imprint, link and level tag.
cita <- function(o) {
  campo <- function(k) if (k %in% names(o)) o[[k]] else ""
  n <- length(personas(o)$nombres)
  nombres <- paste0("**", autores(o), "**",
                    if (campo("editor") != "") if (n > 1 || personas(o)$et_al) " (Eds.)" else " (Ed.)")
  titulo <- llano(o[["title"]])
  parentesis <- if (campo("edition") != "") paste(o[["edition"]], "Edition") else llano(campo("note"))
  pie <- if (o[["tipo"]] == "article") {
    paste0(llano(o[["journal"]]),
           if (campo("volume") != "") paste0(" ", o[["volume"]]),
           if (campo("number") != "") paste0("(", o[["number"]], ")"))
  } else llano(o[["publisher"]])
  d <- destino(o)
  enlace <- if (is.null(d)) "" else sprintf(". [%s](%s)", d[["texto"]], d[["url"]])
  sprintf("%s (%s). *%s*%s%s%s%s. `[Nivel %s | %s]`",
          nombres,
          paste(c(if (campo("origdate") != "") o[["origdate"]], o[["year"]]), collapse = "/"),
          titulo,
          if (parentesis != "") paste0(" (", parentesis, ")") else "",
          if (parentesis == "" && grepl("[?!]$", titulo)) " " else ". ",
          pie, enlace, o[["nivel"]], o[["descriptor"]])
}

# One core work as the page shows it: an anchor that the secondary catalogue links to,
# the reference, its reading mode, the three-field record for the works that carry one and, hanging
# from it, its curated secondary works.
ficha <- function(o) {
  rotulos <- c(lectura = "Modo de lectura", mecanismo = "Mecanismo", aparato = "Aparato formal", funcion = "Función en el RAG")
  presentes <- intersect(names(rotulos), names(o))
  ramas <- Filter(function(s) s[["cuelga"]] == o[["clave"]], curadas)
  c(sprintf("* []{#%s}%s", o[["clave"]], cita(o)),
    sprintf("  * *%s:* %s", rotulos[presentes], unlist(o[presentes])),
    vapply(ramas, function(s) sprintf("  * *%s:* %s", s[["papel"]], cita(s)), ""))
}

# The list for one stratum, in file order, for a `results: asis` chunk.
lista <- function(estrato) {
  cat(unlist(lapply(Filter(function(o) o[["estrato"]] == estrato, obras), ficha)), sep = "\n")
}
