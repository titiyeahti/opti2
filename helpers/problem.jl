"""
Author : Dimitri Watel
Projet OPTIMISATION 2 - ENSIIE - 2020-2021
"""

@doc """
Module contenant les types relatifs aux instances et aux solutions du problème de tonte de gazon avec un robot.
Il contient les types, constantes et les fonctions suivants:

- Instance
- Solution
- LEFT
- RIGHT
- UP
- DOWN
- valid
- neighbors
- shp
- push
- push_left
- push_right
- push_up
- push_down
- push_to
- pop
- robot_position
- robot_battery
- uncovered
- check_cover
- soltime
- print_moves

Utilisez using .Roombot pour utiliser le module et son contenu dans votre code. Ceci est déjà fait dans le
fichier ../main.jl, donc si, dans votre code, vous incluez ce fichier (ce qui est normalement le cas de tous
les fichiers décrivant un algorithme), vous n'avez pas besoin d'inclure .Roombot à votre code.

Utiliser ?NOM dans l'interface en ligne de commande Julia pour avoir de la documentation sur NOM.
Par exemple ?Instance affiche la documentation sur le type Instance


""" -> 
module Roombot

  export Instance, Solution, LEFT, RIGHT, UP, DOWN, valid, neighbors, shp, push, push_left, push_right, push_up, push_down, push_to, pop, robot_position, robot_battery, uncovered, check_cover, soltime, print_moves

  @doc """
  Constante (0, -1) de déplacement à gauche : vers une colonne inférieure
  """ ->
  LEFT = (0, -1)
  
  @doc """
  Constante (0, 1) de déplacement à droite : vers une colonne supérieure
  """ ->
  RIGHT = (0, 1)
  
  @doc """
  Constante (-1, 0) de déplacement en haut : vers une ligne inférieure
  """ ->
  UP = (-1, 0)
  
  @doc """
  Constante (1, 0) de déplacement en bas : vers une ligne supérieure
  """ ->
  DOWN = (1, 0)

  @doc """
  Type représentant une entrée du problème de tonte de gazon avec un robot.

  Il contient 6 attributs:
  - `w` : le nombre de colonnes du jardin
  - `h` : le nombre de lignes du jardin
  - `t` : un tableau 2D de `w x h` entiers, `t[l][c]` vaut 1 si la case située sur la ligne `l` et la colonne `c` doit être tondue et 0 s'il s'agit d'un obstacle sur lequel le robot ne doit pas aller.
  - `cs` : la colonne, entre `1` et `w`, où se trouve la station de rechargement du robot. Cette station est la première position du robot.
  - `ls` : la ligne, entre `1` et `h`, où se trouve la station de rechargement du robot. Cette station est la première position du robot.
  - `β` : la nombre de cases que peut parcourir le robot avant que sa batterie ne soit vide. Si la batterie est vite, le robot doit se trouver sur la station de rechargement, sinon il ne bougera plus.
  Il n'est pas nécessaire de construire vous même les entrées.
  Utilisez le fichier generate.jl pour cela.

  Quelques fonctions d'aides vous sont fournies avec l'instances:
  - `valid(inst::Instance, l::Int, c::Int)` vérifie si la case ligne `l` et colonne `c` est un obstacle ou en dehors du jardin.
  - `neighbors(inst::Instance, l::Int, c::Int)` renvoie la liste des cases adjacentes à la case de la ligne `l` et de la colonne `c` qui ne sont pas des obstacles. 
  - `shp(inst::Instance, l1::Int, c1::Int, l2::Int, c2::Int)` renvoie un plus court chemin entre la case de la ligne `l1` et colonne `c1`, vers la case de la ligne `l2` et colonne `c2`.
  """
  mutable struct Instance
    w::Int # nbre colonnes
    h::Int # nbre lignes
    t::Array{Array{Int}} # matrice indiquant, pour chaque case du jardin si la case doit être tondue (la case est un 1) ou non (la case est un 0)
    ls::Int # Ligne de la station de rechargement
    cs::Int # Colonne de la station de rechargement
    β::Int # Durée de la charge de la batterie du robot

  end
  Instance() = Instance(0, 0, [], 0, 0, 0) # Constructeur par défaut

  @doc """
  `valid(inst::Instance, l::Int, c::Int)`

  Renvoie  vrai si la case ligne `l` et colonne `c` de l'instance n'est ni un obstacle ni en dehors du jardin.
  """ ->
  function valid(inst, l::Int, c::Int)
    return (1 <= l <= inst.h) && (1 <= c <= inst.w) && inst.t[l][c] == 1
  end


  @doc """
  `neighbors(inst::Instance, l::Int, c::Int)`
  
  Renvoie la liste des cases voisines de la case ligne `l` et colonne `c` qui ne sont pas des obstacles et qui sont dans le jardin.
  A chaque case est associée le mouvement pour aller sur cette case. Ainsi, la liste contient des triplets (ligne, colonne, mouvement).
  Le mouvement lui-même est un couple de deux entiers.
  """ ->
  function neighbors(inst, l::Int, c::Int)
    neighb = []

    for (dl, dc) in [LEFT, RIGHT, UP, DOWN]
        nl = l + dl
        nc = c + dc
        if valid(inst, nl, nc)
            push!(neighb, (nl, nc, (dl, dc)))
        end
    end
    return neighb
  end
  
  
  @doc """
  `shp(inst::Instance, l1::Int, c1::Int, l2::Int, c2::Int)`
  
  Renvoie un plus court chemin dans l'instance entre la case ligne `l1` et colonne `c1` et la case ligne `l2` et colonne `c2`. 
  Si ces cases sont en dehors du jardin ou des obstacles, le chemin est vide. 
  Les mouvements sont tous élémentaires (déplacement à gauche, à droite, en haut ou en bas).

  L'algorithme utilisé est Dijkstra. Si le besoin se fait sentir, vous pouvez le recoder sous forme d'un algorithme A*.
  """ ->
  function shp(inst, l1::Int, c1::Int, l2::Int, c2::Int)

    if !valid(inst, l1, c1) || !valid(inst, l2, c2)
        return []
    end

    tovisit = [(l1, c1, [])]
    visited = Set()

    while length(tovisit) != 0
        l, c, moves = popfirst!(tovisit)
        
        if (l, c) in visited
            continue
        end
        push!(visited, (l, c))

        if l == l2 && c == c2
            return moves
        end

        for (nl, nc, move) in neighbors(inst, l, c)
            if (nl, nc) in visited
                continue
            end
            mcp = copy(moves)
            push!(mcp, move)
            push!(tovisit, (nl, nc, mcp))
        end
    end
    return []
  end

  @doc """
  Type représentant une solution du problème de tonte de gazon avec un robot.

  Il contient 2 attributs:
  - `inst` est une instance dont cet objet est la solution
  - `moves` est une liste d'entiers, `moves[i]` est le ie movement du robot. Ce mouvement doit indiquer au robot d'aller à gauche, droite, haut ou bas, autrement dit, respectivement, se déplacer vers une colonne immédiatement inférieure, immédiatement supérieure, ou une ligne immédiatement inférieure ou immédiatement supérieure.
  
  Vous n'avez pas à construire une solution à la main. Vous pouvez utiliser 6 fonctions pour cela:
  - `Solution(inst::Instance)` qui construit une solution vide
  - `push(sol::Solution, move::Tuple{Int64, Int64})` qui déplace le robot sur la grille selon le mouvement indiqué
  - `push_left(sol::Solution)` qui déplace le robot sur la grille vers la gauche (colonne inférieure)
  - `push_right(sol::Solution)` qui déplace le robot sur la grille vers la droite (colonne supérieure)
  - `push_up(sol::Solution)` qui déplace le robot sur la grille vers le haut (ligne inférieure)
  - `push_down(sol::Solution)` qui déplace le robot sur la grille vers le bas (ligne supérieure)
  - `push_to(sol::Solution, l::Int, c::Int)` qui déplace le robot sur la grille jusqu'à la case de la ligne `l` et de la colonne `c` en utilisant un plus court chemin.
  - `pop(sol::Solution)` pour supprimer le dernier mouvement du robot
  
  Il est fortement déconseillé de manipuler `sol.moves` à la main. Ces fonctions font des vérifications en cours de route. Si un déplacement vous envoie dans un obstacle, ou si la batterie est vide, le robot ne se déplacera pas. Les fonctions renvoie une exception en cas d'erreur. Dans ce cas, la solution reste inchangée.

  Vous pouvez enfin utiliser `soltime(sol::Solution)` pour obtenir la durée (en nombre de mouvements) de votre solution et `uncovered(sol::Solution)` et  `check_cover(sol::Solution)` pour savoir si la suite des mouvements a bien permi de tondre le gazon et de revenir à la position initiale.
  """
  mutable struct Solution
    inst
    moves::Array{Tuple{Int64,Int64}} # Liste des mouvements du robot
    __positions::Array{Tuple{Int64,Int64}} # Lignes et colonnes où se trouve le robot au cours de son mouvement
    __b::Array{Int64} # Liste des charges de batterie du robot au cours de son mouvement
  end


  @doc """
  `Solution(inst::Instance)`

  Construit une solution vide pour l'instance inst.
  Vous n'avez normalement pas besoin d'appeler cette fonction, vos algorithmes reçoivent en entrée une solution déjà initialisée avec cette fonction.
  """ ->
  function Solution(inst)
      return Solution(inst, [], [(inst.ls, inst.cs)], [inst.β])
  end

  @doc """
  `push(sol::Solution, move::Tuple{Int64, Int64})`

  Ajoute le mouvement `move` à la liste des mouvements du robot. Cette fonction est à votre disposition si vous en avez besoin. Vous pouvez préférer utiliser `push_left`, `push_right`, `push_up`, `push_down` et `push_to` à la place.

  Une exception est envoyée si ce mouvement envoie le robot dans un obstacle ou en dehors du jardin, si la batterie du robot est vide ou si le mouvement n'est pas un mouvement de type gauche, droite, haut ou bas. Soit respectivement (-1, 0), (1, 0), (0, -1) ou (0, 1).
  Si le robot rejoint la station, sa batterie est pleinement rechargée. 
  """ ->
  function push(sol, move::Tuple{Int64, Int64})
      if !(move in [LEFT, RIGHT, UP, DOWN])
          throw(DomainError(move, "`move` doit être un déplacement vers la gauche, la droite, le haut ou le bas. Soit respectivement (-1, 0), (1, 0), (0, -1) ou (0, 1)."))
      end

      nbmoves = length(sol.moves)
      lr, cr = sol.__positions[nbmoves + 1]
      βr = sol.__b[nbmoves + 1]

      if (βr == 0)
          throw(ErrorException("La batterie du robot ne doit pas être vide quand celui-ci se déplace."))
      end

      dl, dc = move
      l = lr + dl
      c = cr + dc

      if !valid(sol.inst, l, c)
          throw(ErrorException("Le mouvement ne doit pas envoyer le robot sur un obstacle ou en dehors du jardin."))
      end

      push!(sol.__positions, (l, c))
      push!(sol.moves, move)

      if l == sol.inst.ls && c == sol.inst.cs
        push!(sol.__b, sol.inst.β)
      else
        push!(sol.__b, βr - 1)
      end
  end

  @doc """
  `push_left(sol::Solution)`

  Ajoute un déplacement à gauche (vers la colonne inférieure) à la liste des mouvements du robot.
  Une exception est envoyée si ce mouvement envoie le robot dans un obstacle ou en dehors du jardin ou si la batterie du robot est vide
  Si le robot rejoint la station, sa batterie est pleinement rechargée. 
  """ ->
  function push_left(sol)
    push(sol, LEFT)
  end

  @doc """
  `push_right(sol::Solution)`

  Ajoute un déplacement à droite (vers la colonne supérieure) à la liste des mouvements du robot.
  Une exception est envoyée si ce mouvement envoie le robot dans un obstacle ou en dehors du jardin ou si la batterie du robot est vide
  Si le robot rejoint la station, sa batterie est pleinement rechargée. 
  """ ->
  function push_right(sol)
    push(sol, RIGHT)
  end
  
  @doc """
  `push_up(sol::Solution)`

  Ajoute un déplacement en haut (vers la ligne inférieure) à la liste des mouvements du robot.
  Une exception est envoyée si ce mouvement envoie le robot dans un obstacle ou en dehors du jardin ou si la batterie du robot est vide
  Si le robot rejoint la station, sa batterie est pleinement rechargée. 
  """ ->
  function push_up(sol)
    push(sol, UP)
  end
  
  @doc """
  `push_down(sol::Solution)`

  Ajoute un déplacement en bas (vers la ligne supérieure) à la liste des mouvements du robot.
  Une exception est envoyée si ce mouvement envoie le robot dans un obstacle ou en dehors du jardin ou si la batterie du robot est vide
  Si le robot rejoint la station, sa batterie est pleinement rechargée. 
  """ ->
  function push_down(sol)
    push(sol, DOWN)
  end

  @doc """
  `push_to(sol::Solution, l::Int64, c::Int64)`

  Calcule un plus court chemin entre la position actuelle du robot et la case ligne `l` et colonne `c`, puis ajoute tous les mouvements de ce chemin
  à la liste des mouvements du robot.
  Une exception est envoyée si ce mouvement envoie le robot dans un obstacle en dehors du jardin ou si la batterie du robot se vide en cours de route. 
  Si le robot rejoint la station en cours de chemin, sa batterie est pleinement rechargée. 
  """ ->
  function push_to(sol, l::Int64, c::Int64)
      if !valid(sol.inst, l, c)
          throw(ErrorException("Le mouvement ne doit pas envoyer le robot sur un obstacle ou en dehors du jardin."))
      end

      lr, cr = robot_position(sol)
      path = shp(sol.inst, lr, cr, l, c)
      nbmoves = 0
      for move in path
          try
            push(sol, move)
            nbmoves += 1
          catch e
            for i in 1:nbmoves
                pop(sol)
            end
            throw(e)
          end
      end
  end

  @doc """
  `robot_position(sol::Solution)`

  Renvoie la position du robot à l'issue de tous les mouvements effectués. Avant le premier mouvement, le robot est placés sur la station de recharge.
  """ ->
  function robot_position(sol)
      nbmoves = length(sol.moves)
      return sol.__positions[nbmoves + 1]
  end
  
  @doc """
  `robot_battery(sol::Solution)`

  Renvoie la charge de batterie du robot à l'issue de tous les mouvements effectués. Avant le premier mouvement la batterie est complètement chargée.
  """ ->
  function robot_battery(sol)
      nbmoves = length(sol.moves)
      return sol.__b[nbmoves + 1]
  end

  @doc """
  `pop(sol::Solution)`

  Annule le dernier mouvement effectué par le robot. Si celui ci n'a effectué aucun mouvement, il ne se passe rien.
  """ ->
  function pop(sol)
      if length(sol.moves) == 0
        return
      end
      pop!(sol.moves)
      pop!(sol.__positions)
      pop!(sol.__b)
  end
  
  @doc """
  `uncovered(sol::Solution)`

  Renvoie un tableau u de taille `sol.inst.h x sol.inst.w` avec u[l][c] = 1 si la case de la ligne l et colonne c doit être couverte mais n'a pas été couverte par la solution.
  """ ->
  function uncovered(sol)
    lr, cr = robot_position(sol)
    u = [[(sol.inst.t[l][c]) for c in 1:sol.inst.w] for l in 1:sol.inst.h]
    for (l, c) in sol.__positions
        u[l][c] = 0
    end
    return u
  end

  @doc """
  `check_cover(sol::Solution)`

  Renvoie vrai si les mouvements du robot couvrent toute les cases à tondre et s'il est retourné sur la base
  et faux sinon.
  """ ->
  function check_cover(sol)
    lr, cr = robot_position(sol)
    if lr != sol.inst.ls || cr != sol.inst.cs
        return false
    end
    u = uncovered(sol)
    return all(u[l][c] == 0 for c in 1:sol.inst.w for l in 1:sol.inst.h)
  end

  @doc """
  `time(sol::Solution)`

  Renvoie le nombre de mouvements effectués par le robot.
  """ ->
  function soltime(sol)
      return length(sol.moves)
  end

  @doc """
  `print_moves(sol::Solution)`

  Affiche tous les mouvements effectués par le robot, au format L, R, U, D, pour gauche, droite, haut et bas. Apr_s chaque mouvement, affiche un saut de ligne si le robot a rejoint la station et un espace sinon. 
  """ ->
  function print_moves(sol)
      for (move, position) in zip(sol.moves, sol.__positions[2:length(sol.__positions)])
        l, c = position
        
        if move == LEFT
            print("L")
        elseif move == RIGHT
            print("R")
        elseif move == UP
            print("U")
        elseif move == DOWN
            print("D")
        end
        
        if l == sol.inst.ls && c == sol.inst.cs
            println()
        else
            print(' ')
        end

      end
  end

end




