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
	my @take = ('Butterfly Wing', 'Strawberry', 'White Potion', 'Blue Potion', 'Empty Bottle');
	
	foreach(@take)
	{
		Commands::run("storage get $_");
	}
}
 
sub unload
{
	Plugins::delHooks($hooks);
}

sub loop
{

}

