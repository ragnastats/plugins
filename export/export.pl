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
my $hooks = Plugins::addHooks(['mainLoop_post', \&loop]);

sub cmd_export
{
	my($cmd, $args) = @_;
	
	if($args eq "debug")
	{
		debug();
	}
	else
	{
		export();
	}
}

sub debug
{
	my @items = $char->inventory->getItems();

	my $file;
	open($file, '>', 'stats/debug.log'); 
  
	foreach my $item (@items)
	{
		print $file Dumper($item);
	}

	print $file "\n ================================================================== \n";
	
	for(my $i = 0; $i < @storageID; $i++)
	{
		next if ($storageID[$i] eq "");
		my $item = $storage{$storageID[$i]};
		
		print $file Dumper($item);
	}
	close($file); 

	print("Debug output saved to debug.log\n");
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
	
	$export->{character} = {
		name => $char->{'name'},
		class => $jobs_lut{$char->{'jobID'}},
		hp => {current => $char->{'hp'}, total => $char->{'hp_max'}},
		sp => {current => $char->{'sp'}, total => $char->{'sp_max'}},
		level => {base => $char->{'lv'}, job => $char->{'lv_job'}},
		exp => {base => {current => $char->{'exp'}, total => $char->{'exp_max'}},
				job => {current => $char->{'exp_job'}, total => $char->{'exp_job_max'}}},
		weight => {current => $char->{'weight'}, total => $char->{'weight_max'}},
		zeny => $char->{'zeny'}
	};
	
	my $file;
	open($file, '>', 'stats/character-export.json'); 
	print $file to_json($export); 
	close($file); 
 
	print("Export complete!\n"); 
}
 
sub unload
{
	Plugins::delHooks($hooks);
}

sub loop
{

}

