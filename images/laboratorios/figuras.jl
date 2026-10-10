# Repite los laboratorios 1, 3 y 5 de laboratorios.qmd, con las mismas semillas, y guarda
# en CSV lo que dibuja figuras.R. Solo usa la biblioteca estándar de Julia.
#   julia figuras.jl <carpeta>
using Random, Statistics, DelimitedFiles

salida = ARGS[1]

# 1. Berkson
Random.seed!(42)
N = 100_000
talento = randn(N)
diligencia = randn(N)
puntuacion = talento .+ diligencia
seleccionados = puntuacion .>= quantile(puntuacion, 0.90)
writedlm(joinpath(salida, "berkson.csv"), [talento diligencia seleccionados], ',')

# 3. Schelling: el mismo código que la página, guardando el tablero inicial
function prop_vecinos_iguales(tablero, r, c)
    dim = size(tablero, 1)
    agente = tablero[r, c]
    iguales = 0
    ocupados = 0
    for i in max(1, r - 1):min(dim, r + 1), j in max(1, c - 1):min(dim, c + 1)
        (i == r && j == c) && continue
        tablero[i, j] == 0 && continue
        ocupados += 1
        tablero[i, j] == agente && (iguales += 1)
    end
    return ocupados == 0 ? nothing : iguales / ocupados
end

function simular_schelling(dim = 40; vacios = 0.1, umbral = 0.30, max_iter = 50)
    n_celdas = dim * dim
    tablero = rand([1, 2], dim, dim)
    tablero[randperm(n_celdas)[1:round(Int, vacios * n_celdas)]] .= 0
    global inicial = copy(tablero)
    for paso in 1:max_iter
        movimientos = 0
        celdas_vacias = findall(==(0), tablero)
        for ci in CartesianIndices(tablero)
            tablero[ci] == 0 && continue
            isempty(celdas_vacias) && break
            p = prop_vecinos_iguales(tablero, Tuple(ci)...)
            if p !== nothing && p < umbral
                destino = popat!(celdas_vacias, rand(1:length(celdas_vacias)))
                tablero[destino] = tablero[ci]
                tablero[ci] = 0
                push!(celdas_vacias, ci)
                movimientos += 1
            end
        end
        movimientos == 0 && break
    end
    return tablero
end

Random.seed!(7)
final = simular_schelling()
writedlm(joinpath(salida, "schelling_inicial.csv"), inicial, ',')
writedlm(joinpath(salida, "schelling_final.csv"), final, ',')

# 5. Bootstrap
Random.seed!(101)
B = 10_000
patrimonio = exp.(randn(200) .* 1.2 .+ 9.5)
n = length(patrimonio)
medianas_boot = zeros(B)
for b in 1:B
    medianas_boot[b] = median(patrimonio[rand(1:n, n)])
end
writedlm(joinpath(salida, "bootstrap.csv"), medianas_boot, ',')
println("Berkson: ", round(cor(talento[seleccionados], diligencia[seleccionados]), digits = 3),
        " | bootstrap: ", round.(quantile(medianas_boot, [0.025, 0.975]), digits = 2))
