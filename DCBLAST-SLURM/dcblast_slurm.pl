#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Config::Tiny;
use Path::Tiny;

use Data::Dumper;
$Data::Dumper::Indent = 1;

GetOptions (
    'ini=s'        => \my $opt_ini,
    'input=s'      => \my $opt_input,
    'size=i'       => \my $opt_size,
    'output=s'     => \my $opt_output,
    'blast=s'      => \my $opt_blast,
    'dryrun'       => \my $OPT_DRYRUN,
    'help'         => \my $opt_help,
    'verbose'      => \my $opt_verbose,
);

if($opt_help || !$opt_ini || !$opt_input || !$opt_size || !$opt_output || !$opt_blast) {
    usage();
    exit 1;
}

unless (-e $opt_output) {
    print STDERR "Output Directory $opt_output doesn't exist.\n";
}

unless (-e $opt_ini) {
    print STDERR "Cannot read $opt_ini\n";
    exit 1;
}

unless (-e $opt_input) {
    print STDERR "Cannot read $opt_input\n";
    exit 1;
}

my $config = Config::Tiny->read($opt_ini, 'utf8');
print "Config : ", Dumper $config if $opt_verbose;

my $paths = {
    chunks => "$opt_output/chunks",
    results => "$opt_output/results",
};

path($paths->{chunks})->mkpath;
path($paths->{results})->mkpath;

my $cnt = split_fasta($opt_input, $paths, $opt_size);

my $dcblast_blastcmd = 'dcblast_blastcmd.sh';
my $dcblast_mergecmd = 'dcblast_merge.sh';

write_blast_shell($dcblast_blastcmd, $config->{blast}, $opt_blast, $paths);
write_merge_shell($dcblast_mergecmd);

# blastjob
my @slurm_blastjob = slurm_opt($config->{sge});
push @slurm_blastjob, "--job-name=$config->{dcblast}{job_name_prefix}_split";
push @slurm_blastjob, "--array=1-$cnt";
push @slurm_blastjob, "--wrap=$dcblast_blastcmd";
run_command(@slurm_blastjob);

# mergejob
my @slurm_mergejob = slurm_opt($config->{sge});
push @slurm_mergejob, '--dependency=singleton';
#,"$config->{dcblast}{job_name_prefix}_split";
push @slurm_mergejob, "--job-name=$config->{dcblast}{job_name_prefix}_split";
push @slurm_mergejob, "--wrap=$dcblast_mergecmd $opt_output/results $cnt";
run_command(@slurm_mergejob);

# qstat
run_command("squeue")

print "DONE\n";

exit 0;

# ---------------------------------------------------------

sub split_fasta {

    my ($input, $paths, $splitcount) = @_;

    my @list;
    my @sequence;

    open my $in, '<', $input
        or die "Cannot open $input : $!";

    while(defined(my $aline = <$in>)) {
        if($aline =~ m/^>/) {
            if(@sequence > 0) {
                push @list, join('', @sequence);
                @sequence = ();
            }
        }
        push @sequence, $aline;
    }
    if(@sequence > 0) {
        push @list, join('', @sequence);
        @sequence = ();
    }

    close $in;

    my $total_size = 0;
    $total_size += length $_ for @list;
    my $group_size = int($total_size / $splitcount) + 1;

    my $cnt = 0;
    while(@list > 0) {

        my $tmp_size = 0;
        my $tmp_count = 0;
        for my $seq (@list) {
            $tmp_size += length($seq);
            $tmp_count++;
            last if $tmp_size >= $group_size;
        }

        my $split = sprintf("%s/split.%04d", $paths->{chunks}, $cnt+1);
        path($split)->spew(splice @list, 0, $tmp_count);
        $cnt++;
    }

    return $cnt;
}

sub write_blast_shell {
    my ($dcblast_blastcmd, $blastconf, $blast, $paths) = @_;

    my $blast_shell = <<"SHELL";
#!/bin/sh
DCBLAST_TASK_ID=`printf "%04d" \$SLURM_ARRAY_TASK_ID`
$blastconf->{path}/$blast \\
-query $paths->{chunks}/split.\$DCBLAST_TASK_ID \\
-out $paths->{results}/result.\$DCBLAST_TASK_ID \\
SHELL

    my @blast_shell;
    for my $k (sort keys %$blastconf) {
        next if $k eq 'path';
        push @blast_shell, "-$k";
        push @blast_shell, $blastconf->{$k}
            if defined $blastconf->{$k} and $blastconf->{$k} ne '';
    }
    $blast_shell .= join ' ', @blast_shell, "\n";

    path($dcblast_blastcmd)->spew($blast_shell);
    path($dcblast_blastcmd)->chmod("a+x");
}

sub write_merge_shell {

    my ($dcblast_mergecmd) = @_;
    my $merge_shell = <<'SHELL';
#!/bin/sh
FILENAME=$1
END=$2

for i in $(seq -f "%04g" 1 $END); do
  cat $1/result.$i >> $1/merged
done
SHELL

    path($dcblast_mergecmd)->spew($merge_shell);
    path($dcblast_mergecmd)->chmod("a+x");
}

sub slurm_opt {
    my ($sge) = @_;
    my @slurm_opts = ('sbatch');

    for my $k (sort keys %$sge) {
        next if $k eq 'N';
        push @slurm_opts, "--$k";
        if ($k eq 'pe') {
            push @slurm_opts, split(/ /, $sge->{$k});
        }
        elsif (defined $sge->{$k} and $sge->{$k} ne '') {
            push @slurm_opts, $sge->{$k};
        }
    }

    return @slurm_opts;
}

sub run_command {
    my @cmd = @_;
    if ($OPT_DRYRUN) {
        print "DRYRUN COMMAND : [@cmd]\n";
    }
    else {
        system @cmd;
    }
}

sub usage {
    print STDERR <<HELP;
Usage : $0 --ini <ini filename> --input <input-fasta> --size <size-of-group> --output <output-filename-prefix>  --blast <blast-program-name>

  --ini <ini filename> ##config file ex)config.ini

  --input <input filename> ##query fasta file 

  --size <output size> ## size of chunks usually all core x 2, if you have 160 core all nodes, you can use 320. please check it to your admin.

  --output <output filename> ##output name

  --blast <blast name> ##blastp, blastx, blastn and etcs.

HELP
    return 1;
}

# vim: expandtab tabstop=4 shiftwidth=4 smarttab
