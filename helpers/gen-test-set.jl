include("./generate.jl")

function testGen(path::String)
  sample = 10
  size_list = [(2,12), (3,8), (4,6), (2,18), (3,12), (4,9), (6,6)]
  density_list = [0.5, 0.6, 0.7, 0.8, 0.9, 1]
  bat_list = [1, 72]

  for (i, j) in size_list
    for d in density_list
      for b in bat_list
        for k in 1:sample
          s = string(path, i, "x", j, "/_", d, "_", b, "_", k)

          Generator.generate(i, j, d, b, b, s)
        end
      end
    end
  end
end


testGen("../tests/")
