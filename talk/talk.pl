#WORD
package Talk;
 
# Perl includes
use strict;
use Data::Dumper;
 
# Kore includes
use Settings;
use Plugins;
use Network;
use Globals;
 
our $emote = {};
 
 
Commands::register(["talkto", "Usage: talkto [npc name]", \&talk]);
Plugins::register("NPC Talk", "Talk to NPCs by Name", \&unload);

sub unload
{
	# Do nothing?
}

sub talk
{
	my($cmd, $search) = @_;
	my $npcs = $npcsList->getItems();
	
	foreach my $npc (@{$npcs})
	{
		# Sanitize regex in search string
		$search =~ s/[-\\.,_*+?^\$[\](){}!=|]/\\$&/g;
		
	
		if($npc->name =~ /$search/i)
		{
		print(Dumper($npc));
			#my $npcID = $npc->binID;
			#Commands::run("talk $npcID");
		}		
	}
}

1;