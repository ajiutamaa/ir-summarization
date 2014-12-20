#!/usr/local/bin/perl

# author: prasetya ajie

# assumptions:
#	- baris tanpa ditutup titik adalah sub-title
#	- kalimat terakhir dibetulkan dengan menambah titik

use POSIX;
use Math::Complex;
use Bing::Translate;

my (%stopwords_id);
my (%stopwords_en);

init();

require("module_stemming.pl");
print "==============================================================\n";
while($_ = <>){
	process_doc($_);
}
print "==============================================================\n";

sub process_doc
{
	my ($filename) = $_[0];
	my $title;
	my $subtitle;
	my $onDocRead = 0;
	my $documentText = "";
	my (%thematics);
	my @sentences = ();
	my @sorted = ();
	my %scores = ();
	# open doc
	open(DOC, $filename);

	# linewise read
	while($line = <DOC>){
		# check line
		if($line =~ /<TITLE>/){
			$line =~ s/\n//g;
			$line =~ s/<TITLE>|<\/TITLE>//g;
			$title = $line;
			print "title\t\t: $title\n";
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
					$subtitle = $line;
					print "sub-heading\t: $line\n";
				}
			}
		}
	}

	# initialize thematic terms
	%tokens = tokenize(join(" ", @sentences));
	$counter = 0;
	foreach $key (sort {$tokens{$b} <=> $tokens{$a}} keys %tokens){
		if(not defined($stopwords_id{$key})){
			$thematics{$key} = $tokens{$key};
			$counter++;
			if($counter > 10){last;}
		}
	}

	# add list to sentence scoring function
	# function return hash of offset -> score
	%scores = sentence_scoring(\@sentences, \%thematics, $title, $subtitle);
	foreach $t (sort {$scores{$b} <=> $scores{$a}} keys %scores){
		push @sorted, $sentences[$t];
		# print "Score [$scores{$t}] => $sentences[$t]\n";
	}
	
	# create the list of sorted sentence based on their score

	# pass the sorted list to smoothing function

	# print the summarized text
	$compressed_num = ceil(0.2*scalar(@sentences));
	$total_num = scalar(@sentences);
	$final_result = join(". ", @sorted[0..($compressed_num-1)]);
	print "Summary\t\t:\n";
	# print $final_result . "\n";
	# print "Translated:\n";
	print translateToId($final_result) . "\n";
	print "--------------------------------------------------------------\n";
}

# determine the score of each sentence in the list
# the score, later, used to sort the sentences in decending order
sub sentence_scoring
{
	my (@sentences) = @{$_[0]};
	my (%thematics) = %{$_[1]};
	my ($title) = $_[2];
	my ($subtitle) = $_[3];
	my (%scores) = ();
	my (@loc_scores) = location_score(scalar(@sentences));
	$counter = 0;
	foreach $s (@sentences){
		if(defined($subtitle)){
			$scores{$counter} = (0.2 * $loc_scores[$counter]) 
								+ (0.3 * similarity($s, $title))
								+ (0.2 * similarity($s, $subtitle)
								+ (0.3 * thematic_score($s, \%thematics)));
		}
		else{
			$scores{$counter} = (0.3 * $loc_scores[$counter]) 
								+ (0.4 * similarity($s, $title)
								+ (0.3 * thematic_score($s, \%thematics)));
		}
		$counter++;
	}
	return %scores;
}

# tokenize senteces into hash of <word, freq> tuples
sub tokenize
{
	my ($sentence) = $_[0];
	my %words;
	$sentence =~ s/'//g;
	$sentence =~ s/[[:punct:]]/ /g;
	$sentence =~ s/“/ /g;
	$sentence =~ s/”/ /g;
	$sentence =~ s/ [\s]* / /g;
	$sentence =~ s/^\s+|\s+$|\t//g;
	$sentence =~ s/\d//g;
	foreach $w (split(/\s/, $sentence)){
		$words{$w}++;
	}
	return %words;
}

# find similarity score of two sentences
# similarity score determined by cosine similary based on
# vector model
sub similarity
{
	my ($sentence1) = lc($_[0]);
	my ($sentence2) = lc($_[1]);
	my %token1 = tokenize($sentence1);
	my %token2 = tokenize($sentence2);
	$div1 = 0;
	$div2 = 0;
	$sum = 0;
	foreach $t (keys %token1){$div1 += $token1{$t}**2;}
	foreach $t (keys %token2){$div2 += $token2{$t}**2;}
	foreach $i (keys %token1){
		foreach $j (keys %token2){
			if(($i eq $j) or (stem($i) eq stem($j))){
				$sum += $token1{$i} * $token2{$j};
			}
		}
	}
	$div1 = sqrt($div1); $div2 = sqrt($div2);
	return $sum / ($div1 * $div2);
}

sub thematic_score
{
	my ($sentence1) = lc($_[0]);
	my (%thematics) = %{$_[1]};
	my %token1 = tokenize($sentence1);
	$div1 = 0;
	$div2 = 0;
	$sum = 0;
	foreach $t (keys %token1){$div1 += $token1{$t}**2;}
	foreach $t (keys %thematics){$div2 += $thematics{$t}**2;}
	foreach $i (keys %token1){
		foreach $j (keys %thematics){
			if(($i eq $j) or (stem($i) eq stem($j))){
				$sum += $token1{$i} * $thematics{$j};
			}
		}
	}
	$div1 = sqrt($div1); $div2 = sqrt($div2);
	return $sum / ($div1 * $div2);
}

# scores each sentences based on the location relative to
# the start of the passage
# for 19 sentences
# 0 => 19/19
# 1 => 18/19
# 2 => 17/19
sub location_score
{
	my ($sent_num) = $_[0];
	my @ret_vals;
	for($i = 0; $i < $sent_num; $i++){
		push(@ret_vals, ($sent_num - $i) / $sent_num);
	}
	return @ret_vals;
}

sub translateToId
{
	my ($en_str) = $_[0];
	my $translator = Bing::Translate->new('ajiutamaa', 
						'/+tFXDBfvYIZip4BPjrd9XxahB3iiWKJGeNMAcKcUh4='); 
	return $result = $translator->translate("$en_str", "en", "id");
}

sub init
{
	open(SW, "stopwords_id.txt");
	while($line = <SW>){
		@stopwords = split(/\s/, $line);
		foreach $s (@stopwords){
			$stopwords_id{$s} = 1;
		}
	}
}