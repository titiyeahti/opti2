"""
Author : VOTRE NOM
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
  m = Model(GLPK.Optimizer)
  T = (inst.w)*(inst.h)*(inst.β)
  
  @variable(m, u[1:T, 1:inst.h, 1:inst.w], Bin)
  @variable(m, x[1:(T-1), 1:5], Bin)
  @variable(m, b[1:T], Int, lower_bound=1, upper_bound=(inst.β))

  for t in 1:(T-1)
    @constraint(m, sum(x[t, j] for j in 1:5) == 1)
  end

  for t in 1:T
    @constraint(m, sum(u[t, l, c] for l in 1:(inst.h) for c in 1:(inst.w)) == 1)
  end

  for t in 1:(T-2)
    @constraint(m, x[(t+1), 5] >= x[t, 5])
  end

  for l in 1:(inst.h)
    for c in 1:(inst.w)
      @constraint(m, sum(u[t, l, c] for t in 1:T) - (inst.t)[l][c] >= 0)
    end
  end

  for t in 2:T
    @constraint(m, b[(t-1)] -1 + inst.β*u[t, inst.ls, inst.cs] >= b[t])
  end

  @constraint(m, u[1, inst.ls, inst.cs] == 1)
  @constraint(m, u[T, inst.ls, inst.cs] == 1)


  for t in 1:(T-1)
    @constraint(m, u[t, inst.h, inst.w] + x[t, 2] - 1 <= u[(t+1), (inst.h-1), inst.w])
    @constraint(m, u[t, inst.h, inst.w] + x[t, 4] - 1 <= u[(t+1), inst.h, inst.w-1])
    @constraint(m, u[t, inst.h, inst.w] + x[t, 1] <= 1)
    @constraint(m, u[t, inst.h, inst.w] + x[t, 3] <= 1)
  end

  for t in 1:(T-1)
    @constraint(m, u[t, 1, inst.w] + x[t, 1] - 1 <= u[(t+1), 2, inst.w])
    @constraint(m, u[t, 1, inst.w] + x[t, 4] - 1 <= u[(t+1), 1, inst.w-1])
    @constraint(m, u[t, 1, inst.w] + x[t, 2] <= 1)
    @constraint(m, u[t, 1, inst.w] + x[t, 3] <= 1)
  end

  for t in 1:(T-1)
    @constraint(m, u[t, inst.h, 1] + x[t, 2] - 1 <= u[(t+1), (inst.h-1), 1])
    @constraint(m, u[t, inst.h, 1] + x[t, 3] - 1 <= u[(t+1), inst.h, 2])
    @constraint(m, u[t, inst.h, 1] + x[t, 1] <= 1)
    @constraint(m, u[t, inst.h, 1] + x[t, 4] <= 1)
  end

  for t in 1:(T-1)
    @constraint(m, u[t, 1, 1] + x[t, 1] - 1 <= u[(t+1), 2, 1])
    @constraint(m, u[t, 1, 1] + x[t, 3] - 1 <= u[(t+1), 1, 2])
    @constraint(m, u[t, 1, 1] + x[t, 2] <= 1)
    @constraint(m, u[t, 1, 1] + x[t, 4] <= 1)
  end

  for t in 1:(T-1)
    for c in 2:(inst.w-1)
      @constraint(m, u[t, inst.h, c] + x[t, 2] - 1 <= u[(t+1), (inst.h-1), c])
      @constraint(m, u[t, inst.h, c] + x[t, 3] -1 <= u[(t+1), inst.h, c+1])
      @constraint(m, u[t, inst.h, c] + x[t, 4] -1 <= u[(t+1), inst.h, c-1])
      @constraint(m, u[t, inst.h, c] + x[t, 1] <= 1)
    end
  end

  for t in 1:(T-1)
    for c in 2:(inst.w-1)
      @constraint(m, u[t, 1, c] + x[t, 1] - 1 <= u[(t+1), 2, c])
      @constraint(m, u[t, 1, c] + x[t, 3] -1 <= u[(t+1), 1, c+1])
      @constraint(m, u[t, 1, c] + x[t, 4] -1 <= u[(t+1), 1, c-1])
      @constraint(m, u[t, 1, c] + x[t, 2] <= 1)
    end
  end

  for t in 1:(T-1)
    for l in 2:(inst.h-1)
      @constraint(m, u[t, l, inst.w] + x[t, 1] - 1 <= u[(t+1), l+1, inst.w])
      @constraint(m, u[t, l, inst.w] + x[t, 2] -1 <= u[(t+1), l-1, inst.w])
      @constraint(m, u[t, l, inst.w] + x[t, 4] -1 <= u[(t+1), l, inst.w-1])
      @constraint(m, u[t, l, inst.w] + x[t, 3] <= 1)
    end
  end

  for t in 1:(T-1)
    for l in 2:(inst.h-1)
      @constraint(m, u[t, l, 1] + x[t, 1] - 1 <= u[(t+1), l+1, 1])
      @constraint(m, u[t, l, 1] + x[t, 2] - 1 <= u[(t+1), l-1, 1])
      @constraint(m, u[t, l, 1] + x[t, 3] - 1 <= u[(t+1), l, 2])
      @constraint(m, u[t, l, 1] + x[t, 4] <= 1)
    end
  end
  
  for t in 1:(T-1)
    for l in 2:(inst.h-1)
      for c in 2:(inst.w-1)
        @constraint(m, u[t, l, c] + x[t, 1] -1 <= u[(t+1), l+1, c])
      end
    end
  end

  for t in 1:(T-1)
    for l in 2:(inst.h-1)
      for c in 2:(inst.w-1)
        @constraint(m, u[t, l, c] + x[t, 2] -1 <= u[(t+1), l-1, c])
      end
    end
  end

  for t in 1:(T-1)
    for l in 2:(inst.h-1)
      for c in 2:(inst.w-1)
        @constraint(m, u[t, l, c] + x[t, 3] -1 <= u[(t+1), l, c+1])
      end
    end
  end

  for t in 1:(T-1)
    for l in 2:(inst.h-1)
      for c in 2:(inst.w-1)
        @constraint(m, u[t, l, c] + x[t, 4] -1 <= u[(t+1), l, c-1])
      end
    end
  end

 for t in 1:(T-1)
   for l in 1:(inst.h)
     for c in 1:(inst.w)
      @constraint(m, u[t, l, c] + x[t, 5] - 1 <= u[(t+1), l, c])
     end
   end
 end

 for t in 1:T
   for l in 1:inst.h
      for c in 1:inst.w
        @constraint(m,  u[t, l, c] <=  (inst.t)[l][c])
      end
    end
  end

  @objective(m, Min, sum(x[t, j] for j in 1:4 for t in 1:(T-1)))
  print(m)
  optimize!(m)

  return (m, u, x, b)
end
  

@doc """
Cette fonction est appelée après la fonction `run` et permet de faire de l'affichage et des traitement sur la sortie de la fonction `run` ; sans pour autant affecter son temps de calcul.

Le paramètre cpu time est le temps de calcul de `run`. Les valeurs de `inst` et `sol` sont les mêmes qu’à la sortie de la fonction run. Enfin, `others` est ce qui est renvoyé par la fonction `run`. Vous pouvez ainsi effectuer des tests et afficher des résultats sans affecter le temps de calcul.
""" ->
function post_process(cpu_time::Float64, inst, sol, others)
  m, u, x, b = others

  print(m)

  println()

  println("TERMINAISON : ", termination_status(m))
  println("OBJECTIF : $(objective_value(m))")
  println("VALEURS de u : $(value.(u))")
  println("VALEURS de x : $(value.(x))")
  println("VALEURS de b : $(value.(b))")

  println("Temps de calcul : $cpu_time.")
end

# Ne pas enlever
if length(ARGS) > 0
  input_file = ARGS[1] 
  main(input_file)
end

