"""
Author : Thibaut MILHAUD
Projet OPTIMISATION 2 - ENSIIE - 2020-2021
"""

# Ne pas enlever
include("./main.jl")

######
# VOTRE CODE


println("Chargement de JuMP")
using JuMP
println("Chargement de GLPK")
using GLPK
println("Chargé")

######

@doc """
Modifie la solution sol de l'instance inst avec l'algorithme suivant

Cette fonction fait n'importe quoi, c'est juste un exempel de programme linéaire.

Cette fonction peut renvoyer n'importe quel type de variable (dont rien du tout), qui sera ensuite traité dans post_process. 
""" ->
function run(inst, sol)
""" ATTENTION : les coordonnées de la prise peuvent être comptées dans l'autre sens """
  h = inst.h
  w = inst.w
  beta = inst.β
  i0 = inst.ls
  j0 = inst.cs
  m = Model(GLPK.Optimizer)
  T = (h)*(w)*5

  E = [(i,j) for i in 1:h for j in 1:w if (inst.t)[i][j]==1]

  println("COUCOU")

""" Déplacements """
  @variable(m, H[1:T], Bin)
  @variable(m, B[1:T], Bin)
  @variable(m, G[1:T], Bin)
  @variable(m, D[1:T], Bin)
  @variable(m, N[1:T], Bin)
  
  println("DPL OK")
""" Batterie """
  @variable(m, b[1:T], Int)

  println("BAT OK")
""" Position """
  @variable(m, U[s in E, t in 1:T], Bin)

  println("POS OK")
""" Initialisation """
  s0 = (i0, j0)
  @constraint(m, U[s0, 1] == 1)
  @constraint(m, U[s0, T] == 1)
  @constraint(m, b[1] == beta)

  println("INIT OK")
  for t in 1:T
    @constraint(m, H[t] + B[t] + G[t] + D[t] + N[t] == 1)
    @constraint(m, sum(U[s, t] for s in E) == 1)
    @constraint(m, b[t] <= beta)
    @constraint(m, b[t] >= 1)
  end

  println("FIRST ROW")
""" Déplacements interdits """
  for s in E
    i, j = s
    if !valid(inst, i-1, j)
      @constraint(m, [t in 1:T], U[s, t] + H[t] <= 1)
    end 
    if !valid(inst, i+1, j)
      @constraint(m, [t in 1:T], U[s, t] + B[t] <= 1)
    end 
    if !valid(inst, i, j-1)
      @constraint(m, [t in 1:T], U[s, t] + G[t] <= 1)
    end 
    if !valid(inst, i, j+1)
      @constraint(m, [t in 1:T], U[s, t] + D[t] <= 1)
    end 
  end 

  println("DPL INTERDIT OK")
  for t in 1:(T-1)
    @constraint(m, N[t+1] >= N[t])
    @constraint(m, b[t+1] <= b[t] - 1 + (beta)*U[t+1, x0, y0])
  
""" Déplacements : dans l'ordre H, B, G, D, N"""
    for s in E
      i, j = s
      @constraint(m, U[(i-1, j), t+1] >= U[(i, j), t] + H[t])
      @constraint(m, U[(i+1, j), t+1] >= U[(i, j), t] + B[t])
      @constraint(m, U[(i, j-1), t+1] >= U[(i, j), t] + G[t])
      @constraint(m, U[(i, j+1), t+1] >= U[(i, j), t] + D[t])
      @constraint(m, U[(i, j), t+1] >= U[(i, j), t] + N[t])
    end
  end

  println("DPL OK")
  @objective(m, Min, sum(H[t] + B[t] + G[t] + D[t] for t in 1:T))
  optimize!(m)

  println("Programme linéaire paré")
  return (m, H, B, G, D, N, b, U, T)
end

@doc """
Cette fonction est appelée après la fonction `run` et permet de faire de l'affichage et des traitement sur la sortie de la fonction `run` ; sans pour autant affecter son temps de calcul.

Le paramètre cpu time est le temps de calcul de `run`. Les valeurs de `inst` et `sol` sont les mêmes qu’à la sortie de la fonction run. Enfin, `others` est ce qui est renvoyé par la fonction `run`. Vous pouvez ainsi effectuer des tests et afficher des résultats sans affecter le temps de calcul.
""" ->
function post_process(cpu_time::Float64, inst, sol, others)
  
  # Run a renvoyé le modèle et ses variables, qui ont été mis dans others.
  m, H, B, G, D, N, b, U, T = others

  println()

  println("TERMINAISON : ", termination_status(m))
  println("T : $(value.(T))\n")
  println("OBJECTIF : $(objective_value(m))")
  println("Déplacements :")
  println("H : $(value.(H))\n")
  println("B : $(value.(B))\n")
  println("G : $(value.(G))\n")
  println("D : $(value.(D))\n")
  println("N : $(value.(N))\n\n")

#println("Position :")
#println("U : $(value.(U))")

  println("Batterie :")
  println("b : $(value.(b))\n")
  
  println("Temps de calcul : $cpu_time.")

end

# Ne pas enlever
if length(ARGS) > 0
  input_file = ARGS[1]
  println(input_file)
  main(input_file)
end

