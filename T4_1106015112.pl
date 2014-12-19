#!/usr/local/bin/perl

# author: prasetya ajie

# assumptions:
#	- baris tanpa ditutup titik adalah sub-title
#	- kalimat terakhir dibetulkan dengan menambah titik

process_doc();

sub process_doc
{
	my $title;
	my $onDocRead = 0;
	my $documentText = "";
	my @sentences = ();
	my %scores = ();
	# open doc
	open(DOC, "dok.txt");

	# linewise read
	while($line = <DOC>){
		# check line
		if($line =~ /<TITLE>/){
			$line =~ s/\n//g;
			$line =~ s/<TITLE>|<\/TITLE>//g;
			$title = $line;
			print "title: $title\n";
		}
		if($line =~ /<TEXT>/){$onDocRead = 1; next;}
		elsif($line =~ /<\/TEXT>/){$onDocRead = 0;}
		# buffer lines into text line
		if($onDocRead){
			# not empty line
			if($line !~ /^\n$/){
				if($line =~ /[A-Za-z]+\.\n/ or ($line =~ /^\"/ and $line =~ /\"$/)){
					$line =~ s/\n/ /g;
					@temp = split(/\. /, $line);
					push(@sentences, @temp);
				}
				# case: sub heading
				else{
					$line =~ s/\n/ /g;
					print "sub-heading: $line\n";
				}
			}
		}
	}

	# add list to sentence scoring function
	# function return hash of offset -> score
	%scores = sentence_scoring(\@sentences);

	print "=======================\n";
	foreach $t (sort {$scores{$b} <=> $scores{$a}} keys %scores){
		printf "sentence ($scores{$t}): %s\n", $sentences[$t];
	}
	
	# create the list of sorted sentence based on their score

	# pass the sorted list to smoothing function

	# print the summarized text
}

sub sentence_scoring
{
	my (@sentences) = @{$_[0]};
	my (%scores) = ();

	$counter = 0;
	foreach $s (@sentences){
		$scores{$counter} = rand(100);
		$counter++;
	}

	return %scores;
}

# sub tokenize
# {

# }