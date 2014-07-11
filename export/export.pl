package Export;
 
# Perl includes
use strict;
use Data::Dumper;
use Time::HiRes;
use List::Util;
use Storable;
use JSON;
 
# Kore includes
use Settings;
use Plugins;
use Network;
use Globals;
use Utils;

Commands::register(["export", "Export some data!", \&cmd_export]);

Plugins::register("Export", "Export some data!", \&unload);
#my $hooks = Plugins::addHooks(['mainLoop_post', \&loop]);

sub cmd_export
{
	my($cmd, $args) = @_;
	my @arg = split(" ", $args);
	
	if($arg[0] eq "debug")
	{
		debug($arg[1]);
	}
	else
	{
		export();
	}
}

sub debug
{
	my($debug) = @_;
	my $items = @{$char->inventory->getItems()};
	my $file;
	
	if($debug eq "char")
	{
		print(Dumper($char));
	}
	elsif($debug eq "field")
	{
		my $pos = calcPosition($char);	
		print "$field->{baseName} ( $field->{width} / $field->{height} ) - $pos->{x}, $pos->{y}	$char->{look}->{body}\n";
	}
	else
	{
		if($debug)
		{
			open($file, '>', "stats/debug-$debug.log"); 
		}
		else
		{
			open($file, '>', 'stats/debug.log'); 
		}
		
		foreach my $item (@{$items})
		{
			if($debug == "equipped")
			{
				unless($item->{equipped})
				{
					next;
				}
			}
			
			print $file Dumper($item);
		}

		print $file "\n ================================================================== \n";
		
		for(my $i = 0; $i < @storageID; $i++)
		{
			if($debug == "equipped")
			{
				next;
			}
		
			next if ($storageID[$i] eq "");
			my $item = $storage{$storageID[$i]};
			
			print $file Dumper($item);
		}
		close($file); 

		print("Debug output saved.\n");
	}
}

sub export	
{
    $Data::Dumper::Terse = 0;        # Output MORE!
    $Data::Dumper::Indent = 1;       # Output whitespace
    $Data::Dumper::Maxdepth = 10;       # Output whitespace

	#print(Dumper(@{$char->inventory->getItems()}));
	
	my $export = {"inventory" => [], "storage" => []};
	
	# Inventory
	########################
	
	foreach my $item (@{$char->inventory->getItems()})
	{
		push(@{$export->{inventory}}, {item => $item->{nameID}, quantity => $item->{amount}});	
	}

	# Storage
	########################
	
	for(my $i = 0; $i < @storageID; $i++)
	{
		next if ($storageID[$i] eq "");
		my $item = $storage{$storageID[$i]};
	
		push(@{$export->{storage}}, {item => $item->{nameID}, quantity => $item->{amount}});	
	}

	# Character information
	########################
	
	my $pos = calcPosition($char);
	
	$export->{character} = {
		name => $char->{'name'},
		class => $jobs_lut{$char->{'jobID'}},
		hp => {current => $char->{'hp'}, total => $char->{'hp_max'}},
		sp => {current => $char->{'sp'}, total => $char->{'sp_max'}},
		level => {base => $char->{'lv'}, job => $char->{'lv_job'}},
		exp => {base => {current => $char->{'exp'}, total => $char->{'exp_max'}},
				job => {current => $char->{'exp_job'}, total => $char->{'exp_job_max'}}},
		weight => {current => $char->{'weight'}, total => $char->{'weight_max'}},
		zeny => $char->{'zeny'},
		map => {name => $field->{baseName}, width => $field->{width}, height => $field->{height}},
		pos => $pos,
		look => $char->{look}->{body}
	};
	
	my $file;
	open($file, '>', 'stats/character-export.json'); 
	print $file to_json($export); 
	close($file); 
 
	print("Export complete!\n"); 
}
 
sub unload
{
#	Plugins::delHooks($hooks);
}

1;