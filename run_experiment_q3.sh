#! /bin/bash
  
# you will not have to change the SBATCH parameters
#SBATCH -p q_student
#SBATCH -N 1
#SBATCH -c 32
#SBATCH --cpu-freq=High
#SBATCH --time=5:00

# modify parameters accordingly
NPROCS=(32)
#NPROCS=(1)
SIZE=(1000)
#SIZE=(200)
PATCH=(1 10 30 200 500)
NREP=3
BINARY="python ./julia_par.py"


OUTFILE="output_exp_q3.dat"

# remove old output data
echo -n "" > "${OUTFILE}"

for nprocs in "${NPROCS[@]}"
do
   for size in "${SIZE[@]}"
   do
      for patch in "${PATCH[@]}"
      do
         for r in `seq 1 ${NREP}`
         do
            echo "${BINARY} --nprocs $nprocs --size $size --patch $patch"
            ${BINARY} --nprocs $nprocs --size $size --patch $patch >> "${OUTFILE}"
         done
      done
   done
done
