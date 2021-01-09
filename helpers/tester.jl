"""
Author : Dimitri Watel
Projet OPTIMISATION 2 - ENSIIE - 2020-2019

Programme pour lancer une batterie de tests.

Utilisation : 
Supposons pour l'exemple que vous avez un algorithme dans le fichier "algorithm_test.jl"
et un dossier "dir_test" contenant des fichier ".input".
Placez vous à la racine du dossier du projet (dans le dossier contenant algorithm_test.jl et helpers)
et tapez la commande suivante.

julia helpers/tester.jl algorithm_test.jl dir_test/

Cette commande exécutera l'algorithme algorithm_test.jl sur tous les fichiers ".input" du dossier.

"""

println("Chargement des bibliothèques.")

########
# Ajoutez ici toutes les lignes "using ..." que vous avez dans vos algorithmes
#######
using Distributions

## Vous pouvez commenter/décommenter toute la section suivante selon que vous testez ou non un programme linéaire.
# Pour commenter plusieurs lignes en Julia, on peut mettre les lignes entre #= et =# ; supprimez ces deux lignes pour décommenter.

#=
## Indiquer votre solveur de programmation linéaire

using JuMP
using GLPK
m = Model(with_optimizer(GLPK.Optimizer))

# using CPLEX
# m = Model(with_optimizer(CPLEX.Optimizer))

# using SCIP
# m = Model(with_optimizer(SCIP.Optimizer))

# Les lignes suivantes génèrent et lancent un programe linéaire pour charger les bibliothèques ci-dessus. Sans ça, votre premier programme prendre énormément de temps.
@variable(m, x, Bin)
@objective(m, Min, x)
@constraint(m, x <= 0.5)
optimize!(m)
=#

println("Chargement terminé.")



# Ne pas enlever
if length(ARGS) == 2
  algorithm = ARGS[1]
  test_folder = ARGS[2]
  if test_folder[length(test_folder)] != '/'
    test_folder *= "/"
  end

  while length(ARGS) > 0
    pop!(ARGS)
  end

  include("../" * algorithm)
# modif
  println("#n bat sol cpu")
  for input_file in readdir(test_folder)
    if(endswith(input_file, ".input"))
#      println()
      test_path = test_folder * input_file
#      println("#### TEST : $test_path")
      main(test_folder * input_file)
#      println()
    end
  end
end

