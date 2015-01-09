package MarketSearch;

use strict;
use Plugins;
require HTTP::Request;
require LWP::UserAgent;
use Data::Dumper;

Plugins::register("Market Search", "What're those prices?", \&Unload);
my $Hooks = Plugins::addHooks(['mainLoop_post', \&Loop],
                                ["packet_pubMsg", \&ParseChat],
                                ["packet_guildMsg", \&ParseChat],
                                ["packet_selfChat", \&ParseChat],
                                ["packet_privMsg", \&ParseChat]);

sub Unload
{
    Plugins::delHooks($Hooks);
}


my %Option;
my @Queue;
my $Timer;

sub Loop
{
    # Slow things down so the server doesn't kill us.
    
    my $Time = time();
    $Time =~ s/\.[0-9]+//;
    
    if($Time > $Timer)
    {
        $Timer = $Time + 1;
    
        # Stuff to do every second.    
        # Check the shop queue!

        foreach my $Command (@Queue)
        {
            shift(@Queue);
            Commands::run($Command);
            last;
        }
    }
}

sub ParseChat
{
    my($Type, $Args) = @_;
    my($User, $Message);
    
    if($Type eq 'packet_selfChat')
    {
        $User = 'me';
        $Message = $Args->{'msg'};
    }
    else #if($Type eq 'packet_pubMsg')
    {
        $User = $Args->{'MsgUser'};
        $Message = $Args->{'Msg'};
    }
    
    my $Time = time();
    $Time =~ s/\.[0-9]+//;
    $Message = lc($Message);
    
    
    if($Message =~ m/^market\s+(\S+)\s+(.+)$/)
    {
        our $response;
    
        if($1 eq 'search')
        {
            if($Type eq 'packet_privMsg')
            {
#                push(@Queue, "pm \"$User\" Searching RagnaStats.com...");
            }
            else
            {
#                Commands::run("c Searching RagnaStats.com...");
            }
            
            my $request = HTTP::Request->new(GET => "http://ragnastats.com/gamesearch.php?q=$2");
            my $ua = LWP::UserAgent->new;
            $response = $ua->request($request);
        }
        
        if($1 eq 'average')
        {
            if($Type eq 'packet_privMsg')
            {
#                push(@Queue, "pm \"$User\" Searching RagnaStats.com...");
            }
            else
            {
#                Commands::run("c Searching RagnaStats.com...");
            }
            
            my $request = HTTP::Request->new(GET => "http://ragnastats.com/gameaverage.php?q=$2");
            my $ua = LWP::UserAgent->new;
            $response = $ua->request($request);
        }
        
        if($response)
        {
            my @Lines = split("\n", $response->{_content});
            my $Count = 0;
            my %Skip = {};
        
            foreach my $Line (@Lines)
            {
                if($Line =~ m/([0-9]+)\. (.+?)$/)
                {
                    $Option{$1} = $Lines[$Count + 1];
                    
                    $Skip{$Count + 1} = 1;
                }
            
                if(!$Skip{$Count})
                {
                    if($Type eq 'packet_privMsg')
                    {
                        push(@Queue, "pm \"$User\" $Line");
                    }
                    elsif($Type eq 'packet_guildMsg')
                    {
                        Commands::run("g $Line");
                    }
                    else
                    {
                        Commands::run("c $Line");
                    }
                }
                
                $Count++;
            }
        }
    
        
        #print(Dumper($response));
        #Commands::run("c $Message");
    }
    elsif(%Option)
    {
        if($Message =~ m/^([0-9]+)$/)
        {
            if($Option{$1})
            {
                print("$Option{$1}\n");
            
                my $request = HTTP::Request->new(GET => "http://ragnastats.com/gamesearch.php?id=$Option{$1}");
                my $ua = LWP::UserAgent->new;
                my $response = $ua->request($request);

                my @Lines = split("\n", $response->{_content});
            
                foreach my $Line (@Lines)
                {
                    if($Type eq 'packet_privMsg')
                    {
                        push(@Queue, "pm \"$User\" $Line");
                    }
                    elsif($Type eq 'packet_guildMsg')
                    {
                            Commands::run("g $Line");
                    }
                    else
                    {
                        Commands::run("c $Line");
                    }
                }
            }
        }
    }
}


1;
