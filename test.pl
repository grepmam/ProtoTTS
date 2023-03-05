#!/usr/bin/perl

use strict;
use warnings;

use lib '.';
use ProtoTTS;


my $prototts = ProtoTTS->new;
$prototts->set_message('Prueba de voz lucia.');
$prototts->set_voice('Lucia');
$prototts->play;


my $voices = ProtoTTS->List_Speakers;

foreach my $voice (@$voices) {
    print "$voice\n";
}
