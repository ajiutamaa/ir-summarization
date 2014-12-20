#!/usr/local/bin/perl

# author: prasetya ajie

@a = [1,2,3];
@b = [2,3,4,5];

@c = [@a, @b];

foreach $i (@c){
	print "$i\n";
}