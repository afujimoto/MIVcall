# *MIVcall*

A software to indetify indels in microsatellte regions

Overview
1. Extract reads covering microsatellte regions from a bam file
2. Analyze repeat length 
3. Calculate likelihood using an error rate matrix, and identify indels in microsatellte regions

## Requirement
samtools (0.1.18 or higher)

perl (4 or higher)

python3

## Input file format
**bam file**; Sorted bam. (index file for bam (.bai) is required.)


**microsatellte region file**; List of microsatellte (tab-separated text or .gz file). Microsatellte region files are provided. User defined microsatellte lists can be used. 

\<chr\> \<start\> \<end\> \<repeat unit of microsatellte\>  
22      17283835        17283839        A  
22      17283968        17283981        AT  


**reference genome file**; Fasta file of reference genome (index file for samtools is required.)


**parm.conf file**; Parameter for microsatellte calling (optional)


## Output file format
\<chr\> \<start\> \<end\> \<repeat unit of microsatellte\> \<Sequence of microsatellte> \<number of reads with length of microsatellte (length;number of reads)\> \<genotype\> \<calling information (2nd major allele, number of reads, varinat allele frequency)\>  
22      17282432        17282438        (A)n    AAAAAAA 7;44    7/7     -  
22      17282577        17282589        (A)n    AAAAAAAAAAAAA   13;24,14;3      13/14   minor_alelle=14;L=-3.03;Number=3;VAF=0.11 


## Usage
cd \<path to MIVcall\>

perl RUN_MIV_CALL.pl -BAM \<Bam\> -REF \<Reference.fas\> -OUT \<Output file name\> -MS \<Microsatellte region file\> -CONF \<Configuration file (Optional)\>

## Example
git clone git@github.com:afujimoto/MIVcall.git

cd MIVcall

perl RUN_MIV_CALL.pl -BAM \<Path to bam file\> -REF \<Path to reference.fas\> -OUT \<Output file name\> -MS \<Microsatellte region file\> -CONF \<Configuration file (Optional)\>


## Parameter setting in configuration file
We consider that the patemeter set of the provided configuration file is an apprppreate ones for 30x coverage WGS data. If you want to use different parameters, please change configration file.

\##READ SELECTION PRMS##  
mq_cutoff; Minimum mapping quality for reqd selection  
len_cutoff1; Minimum distance between paired reads  
len_cutoff2; Maxmum distance between paired reads  
flanking_len_cutoff; Minimum flanking length  
S_length_cutoff; Minimum softclip length  
q_score_cutoff; Minimum average qility score of flanking region  
match; Match score  
mismatch; Mismatch score  
SW_alignment; Smith Waterman alignmnt  
d; Gap open penalty  
e; Gap extention penalty  

\##MS CALL PRMS##  
BLOOD_MIN_DEPTH; Minimum depth  
BLOOD_L; Likelihood value  
VAF; Mimimum varinat allele frequency  
NUM; Mimimum number of read  
ERROR_RATE_TABLE; Path of error arte matrix   



## Licence

[MIT](https://github.com/tcnksm/tool/blob/master/LICENCE)

## Contact

Akihiro Fujimoto - fujimoto@ddm.med.kyoto-u.ac.jp

https://sites.google.com/site/fujimotoakihironopeji/home/english