# VRPTW.jl

Documentation for VRPTW.jl

```@contents
Depth = 3
```

## Index

```@index
```


# To start
To load the package use the code 

```@repl 1
using VRPTW
```

## Struct

There are 2 structs using in this project: `Problem` and `Solution`. 

- The `Problem` is used to defind the attributes in the problem including, name of problem, number of nodes, number of vehicles, the maximum number of vehicles, etc.
- The `Solution` is used for storing the solution of `Problem`

```@docs
Problem
```
```@docs
Solution
```
### Examples

To create the problem struct, 
```@repl 1
num_node = 5;
distance_matrix = [
    0.0 1.0 2.0 3.0 4.0 5.0;
    1.0 0.0 2.0 3.0 4.0 5.0;
    2.0 1.0 0.0 3.0 0.0 5.0;
    3.0 3.0 3.0 0.0 0.0 0.0;
    4.0 5.0 6.0 3.0 0.0 0.0;
    4.0 5.0 6.0 3.0 4.0 0.0;
];
demand = [0, 1, 3, 4, 5, 6];
lower_time_window = [0, 0, 0, 0, 0, 0];
upper_time_window = [100, 50, 50, 50, 50, 50];
depot_time_window = 100;
service_time = [0, 10, 10, 10, 10, 10, 10];
vehicle_capacity = 1000;
max_vehi = 15;
ins = Problem("test", 
        num_node, 
        distance_matrix, 
        demand, 
        lower_time_window, 
        upper_time_window, 
        depot_time_window, 
        service_time, 
        vehicle_capacity, 
        max_vehi)
```

To create `Solution` struct. We have to input route into the struct. The route must in the form of `Array` and 0 is used to seperate the route and the first and the last element in route must be 0.

For example,
```@repl 1
route = [0, 1, 2, 3, 4, 0];
sol = Solution(route, ins)
```

If there are more than one route,
```@repl 1
route = [0, 1, 2, 3, 4, 0, 5, 6, 7, 0];
sol = Solution(route, ins)
```

## sent email
```@repl 1
methods(sent_email)
```


# Solomon's instance

The Solomon's instance is used for simulating in this project. The Solomon's instance can be divided into 3 classes; clustered, Random, and Random clustered. 

There are 56 instances in Solomon's benchmark which are stored in the variable `ins_names`
```@repl 1
ins_names
```

The Solomon's instance can be divided into 3 classes; clustered (`C1, R2`), Random (`R1, R2`), and Random clustered (`RC1, RC2`). 
```@repl 1
R1
```
## Functions

```@docs
dir
```

```@repl 1
dir()
dir("../ResultsVRPTW", "simulations")
```

```@docs
load_solomon_data
```

```@repl 1
load_solomon_data("c101", num_node=100, max_vehi=25)
```

```@docs
fix_route_zero
```
### Example for `fix_route_zero`
```@repl 1
route = [0, 1, 2, 3, 0, 0, 4, 5, 0, 0]
fix_route_zero(route)
```
# Solomon instances

```@eval
using CSV
using VRPTW
using DataFrames
using Latexify
df = CSV.File(dir("../ResultsVRPTW", "simulated_annealing", "distance", "SA_summary.csv")) |> DataFrame
mdtable(df,latex=false)
```


### load solution from simulation 

```@repl 1 
methods(load_solution)
```

Example load solution of instance C101 which minimizing total distance
```@repl 1
solution = load_solution("C101", 100, distance)
```

To calculate (total distance, total completion time, ...) => there are 2 ways
```@repl 1
distance(load_solution("C101", 100, distance))
```
```@repl 1
total_comp(load_solution("C101", 100, distance))
```
```@repl 1
max_comp(load_solution("C101", 100, distance))
```
Or, use the piping options
```@repl 1
load_solution("C101", 100, distance) |> distance
```
```@repl 1
load_solution("C101", 100, distance) |> total_comp
```
```@repl 1
solution |> max_comp |> sum
```


# Description

VRPTW stands for Vehicle Routing Problem with Time Windows. It is a variant of the classic Vehicle Routing Problem (VRP) that takes into account time constraints.

## Variables and parameters using in VRPTW

| variable, parameter | using in program | description                                                          |
| :-----------------: | ---------------- | -------------------------------------------------------------------- |
|        $s_j$        | service          | service time of node $j$                                             |
|         $n$         |                  | number of nodes                                                      |
|         $k$         |                  | number of vehicles                                                   |
|         $N$         |                  | $=\{0, 1, 2, 3, \dots, n\}$                                          |
|         $K$         |                  | $=\{1, 2, 3, 4, \dots, m\}$                                          |
|        $a_j$        | low_d            | avaiable starting time for node $j$                                  |
|        $b_j$        | d                | latest starting time for node $j$                                    |
|      $d_{ij}$       | distance_matrix  | distance from node $i$ to node $j$                                   |
|        $q_j$        | demand           | demand of node $j$                                                   |
|         $Q$         | solomon_demand   | max caryying capacity                                                |
|     $x_{ij}^k$      |                  | = 1 when vehicle $k$ travel from node $i$ to node $j$, = 0 otherwise |
|        $u_i$        |                  | cumulative demand from depot node to node $i$                        |

## VRPTW to minimize total distance

The goal of the VRPTW is to find the most efficient set of routes for the vehicles to visit all the customers within their respective time windows, while minimizing the total distance traveled and the number of vehicles used. This problem is highly relevant in logistics and transportation management, as it helps optimize delivery routes and scheduling.

## Optimization Model

The model is wriiten in function `opt_total_dis` in the file `optimal.jl`

```math
\min \sum_{i,j\in N, k\in K}d_{ij}x_{ij}^k 
```

```math
 \sum_{j\in N\setminus\{0\}} x_{0j}^k=1, \quad \forall k\in K
```

```math 
\sum_{i\in N\setminus\{0\}} x_{i0}^k=1, \quad \forall k\in K 
```

```math 
\sum_{i\in N, k\in K} x_{ij}^k=1, \quad \forall j\in N\setminus\{0\} 
```

```math
 \sum_{j\in N, k\in K} x_{ij}^k=1, \quad \forall i\in N\setminus\{0\} 
```

```math 
\sum_{i\in N, i\neq j} x_{ij}^k - \sum_{v\in N, j\neq v} x_{jv}^k=0, \quad \forall j\in N\setminus\{0\}, \forall k\in K
```

```math
t_i + d_{ij} + s_i + M(1-x_{ij}^k) \leq t_j, \qquad\forall i,j\in N, \forall k\in K, i\neq j
```

```math
u_i-u_j+q_i\leq Q(1-x_{ij}^k),\qquad\forall i,j\in N, \forall k\in K, i\neq j
```

```math
x_{ij}^k\in \{0,1\},\qquad\forall i,j\in N, \forall k\in K, i\neq j
```

```math
q_i\leq  u_i\leq Q,\qquad\forall i\in N
```

---

## VRPTW to minimize total completion time 

The goal of the VRPTW is to find the most efficient set of routes for the vehicles to visit all the customers within their respective time windows, while minimizing the total completion time. The total completion time is used as the objective function for scheduling problem instead of using in vehicle routing problem. This objective will improve the total waiting time in the system.

Obviously, the minimum total completion time is the solution that the number of vehicles must equal to the number of nodes, therefore in this case, we have to limit the number of vehicles used in the system to prevent this. 

### Additional parameters and veriables

| variable, parameter | using in program | description                 |
| :-----------------: | ---------------- | --------------------------- |
|       $c_{i}$       |                  | completion time of node $i$ |


### Optimization model

The model is wriiten in function `opt_total_comp` in the file `optimal.jl`

```math
   \min \sum_{i\in N} c_j
```

```math 
    \sum_{j\in N\setminus\{0\}} x_{0j}^k=1, \quad \forall k\in K
```

```math
    \sum_{i\in N\setminus\{0\}} x_{i0}^k=1, \quad \forall k\in K 
```

```math
    \sum_{i\in N, k\in K} x_{ij}^k=1, \quad \forall j\in N\setminus\{0\} 
```

```math
    \sum_{j\in N, k\in K} x_{ij}^k=1, \quad \forall i\in N\setminus\{0\} 
```

```math
    \sum_{i\in N, i\neq j} x_{ij}^k - \sum_{v\in N, j\neq v} x_{jv}^k=0, \quad \forall j\in N\setminus\{0\}, \forall k\in K 
```

```math
    t_i + d_{ij} + s_i + M(1-x_{ij}^k) \leq t_j, \qquad\forall i,j\in N, \forall k\in K, i\neq j
```

```math
    u_i-u_j+q_i\leq Q(1-x_{ij}^k),\qquad\forall i,j\in N, \forall k\in K, i\neq j
```

```math
    t_j + s_j \leq c_j,\qquad\forall j\in N
```

```math
    x_{ij}^k\in \{0,1\},\qquad\forall i,j\in N, \forall k\in K, i\neq j
```

```math
    q_i\leq  u_i\leq Q,\qquad\forall i\in N
```
