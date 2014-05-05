package Export;
 
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

Commands::register(["export", "Export some data!", \&export]);

Plugins::register("Export", "Export some data!", \&export);
my $hooks = Plugins::addHooks(['mainLoop_post', \&loop]);

sub export
{
	
}
 
sub unload
{
	Plugins::delHooks($hooks);
}

sub loop
{

}

