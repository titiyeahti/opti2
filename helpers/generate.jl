"""
Author : Dimitri Watel
Projet OPTIMISATION 2 - ENSIIE - 2020-2021
"""

@doc """
Module contenant 3 fonctions de génération d'instances du problème de tonte de gazon avec un robot.
  Il contient 3 fonctions
  - `generate(w, h, δ, minβ, maxβ)` génère une instance.
  - `generate(w, h, δ, minβ, maxβ, filename)` génère une instance et écrit le tout dans le fichier filename. 
  - `generate(filename)` renvoie l'instance décrite dans le fichier filename (généré avec la fonction précédente)

Utilisez using .Generator pour utiliser le module et son contenu dans votre code.

Utiliser ?NOM dans l'interface en ligne de commande Julia pour avoir de la documentation sur NOM.
Par exemple ?generate affiche la documetation sur les fonctions generate
""" -> 
module Generator

  export generate

  include("./problem.jl")
  import .Roombot: Instance
  using Distributions

  @doc """
  `generate(w::Int, h::Int, δ::Float64, minβ:Int, maxβ::Int)`

  - `w` >= 2
  - `h` >= 2
  - `δ` ∈ [0 ; 1]
  - `minβ` >= 1
  - `maxβ` >= `minβ`

  Prérequis : installation du paquet Distributions de Julia
  (using Pkg ; Pkg.add("Distributions"))

  Fonction de génération d'instance.

  Cette fonction génère et renvoie une instance du problème de tonte de gazon avec un robot. Le jardin est de taille `w x h`. La station est posée aléatoirement sur une case. Chaque case a ensuite une probabilité `δ` de __ne pas être un obstacle__. Toutes les cases qui ne sont pas atteignables depuis la stations sont transformées en obstacles. La valeur de la batterie est choisie aléatoirement uniformément entre `minβ` et `maxβ`. La batterie doit être suffisante pour faire l'aller retour entre la station et n'importe quel point. Si minβ et/ou maxβ ne sont pas assez grands par rapport à deux fois le plus court chemin reliant la station à un autre point, alors ils sont augmentés en conséquence.

  """ ->
  function generate(w::Int, h::Int, δ::Float64, minβ::Int, maxβ::Int)
    inst = Instance()
    
    # Paramètres de base
    inst.w = w
    inst.h = h
    
    dist_ls = Distributions.DiscreteUniform(1, h)
    dist_cs = Distributions.DiscreteUniform(1, w)
    dist_δ = Distributions.Bernoulli(δ)

    # Position de la station
    inst.ls = rand(dist_ls)
    inst.cs = rand(dist_cs)

    # Obstacles
    inst.t = [[rand(dist_δ) for c in 1:w] for l in 1:h]
    inst.t[inst.ls][inst.cs] = 1
    tovisit = [(inst.ls, inst.cs, 0)]
    max_dist = 0
    while length(tovisit) != 0
        (l, c, d) = popfirst!(tovisit)
        if inst.t[l][c] == 2
            continue
        end
        if max_dist < d
            max_dist = d
        end
        
        inst.t[l][c] = 2
    
        for (dc, dl) in [(-1, 0), (1, 0), (0, -1), (0, 1)]
            if !(1 <= l + dl <= h) || !(1 <= c + dc <= w) || inst.t[l + dl][c + dc] == 0
                continue
            end
            if inst.t[l + dl][c + dc] == 2
                continue
            end
            push!(tovisit, (l + dl, c + dc, d + 1))
        end
    end

    for l in 1:h
        for c in 1:w
            if inst.t[l][c] != 0
                inst.t[l][c] -= 1
            end
        end
    end

    # Batterie
    if minβ < 2 * max_dist
        minβ = 2 * max_dist
    end
    if maxβ < 2 * max_dist
        maxβ = 2 * max_dist
    end
    dist_β = Distributions.DiscreteUniform(minβ, maxβ)
    inst.β = rand(dist_β)
    return inst
  end

  @doc """
  `generate(w::Int, h::Int, δ::Float64, minβ:Int, maxβ::Int, filename::String)`

  - `w` >= 2
  - `h` >= 2
  - `δ` ∈ [0 ; 1]
  - `minβ` >= 1
  - `maxβ` >= `minβ`
  - `filename` est un chemin vers un fichier, existant ou non

  Prérequis : installation du paquet Distributions de Julia
  (using Pkg ; Pkg.add("Distributions"))

  Fonction de génération d'instance.

  Cette fonction génère et renvoie une instance du problème de tonte de gazon avec un robot. Le jardin est de taille `w x h`. La station est posée aléatoirement sur une case. Chaque case a ensuite une probabilité `δ` de __ne pas être un obstacle__. Toutes les cases qui ne sont pas atteignables depuis la stations sont transformées en obstacles. La valeur de la batterie est choisie aléatoirement uniformément entre `minβ` et `maxβ`. La batterie doit être suffisante pour faire l'aller retour entre la station et n'importe quel point. Si minβ et/ou maxβ ne sont pas assez grands par rapport à deux fois le plus court chemin reliant la station à un autre point, alors ils sont augmentés en conséquence.

  """ ->
  function generate(w::Int, h::Int, δ::Float64, minβ::Int, maxβ::Int, filename::String)
    inst = generate(w, h, δ, minβ, maxβ)
    open(filename, "w") do file
      write(file, "# Fichier généré avec generate.jl, avec les paramètres $w $h $δ $minβ $maxβ\n")
      write(file, "\n")
      
      # Taille de la grille
      write(file, "$(inst.w) $(inst.h)\n")
      
      # Obstacles
      for l in 1:inst.h
        for c in 1:inst.w
          write(file, "$(inst.t[l][c])")
        end
        write(file, "\n")
      end

      # Station et batterie
      write(file, "$(inst.ls) $(inst.cs) $(inst.β)")
    end 
    return inst
  end

  @doc """ 
  generate(filename::String)

  Lecture fichier de données.

  Cette fonction lit un fichier dont le chemin est `filename` et renvoie un objet de type Instance contenant les informations écrites dans le fichier.
  Le fichier doit être au format généré par la fonction `generate(w::Int, h::Int, δ::Float64, minβ::Int, maxβ::Int, filename::String)`
  - Une première ligne contenant un commentaire #
  - Une ligne vide
  - Une ligne contenant deux entiers `w` et `h`
  - `h` lignes contenant `w` entiers 0 ou 1
  - une ligne contenant 3 entiers positifs, les deux premiers respectivement entre 1 et `h` et entre 1 et `w`, séparés par des espaces
  """ ->
  function generate(filename::String)
    
    open(filename) do file
      lines = readlines(file)  # fichier de l'instance à resoudre
      
      inst = Instance()

      # Taille de la grille
      line = lines[3]
      line_decompose=split(line)
      inst.w = parse(Int64, line_decompose[1])
      inst.h = parse(Int64, line_decompose[2])

      # Lecture des obstacles
      for l in 1:inst.h
        line = lines[3 + l]
        push!(inst.t, [])
        for c in 1:inst.w
            push!(inst.t[l], parse(Int64, line[c]))
        end
      end
      
      line = lines[4 + inst.h]
      line_decompose=split(line)
      inst.ls = parse(Int64, line_decompose[1])
      inst.cs = parse(Int64, line_decompose[2])
      inst.β = parse(Int64, line_decompose[3])

      return inst
    end

  end
end
