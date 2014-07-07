package Storage;
 
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

Commands::register(["plop", "Storage lmao", \&storage]);
Commands::register(["unplop", "Anti-storageeee", \&unplop]);

Plugins::register("Storage", "Storage Lmao", \&unload);
my $hooks = Plugins::addHooks(['mainLoop_post', \&loop]);

sub storage
{
	my($command, $count) = @_;	
	
	for(my $i = 1; $i <= $count; $i++)
	{
#		print("Wow $1 !\n");
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

