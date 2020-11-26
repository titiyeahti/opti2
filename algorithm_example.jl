"""
Author : Dimitri Watel
Projet OPTIMISATION 2 - ENSIIE - 2020-2021
"""

# Ne pas enlever
include("./main.jl")


######
# VOTRE CODE

# Exemple d'utilisation d'une bibliothèque que vous auriez codé vous même et placé dans customlibs
include("customlibs/libexample.jl")

######


@doc """
Modifie la solution sol de l'instance inst avec l'algorithme suivant

Cet algorithme se déplace vers chaque case qui n'est pas un obstacle, puis revient vers la station, puis recommence jusqu'à ce que toutes les cases soient couvertes.

Cette fonction peut renvoyer n'importe quel type de variable (dont rien du tout), qui sera ensuite traité dans post_process. 
""" ->
function run(inst, sol)

  # Appel de la fonction hello dans la bibliothèque inclue plus haut
  hello()

  for l in 1:inst.h
      for c in 1:inst.w
        if inst.t[l][c] == 1
            push_to(sol, l, c)
            push_to(sol, inst.ls, inst.cs)
        end
      end
  end

end

@doc """
Cette fonction est appelée après la fonction `run` et permet de faire de l'affichage et des traitement sur la sortie de la fonction `run` ; sans pour autant affecter son temps de calcul.

Le paramètre cpu time est le temps de calcul de `run`. Les valeurs de `inst` et `sol` sont les mêmes qu’à la sortie de la fonction run. Enfin, `others` est ce qui est renvoyé par la fonction `run`. Vous pouvez ainsi effectuer des tests et afficher des résultats sans affecter le temps de calcul.
""" ->
function post_process(cpu_time::Float64, inst, sol, others)
  println("INSTANCE")

  # Affichage du nombre de mouvements du robot de la solution
  println("Durée de la solution : $(soltime(sol))")
  println("TEmps de calcul de la solution : $(cpu_time)")

  println("Mouvements de la solution : ")
  print_moves(sol)
  println()
end

# Ne pas enlever
if length(ARGS) > 0
  input_file = ARGS[1] 
  main(input_file)
end

