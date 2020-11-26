
ALGORITHMSSRC=$(wildcard algorithm_*.jl)

.PHONY:archive
archive:
	tar cvzf code.tar.gz $(filter-out algorithm_0.jl algorithm_example.jl algorithm_lpexample.jl, $(ALGORITHMSSRC)) customlibs others
