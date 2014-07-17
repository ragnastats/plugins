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

	# Sanitize usernames to prevent command execution xD
	$chat->{MsgUser} =~ s/;/\\;/g;
	
	if($chat->{Msg} =~ m/p+l+e+a+s+e*/)
	{
		$please->{timeout} = $time + 30;
	}
	
	if($chat->{Msg} =~ m/\b(invite|party)\b/ and $please->{timeout} > $time)
	{
		Commands::run("party request $chat->{MsgUser}");
	}
	
	if($chat->{Msg} =~ m/\bdeal\b/ and $please->{timeout} > $time)
	{
		my $player = Match::player($chat->{MsgUser});
		
		if($player)
		{
			Commands::run("deal $player->{binID}");
		}
	}
		
	if($chat->{Msg} =~ m/\b(sit|stand|kis|lv|heh|no1|rice|gg|fsh|awsm|slur|ho|thx|omg|go|sob|pif|meh|shy|spin|fsh|sigh|dum|hum|oops|spit|panic|follow|look (?:[0-9]+))\b/ and $please->{timeout} > $time)
	{
		my ($request, $option) = split(' ', $1);

		if($request eq "sit" or $request eq "stand")
		{
			Commands::run($request);
		}
		elsif($request eq "follow")
		{
			Commands::run("follow $chat->{MsgUser}");
		}
		elsif($request eq "look")
		{
			Commands::run("$request $option");
		}
		else
		{
			Commands::run("e $request");
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