package Take;
 
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

our $iList = {};
our $iDist = {};
our $iPos = {};
our $pos_from = {x => 0, y => 0};
our $pos_to = {x => 0, y => 0};
our $moving = 0;
our $movingTo = {};

Commands::register(["itemlist", "Items?", \&items]);
Commands::register(["distance", "Items?", \&dist]);
Commands::register(["spiral", "Items?", \&spiral]);

Plugins::register("Take", "Take all the things!", \&unload);
my $hooks = Plugins::addHooks(['mainLoop_post', \&loop],
								# Item packets
								['packet/item_exists', \&itemAppeared],
								['packet/item_appeared', \&itemAppeared],
								['packet/item_disappeared', \&itemDisappeared],
								['packet/inventory_item_added', \&defaultHandler],
								['packet/use_item', \&defaultHandler],
								# Character packets
								['packet/character_moves', \&characterMoved]
								);

sub unload
{
	Plugins::delHooks($hooks);
}
 
our $timeout = time();
 
sub loop
{
	# Get time
	# Timeout every so often
	# Check char position vs position of item we're moving to
	# Run spiral if < 1.5
	
	my $time = Time::HiRes::time();
	
	if($time > $timeout)
	{
		$timeout = $time + 0.1;
		
		#print("Time: $time\n");
		
		
		if($moving > 0)
		{
			my $distance = distance(calcPosition($char), $movingTo);
		
			print("Distance: $distance\n");
		
			if($distance <= 1)
			{
				$moving--;
				spiral();
			}
			
#			$moving = 0;
		}
	}
}

sub look
{
	my($looked, $position) = @_;
	
	if($iPos->{$position->{x}}->{$position->{y}})
	{
		my($id, $item) = each(%{$iPos->{$position->{x}}->{$position->{y}}});
		
		$looked->{status} = 'found';
		print("Item found at $position->{x}, $position->{y} \n");
		
		my $distance = distance(calcPosition($char), $position);
		
		if($distance > 1)
		{
			$moving = 5;

			# Too far, let's move!
			$char->move(@{$position}{qw(x y)});
			$movingTo = $position;
		}
		else
		{
			$messageSender->sendTake($id);
		}
	}
	
	$looked->{$position->{x}}->{$position->{y}} = 1;	
	return $looked;
}

# Uhh... it... works?
sub spiral
{
	my $position = calcPosition($char);
	my $looked = {};
	
	$Data::Dumper::Terse = 1;        
    $Data::Dumper::Indent = 0;       
	
	# Output the origin
#	print(Dumper($position)."\n");
	
	my $changeX = 0;
	my $changeY = 1;
	my $length = 1;
	
	my $directions =
	[
		{name => 'north', x => 0, y => 1},
		{name => 'east', x => 1, y => 0},
		{name => 'south', x => 0, y => -1},
		{name => 'west', x=> -1, y => 0}
	];
	
	# First we look at the origin
	$looked = look($looked, $position);
	
	my $count = 1;
	
	for(my $step = 1; $step < 20; $step++)
	{
		my $previous = $directions->[-1];
		my $direction = shift @{$directions};
		push @{$directions}, $direction;
		
		# Uhhh.... only increase the length once per loop
		my $lengthIncreased = 0;
		
		for(my $remaining = $length; $remaining > 0; $remaining--)
		{
			last if($looked->{status} eq 'found');			

			my $nextPosition =
			{
				x => $position->{x} + $direction->{x},
				y => $position->{y} + $direction->{y}
			};
			
			# Have we already looked here?
			if($looked->{$nextPosition->{x}}->{$nextPosition->{y}})
			{				
				# Do the last step once more
				$position->{x} += $previous->{x};
				$position->{y} += $previous->{y};
			
				if(!$lengthIncreased)
				{
					$lengthIncreased = 1;
					$length++;
				}
								
			#	print("$count :: $position->{x}, $position->{y} :: ");
			#	print("$length - $remaining - $previous->{name} :: COLLISION \n");
				
			}
			else
			{
				$position = $nextPosition;
				
			#	print("$count :: $position->{x}, $position->{y} :: ");
			#	print("$length - $remaining - $direction->{name} \n");
			}

			#print("------------------------------------------------------\n");

			# Look at the new position
			$looked = look($looked, $position);		
			$count++;
		}
	}
	
#	print(Dumper
}

sub dist
{
	my $pos = calcPosition($char);
	
	print("Current position: $pos->{x}, $pos->{y} \n");

	while(my($id, $item) = each(%{$iList}))
	{
		print("Distance: ".distance($pos, {x => $item->{x}, y => $item->{y}})." \n");
	}	
}

sub items
{
    $Data::Dumper::Terse = 0;        # Output MORE!
    $Data::Dumper::Indent = 1;       # Output whitespace
    $Data::Dumper::Maxdepth = 10;       # Output whitespace
	
	print(Dumper($iList));
	print(Dumper($iPos));
}

sub characterMoved
{
	#print("Moving!\n");
	#print(Dumper($args)."\n");
	
	
	if($moving)
	{
		#$moving = 0;
	}
	
#	while(my($id, $item) = each(%{$iList}))
#	{
#		print("Distance: ".distance($char->{pos_to}, {x => $item->{x}, y => $item->{y}})." \n");
#	}	
	
#	print(Dumper($char->{pos}));
#	print(Dumper($char->{pos_to}));
}

sub itemAppeared
{
	my($hook, $args) = @_;
	print("Hook: $hook \n");

	delete($args->{KEYS});
	
    $Data::Dumper::Terse = 0;        # Output MORE!
    $Data::Dumper::Indent = 1;       # Output whitespace
	
#	print(Dumper($args));
#	print(unpack('V', $args->{ID}));
#	print("\n============\n");
	
	$iList->{$args->{ID}} =
	{
		x => $args->{x},
		y => $args->{y},
		type => $args->{nameID},
		amount => $args->{amount}
	};
	
	# We save the type and amount in the position hash to allow for prioritization
	$iPos->{$args->{x}}->{$args->{y}}->{$args->{ID}} =
	{
		type => $args->{nameID},
		amount => $args->{amount}
	};
	
	my $items = scalar keys %{$iList};
	print("$items items on screen.\n");
	
	# More more!
	spiral();
}

sub itemDisappeared
{
	my($hook, $args) = @_;
	print("Hook: $hook \n");

	delete($args->{KEYS});
	
    $Data::Dumper::Terse = 0;        # Output MORE!
    $Data::Dumper::Indent = 1;       # Output whitespace

#	print(Dumper($args));
#	print(unpack('V', $args->{ID}));
#	print("\n============\n");
	
	my $x = $iList->{$args->{ID}}->{x};
	my $y = $iList->{$args->{ID}}->{y};

	delete($iPos->{$x}->{$y}->{$args->{ID}});	
	
	if(!%{ $iPos->{$x}->{$y} })
	{
		delete($iPos->{$x}->{$y});
		
		if(!%{ $iPos->{$x} })
		{
			delete($iPos->{$x});
		}
	}
	
	delete($iList->{$args->{ID}});
	
	my $items = scalar keys %{$iList};
	print("$items items on screen.\n");
	
	# Are there still items? Pick them up!
	spiral();
}

sub serverHandler
{
	my($hook, $args) = @_;
	print("Hook: $hook \n");
	
	if($hook eq "packet/account_server_info")
	{
		my $server_info =
		{
			'accountID' => $args->{accountID},
			'accountSex' => $args->{accountSex},
			'servers' => $args->{servers}
		};
		
		$Data::Dumper::Indent = 0;       # Don't output whitespace	
		print(Dumper($server_info) . "\n");
	}
	else
	{
		print(Dumper($args));
	}
}

sub defaultHandler
{
	my($hook, $args) = @_;
	print("Hook: $hook \n");
}

sub verboseHandler
{
	my($hook, $args) = @_;
	print("Hook: $hook \n");

	delete($args->{KEYS});
	
    $Data::Dumper::Terse = 0;        # Output MORE!
    $Data::Dumper::Indent = 1;       # Output whitespace

	print(Dumper($args));
	print("============\n");
}


1;