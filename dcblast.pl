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
    'dryrun'       => \my $opt_dryrun,
    'help'         => \my $opt_help,
    'verbose'      => \my $opt_verbose,
);

if($opt_help || !$opt_ini || !$opt_input || !$opt_size || !$opt_output || !$opt_blast) {
    usage();
    exit 1;
}

unless(-e $opt_input) {
    print STDERR "Cannot read $opt_input\n";
    exit 1;
}

my $config = Config::Tiny->read($opt_ini, 'utf8');
print "Config : ", Dumper $config if $opt_verbose;

my $cnt = split_fasta($opt_input, $opt_output, $opt_size);

my $dcblast_blastcmd = 'dcblast_blastcmd.sh';
my $dcblast_mergecmd = 'dcblast_merge.sh';

write_blast_shell($dcblast_blastcmd, $config->{blast}, $opt_output);
write_merge_shell($dcblast_mergecmd);

# blastjob
my @qsub_blastjob = qsub_opt($config->{sge});
push @qsub_blastjob, '-N', "$config->{dcblast}{job_name_prefix}_split";
push @qsub_blastjob, '-t', "1-$cnt";
push @qsub_blastjob, $dcblast_blastcmd;
run_command($opt_dryrun, @qsub_blastjob);

# mergejob
my @qsub_mergejob = qsub_opt($config->{sge});
push @qsub_mergejob, '-hold_jid', "$config->{dcblast}{job_name_prefix}_split";
push @qsub_mergejob, '-N',        "$config->{dcblast}{job_name_prefix}_merge";
push @qsub_mergejob, $dcblast_mergecmd, "$opt_output.result", $cnt;
run_command($opt_dryrun, @qsub_mergejob);

# qstat
run_command($opt_dryrun, 'qstat');

print "DONE\n";

exit 0;

# ---------------------------------------------------------

sub split_fasta {

    my ($input, $output, $splitcount) = @_;

    my @list;
    my @sequence;

    open my $in, '<', $input
        or die "Cannot open $input : $!";

    while(<$in>) {
        if(/^>/) {
            if(@sequence > 0) {
                push @list, join('', @sequence);
                @sequence = ();
            }
        }
        push @sequence, $_;
    }
    if(@sequence > 0) {
        push @list, join('', @sequence);
    }
    close $in;

    my $total_size = 0;
    map { $total_size += length($_) } @list;
    my $group_size = int($total_size / $splitcount) + 1;

    my $cnt = 0;
    while(@list > 0) {

        my $tmp_size = 0;
        my $tmp_count = 0;
        for my $seq (@list) {
            $tmp_size += length($seq);
            $tmp_count++;
            last if $tmp_size > $group_size;
        }

        my $split = sprintf("%s.split.%04d", $output, $cnt+1);
        path($split)->spew(splice @list, 0, $tmp_count);
        $cnt++;
    }

    return $cnt;
}

sub write_blast_shell {
    my ($dcblast_blastcmd, $blast, $opt_output) = @_;
    my $opt_blast_path = $blast->{path};

    my $blast_cmd = <<CMD;
#!/bin/sh
DCBLAST_TASK_ID=`printf "%04d" \$SGE_TASK_ID`
$opt_blast_path/$opt_blast \\
-query $opt_output.split.\$DCBLAST_TASK_ID \\
-out $opt_output.result.\$DCBLAST_TASK_ID \\
CMD

    my @blast_cmd;
    for my $k (sort keys %$blast) {
        next if $k eq 'path';
        push @blast_cmd, "-$k";
        push @blast_cmd, $blast->{$k}
            if defined $blast->{$k} and $blast->{$k} ne '';
    }
    $blast_cmd .= join ' ', @blast_cmd, "\n";

    path($dcblast_blastcmd)->spew($blast_cmd);
    run_command($opt_dryrun, "chmod +x $dcblast_blastcmd");
}

sub write_merge_shell {

    my ($dcblast_mergecmd) = @_;
    my $merge_shell = <<'SHELL';
#!/bin/sh
FILENAME=$1
END=$2

for i in $(seq -f "%04g" 1 $END); do
  cat $1.$i >> $1.merged
done
SHELL

    path($dcblast_mergecmd)->spew($merge_shell);
    run_command($opt_dryrun, "chmod +x $dcblast_mergecmd");
}

sub qsub_opt {
    my ($sge) = @_;
    my @qsub_opts = ('qsub');

    for my $k (sort keys %$sge) {
        next if $k eq 'N';
        push @qsub_opts, "-$k";
        if ($k eq 'pe') {
            push @qsub_opts, split(/ /, $sge->{$k});
        }
        elsif (defined $sge->{$k} and $sge->{$k} ne '') {
            push @qsub_opts, $sge->{$k};
        }
    }

    return @qsub_opts;
}

sub run_command {
    my ($dryrun, @cmd) = @_;
    if ($dryrun) {
        print "DRYRUN COMMAND : [", join(', ', @cmd), "]\n";
    }
    else {
        system(@cmd);
    }
}

sub usage {
    print STDERR <<HELP;
Usage : $0 --input input-fasta --size size-of-group --output output-filename-prefix --db fasta-dbfilename --blast blast-command-name
  --ini <ini filename>
  --input <input filename>
  --size <output size>
  --output <output filename>
  --blast <blast name>
HELP
    return 1;
}

# vim: expandtab tabstop=4 shiftwidth=4 smarttab
