# *MIVcall*

A software to indetify indels in microsatellite regions

Overview
1. Extract reads covering microsatellite regions from a bam file
2. Analyze repeat lengths 
3. Calculate likelihood using an error rate matrix, and identify indels in microsatellite regions

## Requirement
samtools (0.1.18 or higher)

perl (5 or higher)

python

## Input file format
**bam file**; Sorted bam (index file for bam (.bai) is required.)


**microsatellite region file**; List of microsatellite (tab-separated text or .gz file). Microsatellite region files are provided in MS_list directory. User defined microsatellite lists can be used. 

\<chr\> \<start\> \<end\> \<repeat unit of microsatellite\>  
22      17283835        17283839        A  
22      17283968        17283981        AT  


**parm.conf file**(optional) ; Parameter file for microsatellite calling (VIMcall/parm.conf is used by default. If you want to change parameters, please change this file (see below))


## Output file format
\<chr\> \<start\> \<end\> \<repeat unit of microsatellite\> \<Sequence of microsatellite> \<number of reads with length of microsatellte (length;number of reads)\> \<genotype\> \<calling information (2nd major allele, number of reads, variant allele frequency)\>  
22      17282432        17282438        (A)n    AAAAAAA 7;44    7/7     -  
22      17282577        17282589        (A)n    AAAAAAAAAAAAA   13;24,14;3      13/14   minor_alelle=14;L=-3.03;Number=3;VAF=0.11 


## Usage
```
cd <path to MIVcall>
perl RUN_MIV_CALL.pl -BAM <Bam> -OUT <Output file name> -MS <Microsatellte region file> -CONF <Configuration file (Optional)>
```

## Example
```
git clone https://github.com/afujimoto/MIVcall.git
cd MIVcall
perl RUN_MIV_CALL.pl -BAM ./test/test.bam -OUT ./test/test.out -MS ./test/test_MS_list.txt
```


## Parameter setting in configuration file
We consider the parameter set in the provided configuration apprppreate for 30x coverage WGS data. If you would like to use different parameters, please make changes in the parm.config file. 

\##READ SELECTION PRMS##  
mq_cutoff; Minimum mapping quality for read selection (20)  
len_cutoff1; Minimum distance between paired reads (100)  
len_cutoff2; Maximum distance between paired reads (550)   
flanking_len_cutoff; Minimum flanking length (3)  
S_length_cutoff; Minimum softclip length (3)  
q_score_cutoff; Minimum average quality score of flanking region (10)  
SW_alignment; Perform Smith-Waterman alignment (1; Yes, 0; No) (0)    
REF; Path to reference.fasta file (samtools index file is also required.)  
d; Gap open penalty (1)  
e; Gap extention penalty (1)  

\##MS CALL PRMS##  
MIN_DEPTH; Minimum depth (10)  
L; Likelihood value (-3)   
VAF; Mimimum variant allele frequency (0.05)    
NUM; Mimimum number of read (2)  
ERROR_RATE_TABLE; Path of error rate matrix (VIMcall/Error_rate_matrix.txt)   

## Preformance
Performance of this tool is provided in Fujimoto et al. (bioRxiv).

## Licence
GPL

## Contact

Akihiro Fujimoto - fujimoto@ddm.med.kyoto-u.ac.jp

https://sites.google.com/site/fujimotoakihironopeji/home/english

## Update
