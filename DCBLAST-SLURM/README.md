---
layout: page
title: 14_BLAST
published: true
---


## location
```
 mkdir /data/gpfs/assoc/bch709/<YOURID>/alignment
 cd $!
```

## ENV
```bash
conda activate alignment
```

## BLAST
Basic Local Alignment Search Tool (Altschul et al., 1990 & 1997) is a sequence comparison algorithm optimized for speed used to search sequence databases for optimal local alignments to a query. The initial search is done for a word of length "W" that scores at least "T" when compared to the query using a substitution matrix. Word hits are then extended in either direction in an attempt to generate an alignment with a score exceeding the threshold of "S". The "T" parameter dictates the speed and sensitivity of the search.

### Rapidly compare a sequence Q to a database to find all sequences in the database with an score above some cutoff S.
- Which protein is most similar to a newly sequenced one?
- Where does this sequence of DNA originate?
- Speed achieved by using a procedure that typically finds *most* matches with scores > S.
- Tradeoff between sensitivity and specificity/speed
- Sensitivity – ability to find all related sequences
- Specificity – ability to reject unrelated sequences 


### Homologous sequence are likely to contain a short high scoring word pair, a seed.
– Unlike Baeza-Yates, BLAST *doesn't* make explicit guarantees 

### BLAST then tries to extend high scoring word pairs to compute maximal high scoring segment pairs (HSPs).
– Heuristic algorithm but evaluates the result statistically.

![seed]({{site.baseurl}}/fig/seed.png)
![seed]({{site.baseurl}}/fig/I.7_1_blast_illustration.png)


### E-value
E-value = the number of HSPs having score S (or higher) expected to occur by chance.

Smaller E-value, more significant in statistics
Bigger E-value , by chance

** E[# occurrences of a string of length m in reference of length L] ~ L/4m **



## PAM and BLOSUM Matrices
Two different kinds of amino acid scoring matrices, *PAM (Percent Accepted Mutation) and BLOSUM (BLOcks SUbstitution Matrix)*, are in wide use. The PAM matrices were created by Margaret Dayhoff and coworkers and are thus sometimes referred to as the Dayhoff matrices. These scoring matrices have a strong theoretical component and make a few evolutionary assumptions. The BLOSUM matrices, on the other hand, are more empirical and derive from a larger data set. Most researchers today prefer to use BLOSUM matrices because in silico experiments indicate that searches employing BLOSUM matrices have higher sensitivity.

There are several PAM matrices, each one with a numeric suffix. The PAM1 matrix was constructed with a set of proteins that were all 85 percent or more identical to one another. The other matrices in the PAM set were then constructed by multiplying the PAM1 matrix by itself: 100 times for the PAM100; 160 times for the PAM160; and so on, in an *attempt to model the course of sequence evolution*. Though highly theoretical (and somewhat suspect), it is certainly a reasonable approach. There was little protein sequence data in the 1970s when these matrices were created, so this approach was a good way to extrapolate to larger distances.

Protein databases contained many more sequences by the 1990s so a more empirical approach was possible. The BLOSUM matrices were constructed by extracting ungapped segments, or blocks, from a set of multiply aligned protein families, and then further clustering these blocks on the basis of their percent identity. The blocks used to derive the BLOSUM62 matrix, for example, all have at least 62 percent identity to some other member of the block.

![PAM-250-and-Blosum-62-matrices]({{site.baseurl}}/fig/PAM-250-and-Blosum-62-matrices.png)

![codon]({{site.baseurl}}/fig/codon.jpg)

### BLAST has a number of possible programs to run depending on whether you have nucleotide or protein sequences:

nucleotide query and nucleotide db - blastn
nucleotide query and nucleotide db - tblastx (includes six frame translation of query and db sequences)
nucleotide query and protein db - blastx (includes six frame translation of query sequences)
protein query and nucleotide db - tblastn (includes six frame translation of db sequences)
protein query and protein db - blastp

![blasttype]({{site.baseurl}}/fig/blasttype.png)
### BLAST Process


![step1]({{site.baseurl}}/fig/step1.png)
![step2]({{site.baseurl}}/fig/step2.png)
![step3]({{site.baseurl}}/fig/step3.png)
![step4]({{site.baseurl}}/fig/step4.png)


![blast]({{site.baseurl}}/fig/blast.gif)



### NCBI BLAST
https://blast.ncbi.nlm.nih.gov/Blast.cgi

### Uniprot

https://www.uniprot.org/


### BLASTN example
Run blastn against the nt database.


```

ATGAAAGCGAAGGTTAGCCGTGGTGGCGGTTTTCGCGGTGCGCTGAACTA
CGTTTTTGACGTTGGCAAGGAAGCCACGCACACGAAAAACGCGGAGCGAG
TCGGCGGCAACATGGCCGGGAATGACCCCCGCGAACTGTCGCGGGAGTTC
TCAGCCGTGCGCCAGTTGCGCCCGGACATCGGCAAGCCCGTCTGGCATTG
CTCGCTGTCACTGCCTCCCGGCGAGCGCCTGAGCGCCGAGAAGTGGGAAG
CCGTCGCGGCTGACTTCATGCAGCGCATGGGCTTTGACCAGACCAATACG
CCGTGGGTGGCCGTGCGCCACCAGGACACGGACAAGGATCACATCCACAT
CGTGGCCAGCCGGGTAGGGCTGGACGGGAAAGTGTGGCTGGGCCAGTGGG
AAGCCCGCCGCGCCATCGAGGCGACCCAAGAGCTTGAGCATACCCACGGC
CTGACCCTGACGCCGGGGCTGGGCGATGCGCGGGCCGAGCGCCGGAAGCT
GACCGACAAGGAGATCAACATGGCCGTGAGAACGGGCGATGAACCGCCGC
GCCAGCGTCTGCAACGGCTGCTGGATGAGGCGGTGAAGGACAAGCCGACC
GCGCTAGAACTGGCCGAGCGGCTACAGGCCGCAGGCGTAGGCGTCCGGGC
AAACCTCGCCAGCACCGGGCGCATGAACGGCTTTTCCTTCGAGGTGGCCG
GAGTGCCGTTCAAAGGCAGCGACTTGGGCAAGGGCTACACATGGGCGGGG
CTACAGAAAGCAGGGGTGACTTATGACGAAGCTAGAGACCGTGCGGGCCT
TGAACGATTCAGGCCCACAGTTGCAGATCGTGGAGAGCGTCAGGACGTTG
CAGCAGTCCGTGAGCCTGATGCACGAGGACTTGAAGCGCCTACCGGGCGC
AGTCTCGACCGAGACGGCGCAGACCTTGGAACCGCTGGCCCGACTCCGGC
AGGACGTGACGCAGGTTCTGGAAGCCTACGACAAGGTGACGGCCATTCAG
CGCAAGACGCTGGACGAGCTGACGCAGCAGATGAGCGCGAGCGCGGCGCA
GGCCTTCGAGCAGAAGGCCGGGAAGCTGGACGCGACCATCTCCGACCTGT
CGCGCAGCCTGTCAGGGCTGAAAACGAGCCTCAGCAGCATGGAGCAGACC
GCGCAGCAGGTGGCGACCTTGCCGGGCAAGCTGGCGAGCGCACAGCAGGG
CATGACGAAAGCCGCCGACCAACTGACCGAGGCAGCGAACGAGACGCGCC
CGCGCCTTTGGCGGCAGGCGCTGGGGCTGATTCTGGCCGGGGCCGTGGGC
GCGATGCTGGTAGCGACTGGGCAAGTCGCTTTAAACAGGCTAGTGCCGCC
AAGCGACGTGCAGCAGACGGCAGACTGGGCCAACGCGATTTGGAACAAGG
CCACGCCCACGGAGCGCGAGTTGCTGAAACAGATCGCCAATCGGCCCGCG
AACTAGACCCGACCGCCTACCTTGAGGCCAGCGGCTACACCGTGAAGCGA
GAAGGGCGGCACCTGTCCGTCAGGGCGGGCGGTGATGAGGCGTACCGCGT
GACCCGGCAGCAGGACGGGCGCTGGCTCTGGTGCGACCGCTACGGCAACG
ACGGCGGGGACAATATCGACCTGGTGCGCGAGATCGAACCCGGCACCGGC
TACGCCGAGGCCGTCTATCGGCTTTCAGGTGCGCCGACAGTCCGGCAGCA
ACCGCGCCCGAGCGAGCCGAAGCGCCAACCGCCGCAGCTACCGGCGCAAG
GGCTGGCAGCCCGCGAGCATGGCCGCGACTACCTCAAGGGCCGGGGCATC
AGCCAGGACACCATCGAGCACGCCGAGAAGGCGGGCATGGTGCGCTATGC
AGACGGTGGAGTGCTGTTCGTCGGCTACGACCGTGCAGGCACCGCGCAGA
ACGCCACACGCCGCGCCATTGCCCCCGCTGACCCGGTGCAGAAGCGCGAC
CTACGCGGCAGCGACAAGAGCTATCCGCCGATCCTGCCGGGCGACCCGGC
AAAGGTCTGGATCGTGGAAGGTGGCCCGGATGCGCTGGCCCTGCACGACA
TCGCCAAGCGCAGCGGCCAGCAGCCGCCCACCGTCATCGTGTCAGGCGGG
GCGAACGTGCGCAGCTTCTTGGAGCGGGCCGACGTGCAAGCGATCCTGAA
GCGGGCCGAGCGCGTCACCGTGGCCGGGGAAAACGAGAAGAACCCCGAGG
CGCAGGCAAAGGCCGACGCCGGGCACCAGAAGCAGGCGCAGCGGGTGGCC
AAAATCACCGGGCGCGAGGTGCGCCAATGGACGCCGAAGCCCGAGCACGG
CAAGGACTTGGCCGACATGAACGCCCGGCAGGTGGCAGAGATCGAGCGCA
AGCGACAGGCCGAGATCGAGGCCGAAAGAGCACGAAACCGCGAGCTTTCA
CGCAAGAGCCGGAGGTATGATGGCCCCAGCTTCGGCAGATAA
```

### BLASTP Query
Do a BLASTP on NCBI website with the following protein against nr, but limit the organism to cetartiodactyla using default parameters:

```
MASGPGGWLGPAFALRLLLAAVLQPVSAFRAEFSSESCRELGFSSNLLCSSCDLLGQFSL
LQLDPDCRGCCQEEAQFETKKYVRGSDPVLKLLDDNGNIAEELSILKWNTDSVEEFLSEK
LERI
```


Have a look at the multiple sequence alignment, can you explain the results?  

Do a similar blastp vs UniProtKB (UniProt) without post filtering.

Select and align all proteins. Can you explain the differences?

What do you think of the Bos taurus sequence (A8YXY3) and the pig sequence (A1Z623)?


### Running a standalone BLAST program
Create the index for the target database using makeblastdb;
Choose the task program: blastn, blastp, blastx, tblatx, psiblast or deltablast;
Set the configuration for match, mismatch, gap-open penalty, gap-extension penalty or scoring matrix;
Set the word size;
Set the E-value threshold;
Set the output format and the number of output results


### Standalone BLAST
1. Download the database.
2. Use makeblastdb to build the index.
3. Change the scoring matrix, record the changes in the alignment results and interpret the results.

### Download Database
```
ftp://ftp.ncbi.nih.gov/refseq/release/plant/plant.1.protein.faa.gz
```
### How many sequences in `plant.1.protein.faa.gz`


### Run BLAST
```
makeblastdb -in plant.1.protein.faa -dbtype prot
blastx -query /data/gpfs/assoc/bch709/<YOURID>/rnaseq_slurm/trinity_out_dir/Trinity.fasta -db plant.1.protein.faa 
```


### Tab output

	qseqid 		Query sequence ID
	sseqid		Subject (ie DB) sequence ID
	pident		Percent Identity across the alignment
	length 		Alignment length
	mismatch 	# of mismatches
	gapopen 	Number of gap openings
	qstart 		Start of alignment in query
	qend 		End of alignment in query 
	sstart 		Start of alignment in subject
	send		End of alignment in subject
	evalue 		E-value
	bitscore	Bit score


### Assignment Run standalone BLASTX
- find the option below within BLASTX
1. output to file
2. tabular output format
3. set maximum target sequence to one
4. threads (CPU) to 32
- Upload your output file to Webcanvas




# DCBLAST

The Basic Local Alignment Search Tool (BLAST) is by far best the most widely used tool in for sequence analysis for rapid sequence similarity searching among nucleic acid or amino acid sequences. Recently, cluster, HPC, grid, and cloud environmentshave been are increasing more widely used and more accessible as high-performance computing systems. Divide and Conquer BLAST (DCBLAST) has been designed to perform run on grid system with query splicing which can run National Center for Biotechnology Information (NCBI) BLASTBLAST search comparisons  over withinthe cluster, grid, and cloud computing grid environment by using a query sequence distribution approach NCBI BLAST. This is a promising tool to accelerate BLAST job dramatically accelerates the execution of BLAST query searches using a simple, accessible, robust, and practical approach. 

- DCBLAST can run BLAST job across HPC.
- DCBLAST suppport all NCBI-BLAST+ suite.
- DCBLAST generate exact same NCBI-BLAST+ result.
- DCBLAST can use all options in NCBI-BLAST+ suite.




## Requirement
Following basic softwares are needed to run

- Perl (Any version 5+)

```bash
which perl
perl --version
```

- NCBI-BLAST+ (Any version)
for easy approach, you can download binary version of blast from below link.
ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST

For using recent version, please update BLAST path in config.ini

```bash
which blastn
```

- Sun Grid Engine (Any version)
```bash
which qsub
```

- Slurm
```bash
which sbatch
```

- Grid cloud or distributed computing system.


## Prerequisites

The following Perl modules are required:
```bash
- Path::Tiny
- Data::Dumper
- Config::Tiny
```
Install prerequisites with the following command:

```bash
cpan `cat requirement`
```
or
```bash
cpanm `cat requirement`
```
or 
```bash
cpanm Path::Tiny Data::Dumper Config::Tiny
```
We strongly recommend to use Perlbrew http://perlbrew.pl/ to avoid having to type sudo

We also recommend to use 'cpanm' https://github.com/miyagawa/cpanminus

## Prerequisites by Conda

```bash
conda create -n DCBLAST
conda install -c bioconda perl-path-tiny blast perl-data-dumper perl-config-tiny 
```

## Installation

The program is a single file Perl scripts. Copy it into executive directories.

We recommend to copy it on scratch disk.


```bash
cd ~/scratch/  # We recommend to copy it on scratch disk.

git clone git://github.com/ascendo/DCBLAST.git

cd ~/scratch/DCBLAST

perl dcblast.pl
```

### Help

```bash
Usage : dcblast.pl --ini config.ini --input input-fasta --size size-of-group --output output-filename-prefix  --blast blast-program-name

  --ini <ini filename> ##config file ex)config.ini

  --input <input filename> ##query fasta file

  --size <output size> ## size of chunks usually all core x 2, if you have 160 core all nodes, you can use 320. please check it to your admin.

  --output <output filename> ##output folder name

  --blast <blast name> ##blastp, blastx, blastn and etcs.

  --dryrun Option will only split fasta file into chunks
```


### Configuration

**Please edit config.ini before you run!!**

```bash
[dcblast]
##Name of job (will use for SGE job submission name)
job_name_prefix=dcblast

[blast]
##BLAST options

##BLAST path (your blast+ path); $ which blastn; then remove "blastn"
path=~/bin/blast/ncbi-blast-2.2.30+/bin/

##DB path (build your own BLAST DB)
##example
##makeblastdb -in example/test_db.fas -dbtype nucl (for nucleotide sequence)
##makeblastdb -in example/your-protein-db.fas -dbtype prot (for protein sequence)
db=example/test_db.fas

##Evalue cut-off (See BLAST manual)
evalue=1e-05

##number of threads in each job. If your CPU is AMD it needs to be set 1.
num_threads=2

##Max target sequence output (See BLAST manual)
max_target_seqs=1

##Output format (See BLAST manual)
outfmt=6

##any other option can be add it this area
#matrix=BLOSUM62
#gapopen=11
#gapextend=1

[oldsge]
##Grid job submission commands
##please check your job submission scripts
##Especially Queue name (q) and Threads option (pe) will be different depends on your system

pe=SharedMem 1
M=your@email
q=common.q
j=yes
o=log
cwd=

[slurm]
time=04:00:00
cpus-per-task=1
mem-per-cpu=800M
ntasks=1
output=log
hint=compute_bound
error=error
partition=cpu-s2-core-0
account=cpu-s2-bch709-0
mail-type=all
mail-user=<YOURID>@unr.edu

```
If you need any other options for your enviroment please contant us or admin

PBS & LSF need simple code hack. If you need it please request through issue.

## Examples

### Dryrun (--dryrun option will only split fasta file into chunks)
```bash
perl dcblast.pl --ini config.ini --input example/test_query.fas --output test --size 20 --blast blastn --dryrun
```
```bash
DRYRUN COMMAND : [qsub -M your@email -cwd -j yes -o log -pe SharedMem 1 -q common.q -N dcblast_split -t 1-20 dcblast_blastcmd.sh]
DRYRUN COMMAND : [qsub -M your@email -cwd -j yes -o log -pe SharedMem 1 -q common.q -hold_jid dcblast_split -N dcblast_merge dcblast_merge.sh test/results 20]
DRYRUN COMMAND : [qstat]
DONE
```
Check the test folder "test/chunks/" for sequence split result.

### Example sequence

This sequences are randomly selected from plant species.
The size and gene number informations are below.

```bash
test_db.fas

Number of gene	35386
Total size of gene	43546761
Longest gene	16182
Shortest gene	22
```

```bash
test_query.fas

Number of gene	6282
Total size of gene	7247997
Longest gene	11577
Shortest gene	22
```

**It usually finish within ~20min depends on HPC status and CPU speed.**



## Usage
```bash
perl dcblast.pl

Usage : dcblast.pl --ini config.ini --input input-fasta --size size-of-group --output output-filename-prefix  --blast blast-program-name

  --ini <ini filename> ##config file ex)config.ini

  --input <input filename> ##query fasta file

  --size <output size> ## size of chunks usually all core x 2, if you have 160 core in nodes, you can use 320. please check it to your admin.

  --output <output filename> ##output folder name

  --blast <blast name> ##blastp, blastx, blastn and etcs.

  --dryrun Option will only split fasta file into chunks
```



### Run with example
You don't need to run "dryrun" everytime.

```bash
perl dcblast.pl --ini config.ini --input example/test_query.fas --output test --size 20 --blast blastn 
```

This run will splits file into 20 chunks, run on 20 cores and generated BLAST output file "test/results/merged" and chunked input file "test/chunks/"

It will finish their search within ~20min depends on HPC status and CPU speed.

For your research, please format database according to NCBI-BLAST+ instruction.
Here is the brief examples.
```bash
makeblastdb -in your-nucleotide-db.fa -dbtype nucl ###for nucleotide sequence
```

```bash
makeblastdb -in your-protein-db.fas -dbtype prot ###for protein sequence
```

## Citation
Won C. Yim and John C. Cushman (2017) Divide and Conquer BLAST: using grid engines to accelerate BLAST and other sequence analysis tools. PeerJ 10.7717/peerj.3486 https://peerj.com/articles/3486/

