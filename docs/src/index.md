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

## Functions

```@docs
dir
```

```@repl 1
dir()
dir("data", "simulations")
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

# Solomon instances

```@eval
using CSV
using Latexify
using MDTable
df = CSV.Files(dir("data", "simulated_annealing", "distance", "SA_summary.csv"))
mdtable(df,latex=false)
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
