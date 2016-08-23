package Plop;
 
# Perl includes
use strict;
use Data::Dumper;
use Time::HiRes;
use List::Util;
use Storable;
 
# Kore includes
use Settings;
use Plugins;
use Network;
use Globals;
use Utils;

Commands::register(["plop", "Plop lmao", \&plop]);
Commands::register(["unplop", "Anti-storage", \&unplop]);

Plugins::register("Plop", "Plop items into storage", \&unload);
my $hooks = Plugins::addHooks(['mainLoop_post', \&loop]);

sub plop
{
	// Atempt to add all items into your storage (iRO only allows 100 items in your inventory at once)
	for(my $i = 1; $i <= 100; $i++)
	{
		Commands::run("storage add $i");
	}
}

sub unplop
{
	my @take = (
		['Butterfly Wing', 15],
		['Fly Wing', 25], 
		['Yggdrasil Leaf', 5],
		['Strawberry', 10], 
		['White Potion', 5], 
		['Blue Potion', 5], 
		['Empty Bottle', 10], 
		['Green Herb', 5],
		['Blue Gemstone', 100]
	);
	
	foreach(@take)
	{
		my $item = $_;
		
		print("$item\n");
		
		if(ref($item) eq "ARRAY")
		{
			my($item, $quantity) = @{$_};
			Commands::run("storage get $item $quantity")
		}
		else
		{
			Commands::run("storage get $item");
		}		
	}
}
 
sub unload
{
	Plugins::delHooks($hooks);
}

sub loop
{

}

