#load modules
module load anaconda3/2020.02
conda activate LaurenTools
#cutadapt (Add concatenate later)
fastq_filenames=($(ls *.fastq))
for i in "${fastq_filenames[@]}"
do
  i_basename=$(basename $i .fastq)
  echo "trimming adapters from $i_basename ..."
  cutadapt -a  AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC -m 22 -o "$i_basename"_22bp.trim.fastq "$i_basename".fastq > "$i_basename"_22bp.cutadapt_log.txt
done
#mapping with bowtie2
trim_filenames=($(ls *.trim.fastq))
for i in "${trim_filenames[@]}"
do
  i_basename=$(basename $i .trim.fastq)
  echo "map to pseudomonas $i_basename ...."
  bowtie2 --end-to-end -p 16 -x "<path to referencegenomes folder>"/PAo1_pseudomonas.com -q -U "$i_basename".trim.fastq PAo1_"$i_basename".sam 2>> PAo1_"$i_basename".bowtie_output.txt
  echo "map to staph $i.basename ..."
  bowtie2 --end-to-end -p 16 -x "<path to referencegenomes folder>"/USA300_FPR3757_ncbi -q -U "$i_basename".trim.fastq SA_"$i_basename".sam 2>> SA_"$i_basename".bowtie_output.txt  
done
#mapping with metaphlan3: this loop is very basic. This code currently won't work because of two reasons 1. I can't have metaphlan in my LaurenTools, and it's not even installed on pace yet, and when it is it will be in a different envirionment. 2. I would have to change the path manually every time becuase folders in my scratch are organized by projects (I guess an easy fix to that would be to put all the files into projects later after the run, but if I'm doing multiple runs at a time this is not ideal).#####
#for i in "${trim_filenames[@]}"
#do
  #i_basename=$(basename $i .trim.fastq)
  #echo "metaphlan analysis of $i_basename ...."
  #metaphlan "$i_basename".trim.fastq --input_type fastq --nproc 14 --read_min_len 22 --bowtie2db /storage/home/hcoda1/4/lwhiteley3/scratch > "$i_basename".bact_euk_profile.txt
#done
#featureCounts
PAo1_sam_filenames=($(ls PAo1*.sam))
for i in "${PAo1_sam_filenames[@]}"
do
  i_basename=$(basename $i .sam)
  echo "counting features Pseudomonas $i_basename ..."
  "<path to featureCounts>"featureCounts -a "<path to referencegenomes folder>"/Pseudomonas_aeruginosa_PAO1_107.gff3 -g locus -t CDS -o featurecounts_"$i_basename".txt "$i_basename".sam                                   
done
SA_sam_filenames=($(ls SA*.sam))
for i in "${SA_sam_filenames[@]}"
do
  i_basename=$(basename $i .sam)
  echo "counting features Staph $i_basename ..."
  "<path to featureCounts>"/featureCounts -a "<path to referencegenomes folder>"/USA300_FPR3757_genomic.gff3 -g Parent -t CDS -o featurecounts_"$i_basename".txt "$i_basename".sam
done
"<path to featureCounts"/featureCounts -a "<path to referencegenomes folder>"/USA300_FPR3757_genomic.gff3 -g Parent -t CDS -o featurecounts_SA_summary_MW14.txt SA*.sam.sam
"<path to featureCounts>"/featureCounts -a "<path to referencegenomes folder>"referencegenomes/Pseudomonas_aeruginosa_PAO1_107.gff3 -g locus -t CDS -o featurecounts_PA_summary_MW14.txt PAo1*.sam
source "<path to your script folder>"/PA_coveragecalculation.sh
source "<path to your script folder>"/SA_coveragecalculation.sh
python3 "<path to your script folder>"/PA_coverageScript.py
python3 "<path to your script folder>"/SA_coverageScript.py
#python3 "<path to your script folder>"/PA_csvConversion.py
#python3 "<path to your script folder>"/SA_csvConversion.py
