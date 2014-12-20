#!/usr/local/bin/perl

# author: prasetya ajie

use Bing::Translate;

my $srcText = "Alcoholics are usually smokers too, and that presents something of a problem for someone trying to get back on the wagon. It seems that smoking makes it harder to quit drinking. Puzzlingly, it's not nicotine but rather an as yet unknown component of tobacco smoke that's to blame, according to research published today.";
my $translator = Bing::Translate->new('ajiutamaa', '/+tFXDBfvYIZip4BPjrd9XxahB3iiWKJGeNMAcKcUh4='); 
my $result = $translator->translate("$srcText", "en", "id");
print "$result\n";