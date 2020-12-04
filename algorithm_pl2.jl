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
  x0 = inst.ls
  y0 = inst.cs
  m = Model(GLPK.Optimizer)
  T = (h)*(w)*(beta)

""" Déplacements """
  @variable(m, H[1:T], Bin)
  @variable(m, B[1:T], Bin)
  @variable(m, G[1:T], Bin)
  @variable(m, D[1:T], Bin)
  @variable(m, N[1:T], Bin)
  
""" Batterie """
  @variable(m, b[1:T], Int)

""" Position """
  @variable(m, U[1:T, 1:h, 1:w], Bin)

""" Initialisation """
  @constraint(m, U[1, x0, y0] == 1)
  @constraint(m, U[T, x0, y0] == 1)
  @constraint(m, b[1] == beta)

  for t in 1:T
    @constraint(m, H[t] + B[t] + G[t] + D[t] + N[t] == 1)
    @constraint(m, sum(U[t, x, y] for x in 1:(h) for y in 1:(w)) == 1)
    @constraint(m, b[t] <= beta)
    @constraint(m, b[t] >= 1)

""" Bords du cadre """
    @constraint(m, H[t] <= sum(U[t, h, y] for y in 1:(w)))
    @constraint(m, B[t] <= sum(U[t, 1, y] for y in 1:(w)))
    @constraint(m, G[t] <= sum(U[t, x, 1] for x in 1:(h)))
    @constraint(m, D[t] <= sum(U[t, x, w] for x in 1:(h)))
  end

  for t in 1:(T-1)
    @constraint(m, N[t+1] >= N[t])
    @constraint(m, b[t+1] <= b[t] - 1 + (beta)*U[t+1, x0, y0])
  
""" Déplacements : dans l'ordre H, B, G, D, N"""
    for y in 1:(w)
      for x in 1:(h - 1)
        @constraint(m, U[t+1, x+1, y] >= U[t, x, y] + H[t] - 1)
      end
      
      for x in 2:(h)
        @constraint(m, U[t+1, x-1, y] >= U[t, x, y] + B[t] - 1)
      end
    end
    
    for x in 1:(h)
      for y in 2:(w)
        @constraint(m, U[t+1, x, y-1] >= U[t, x, y] + G[t] - 1)
      end
      
      for y in 1:(w - 1)
        @constraint(m, U[t+1, x, y+1] >= U[t, x, y] + D[t] - 1)
      end
    end

    for x in 1:(h)
      for y in 1:(w)
        @constraint(m, U[t+1, x, y] >= U[t, x, y] + N[t] - 1)
      end
    end
  end

""" Zones interdites """
  println(inst.t)
  println(typeof(inst.t))
  for x in 1:(h)
    for y in 1:(w)
      if (inst.t)[x][y] == 1
        @constraint(m, sum(U[t, x, y] for t in 1:T) >= 1)
      end
    end
  end

  @constraint(m, sum(U[t, x, y] for t in 1:T for x in 1:h for y in 1:w 
        if (inst.t)[x][y] == 0) == 0)

  @objective(m, Min, sum(H[t] + B[t] + G[t] + D[t] for t in 1:T))
  optimize!(m)

  return (m, H, B, G, D, N, b, U)
end

@doc """
Cette fonction est appelée après la fonction `run` et permet de faire de l'affichage et des traitement sur la sortie de la fonction `run` ; sans pour autant affecter son temps de calcul.

Le paramètre cpu time est le temps de calcul de `run`. Les valeurs de `inst` et `sol` sont les mêmes qu’à la sortie de la fonction run. Enfin, `others` est ce qui est renvoyé par la fonction `run`. Vous pouvez ainsi effectuer des tests et afficher des résultats sans affecter le temps de calcul.
""" ->
function post_process(cpu_time::Float64, inst, sol, others)
  
  # Run a renvoyé le modèle et ses variables, qui ont été mis dans others.
  m, H, B, G, D, N, b, U = others

  println()

  println("TERMINAISON : ", termination_status(m))
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
  main(input_file)
end

