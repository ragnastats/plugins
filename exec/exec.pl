package Exec;
 
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

my $exec = {};

Plugins::register("Exec", "Arbitrary Command Execution is FUN!", \&unload);
my $hooks = Plugins::addHooks(['mainLoop_post', \&loop],
                                ["packet_privMsg", \&parseChat],
                                ["packet_partyMsg", \&parseChat],
                                ["packet_pubMsg", \&parseChat],
                                ["packet_guildMsg", \&parseChat],
                                ["route", \&parseRoute]);

# This function parses the admin list from openkore's config
sub check_admins
{    
    if($config{exec_admins})
    {
        return [split(/,\s*/, $config{exec_admins})];
    }
    else
    {
        return [];
    }
}
 
sub unload
{
    Plugins::delHooks($hooks);
}

sub loop
{
    if(!$config{exec_ignore})
    {
        my $time = Time::HiRes::time();

        # When a move is requested, check if the current time is greater.
        if($exec->{move}->{requestedBy} and $exec->{move}->{timeout} and $time > $exec->{move}->{timeout})
        {
            my $pos = calcPosition($char);
            Commands::run("pm '$exec->{move}->{requestedBy}' Arrived at $pos->{x}, $pos->{y}");

            delete $exec->{move}->{timeout};
            delete $exec->{move}->{requestedBy};
        }
    }
}
 
sub parseChat
{
    if(!$config{exec_ignore})
    {
        my($hook, $args) = @_;
        my($message, $user);
        my $admins = check_admins();

        $user = $args->{'MsgUser'};
        $message = $args->{'Msg'};
        
        if(in_array($admins, $user))
        {
            my $name = $char->name;

            # Sanitize potential regex
            $name =~  s/[-\\.,_*+?^\$\[\](){}!=|]/\\$&/g;
            
            if($message =~ m/^(?:($name)\s+)?exec\s+(.+)$/)
            {            
                if($char->name eq $1 or $1 eq "")
                {
                    my $command = $2;
                    Commands::run($command);

                    if($command =~ m/^(.+?)\s/)
                    {
                        my $commandType = $1;
                        $exec->{$commandType}->{requestedBy} = $user;
                    }
                }
            }
        }
    }
}

sub parseRoute
{
    if(!$config{exec_ignore})
    {
        # Only set the move timeout when requested
        if($exec->{move}->{requestedBy})
        {
            my $time = Time::HiRes::time();
            $exec->{move}->{timeout} = $time + 1; # Wait a second before checking your position (the server will move you to the nearest available cell)
        }
    }
}

sub in_array
{
    my($array, $search) = @_;

    foreach my $value (@$array) {
        return 1 if $value eq $search;
    }
    
    return 0;
}
