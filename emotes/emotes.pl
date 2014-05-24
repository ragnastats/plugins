#WORD
 
package Emote;
 
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
 
our @queue;
our $emote = {};
 
Plugins::register("Emote Browser!", "Version 0.1 r1", \&unload);
my $hooks = Plugins::addHooks(['mainLoop_post', \&loop],
								['Commands::run/pre', \&command]);
 
sub unload
{
	Plugins::delHooks($hooks);
}
 
sub loop
{
	if(Network::DirectConnection::getState() == Network::IN_GAME)
	{
		my $time = Time::HiRes::time();
							   
		if($emote->{time} < $time)
		{
			if(@queue)
			{
				my $emoteID = shift(@queue);
				my $command = $emotions_lut{$emoteID}{command};
				
				if($command)
				{
#					Commands::run("p Using emote $command");
				}
				else
				{
#					Commands::run("p Using unknown emote, ID: $emoteID");
				}
				
				$messageSender->sendEmotion($emoteID);   
				$emote->{time} = $time + 1;
			}
		}
	}
}

sub command
{
	my($hook, $args) = @_;
	
	if($args->{switch} eq 'e')
	{
		if($args->{args} eq 'all')
		{
			for(my $i = 0; $i < 85; $i++)
			{
				push(@queue, $i);
			}
		}
		elsif($args->{args} =~ m/^([0-9]+)$/)
		{
			push(@queue, $1);
		}
	}	
}

1;