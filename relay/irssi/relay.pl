use strict;
use vars qw($VERSION %IRSSI);

use Irssi qw(command_bind signal_add);

use HTTP::Request;
use LWP::UserAgent;
use Data::Dumper;
use Text::Wrap;
#use JSON;


$VERSION = '0.1';
%IRSSI = (
        authors         => 'Rachel Derp',
        contact         => 'rachelderp@gmail.com',
        name            => 'relay',
        description     => 'Relay messages between IRC and Ragnarok.',
        license         => 'GPL',
);

sub relay {
        my ($server, $msg, $nick, $address, $target) = @_;
        my ($type, $prefix);

        if($msg =~ m/^market\s+(\S+)\s+(.+)$/i)
        {
                my $response;
                my $keyword = lc($1);

                if($keyword eq 'search')
                {
                        my $request = HTTP::Request->new(GET => "http://CHANGE_ME_SERVER/gamesearch.php?q=$2");
                        my $ua = LWP::UserAgent->new;
                        $response = $ua->request($request);
                }

                elsif($keyword eq 'average')
                {
                        my $request = HTTP::Request->new(GET => "http://CHANGE_ME_SERVER/gameaverage.php?q=$2");
                        my $ua = LWP::UserAgent->new;
                        $response = $ua->request($request);
                }

                else
                {
                        $response->{_content} = "Sorry, I don't know what you meant. I only know how to... \n";
                        $response->{_content} .= " - market search item \n";
                        $response->{_content} .= " - market average item \n";
                }

                if($response)
                {
                        my @lines = split("\n", $response->{_content});
                        my $count = 0;
                        my %skip = {};

                        foreach my $line (@lines)
                        {
                                if($line =~ m/([0-9]+)\. (.+?)$/)
                                {
                                        $skip{$count + 1} = 1;
                                }

                                if(!$skip{$count})
                                {
                                        $server->command("msg #ragnastats $line");
                                }

                                $count++;
                        }
                }
        }
        else
        {
                if($msg =~ m/^!(?:c|(?:pub(?:lic)?))\s+(.*)$/i)
                {
                        $msg = $1;
                        $type = 'public';
                        $prefix = 'c';
                }
                elsif($msg =~ m/^!t(?:roll)?\s+(.*)$/i)
                {
                        $msg = $1;
                        $type = 'troll';
                        $prefix = 'c';
                }
                elsif($msg =~ m/^!(?:pm|private)?\s+(.*)$/i)
                {
                        $msg = $1;
                        $type = 'private';
                        $prefix = 'pm';
                }
        elsif($msg =~ m/^!p(?:arty)?\s+(.*)$/i)
                {
                        $msg = $1;
                        $type = 'party';
                        $prefix = 'p';
                }
        elsif($msg =~ m/^!e(?:mote)?\s+(.*)$/i)
                {
                        $msg = $1;
                        $type = 'emote';
                        $prefix = 'e';
                }
        elsif($msg =~ m/^!pl(?:\s+(.*))?/i)
        {
            $msg = $1;
            $type = 'command';
            $prefix = 'pl';
        }
        elsif($msg =~ m/^!(move|south|north|east|west)\s+(.*)$/i)
        {
            $msg = $2;
            $type = 'command';
            $prefix = $1;
        }
                else
                {
                        $type = 'guild';
                        $prefix = 'g';
                }

                if($target eq '#ragnastats' || $target eq '#relay')
                {
                        my $message = $msg;
                        my $columns = 75 - length($nick);

                        $Text::Wrap::columns=$columns;
                        $Text::Wrap::separator="\n$prefix <$nick> ";

            if($type eq 'public' or $type eq 'party' or $type eq 'guild')
            {
                $message = "$prefix <$nick> ".wrap('', '',$message);
            }
            else
            {
                $message = "$prefix ".wrap('', '',$message);
            }

                        my $http = LWP::UserAgent->new;
                        my $response = $http->post("http://CHANGE_ME_SERVER/relay.php",
                                                                                {'send' => 'true',
                                                                                 'destination' => 'rags',
                                                                                 'type' => $type,
                                                                                 'message' => $message,
                                                                                 'secret' => 'CHANGE_ME SHARED SECRET'});

                        #print($response->decoded_content); 
                }
        }
}

sub check_stats
{
        my $server = Irssi::active_server();

        if(!$server)
        {
                return;
        }

        my $http = LWP::UserAgent->new;
        my $response = $http->post("http://CHANGE_ME_SERVER/relay.php",
                                                                {'recv' => 'true',
                                                                 'destination' => 'irc',
                                                                 'secret' => 'CHANGE_ME SHARED SECRET'});
        #print($response->decoded_content."\n"); 

        if($response->is_success)
        {
                my @lines = split(/\n/, $response->decoded_content);

                foreach my $line (@lines)
                {
            # Default target
            my $target = "#relay";

                        if($line =~ /^\[guild/) {
                $target = "#ragnastats";
                                $line = "^C3$line";
                        }
                        elsif($line =~ /^\[party/) {
                                $line = "^C7$line";
                        }
                        elsif($line =~ /^\[emote/) {
                                $line = "^C14$line";
                        }
                        elsif($line =~ /^\[private/) {
                $target = "#ragnastats";
                                $line = "^C8$line";
                        }
                        elsif($line =~ /^\[announcement/) {
                                $line = "^C8$line";
                        }
                        elsif($line =~ /^\[public/) {
                                $line = "^C9$line";
                        }

                        $server->command("msg $target $line");
                }
        }
        else
        {
                print($response->status_line);
        }
}

my $timer = Irssi::timeout_add(1000, \&check_stats, []);

signal_add("message public", "relay");
