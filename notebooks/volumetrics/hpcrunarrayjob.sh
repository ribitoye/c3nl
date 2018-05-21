#!/bin/sh

Usage() {
cat <<EOF
   ___________ _   ____
  / ____|__  // | / / /
 / /     /_ </  |/ / /
/ /___ ___/ / /|  / /___
\____//____/_/ |_/_____/ Imperial College London

hpcrunarrayjob, v.0.1
n.bourke@imperial.ac.uk, gregory.scott99@imperial.ac.uk

Usage: hpcrunarrayjob <commands.txt> <walltime> <ncpus> <memory>
e.g. hpcrunarrayjob commands.txt 01:00:00 1 8Gb

Executes each line of a text file as separate tasks in a PBSPRO array job.

+-------------------------------------+
| Rough guide to resource allocation: |
|                                     |
| Light Job    01:00:00 1 8Gb         |
| Medium Job   12:00:00 1 8Gb         | 
| Heavy Job    24:00:00 1 8Gb         |
| V.heavy Job  48:00:00 1 8Gb         |
+-------------------------------------+

Other tips:
- Max walltime is 72:00:00.
- Greater resources (memory, number of CPUs) will delay the start of your jobs
- Most neuroimaging software will not go above 8Gb of memory. If thinking of going above this, check that it is actually required.
- Can your process use more than 1 CPU? If it can and you dont ask for >1, your job can be killed. If it doesnt, dont increase this number as it will also slow job allocation.
EOF
exit 1
}

if [  $# -lt 4 ];
  then
  Usage
  exit 1
fi

if [ $# -eq 4 ];
  then
  input=$1
  walltime=$2
  ncpus=$3
  mem=$4

  echo "Walltime = $walltime"
  echo "Number of CPUs = $ncpus"
  echo "Memory = $mem"
  
  # Get number of jobs from command file
  NUMJOBS=`wc -l < $input`; 
  
  input_copy="$HOME/$$.$RANDOM.txt"
  cp ${input} ${input_copy}

    # Setup pbs submission file and execute it
    pbsfile=`mktemp`;
    echo "#!/bin/sh" > $pbsfile;
    echo "#PBS -l walltime=${walltime}" >> $pbsfile;
    echo "#PBS -l select=1:ncpus=${ncpus}:mem=${mem}" >> $pbsfile;
    echo "#PBS -J 1-${NUMJOBS}" >> $pbsfile;
    echo "cmd=\`sed \"\${PBS_ARRAY_INDEX}q;d\" ${input_copy}\`" >> $pbsfile;
    echo "PATH=${PATH}:`pwd`" >> $pbsfile;
    echo "eval \${cmd}" >> $pbsfile;

    echo "PBS file = "
    echo ${pbsfile}
  
    echo "PBS job id = "
    qsub ${pbsfile}
fi