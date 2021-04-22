###load modules: for thor, make sure to "conda activate metaphlan3" before running the script###
###Ask for project name so we're in the right directory###
echo "Enter project name"
read projectname
cd "<path to project folders>"/"$projectname"
mapping with metaphlan
trim_filenames=($(ls *.trim.fastq))
for i in "${trim_filenames[@]}"
do
	i_basename=$(basename $i .trim.fastq)
	echo "metaphlan analysis of $i_basename ...."
	metaphlan "$i_basename".trim.fastq --input_type fastq --nproc 14 --read_min_len 22 --bowtie2db "<path to project folders>"/"$projectname" > "$i_basename".bact_euk_profile.txt
done
#merging files into a table: I don't know how useful this will be. Add it if you want, but it requires you to download "merge_metaphlan_tables.py" from the metaphlan github.
#python3 "<path to metaphlan merge script>"/merge_metaphlan_tables.py *bact_euk_profile.txt > "<path to project folders>"/"$projectname"/"$projectname"_merged_abundance_table.txt
