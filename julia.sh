#!/bin/bash

#SBATCH --job-name=solo         ## ชื่อของงาน
#SBATCH --output=output/VRP_%j.out    ## ชื่อไฟล์ Output (%j = Job-ID)
#SBATCH --error=output/VRP_%j.out     ## ชื่อไฟล์ error (%j = Job-ID)
#SBATCH --time=168:00:00          ## เวลาที่ใช้รันงาน
#SBATCH --partition=cpu         ## ระบุ partition ที่ต้องการใช้งาน
#SBATCH --nodes=1               # node count
#SBATCH --ntasks=1              ## จำนวน tasks ที่ต้องการใช้ในการรัน
#SBATCH --cpus-per-task=32      ## จำนวน code ที่ต้องการใช้ในการรัน
#SBATCH --mail-type=END
#SBATCH --mail-user=payakorn_sak@cmu.ac.th

# module purge                    ## unload module ทั้งหมด เพราะว่าอาจจะมีการ load module ไว้ก่อนหน้านั้น

# source $HOME/.julia/dev/VRPTW/
module load julia
module load gurobi

# srun python copy_of_atom_10_payakorn.py           ## สั่งรัน code
# srun julia --threads 32 src/script.jl           ## สั่งรัน code
# srun julia --threads 32 src/script2.jl           ## สั่งรัน code
srun julia --threads 32 src/script3.jl           ## สั่งรัน code
