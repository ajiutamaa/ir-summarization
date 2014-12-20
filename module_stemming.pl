sub stem {
	my ($string) = @_;
	
	my @prefix;
	my @suffix;
	my $infix;
	
	# DETERMINE WORD PREFIXES
	# Check if word contain 'me' prefix
	if($string =~ /^me/){	
		if($string =~ /^mem/){
			push(@prefix, "mem");	
			if($string =~ /^memper/){push(@prefix, "per");}
		}
		elsif($string =~ /^menge/){push(@prefix, "menge");}
		elsif($string =~ /^meng/){push(@prefix, "meng");}
		elsif($string =~ /^meny/){push(@prefix, "meny");}
		elsif($string =~ /^men/){push(@prefix, "men");}
		else{push(@prefix, "me");}
	}
	elsif($string =~ /^di/){
		push(@prefix, "di");	
		if($string =~ /^diper/){push(@prefix, "per");}
	}
	elsif($string =~ /^ber/){push(@prefix, "ber");}
	elsif($string =~ /^per/){push(@prefix, "per");}
	elsif($string =~ /^pe/){
		if($string =~ /^pem/){push(@prefix, "pem");}
		elsif($string =~ /^penge/){push(@prefix, "penge");}
		elsif($string =~ /^peng/){push(@prefix, "peng");}
		elsif($string =~ /^peny/){push(@prefix, "peny");}
		elsif($string =~ /^pen/){push(@prefix, "pen");}
		else{push(@prefix, "pe");}
	}
	elsif($string =~ /^se/){push(@prefix, "se");}
	elsif($string =~ /^ke/){push(@prefix, "ke");}
	elsif($string =~ /^ter/){push(@prefix, "ter");}
	
	# DETERMINE WORD SUFFIXES
	if($string =~ /kan$/){unshift(@suffix, "kan");}
	elsif($string =~ /an$/){unshift(@suffix, "an");}
	elsif($string =~ /lah$/){unshift(@suffix, "lah");}
	elsif($string =~ /kah$/){unshift(@suffix, "kah");}
	#elsif($string =~ /i$/ && length($string) > 3){unshift(@suffix, "i");}
	
	elsif($string =~ /ku$/){
		unshift(@suffix, "ku");
		if($string =~ /kanku$/){unshift(@suffix, "kan");}
		elsif($string =~ /anku$/){unshift(@suffix, "an");}
		elsif($string =~ /lahku$/){unshift(@suffix, "lah");}
		elsif($string =~ /kahku$/){unshift(@suffix, "kah");}
		elsif($string =~ /iku$/){unshift(@suffix, "i");}
	}
	elsif($string =~ /mu$/){
		unshift(@suffix, "mu");
		if($string =~ /kanmu$/){unshift(@suffix, "kan");}
		elsif($string =~ /anmu$/){unshift(@suffix, "an");}
		elsif($string =~ /lahmu$/){unshift(@suffix, "lah");}
		elsif($string =~ /kahmu$/){unshift(@suffix, "kah");}
		elsif($string =~ /imu$/){unshift(@suffix, "i");}
	}
	elsif($string =~ /nya$/){
		unshift(@suffix, "nya");
		if($string =~ /kannya$/){unshift(@suffix, "kan");}
		elsif($string =~ /annya$/){unshift(@suffix, "an");}
		elsif($string =~ /lahnya$/){unshift(@suffix, "lah");}
		elsif($string =~ /kahnya$/){unshift(@suffix, "kah");}
		elsif($string =~ /inya$/){unshift(@suffix, "i");}
	}

	$join_p = join("", @prefix);
	$join_s = join("", @suffix);
	
	$stemmed = $string;
	$stemmed =~ s/^$join_p//g;
	$stemmed =~ s/$join_s$//g;
	
	# CONSTRUCTING STEMMED WORD
	if($join_p =~ /(pe|me)ny/ && $stemmed =~ /^[aiueo]/){$stemmed = "s".$stemmed;}
	elsif($join_p =~ /(pe|me)ng/ && $stemmed =~ /^[aiueo]/){$stemmed = $stemmed;}
	elsif($join_p =~ /(pe|me)m/ && $stemmed =~ /^[aiueo]/){$stemmed = "p".$stemmed;}
	elsif($join_p =~ /(pe|me)n/ && $stemmed =~ /^[aiueo]/){$stemmed = "t".$stemmed;}
	
	return $stemmed;
}

1;