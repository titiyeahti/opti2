"""
Author : VOTRE NOM
Projet OPTIMISATION 2 - ENSIIE - 2020-2021
"""

# Ne pas enlever
include("./main.jl")

######
# VOTRE CODE


# Vous pouvez mettre du code ici, il n'est pas nécesasire de mettre tout votre code dans la fonction run, ce serait illisible. 
#
# Vous pouvez mettre des fonctions, des variables globales (attention à ne pas faire n'importe quoi), des modules, ...
#

######

@doc """
Modifie la solution sol de l'instance inst avec l'algorithme suivant
*** DECRIRE VOTRE ALGORITHME ICI en quelques mots ***

Cette fonction peut renvoyer n'importe quel type de variable (dont rien du tout), qui sera ensuite traité dans post_process. 
""" ->
function run(inst, sol)
  # Remplir la fonction
end

@doc """
Cette fonction est appelée après la fonction `run` et permet de faire de l'affichage et des traitement sur la sortie de la fonction `run` ; sans pour autant affecter son temps de calcul.

Le paramètre cpu time est le temps de calcul de `run`. Les valeurs de `inst` et `sol` sont les mêmes qu’à la sortie de la fonction run. Enfin, `others` est ce qui est renvoyé par la fonction `run`. Vous pouvez ainsi effectuer des tests et afficher des résultats sans affecter le temps de calcul.
""" ->
function post_process(cpu_time::Float64, inst, sol, others)
  # Remplir la fonction
end

# Ne pas enlever
if length(ARGS) > 0
  input_file = ARGS[1] 
  main(input_file)
end

