#!/usr/bin/perl
use strict;
use Socket;
$| = 1;
open(FH, "<", "puzzle.txt") or die 'qwe';

my $puz_start=1;
my @puzzile=();
my $socket = new IO::Socket::INET (
    PeerHost => 'edgy.2015.ghostintheshellcode.com',
    PeerPort => '44440',
    Proto => 'tcp',
);
die "cannot connect to the server $!\n" unless $socket;
print "connected to the server\n";

#$socket->autoflush(1);
my $data = undef;
my $counter=0;
while (1) {
    print "Start solve ".$counter++."\n";
    sleep 1;
    
    $/="";    
    $data=<FH>;
    #$socket->recv($data,4096);
    my @lines=split"\n",$data;
    for my $line (@lines) {
        print $line."\n";
        if ($line=~/Password/) {
            $socket->send("EdgesAreFun\n");
        }
        
        if ($line=~/^\-+$/ && $puz_start==1) {
            $puz_start=0;
            @puzzile=();
            my @puz_line = split//,$line;
            push @puzzile,\@puz_line;
            next;
        }
        if ($line =~ /^[\-\|]/) {
            my @puz_line = split//,$line;
            push @puzzile,\@puz_line;
        }
        if ($line=~/maximum\s+of\s+(\d+)\smoves/) {
            $puz_start=1;
            my $variant=try_puzzle(\@puzzile,$1);
            #my $variant=solve_puzzle(\@puzzile,$1);
            print "Send $variant\n";
            $socket->send("$variant\n");
        }
    }
}
sub start_pos{
    my $puzzile_ref=shift;
    my $y=0;
    for my $pline (@$puzzile_ref){
        my $x=0;
        for my $item (@$pline){
            return($x,$y) if $item eq '@';
            $x++;
        }
        $y++;    
    }
}


sub solve_puzzle{
    my $puzzile_ref=shift;
    my $scount=shift;
    my @data = ('W','A','S','D');
 #   my @variants = variations_with_repetition(\@data, $scount);
    my($start_x,$start_y)=start_pos($puzzile_ref);
    print "work with $scount\n";
    VARIANT: for my $variant (variations_with_repetition(\@data, $scount)){
        my $cur_x_pos=$start_x;
        my $cur_y_pos=$start_y;
        my $sentense='';
        while(1){
            STEP: for my $step (@$variant){
                $sentense.=$step;
                next VARIANT if $sentense =~ /(AD)|(DA)|(WS)|(SW)/;
                $cur_y_pos-- if $step eq 'W';
                $cur_y_pos++ if $step eq 'S';
                $cur_x_pos-- if $step eq 'A';
                $cur_x_pos++ if $step eq 'D';
                next STEP if ($puzzile_ref->[$cur_y_pos][$cur_x_pos] eq ' ');
                next STEP if ($puzzile_ref->[$cur_y_pos][$cur_x_pos] eq '@');
                next VARIANT if ($puzzile_ref->[$cur_y_pos][$cur_x_pos] eq 'x');
                return join'',@$variant if ($puzzile_ref->[$cur_y_pos][$cur_x_pos] eq '-' || $puzzile_ref->[$cur_y_pos][$cur_x_pos] eq '|');
            }
        }
    }
    print "OOPS!! no variants\n";
    
}
sub check_way{
    my $puzzile_ref=shift;
    my $variant=shift;
    my @data = ('W','A','S','D');
    my($start_x,$start_y)=start_pos($puzzile_ref);
    my $cur_x_pos=$start_x;
    my $cur_y_pos=$start_y;
    my $sentense='';
    while(1){
        STEP: for my $step (@$variant){
            $sentense.=$step;
                        if (length($sentense)>3000){
                return 0;
            }
            return 0 if $sentense =~ /(AD)|(DA)|(WS)|(SW)/;
            $cur_y_pos-- if $step eq 'W';
            $cur_y_pos++ if $step eq 'S';
            $cur_x_pos-- if $step eq 'A';
            $cur_x_pos++ if $step eq 'D';
#            print "check ".$puzzile_ref->[$cur_y_pos][$cur_x_pos]." at $cur_y_pos:$cur_x_pos \n";
            next STEP if ($puzzile_ref->[$cur_y_pos][$cur_x_pos] eq ' ');
            next STEP if ($puzzile_ref->[$cur_y_pos][$cur_x_pos] eq '@');
            return 0 if ($puzzile_ref->[$cur_y_pos][$cur_x_pos] eq 'x');
            return join'',@$variant if ($puzzile_ref->[$cur_y_pos][$cur_x_pos] eq '-' || $puzzile_ref->[$cur_y_pos][$cur_x_pos] eq '|');
        }
    }
}

sub check_step{
    my $puzzile_ref=shift;
    my $variant=shift;
    my @data = ('W','A','S','D');
    my($start_x,$start_y)=start_pos($puzzile_ref);
    my $cur_x_pos=$start_x;
    my $cur_y_pos=$start_y;
    my $sentense='';
        STEP: for my $step (@$variant){
            $sentense.=$step;
            if ($sentense eq 'ASSS') {
                print"";
            }
            
            if (length($sentense)>3000){
                return 0;
            }
            return 0 if $sentense =~ /(AD)|(DA)|(WS)|(SW)/;
            $cur_y_pos-- if $step eq 'W';
            $cur_y_pos++ if $step eq 'S';
            $cur_x_pos-- if $step eq 'A';
            $cur_x_pos++ if $step eq 'D';
#            print "check ".$puzzile_ref->[$cur_y_pos][$cur_x_pos]." at $cur_y_pos:$cur_x_pos \n";
            next STEP if ($puzzile_ref->[$cur_y_pos][$cur_x_pos] eq ' ');
            next STEP if ($puzzile_ref->[$cur_y_pos][$cur_x_pos] eq '@');
            return 0 if ($puzzile_ref->[$cur_y_pos][$cur_x_pos] eq 'x');
            return join'',@$variant if ($puzzile_ref->[$cur_y_pos][$cur_x_pos] eq '-' || $puzzile_ref->[$cur_y_pos][$cur_x_pos] eq '|');
        }
    return 1;
}

sub try_puzzle($$){
    my $pussile=shift;
    my $max_len=shift;
    my @sdata = ('W','A','S','D');
    my @all;
    push @all,[$_] for (@sdata);
    my $del_hash={};
    while (1) {
        my $res='';
        my @cur;
        %$del_hash=();
        for my $i (0..$#all){
            die "too long" if scalar @{$all[$i]} > $max_len;
            if ($res=check_step($pussile,$all[$i])) {
                print "good ".(join"",@{$all[$i]})."\n";
#                return join"",@{$all[$i]};
                if ($res=check_way($pussile,$all[$i])){
                    print "!!!!!! solved with $res\n";
                    return $res;
                }
            }
            else{
                print "miss ".(join"",@{$all[$i]})."\n";
                $del_hash->{$i}=1;
            }   
        }
        for my $key (sort {$b<=>$a} keys %$del_hash){
            splice(@all, $key, 1);
        }
        my $to_del=$#all;
        for my $i (0..$#sdata){
 #           push $all[$i],[$_]
            for my $ii (0..$to_del){
#                print '@all have '.$#all.' todel have'.$to_del."\n";
                push @all,[@{$all[$ii]},$sdata[$i]];
            }
        }
        for my $dk(0..$to_del){
            shift @all; 
        }
    }    
    print "good\n" if check_way($pussile,);
    return 0;
}