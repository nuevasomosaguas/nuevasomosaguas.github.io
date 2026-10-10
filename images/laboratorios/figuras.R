# Las figuras de laboratorios.qmd, con los resultados de figuras.jl y el tema de la casa.
#   Rscript images/laboratorios/figuras.R      (desde la raíz del sitio)
library(ggplot2)
library(somosaguas)  # https://github.com/nuevasomosaguas/somosaguas-ggplot2

carpeta <- "images/laboratorios"
datos <- tempfile()
dir.create(datos)
stopifnot(system2("julia", c(file.path(carpeta, "figuras.jl"), datos)) == 0)
leer <- function(f) as.matrix(read.csv(file.path(datos, f), header = FALSE))
guardar <- function(grafico, nombre, alto = 4) {
  ggsave(file.path(carpeta, nombre), grafico, width = 7, height = alto, dpi = 200,
         device = ragg::agg_png, bg = "#ffffff")
}
tema <- theme_somosaguas(fondo = "#ffffff")
paleta <- unname(paleta_somosaguas)
granate <- paleta[1]
coma <- scales::label_number(decimal.mark = ",", big.mark = ".")

# 1. Berkson: la nube de la población y, resaltados, los seleccionados
b <- as.data.frame(leer("berkson.csv"))
names(b) <- c("talento", "diligencia", "seleccionado")
r <- with(b[b$seleccionado == 1, ], cor(talento, diligencia))  # con los 100 000
set.seed(1)
b <- b[sample(nrow(b), 8000), ]  # se dibuja una muestra, para que la nube se lea
guardar(
  ggplot(b, aes(talento, diligencia)) +
    geom_point(data = b[b$seleccionado == 0, ], colour = "grey75", size = 0.5) +
    geom_point(data = b[b$seleccionado == 1, ], colour = granate, size = 0.7) +
    geom_smooth(data = b[b$seleccionado == 1, ], method = "lm", formula = y ~ x,
                se = FALSE, colour = "black", linewidth = 0.6) +
    annotate("text", x = 1.4, y = 3.8, label = paste0("admitidos: r = ", format(round(r, 2), nsmall = 2, decimal.mark = ",")),
             colour = granate, hjust = 0) +
    annotate("text", x = -3.8, y = -3.6, label = "población: r = 0,00", colour = "grey45", hjust = 0) +
    scale_x_continuous(labels = coma) + scale_y_continuous(labels = coma) +
    coord_equal(xlim = c(-4, 4.5), ylim = c(-4, 4)) +
    labs(x = "Talento", y = "Diligencia") + tema,
  "berkson.png", alto = 5)

# 2. Beta-Binomial: la creencia previa y la posterior
theta <- seq(0, 1, length.out = 501)
beta <- rbind(data.frame(theta, densidad = dbeta(theta, 2, 2), curva = "A priori: Beta(2, 2)"),
              data.frame(theta, densidad = dbeta(theta, 16, 8), curva = "A posteriori: Beta(16, 8)"))
guardar(
  ggplot(beta, aes(theta, densidad, colour = curva)) +
    geom_line(linewidth = 0.9) +
    annotate("text", x = 0.18, y = 1.75, label = "A priori\nBeta(2, 2)", colour = paleta[2]) +
    annotate("text", x = 0.86, y = 3.9, label = "A posteriori\nBeta(16, 8)", colour = paleta[1]) +
    scale_colour_manual(values = c("A posteriori: Beta(16, 8)" = paleta[1], "A priori: Beta(2, 2)" = paleta[2]),
                        guide = "none") +
    scale_x_continuous(labels = coma) +
    labs(x = "Probabilidad de cooperación θ", y = "Densidad") + tema,
  "beta-binomial.png")

# 3. Schelling: el tablero antes y después
tablero <- function(m, momento) {
  data.frame(fila = as.vector(row(m)), columna = as.vector(col(m)),
             grupo = factor(as.vector(m), levels = 0:2, labels = c("Vacía", "Grupo A", "Grupo B")),
             momento = momento)
}
s <- rbind(tablero(leer("schelling_inicial.csv"), "Al principio: 50 % de vecinos afines"),
           tablero(leer("schelling_final.csv"), "Tras nueve rondas: 75 %"))
s$momento <- factor(s$momento, levels = unique(s$momento))
guardar(
  ggplot(s, aes(columna, fila, fill = grupo)) +
    geom_raster() +
    facet_wrap(~momento) +
    scale_fill_manual(values = c("Vacía" = "#ffffff", "Grupo A" = paleta[1], "Grupo B" = paleta[2]),
                      breaks = c("Grupo A", "Grupo B"), name = NULL) +
    coord_equal() +
    tema +
    theme(axis.text = element_blank(), axis.title = element_blank(), axis.ticks = element_blank(),
          axis.line = element_blank(), axis.line.x = element_blank(), axis.ticks.x = element_blank(),
          panel.grid = element_blank(), panel.grid.major.y = element_blank()),
  "schelling.png", alto = 4)

# 5. Bootstrap: la distribución de las medianas remuestreadas
m <- data.frame(mediana = leer("bootstrap.csv")[, 1])
ic <- quantile(m$mediana, c(0.025, 0.975))
guardar(
  ggplot(m, aes(mediana)) +
    geom_histogram(bins = 60, fill = "grey70", colour = NA) +
    geom_vline(xintercept = ic, colour = granate, linetype = "dashed") +
    geom_vline(xintercept = exp(9.5), colour = "black") +
    annotate("text", x = exp(9.5), y = Inf, label = "  mediana de la población", hjust = 0, vjust = 1.5) +
    annotate("text", x = ic[1], y = Inf, label = "IC 95 %  ", hjust = 1, vjust = 1.5, colour = granate) +
    scale_x_continuous(labels = scales::label_number(big.mark = ".", decimal.mark = ",")) +
    labs(x = "Mediana del patrimonio en cada remuestra (€)", y = "Remuestras") + tema,
  "bootstrap.png")
