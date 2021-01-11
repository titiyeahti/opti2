#!/bin/bash

julia helpers/tester.jl algorithm_1.jl tests/$1/ > data/$1.dat

