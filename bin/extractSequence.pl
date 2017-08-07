#!/usr/bin/perl
# 
#    extractSequence.pl
#    Extract the specified sequence.
#    
#    extractSequence.pl -i <Forward read/sequence file> -r <Reverse read/sequence file of paired-end data> -o <outPrefix> -l <sequence id list> -s <reads number> -f <fasta|fastq>
#
### Authors : JiaojiaoMiao <jjmiao1314@163.com>

use strict;
use warnings;
use Getopt::Long;
use File::Basename;

my ($f,$r,$helpAsked,$list,$tag,$o);
my $split_read=2000;
GetOptions(
			"h|help" => \$helpAsked,
			"i|inputfile=s" => \$f,
			"r|reverse=s" => \$r,
			"l|list=s" => \$list,
			"f|format=s" => \$tag,
			"s|split=i" => \$split_read,
			"o|outPrefix=s" => \$o,
);
if(defined($helpAsked)) {
	prtUsage();
	exit;
}
if(!defined($list)|| !defined($f) || !defined($tag)) {
	prtError("No input files are provided");
}
if(!defined($o)){
	$o=$f;
}

my %pathon_id;
open(L,"<$list")or die "can not open file: $list\n";
while(my $line=<L>){
	my @s=split /\t/,$line;
	$pathon_id{$s[0]}=1;
}
close L;
if(defined($r)){
	if($tag=~/fasta/i){
		prtError("Only supports fastq format double-ended sequence");
	}
	open(I,"<$f")or die "can not open file: $f\n";
	open(R,"<$r")or die "can not open file: $r\n";
	my $num=0;
	my $suffix=1;
	open(O,">$o.$suffix.R1.pathon.fa")or die "can not open file: $o.$suffix.R1.pathon\n";
	open(O2,">$o.$suffix.R2.pathon.fa")or die "can not open file: $o.$suffix.R2.pathon\n";
	while(my $l=<I>){
		my $l2=<I>;
		my $l3=<I>;
		my $l4=<I>;
		my $l5=<R>;
		my $l6=<R>;
		my $l7=<R>;
		my $l8=<R>;
		my @s4=split /\s+/,$l;
		my @s5=split /\s+/,$l5;
		if($s4[0] ne $s5[0]){
			prtError("The two-ended sequence is inconsistent");
		}
		$s4[0]=~s/^@//;
		$s4[0]=~s/_/:/g;
		if($pathon_id{$s4[0]}){
			$num++;
			$l=~s/^@/>/;
			$l5=~s/^@/>/;
			print O "$l$l2";
			print O2 "$l5$l6";
			if($num == $split_read){
				close O;
				close O2;
				$suffix++;
				$num=0;
				open(O,">$o.$suffix.R1.pathon.fa")or die "can not open file: $o.$suffix.R1.pathon\n";
				open(O2,">$o.$suffix.R2.pathon.fa")or die "can not open file: $o.$suffix.R2.pathon\n";
			}
		}
	}
	close I;
	close R;
	close O;
	close O2;
}
else{
	open(I,"$f")or die "can not open file: $f\n";
	if($tag=~/fasta/i){
		my $num=0;
		my $suffix=1;
		open(O,">$o.$suffix.pathon.fa")or die "can not open file: $o.$suffix.pathon.fa\n";
		while(my $line=<I>){
			my $line2=<I>;
			my @s2=split /\s+/,$line;
			$s2[0]=~s/^>//;
			$s2[0]=~s/_/:/g;
			if($pathon_id{$s2[0]}){
				$num++;
				print O "$line$line2";
				if($num == $split_read){
					close O;
					$suffix++;
					$num=0;
					open(O,">$o.$suffix.pathon.fa")or die "can not open file: $o.$suffix.pathon\n";
				}
			}
		}
		close I;
		close O;
	}
	elsif($tag=~/fastq/i){
		my $num=0;
		my $suffix=1;
		open(O,">$o.$suffix.pathon.fa")or die "can not open file: $o.$suffix.pathon\n";
		while(my $l=<I>){
			my $l2=<I>;
			my $l3=<I>;
			my $l4=<I>;
			my @s3=split /\s+/,$l;
			$s3[0]=~s/^@//;
			$s3[0]=~s/_/:/g;
			if($pathon_id{$s3[0]}){
				$num++;
				$l=~s/^@/>/;
				print O "$l$l2";
				if($num == $split_read){
					close O;
					$suffix++;
					$num=0;
					open(O,">$o.$suffix.pathon.fa")or die "can not open file: $o.$suffix.pathon\n";
				}
			}
		}
	}
	close I;
	close O;
}

sub prtError {
	my $errorm = $_[0];
	print STDERR "+======================================================================+\n";
	printf STDERR "|%-70s|\n", "  Error:";
	printf STDERR "|%-70s|\n", "       $errorm";
	print STDERR "+======================================================================+\n";
	prtUsage();
	exit;
}

sub prtErrorExit {
	my $errmsg = $_[0];
	print STDERR "Error:\t", $errmsg, "\n";
	exit;
}

sub prtUsage {
	print "\nUsage: perl $0 <options>\n";
	prtHelp();
}

sub prtHelp {
	print "\n$0 options:\n\n";
	print "### Input reads/sequences (FASTQ/FASTA) (Required)\n";
	print "  -i | -inputfile <Forward read/sequence file>\n";
	print "    File containing reads/sequences in either FASTQ or FASTA format\n";
	print "\n";
	print "### Input reads/sequences (FASTQ) [Optional]\n";
	print "  -r | -reverse <Reverse read/sequence file of paired-end data>\n";
	print "    File containing reverse reads/sequences of paired-end data in FASTQ format\n";
	print "\n";
	print "### Input the id list of the detached sequence (Required)\n";
	print "  -l | -list <list name>\n";
	print "\n";
	print "### Other options [Optional]\n";
	print "  -h | -help\n";
	print "    Prints this help\n";
	print "  -s | -split <Integer>\n";
	print "    Number of Separated Sequence Files\n";
	print "    default: 2000\n";
	print "  -r | -rightTrimBases <Integer>\n";
	print "    Number of bases to be trimmed from right end (3' end)\n";
	print "    default: 0\n";
	print "  -f | -format <fasta|fastq> \n";
	print "    File format fasta or fastq \n";
	print "\n";
	print "--------------------------------- Output Options ---------------------------------\n";
	print "  -o | -outPrefix <Output file name prefix>\n";
	print "    Output will be stored in the given file\n";
	print "    default: By default, output file will be stored where the input file is\n";
}




