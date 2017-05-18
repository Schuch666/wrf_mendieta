#!/bin/bash

##############################################################################################
### How to run:
### sbatch job_wrf_3_nodes.sh A_Thompson_MYJ 2016-09-28_18:00:00 2016-09-30_06:00:00
### 

#################################### Slurm configuration #####################################

### Samples of job scripts in /usr/share/doc/mendieta/
 
#SBATCH --mail-type=ALL
#SBATCH --mail-user=andreslighezzolo@gmail.com
#SBATCH --job-name=WRF
#SBATCH --partition=multi
#SBATCH --exclusive

#SBATCH --nodes=3
#SBATCH --ntasks-per-node=20

### Execution Time. Format: days-hours:minutes. Max time: Four days.
#SBATCH --time 0-2:30


### Environment setup
. /etc/profile
################################# WRF Configuration ###################################


./run_wrf_model.sh $1 $2 $3 3

