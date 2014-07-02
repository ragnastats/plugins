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
our $timeout; # The last time we looped
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
	my $time = time();

    # Should do some sort of timing thing here?
    # Also wait until arrival for movement?
    
    if($status eq "replay" and $timeout < $time)
    {
        # Increment the step and run that line
		
		if($step < scalar(@replay))
		{
			Commands::run($replay[$step]);
			$step++;
		}
		
		# Set the timeout ^_~
		$timeout = $time;
    }
}

sub command
{
    my($hook, $action) = @_;

    if($status eq "record")
    {
		# Don't record recordings!
		if($action->{switch} !~ /record|replay/i)
		{
			push(@record, "$action->{switch} $action->{args}");
		}
	}
}

# Ensure a recordings directory exists on load
# TODO: Actually make this work?
if(-d 'recordings')
{
    mkdir('recordings', 0755);
}

# Function to format filenames
sub filename
{
    my($file) = @_;

    # Set the filename to the current time if none is specified
    if($file eq "")
    {
        $file = time();
    }
        
    return $file.".record";
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
	elsif($action[0] eq "print")
	{
		print(Dumper(@record));
	}
    elsif($action[0] eq "save")
    {
		if($action[1]) {
			$filename = $action[1];
		}

		# Only save when there's a filename defined
		if($filename)
		{
			my $fh;
			open($fh, '>', "recordings/$filename"); 

			foreach my $command (@record)
			{
				print "Writing $command\n";
				print $fh "$command\n";
			}

			close($fh);
			
			Log::message "Record saved - $filename \n";
		}
		
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
        $filename = ($action[1]) ? $action[1] : "";
		
		if($filename)
		{
			$filename .= ".record";
			$step = 0;
		
			my $fh;
			open($fh, '<', "recordings/$filename"); 
			@replay = ();
			
			while(<$fh>)
			{
				chomp;
				push @replay, $_;
			}
			
			close($fh);
		
			&replay_start;
		}
    }
    elsif($action[0] eq "stop") 
    {
        &replay_stop;
    }
}

1;