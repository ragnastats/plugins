package Reconnect;

# Perl includes
use strict;

# Kore includes
use Settings;
use Plugins;
use Network;
use Globals;


our $reconnect ||=
{
    'timeout' =>
    [
        30,     # 30 seconds
        60,     # 1 minute
        60,     # 1 minute
        180,    # 3 minutes
        180,    # 3 minutes
        300,    # 5 minutes
        300,    # 5 minutes
        900,    # 15 minutes
        900,    # 15 minutes
        1800,   # 30 minutes
        3600    # 1 hour
    ],

    'random'        => 15,
    'counter'       => 0
};

Plugins::register("Reconnect", "Version 0.1 r7", \&unload);

my $hooks = Plugins::addHooks(
    ['mainLoop_post', \&loop],
    ['packet/received_character_ID_and_Map', \&connected]
);

sub unload
{
        Plugins::delHooks($hooks);
}

sub loop
{
    my $time = time();

    if(Network::DirectConnection::getState() == Network::NOT_CONNECTED and $reconnect->{time} < $time)
    {
        my $reconnectTime = @{$reconnect->{timeout}}[$reconnect->{counter}];

        if($reconnect->{random})
        {
            $reconnectTime += int(rand($reconnect->{random}));
        }

        $reconnect->{time} = $time + $timeout{reconnect}->{timeout};
        $timeout{reconnect} = {'timeout' => $reconnectTime};

        my $sizeOf = @{$reconnect->{timeout}};
        if($reconnect->{counter} < $sizeOf - 1)
        {
            $reconnect->{counter}++;
        }
    }
}

sub connected
{
    my $time = time();
    $reconnect->{counter} = 0;

    my $reconnectTime = @{$reconnect->{timeout}}[$reconnect->{counter}];

    if($reconnect->{random})
    {
        $reconnectTime += int(rand($reconnect->{random}));
    }

    $timeout{reconnect} = {'timeout' => $reconnectTime};
}

1;
