module VRPTW

import Base.push!, Base.splice!
using Revise, JLD2, JuMP, CSV, JSON, JSON3, DataFrames, Combinatorics, Shuffle, Glob

# Write your package code here.
include("func.jl")
include("load_data.jl")
include("solution.jl")
include("opt_func_solution.jl")
include("optimal.jl")
include("simulated_annealing.jl")

# export function that clould be used
export load_solomon_data, dir, dir_data, Solution, Problem, swap!, add!, push!, splice!, empty_solution, fix_route_zero, route_length, distance, opt_balancing, find_opt, show_opt_solution, dict_to_solution, load_solution, max_completion_time_and_feasible, find_route, opt_total_com, read_optimal_solution, opt_max_com, opt_total_dis, opt_total_dis_compat, save_simulation_file, max_comp, total_comp, total_max_comp, inserting, seperate_route, check_time_window_capacity, feasibility, inserting_procedure, swapping_procedure, load_solution_phase1, load_solution_phase2, load_solution_phase3, ins_names, create_phase_conclusion, obj_value, move!, moving_procedure, simulated_annealing, print_route, cross_over, opt_procedure

end
# opr0--------de