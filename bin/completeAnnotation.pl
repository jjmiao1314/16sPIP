#!/usr/bin/perl
#
#    completeAnnotation.pl blast.lsit 16S-complete.list species outFile
#
### Authors : JiaojiaoMiao <jjmiao1314@163.com>
use strict;
use warnings;

if($#ARGV<1){
	die "usage: $0 <Best match list> <16S-complete.list> <species|genus|family|order|class|phylum|domain> <outFile>\n";
}

my $file=$ARGV[0];
my $list=$ARGV[1];
my $level=$ARGV[2];
my $out=$ARGV[3];
my $tag=6;
if($level eq "species"){
	$tag=7;
}
elsif($level eq "genus"){
	$tag=6;
}
elsif($level eq "family"){
	$tag=5;
}
elsif($level eq "order"){
	$tag=4;
}
elsif($level eq "class"){
	$tag=3;
}
elsif($level eq "phylum"){
	$tag=2;
}
elsif($level eq "domain"){
	$tag=1;
}

open(L,"<$list")or die "can not open file: $list\n";
my %classify;
while(my $line=<L>){
	chomp($line);
	my @s=split /\t/,$line;
	$classify{$s[0]}=$s[$tag];
}
close L;

open(F,"<$file")or die "can not open file: $file\n";
open(O,">$out")or die "can not open file: $out\n";
while(my $l=<F>){
	chomp($l);
	my @s2=split /\t/,$l;
	print O "$l\t$classify{$s2[1]}\n";
}
close F;
close O;

