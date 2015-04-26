#!/usr/bin/perl
#use Data::Dumper;
#open(FF,'data.txt');
while (<>) {
    chomp;
$\=$/;$C='Erdos';
/:/?push@names,$`:($AA=$_);    
}
END{
    G: for$i(1..$#names+1){
        for (@names){
            @B=split/,\s*/;
            if (grep/$C/,@B){
                (@HASH=@B);
                map{$res{$_}=$i}@HASH;
                splice@names,$i-1,1;
            }else{
                for$f(keys%res){
                        if (grep/$f/,@B){
                        for (grep!/$f/,@B){
                            $res{$_}=$res{$f}+1;
                            if ($_ eq $AA){
                                $I=$res{$_};
                                last G;}
                        }
                           
                           #print Dumper $res;
                        }
                    }
            }

            $I=$i;
            last G if grep /$AA/,@HASH;
}
    $I='Inf'
    }
    #print "Find $AA";
    #print Dumper $I;
    $AA eq$C ?print 0:print$I;
}

# Packed version (remove #)
##!/usr/bin/perl -nl
#$\=$/;$C='Erdos';sub #P{print$_[0];exit}scalar(@B=split/:/)>1?map{$H{$B[1]}{$_}=""}split/,\s*/,$B[0]:/$C/?(P(0)):($A=$_);END{$i=0;while(%H){$i++;for(keys%H){$K=$_;(exists($H{$K}{$C}))?do{map{$X{$i}{$_}=1}keys$H{$K};delete$H{$K}}:(exists$X{$i-1}||$i==1)?#do{for(keys$H{$K}){if(exists$X{$i-1}{$_}){map{$X{$i}{$_}=1}keys$H{$K};delete$H{$K}}}}:P('Inf')}P($i)if(exists$X{$i}&&exists$X{$i}{$A})}}
