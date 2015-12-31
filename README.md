

#DCBLAST
 The Basic Local Alignment Search Tool (BLAST) is by far best the most widely used tool in for sequence analysis for rapid sequence similarity searching among nucleic acid or amino acid sequences. Recently, cluster, grid, and cloud environmentshave been are increasing more widely used and more accessible as high-performance computing systems. Divide and Conquer BLAST (DCBLAST) has been designed to perform run on grid system with query splicing which can run National Center for Biotechnology Information (NCBI) BLASTBLAST search comparisons  over withinthe cluster, grid, and cloud computing grid environment by using a query sequence distribution approach NCBI BLAST. This is a promising tool to accelerate BLAST job dramatically accelerates the execution of BLAST query searches using a simple, accessible, robust, and practical with extremely easy access, robust and practical approach.


##Requirement

-Sun Grid Engine (Any version)

-Grid cloud or distributed computing system.

##Prerequisites

The program requires Perl to run.

The following Perl modules are required:

- Path::Tiny
- Data::Dumper

Install prerequisites with the following command:
```
$ cpan `cat requirement`
```
or
```
$ cpanm `cat requirement`
```

We strongly recommend to use Perlbrew http://perlbrew.pl/ and cpanm https://github.com/miyagawa/cpanminus



##Installation

The program is a single file Perl scripts. Copy it into executive directories.


##Configuration

Please edit config.ini before you run!!

```
[dcblast]
##Name of job
job_name_prefix=dcblast

[blast]
##BLAST options

##BLAST path (your blast+ path)
path=~/bin/blast/ncbi-blast-2.2.30+/bin/

##DB path (build your own BLAST DB)
##example
##makeblastdb -in example/test_db.fas -dbtype nucl
db=example/test_db.fas

##Evalue cut-off (See BLAST manual)
evalue=1e-05

##number of threads in each job. If your CPU is AMD it needs to be set 1.
num_threads=2

##Max target sequence output (See BLAST manual)
max_target_seqs=1

##Output format (See BLAST manual)
outfmt=6

[sge]
##Grid job submission commands
##please check your job submission scripts
pe=SharedMem 1
M=your@email
q=common.q
j=yes
cwd=

```
If you need any other options for your enviroment please contant us.

##Usage

```

Usage : dcblast.pl --input input-fasta --size size-of-group --output output-filename-prefix --db fasta-dbfilename --blast blast-command-name
  --ini <ini filename>
  --input <input filename>
  --size <output size>
  --output <output filename>
  --blast <blast name>

```


##Examples

###Dryrun (--dryrun option will only split fasta file into chunks)
```
perl dcblast.pl --ini config.ini --input example/test.fas --output test --size 20 --blast blastn --dryrun
```

```
DRYRUN COMMAND : [chmod +x dcblast_blastcmd.sh]
DRYRUN COMMAND : [chmod +x dcblast_merge.sh]
DRYRUN COMMAND : [qsub, -M, wyim@unr.edu, -cwd, -j, yes, -pe, SharedMem, 1, -q, common.q, -N, dcblast11_split, -t, 1-19, dcblast_blastcmd.sh]
DRYRUN COMMAND : [qsub, -M, wyim@unr.edu, -cwd, -j, yes, -pe, SharedMem, 1, -q, common.q, -hold_jid, dcblast11_split, -N, dcblast11_merge, dcblast_merge.sh, o.result, 19]
DRYRUN COMMAND : [qstat]
DONE
```
###Run

```
perl dcblast.pl --ini config.ini --input example/test.fas --output test --size 20 --blast blastn 
```

This run will splits file into 20 chunks, run on 20 cores and generated BLAST output file "test.result.merged"


##Citation
Won Cheol Yim and John Cushman (2015) Divide and Conquer BLAST: using grid engines to accelerate BLAST and other sequence analysis tools. Bioinformatics apllication note submitted.



##Copyright

The program is copyright by Yim, Won Cheol.
