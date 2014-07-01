package Record;
 
# Perl includes
use strict;
use Data::Dumper;
 
# Kore includes
use Settings;
use Plugins;
use Network;
use Globals;
use Log;

our $status; # The current status of the plugin
our $filename; # The filename we're currently reading from / writing to
our $step; # The line number we're on when replaying
our @record;
our @replay;
 
Commands::register(["record", "Usage: record [action] [output file name]", \&record]);
Commands::register(["replay", "Usage: replay [action] [input file name]", \&replay]);
Plugins::register("NPC Talk", "Talk to NPCs by Name", \&unload);

my $hooks = Plugins::addHooks(  ['mainLoop_post', \&loop],
                                ['Commands::run/pre', \&command]);

sub unload
{
    Plugins::delHooks($hooks);
}

sub loop
{
    # Should do some sort of timing thing here?
    # Also wait until arrival for movement?
    
    if($status eq "replay")
    {
        # Increment the step and run that line
    }
}

sub command
{
    my($hook, $action) = @_;

    print("$hook \n");
    print(Dumper($action));

    if($status eq "record")
    {
        # Push command to @record
    }
}

# Ensure a recordings directory exists on load
if(-d 'recordings')
{
    mkdir 'recordings', 0755;
}

# Function to format filenames
sub filename
{
    my($file) = @_;

    # Set the filename to the current time if none is specified
    if($file eq "")
    {
        $file = strftime "%F_%H-%M-%S", localtime;
    }
        
    return $file."record";
}


#
# Recording functions
################################


sub record_start
{
    $status = "record";
    Log::message "Recording started - $filename \n";
}

sub record_stop
{
    $status = "";
    Log::message "Recording stopped. \n";
}

sub record
{
    my(undef, $actions) = @_;
    my @action = split(" ", $actions);

    if($action[0] eq "start")
    {
        $filename = filename($action[1]);
        &record_start;
    }
    elsif($action[0] eq "stop") 
    {
        &record_stop;
    }
    elsif($action[0] eq "save")
    {
        $filename = filename($action[1]);

        my $fh;
        open($fh, '>', "recordings/$filename"); 

        foreach my $command (@record)
        {
            print $fh "$command\n";
        }

        close($fh);
        
        Log::message "Record saved - $filename \n";
        &record_stop;
    }
    elsif($action[0] eq "clear")
    {
        @record = ();

        Log::message "Record cleared - $filename \n";
        &record_stop;
    }
}


#
# Replay functions
################################


sub replay_start
{
    $status = "replay";
    Log::message "Replay started - $filename\n";
}

sub replay_stop
{
    $status = "";
    Log::message "Replay stopped. \n";
}

sub replay
{
    my(undef, $actions) = @_;
    my @action = split(" ", $actions);

    if($action[0] eq "start")
    {
        $filename = filename($action[1]);
        &replay_start;
    }
    elsif($action[0] eq "stop") 
    {
        &replay_stop;
    }
}

1;