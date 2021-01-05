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
 len
 circuitVide
end

#Retourne la valeur des paramettre b, n, len, circuitVide pour l'etat s
function getValue(inst, s)
  if s.l < 1 || s.l > inst.h || s.c < 1 || s.c > inst.w || (inst.t)[s.l][s.c] == 0 || s.n < 0 || s.b < 0 || s.b < abs(s.l - inst.ls) + abs(s.c - inst.cs) || s.len > (inst.h)*(inst.w)*inst.β || (s.l == inst.ls && s.c == inst.cs && s.circuitVide == 1)
    s.n = -1
  elseif s.n > 0
    cur = s.prevState
    while cur != nothing && (cur.l != s.l || cur.c != s.c)
      cur = cur.prevState
    end
    if cur == nothing
      s.n = s.n - 1
      s.circuitVide = 0
    end
  end
  if s.l == inst.ls && s.c == inst.cs
    s.b = inst.β
    s.circuitVide = 1
  end
  return s
end

function getRightState(inst, state)
   s = State(state.l, state.c+1, state.n, state.b - 1, state, state.len + 1, state.circuitVide)
   s = getValue(inst, s)
   return s
end

function getLeftState(inst, state)
   s = State(state.l, state.c-1, state.n, state.b - 1, state, state.len + 1, state.circuitVide)
   s = getValue(inst, s)
   return s
end

function getUpState(inst, state)
   s = State(state.l-1, state.c, state.n, state.b - 1, state, state.len + 1, state.circuitVide)
   s = getValue(inst, s)
   return s
end

function getDownState(inst, state)
   s = State(state.l+1, state.c, state.n, state.b - 1, state, state.len + 1, state.circuitVide)
   s = getValue(inst, s)
   return s
end

function getIndexHeuristique(state, liste, ls, cs)
  if length(liste) == 0
    return 1
  end
  i = 1
  while i <= length(liste) && (state.n + state.len + abs(state.l - ls) + abs(state.c - cs) > liste[i].n + liste[i].len + abs(liste[i].l - ls) + abs(liste[i].c - cs) ||
  (state.n == 0 && state.n + state.len + abs(state.l - ls) + abs(state.c - cs) == liste[i].n + liste[i].len + abs(liste[i].l - ls) + abs(liste[i].c - cs) && state.n + abs(state.l - ls) + abs(state.c - cs) > liste[i].n + abs(liste[i].l - ls) + abs(liste[i].c - cs)) ||
  (state.n > 0 && state.n == 0 && state.n + state.len + abs(state.l - ls) + abs(state.c - cs) == liste[i].n + liste[i].len + abs(liste[i].l - ls) + abs(liste[i].c - cs) && state.n < liste[i].n) ||
  (state.n > 0 && state.n + state.len + abs(state.l - ls) + abs(state.c - cs) == liste[i].n + liste[i].len + abs(liste[i].l - ls) + abs(liste[i].c - cs) && state.n == liste[i].n && state.b > liste[i].b))
    i = i + 1
  end
  return i
end

#retourne l'index pour lequel state doit etre insérer dans la liste
function getIndexHeuristique2(state, liste, ls, cs)
  if length(liste) == 0
    return 1
  end
  i = 1
  while i <= length(liste) && ((state.n > liste[i].n) || (state.n == liste[i].n && state.n == 0 && abs(state.l - ls) + abs(state.c - cs) > abs(liste[i].l - ls) + abs(liste[i].c - cs))  || (state.n == liste[i].n && state.n > 0 && state.len > liste[i].len) || (state.n == liste[i].n && state.n > 0 && state.len == liste[i].len && abs(state.l - ls) + abs(state.c - cs) < abs(liste[i].l - ls) + abs(liste[i].c - cs)))
    i = i + 1 
  end
  return i
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
 mini = 0
 solState = nothing
 cur = [State(inst.ls, inst.cs, ntot - 1, inst.β, nothing, 1, 1)]
 while length(cur) > 0
   #print(cur[1].len)
   #print(" ")
   #print(cur[1].n)
   #print(" ")
   #print(abs(cur[1].l - inst.ls) + abs(cur[1].c - inst.cs))
   #print(" ")
   #println(mini)
   if cur[1].l == inst.ls && cur[1].c == inst.cs && cur[1].n == 0 && (solState == nothing || solState.len > cur[1].len)
     solState = cur[1]
     mini = cur[1].len
   end
   rState = getRightState(inst, cur[1])
   lState = getLeftState(inst, cur[1])
   uState = getUpState(inst, cur[1])
   dState = getDownState(inst, cur[1])
   popfirst!(cur)
   if (rState).n >= 0 && (solState == nothing ||  (rState.n + rState.len < solState.len && abs(rState.l - inst.ls) + abs(rState.c - inst.cs) + rState.len < solState.len))
     insert!(cur, getIndexHeuristique2(rState, cur, inst.ls, inst.cs), rState)
   end
   if (lState).n >= 0 && (solState == nothing || (lState.n + lState.len < solState.len && abs(lState.l - inst.ls) + abs(lState.c - inst.cs) + lState.len < solState.len))
     insert!(cur, getIndexHeuristique2(lState, cur, inst.ls, inst.cs), lState)
   end
   if (uState).n >= 0 && (solState == nothing || (uState.n + uState.len < solState.len && abs(uState.l - inst.ls) + abs(uState.c - inst.cs) + uState.len < solState.len))
     insert!(cur, getIndexHeuristique2(uState, cur, inst.ls, inst.cs), uState)
   end
   if (dState).n >= 0 && (solState == nothing || (dState.n + dState.len < solState.len && abs(dState.l - inst.ls) + abs(dState.c - inst.cs) + dState.len < solState.len))
     insert!(cur, getIndexHeuristique2(dState, cur, inst.ls, inst.cs), dState)
   end
   step = step + 1
 end

 #println(solState)
 #println(step)

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

