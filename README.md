# *MIVcall*

A software to identify indels in microsatellite regions.  
MIVcall counts the length of each MS in each read. When multiple lengths are observed in a MS locus in a sample, the most frequent pattern is assumed to be present, and the second most frequent pattern is examined. The likelihood value (L) is calculated based on the number of reads and the difference in length between the most frequent pattern and the second most frequent pattern. Genotypes are determined based on the likelihood value, the number of reads of each allele, and variant allele frequency (VAF). 


Overview
1. Extract reads covering microsatellite regions from a bam file
2. Analyze repeat lengths 
3. Calculate likelihood using an error rate matrix, and identify indels in microsatellite regions

## Requirement
samtools (1.1.14 or higher)

perl (5 or higher)

python3

## Input file format
**bam file**; Sorted bam (index file for bam (.bai) is required.)


**microsatellite region file (MS list1)**; List of microsatellites (tab-separated text file). MS list1 for the human genome is available from Releases. User-defined microsatellite lists can be used. 

\<chr\> \<start\> \<end\> \<repeat unit of microsatellite\>  
chr1    822365  822369  G  
chr1    834138  834143  A  
chr1    834753  834758  G  
chr1    834982  834986  G

**microsatellite region file (MS list2)**; List of microsatellites (tab-separated text file). MS list2 for the human genome is available from Releases. User-defined microsatellite lists can be used (Please extend 10bp of the MS regions in the MS list1). 

\<chr\> \<start\> \<end\> \<repeat unit of microsatellite\>  
chr1    822355  822379  G  
chr1    834128  834153  A  
chr1    834743  834768  G  
chr1    834972  834996  G  

MS lists for the GRCh37 and 38 are available from https://github.com/afujimoto/MIVcall/releases.


**parm.conf file**(optional) ; Parameter file for microsatellite calling (VIMcall/parm.conf is used by default. If you want to change parameters, please change this file (see below))


## Output file format
\<chr\> \<start\> \<end\> \<repeat unit of microsatellite\> \<sequence of microsatellite> \<number of reads with length of microsatellite (length;number of reads)\> \<genotype\> \<calling information (2nd major allele, number of reads, variant allele frequency)\>  
22      17282432        17282438        (A)n    AAAAAAA 7;44    7/7     -  
22      17282577        17282589        (A)n    AAAAAAAAAAAAA   13;24,14;3      13/14   minor_allele=14;L=-3.03;Number=3;VAF=0.11 

"LOW" means that low depth of coverage and genotype was not obtained.


## Usage
```
cd <path to MIVcall>
perl MIVcall.pl -BAM <Bam> -OUT <Output file name> -MS <MS list1> -MS2 <MS list2> -CONF <Configuration file (Optional)>
```

## Example
```
git clone https://github.com/afujimoto/MIVcall.git
cd MIVcall
perl MIVcall.pl -BAM ./test/test.bam -OUT ./test/test.out -MS ./test/MS_GRCh37.test.txt -MS2 ./test/MS_GRCh37.region.test.txt
```


## Parameter setting in the configuration file
We consider the parameter set in the provided configuration appropriate for 30x coverage WGS data. If you would like to use different parameters, please make changes in the parm.config file. 

\##READ SELECTION PRMS##  
mq_cutoff; Minimum mapping quality for read selection (20)  
len_cutoff1; Minimum distance between paired reads (100)  
len_cutoff2; Maximum distance between paired reads (1000)   
flanking_len_cutoff; Minimum flanking length (3)  
S_length_cutoff; Minimum soft-clip length (3)  
q_score_cutoff; Minimum average quality score of flanking region (10)  
SW_alignment; Perform Smith-Waterman alignment (1; Yes, 0; No) (0)    
REF; Path to reference.fasta file (samtools index file is also required.)  
d; Gap open penalty (1)  
e; Gap extension penalty (1)  

\##MS CALL PRMS##  
MIN_DEPTH; Minimum depth (10)  
L; Likelihood value (-3)   
VAF; Minimum variant allele frequency (0.05)    
NUM; Minimum number of read (2)  
ERROR_RATE_TABLE; Path of error rate matrix (VIMcall/Error_rate_matrix.txt)   

## Performance
The performance of this tool is described in Fujimoto et al. (Genome Research (2020)) and Gochi et al. (Human Genetics (2022)).

https://genome.cshlp.org/content/early/2020/03/16/gr.255026.119  

## Licence
GPL

## Contact

Akihiro Fujimoto - afujimoto@m.u-tokyo.ac.jp

http://www.humgenet.m.u-tokyo.ac.jp/index.en.html

## Update
