#!/usr/bin/perl
# 
#    FilterReads.pl
#    Read filter procedures were based on the read ambiguous base (N) content.
#    
#    FilterReads.pl <seq> <fasta|fastq> <N_percentage> 
#
### Authors : JiaojiaoMiao <jjmiao1314@163.com>


use strict;
use warnings;

if($#ARGV<1){
	die "usage: $0 <seq> <fasta|fastq> <N_percentage>\n";
}

my $f=$ARGV[0];
my $ncutoff;
my $format=$ARGV[1];
if(defined($ARGV[2])){
	$ncutoff=$ARGV[2];
}
else{
	$ncutoff=10;
}

my $o=$f."_filter";
open(F,"<$f")or die "can not open file: $f\n";
open(O,">$o")or die "can not open file: $o\n";

if($format=~/fastq/i){
	while(my $l=<F>){
		my $l2=<F>;
		my $l3=<F>;
		my $l4=<F>;
		my $length=length($l2);
		my $ncount=$l2=~tr/N|n/N/;
		if($length-1 == 0){
			next;
		}
		if($ncount/($length-1)*100<=$ncutoff){
			print O "$l$l2$l3$l4";
		}
	}
}
else{
	my $line=<F>;
	my $ncount=0;
	my $seqlen=0;
	my $seq="";
	while(my $l=<F>){
		if($l=~/^>/){
			if($seqlen != 0){
				if($ncount/$seqlen*100 <=$ncutoff){
					print O "$line$seq\n";
				}
			}
		$line=$l;
		$ncount=0;
		$seqlen=0;
		$seq="";
		}
		else{
			$l=~s/\s//g;
			$seqlen += length($l);
			$ncount += $l=~tr/N|n/N/;
			$seq .= $l;
		}
	}
	if($seqlen != 0){
		if($ncount/$seqlen*100 <= $ncutoff){
			print O "$line$seq\n";
		}
	}
}

close F;
close O;
