#!/usr/bin/perl
#
#    PathogenDBList.pl 155pathogens.classify 155pathogens.txt
### Authors : JiaojiaoMiao <jjmiao1314@163.com>
use strict;
use warnings;

if($#ARGV<1){
	die "usage: $0 <155pathogens.classify> <155pathogens.txt>\n";
}

my $list=$ARGV[0];
my $file=$ARGV[1];
open(L,"<$list")or die "can not open file: $list \n";
open(F,"<$file")or die "can not open file: $file \n";
open(O,">155pathogens.list")or die "can not open file: 155pathogens.list\n";

my %pathogen;
<F>;
my @pathongens=<F>;
while(my $line=<L>){
	my @s=split /\t/,$line;
	foreach my $p (@pathongens) {
		my @s2=split /\t/,$p;
		if($s2[1]){
			my $qr=qr($s2[1]);
			if($s[1]=~/$qr/ix){
				if($pathogen{$s2[0]}){
					$pathogen{$s2[0]} .= ",".$s[0];
				}
				else{
					$pathogen{$s2[0]}="$s[0]";
				}
				last;
			}
		}
		my $qr2=qr($s2[0]);
		if($s[1]=~/$qr2/ix){
			if($pathogen{$s2[0]}){
				$pathogen{$s2[0]} .= ",".$s[0];
			}
			else{
				$pathogen{$s2[0]}="$s[0]";
			}
			last;
		}
	}
}

foreach my $k (keys %pathogen) {
	print O "$k\t$pathogen{$k}\n";
}

close F;
close O;

