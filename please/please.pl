package Please;

# Perl includes
use strict;
use Data::Dumper;
use Storable;

# Kore includes
use Plugins;
use Globals;
use Match;

our $please = {};

#		'00E7' => ['deal_begin', 'C', [qw(type)]],
#		'00E9' => ['deal_add_other', 'V v C3 a8', [qw(amount nameID identified broken upgrade cards)]],
#		'00EA' => ['deal_add_you', 'v C', [qw(index fail)]],
#		'00EC' => ['deal_finalize', 'C', [qw(type)]],
	

Plugins::register("Please", "Everything Please?", \&unload);
my $hooks = Plugins::addHooks(["packet_pubMsg", \&parseChat],
								["packet_partyMsg", \&parseChat],
								["packet_guildMsg", \&parseChat],
								["packet_selfChat", \&parseChat],
								["packet_privMsg", \&parseChat],
								["packet/deal_begin", \&deal_begin],
								["packet/deal_finalize", \&deal_finalize]);

								
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

sub deal_begin
{
	my($hook, $args) = @_;
	
	if($args->{type} == 3 and $config{autodeal})
	{
		# Immediately finalize the deal once opened
		$messageSender->sendDealFinalize();
	}
}

sub deal_finalize
{
	my($hook, $args) = @_;
	
	if($args->{type} == 1 and $config{autodeal})
	{
		# Immediately accept the deal
		$messageSender->sendDealTrade();
	}	
}

1;