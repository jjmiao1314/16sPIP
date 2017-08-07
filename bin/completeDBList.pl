#!/usr/bin/perl
#
#    completeDBList.pl 16S-complete.classify 16S-complete.list
### Authors : JiaojiaoMiao <jjmiao1314@163.com>
use strict;
use warnings;

if($#ARGV<1){
	die "usage: $0 <16S-complete.classify> <16S-complete.list>\n";
}

my $file=$ARGV[0];
my $out=$ARGV[1];
open(F,"<$file")or die "can not open file: $file \n";
open(O,">$out")or die "can not open file: $out \n";
my $domain;
my $phylum;
my $class;
my $order;
my $family;
my $genus;
my $species;

while(my $l=<F>){
	chomp($l);
	my $domain="unclassify";
	my $phylum="unclassify";
	my $class="unclassify";
	my $order="unclassify";
	my $family="unclassify";
	my $genus="unclassify";
	my $species="unclassify";

	my @s=split /\t/,$l;
	if($s[2]=~/.*\;(.*)\;domain\;/){
		$domain=$1;
	}
	if($s[2]=~/.*\;(.*)\;phylum/){
		$phylum=$1;
	}
	if($s[2]=~/.*\;(.*)\;class/){
		$class=$1;
	}
	if($s[2]=~/.*\;(.*)\;order/){
		$order=$1;
	}
	if($s[2]=~/.*\;(.*)\;family/){
		$family=$1;
	}
	if($s[2]=~/.*\;(.*)\;genus/){
		$genus=$1;
	}
	my @s2=split /\s+/,$s[1];
	if($#s2>=1){
		$species=join " ",$s2[0],$s2[1];
	}
	elsif($#s2==0){
		$species=$s2[0];
	}
	print O "$s[0]\t$domain\t$phylum\t$class\t$order\t$family\t$genus\t$species\n";
}

close F;
close O;



