"""
Author : Dimitri Watel
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
  m = Model(GLPK.Optimizer)
  @variable(m, x[1:10], Bin)
  @variable(m, y, Int)
  @variable(m, z[i in 1:5] >= i)

  for i in 1:10
    @constraint(m, x[i] + sum(z[j] for j in 1:5 if j % 2 == 0) <= y) 
  end
  # Ou, de manière équivalente,
  # @constraint(m, cons[i in 1:10], x[i] + sum(z[j] for j in 1:5 if j % 2 == 0) <= y) 


  @objective(m, Min, sum(z[j] for j in 1:5))
  optimize!(m)

  return (m, x, y, z)
end

@doc """
Cette fonction est appelée après la fonction `run` et permet de faire de l'affichage et des traitement sur la sortie de la fonction `run` ; sans pour autant affecter son temps de calcul.

Le paramètre cpu time est le temps de calcul de `run`. Les valeurs de `inst` et `sol` sont les mêmes qu’à la sortie de la fonction run. Enfin, `others` est ce qui est renvoyé par la fonction `run`. Vous pouvez ainsi effectuer des tests et afficher des résultats sans affecter le temps de calcul.
""" ->
function post_process(cpu_time::Float64, inst, sol, others)
  
  # Run a renvoyé le modèle et ses variables, qui ont été mis dans others.
  m, x, y, z = others

  print(m)

  println()

  println("TERMINAISON : ", termination_status(m))
  println("OBJECTIF : $(objective_value(m))")
  println("VALEURS de x : $(value.(x))")
  println("VALEURS de y : $(value.(y))")
  println("VALEURS de z : $(value.(z))")

  println("Temps de calcul : $cpu_time.")

end

# Ne pas enlever
if length(ARGS) > 0
  input_file = ARGS[1] 
  main(input_file)
end

