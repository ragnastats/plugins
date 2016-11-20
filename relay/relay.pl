package Relay;

# Perl includes.
use strict;
use HTTP::Request;
use LWP::UserAgent;
use Data::Dumper;
use JSON;

# Kore includes.
use Plugins;
use Globals;

our $relay;

# We need to check if these variables haven't been defined yet.
# Otherwise Kore will overwrite them if the plugin is ever reloaded.
if(ref($relay) ne 'HASH')
{
    $relay = {};
}

Plugins::register("Chat Relay", "To wetfish, and beyond!", \&unload);
my $hooks = Plugins::addHooks
(
    ['mainLoop_post', \&loop],
    ['packet/received_character_ID_and_Map', \&connected],
    ['disconnected', \&disconnected],

    ["packet_pubMsg", \&sendChat],
    ["packet_partyMsg", \&sendChat],
    ["packet_guildMsg", \&sendChat],
    ["packet_selfChat", \&sendChat],
    ["packet_privMsg", \&sendChat],
    ["packet_sentPM", \&sendChat],
    ["packet_emotion", \&sendChat],
    ["packet_sysMsg", \&sendChat]
);

sub unload
{
    Plugins::delHooks($hooks);
}

sub connected
{
    my $time = time();
    $time =~ s/\.[0-9]+//;

    # Wait 5 seconds after connecting to relay messasges.
    $relay->{time} = $time + 5;
    $relay->{status} = 'connected';
}

sub disconnected
{
    $relay->{status} = 'disconnected';
}


sub loop
{
    # This subroutine handles queues.

    my $time = time();
    $time =~ s/\.[0-9]+//;

    if($relay->{status} eq 'connected' and $relay->{time} < $time)
    {
        $relay->{time} = $time;
        recvChat();
    }
}

sub sendChat
{
    my($hook, $args) = @_;
    my $type;
    my $time = time();

    if($hook eq 'packet_guildMsg')
    {
        $type = 'guild';
    }
    elsif($hook eq 'packet_partyMsg')
    {
        $type = 'party';
    }
    elsif($hook eq 'packet_pubMsg')
    {
        $type = 'public';
    }
    elsif($hook eq 'packet_selfChat')
    {
        $type = 'self';
        $args->{Msg} = $args->{msg};
        $args->{MsgUser} = $args->{user};
    }
    elsif($hook eq 'packet_privMsg')
    {
        $type = 'private';
        $args->{MsgUser} = "From: ".$args->{MsgUser};
    }
    elsif($hook eq 'packet_sentPM')
    {
        $type = 'private';
        $args->{Msg} = $args->{msg};
        $args->{MsgUser} = "To: ".$args->{to};
    }
    elsif($hook eq 'packet_emotion')
    {
        $type = 'emote';
        $args->{Msg} = $args->{emotion};

        my $actor = Actor::get($args->{ID});
        $args->{MsgUser} = $actor->{name};

        if($actor->{actorType} ne 'Player')
        {
            return 0;
        }

        if($relay->{emoteSpam}->{$args->{ID}} + 3 > $time)
        {
            return 0;
        }

        if($relay->{lastEmote}->{$args->{ID}} eq $args->{emotion})
        {
            return 0;
        }

        $relay->{emoteSpam}->{$args->{ID}} = time();
        $relay->{lastEmote}->{$args->{ID}} = $args->{emotion};
    }
    elsif($hook eq 'packet_sysMsg')
    {
        $type = 'announcement';
        $args->{MsgUser} = "GM";
    }
    else
    {
        print("$hook\n");
        print(Dumper($args));
    }

    if($type)
    {
        if($relay->{ignore}->{$args->{Msg}})
        {
            delete $relay->{ignore}->{$args->{Msg}};
        }
        else
        {

            my $http = LWP::UserAgent->new;
            my $response = $http->post("http://localhost:1444",
                                        {'send' => 'true',
                                         'destination' => 'irc',
                                         'type' => $type,
                                         'message' => "<$args->{MsgUser}> $args->{Msg}",
                                         'secret' => $config{relay_secret}});
        }
    }
}

sub recvChat
{
    my $http = LWP::UserAgent->new;
    my $response = $http->post("http://localhost:1444",
                                {'recv' => 'true',
                                 'destination' => 'rags',
                                 'secret' => $config{relay_secret}});

    my @lines = split("\n", $response->decoded_content);

    foreach my $line (@lines)
    {
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;

        $relay->{ignore}->{substr($line, 2)} = 1;
        Commands::run($line);
    }
}

1;
