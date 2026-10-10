# The secondary area's catalogue, generated from biblioteca.bib before every render
# (pre-render in _quarto.yml): one listing item per curated work. Adding a work to the
# catalogue is adding an entry to the .bib.
source("refs.R")

items <- lapply(unname(curadas), function(o) {
  nucleo <- obras[[o[["cuelga"]]]]
  d <- destino(o)
  c(list(title = llano(o[["title"]])),
    if (!is.null(d)) list(path = d[["url"]]),
    list(autores = autores(o),
         anio = o[["year"]],
         papel = o[["papel"]],
         tema = o[["descriptor"]],
         nivel = as.integer(o[["nivel"]]),
         cuelga = sprintf("[%s (%s)](../biblioteca.html#%s)", apellidos(nucleo), nucleo[["year"]], nucleo[["clave"]]),
         categories = c(o[["papel"]], o[["descriptor"]])))
})
yaml::write_yaml(items, "biblioteca-secundaria/obras.yml")
