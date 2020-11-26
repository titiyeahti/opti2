"""
Author : Dimitri Watel
Projet OPTIMISATION 2 - ENSIIE - 2020-2021

NE PAS APPELER CE FICHIER SEUL.
UTILISEZ LE CONJOINTEMENT AVEC UN FICHIER algorithm_XXX.jl
"""

include("helpers/generate.jl")
include("helpers/problem.jl")

using .Roombot
using .Generator

@doc """
Prend un fichier en entrée et exécute un algorithme avec.


""" ->
function main(input_file::String)
  # Création de l'instance
  inst = generate(input_file)
  sol = Solution(inst)

  cpu_time = @elapsed(others = run(inst, sol))
  post_process(cpu_time, inst, sol, others)
end
