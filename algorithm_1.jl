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
mutable struct State
 l
 c
 n
 b
 prevState
end

function getValue(inst, s)
  if s.l < 1 || s.l > inst.h || s.c < 1 || s.c > inst.w || (inst.t)[s.l][s.c] == 0 || s.n < 0 || s.b < 0
    s.n = -1
  elseif s.n > 0
    cur = s.prevState
    while cur != nothing && ((cur).l != s.l || (cur).l != s.c)
      cur = cur.prevState
    end
    if cur == nothing
      s.n = s.n - 1
    end
  end
  if s.l == inst.ls && s.c == inst.cs
    s.b = inst.β
  end
  return s
end

function getRightState(inst, state)
   s = State(state.l, state.c+1, state.n, state.b - 1, state)
   s = getValue(inst, s)
   return s
end

function getLeftState(inst, state)
   s = State(state.l, state.c-1, state.n, state.b - 1, state)
   s = getValue(inst, s)
   return s
end

function getUpState(inst, state)
   s = State(state.l-1, state.c, state.n, state.b - 1, state)
   s = getValue(inst, s)
   return s
end

function getDownState(inst, state)
   s = State(state.l+1, state.c, state.n, state.b - 1, state)
   s = getValue(inst, s)
   return s
end

function run(inst, sol)

 ntot = 0
 for i in 1:inst.h
   for j in 1:inst.w
     if (inst.t)[i][j] == 1
       ntot = ntot + 1
     end
   end
 end

 T = (inst.h)*(inst.w)*(inst.β)
 step = 0
 solState = nothing
 cur = [State(inst.ls, inst.cs, ntot, inst.β, nothing)]
 while length(cur) > 0 && solState == nothing && step < 10
   next = []
   println(step)
   for i in 1:length(cur)
     if cur[i].l == inst.ls && cur[i].c == inst.cs && cur[i].n == 0
       solState = cur[i]
     end
     rState = getRightState(inst, cur[i])
     lState = getLeftState(inst, cur[i])
     uState = getUpState(inst, cur[i])
     dState = getDownState(inst, cur[i])
     if (rState).n >= 0
       push!(next, rState)
     end
     if (lState).n >= 0
       push!(next, lState)
     end
     if (uState).n >= 0
       push!(next, uState)
     end
     if (dState).n >= 0
       push!(next, dState)
     end
   end
   cur = next
   step = step + 1
 end

 while solState != nothing
   push_to(sol, solState.l, solState.c)
   solState = solState.prevState
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

