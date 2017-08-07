#!/usr/bin/perl
# 
#    pathogenSamMatch.pl
#    
#    pathogenSamMatch.pl <sam> <outFile>
#
### Authors : JiaojiaoMiao <jjmiao1314@163.com>

if($#ARGV<1){
	die "usage: $0 <sam> <outFile>\n";
}

my $sam=$ARGV[0];
my $out=$ARGV[1];
open(S,"<$sam")or die "can not open file: $sam\n";
open(O,">$out")or die "can not open file: $out\n";

my $match=0;
my %p;
while(my $l=<S>){
	if($l=~/^@|^\[/){
		next;
	}
	my @s=split /\t/,$l;
	if($#s<11){
		next;
	}
	if($s[3] ne "*" && $s[5] ne "*" ){
		$p{$s[0]}=1;
	}

}

my @k=keys %p;
print O "SampleSamFile: $sam\n";
print O "Match Num: ",$#k,"\n";
close F;
close O;


