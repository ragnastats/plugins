package Drop;
 
# Perl includes
use strict;
use Data::Dumper;
use Time::HiRes;
use List::Util;
 
# Kore includes
use Settings;
use Plugins;
use Network;
use Globals;
 
our $drop = {};
 
Plugins::register("Auto-drop", "Drop items randomly~", \&unload);
my $hooks = Plugins::addHooks(['mainLoop_post', \&loop]);
 
sub unload
{
        Plugins::delHooks($hooks);
}
 
sub loop
{
	if(Network::DirectConnection::getState() == Network::IN_GAME)
	{   
	
		if($config{autodrop})
		{
			my $time = Time::HiRes::time();
								   
			if($drop->{time} < $time)
			{
				$drop->{item} = [];
	   
				foreach my $item (@{$char->inventory->getItems()})
				{
					push(@{$drop->{item}}, $item->{invIndex});
				}

				@{$drop->{item}} = List::Util::shuffle @{$drop->{item}};
			   
				#print(@{$drop->{item}}[0]."n");
				Commands::run("drop @{$drop->{item}}[0] 1");
											   
				$drop->{time} = $time + $config{autodrop_timeout};
			}
		}
	}
}