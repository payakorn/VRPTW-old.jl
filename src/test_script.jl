
all_files = glob("*-25.json", "data/opt_solomon/opt_balancing_weighted_sum_w1_w9") .|> JSON.parsefile

all_gap = [data["relative_gap"] for data in all_files]

optimum = all_gap .<1e-3

count(optimum)