module VRPTW

import Base.push!, Base.splice!
using Revise, JLD2, JuMP, CSV, JSON, JSON3, DataFrames

# Write your package code here.
include("func.jl")
include("load_data.jl")
include("solution.jl")
include("opt_func_solution.jl")
include("optimal.jl")

# export function that clould be used
export load_solomon_data, dir, dir_data, Solution, Problem, swap!, add!, push!, splice!, empty_solution, fix_route_zero, route_length, distance, opt_balancing, find_opt, show_opt_solution, dict_to_solution, load_solution, max_completion_time_and_feasible, find_route, opt_total_com, read_optimal_solution, opt_max_com, save_csv_optimal

end
# opr0--------de