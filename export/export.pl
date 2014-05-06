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

Commands::register(["export", "Export some data!", \&export]);

Plugins::register("Export", "Export some data!", \&unload);
my $hooks = Plugins::addHooks(['mainLoop_post', \&loop]);

sub export	
{
    $Data::Dumper::Terse = 0;        # Output MORE!
    $Data::Dumper::Indent = 1;       # Output whitespace
    $Data::Dumper::Maxdepth = 10;       # Output whitespace

	#print(Dumper(@{$char->inventory->getItems()}));
	
	my $export = {"inventory" => [], "storage" => []};
	
	foreach my $item (@{$char->inventory->getItems()})
	{
		print("Name: $item->{name} \n");
		print("Amount: $item->{amount} \n");
		print("ID: $item->{nameID} \n");
		print("Sprite: $item->{sprite_id} \n");
		print("Type: $item->{type} \n");
		print("Equip Type: $item->{type_equip} \n");
		print("Identified: $item->{identified} \n");
		print("Broken: $item->{broken} \n");
		print("Bind On Equip: $item->{bindOnEquipType} \n");
		print("Upgrade: $item->{upgrade} \n");
		print("Cards: $item->{cards} \n");
		print("Equipped: $item->{equipped} \n");
		print("Expire: $item->{cards} \n");
		print("Actor Type: $item->{actorType} \n");
		print("=============\n");

		push(@{$export->{inventory}}, {item => $item->{nameID}, quantity => $item->{amount}});
	
#		print(" - ".$item->{name}." \n - Inv Index: ".$item->{invIndex}." \n - Index: ".$item->{index}." \n - Amount: ".$item->{amount}." \n - Type: ".$item->{type}." \n ======================== \n");
	}

	for (my $i = 0; $i < @storageID; $i++)
	{
		next if ($storageID[$i] eq "");
		my $item = $storage{$storageID[$i]};
	
		print("Name: $item->{name} \n");
		print("Amount: $item->{amount} \n");
		print("ID: $item->{nameID} \n");
		print("Storage! \n============ \n");
		push(@{$export->{storage}}, {item => $item->{nameID}, quantity => $item->{amount}});	
	}

	my $file;
	
	open($file, '>', 'stats/character-export.json'); 
	print $file to_json($export); 
	close($file); 
 
	print("Export complete!\n");
 
#	print(Dumper($char->inventory->getItems())."\n");
}
 
sub unload
{
	Plugins::delHooks($hooks);
}

sub loop
{

}

