package Please;

# Perl includes
use strict;
use Data::Dumper;
use Storable;

# Kore includes
use Plugins;
use Match;

our $please = {};

Plugins::register("Please", "Everything Please?", \&unload);
my $hooks = Plugins::addHooks(["packet_pubMsg", \&parseChat],
								["packet_partyMsg", \&parseChat],
								["packet_guildMsg", \&parseChat],
								["packet_selfChat", \&parseChat],
								["packet_privMsg", \&parseChat]);

								
sub unload
{
	Plugins::delHooks($hooks);
}

sub parseChat
{
	my($hook, $args) = @_;	
	my $chat = Storable::dclone($args);
	my $time = Time::HiRes::time();
	
	# selfChat returns slightly different arguements, let's fix that
	if($hook eq 'packet_selfChat')
	{
		$chat->{Msg} = $chat->{msg};
		$chat->{MsgUser} = $chat->{user};
	}	
	
	if($chat->{Msg} =~ m/p+l+e+a+s+e*/)
	{
		$please->{timeout} = $time + 30;
	}
	
	if($chat->{Msg} =~ m/invite|party/ and $please->{timeout} > $time)
	{
		# Sanitize usernames to prevent command execution xD
		$chat->{MsgUser} =~ s/;/\\;/g;
		Commands::run("party request $chat->{MsgUser}");
	}
	
	if($chat->{Msg} =~ m/deal/ and $please->{timeout} > $time)
	{
		my $player = Match::player($chat->{MsgUser});
		
		if($player)
		{
			Commands::run("deal $player->{binID}");
		}
	}
}

1;