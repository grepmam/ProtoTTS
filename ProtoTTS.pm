package ProtoTTS;

use strict;
use warnings;

use JSON qw(decode_json);
use Encode qw(encode);
use File::Temp;

use LWP::UserAgent;
use Audio::Play::MPG123;


# --------------------------------------------
#
#   CONSTANTS
#
# --------------------------------------------

use constant {
    TTS_SERVICE_URL => 'https://ttsmp3.com',
    MAX_CHARACTERS  => 3000
};


# --------------------------------------------
#
#   GLOBALS
#
# --------------------------------------------

my $ua = LWP::UserAgent->new;



sub new {

    my $class = shift;

    return bless {

        _message => '',
        _voice   => 'Kimberly',
        _source  => 'ttsmp3'

    }, $class;

}


sub set_message {

    my $self = shift;
    my $message = shift;

    $self->{_message} = length $message > MAX_CHARACTERS ? substr $message, 0, MAX_CHARACTERS : $message;
    $self->{_message} = encode 'utf-8', $self->{_message};

    return;

}


sub set_voice {

    my $self = shift;
    my $voice = shift;

    $self->{_voice} = $voice;

    return;

}


# --------------------------------------------
#
#   METHOD play
#
# --------------------------------------------     
#
#   [Description]
# 
#   Plays the audio generated from the specified message and voice.
#
# --------------------------------------------
#
#   @param self -> object
#
# --------------------------------------------


sub play {

    my $self = shift;

    my $audio_url = $self->_get_audio_url;
    my $audio_content = $self->_get_page_content( $audio_url );

    return unless $audio_content;

    my $tempfile = File::Temp->new( SUFFIX => '.mp3' );
    print $tempfile $audio_content;
    close $tempfile;

    my $player = Audio::Play::MPG123->new;
    $player->load($tempfile->filename);
    $player->poll(1) until $player->state == 0;

    return;

}


# --------------------------------------------
#
#   METHOD _get_audio_url
#
# --------------------------------------------     
#
#   [Description]
# 
#   Generates the audio URL from the specified message and voice.
#
# --------------------------------------------
#
#   @param self -> object
#
#   @return url -> string: URL of the audio generated from the message and voice.
#
# --------------------------------------------


sub _get_audio_url {

    my $self = shift;
    my $message = $self->{_message};
    my $voice = $self->{_voice};
    my $source = $self->{_source};

    my $url = sprintf '%s/makemp3_new.php', TTS_SERVICE_URL;
    my $data = "msg=$message&lang=$voice&source=$source";

    my $response = $ua->post( $url, Content => $data );

    my $ttsmp3_json = $response->is_success ? decode_json $response->decoded_content : {};

    return '' unless $ttsmp3_json;
    return $ttsmp3_json->{URL};

}


# --------------------------------------------
#
#   METHOD _get_page_content
#
# --------------------------------------------     
#
#   [Description]
# 
#   Gets the page content from the specified URL.
#
# --------------------------------------------
#
#   @param self -> object: 
#   @param url -> string: URL
#
#   @return content -> string: page content retrieved from the specified URL.
#
# --------------------------------------------


sub _get_page_content {

    my $self = shift;
    my $url = shift;

    my $response = $ua->get( $url );

    return '' unless $response->is_success;
    return $response->decoded_content;

}


# --------------------------------------------
#
#   METHOD _get_speakers
#
# --------------------------------------------     
#
#   [Description]
# 
#   Gets a list of available speakers from a TTS service
#
# --------------------------------------------
#
#   @param self -> object
#
#   @return speakers -> hashref: a reference to a hash containing the available speakers, 
#                                where the keys are the languages and the values are arrays 
#                                of available voices for each language.
#
# --------------------------------------------


sub _get_speakers {
    
    my $self = shift;

    my $response = $ua->get( TTS_SERVICE_URL );

    return {} unless $response->is_success;

    my $content = $response->decoded_content;

    my $speakers = {};

    while ( $content =~ m/<option[^>]*>(.+?)<\/option>/ig ){
        my $item = encode 'utf-8', $1;
        my ( $lang, $voice ) = split /\s\/\s/, $item;
        $speakers->{$lang} = [] if ( ! exists $speakers->{$lang} );
        push @{$speakers->{$lang}}, $voice;
    }

    return $speakers;

}


# --------------------------------------------
#
#   METHOD list_langs
#
# --------------------------------------------     
#
#   [Description]
# 
#   Lists the languages available in a TTS service
#
# --------------------------------------------
# 
#   @param self -> object
#
#   @return void
#
# --------------------------------------------


sub list_langs {

    my $self = shift;
    my $speakers = $self->_get_speakers;

    return unless $speakers;

    my @langs = keys %$speakers;
    foreach my $lang (@langs){ print "$lang\n"; }

    return;

}


# --------------------------------------------
#
#   METHOD list_voices
#
# --------------------------------------------     
#
#   [Description]
# 
#   Lists the voices available for a given language in a TTS service
#
# --------------------------------------------
#
#   @param self -> object
#   @param lang -> string: language to list voices for
#
#   @return void
#
# --------------------------------------------


sub list_voices {

    my $self = shift;
    my $lang = shift;

    my $speakers = $self->_get_speakers;

    return unless $speakers;

    if ( ! exists $speakers->{$lang} ){
        print "Language does not exist\n";
        return;
    }

    my $voices = $speakers->{$lang};
    
    foreach my $voice (@$voices){ print "$voice\n"; }

    return;

}


# ---------------------------------------------------


sub Display_Banner {

    my $banner = q{

  _____           _     _______ _______ _____ 
 |  __ \         | |   |__   __|__   __/ ____|
 | |__) | __ ___ | |_ ___ | |     | | | (___  
 |  ___/ '__/ _ \| __/ _ \| |     | |  \___ \ 
 | |   | | | (_) | || (_) | |     | |  ____) |
 |_|   |_|  \___/ \__\___/|_|     |_| |_____/ 

           Created by: grepmam

};

    print $banner;

    return;

}


sub Display_Options {

    my $options = qq|
USAGE: ./lucia-notify [OPTIONS]

ProtoTTS is a small module for converting text to speech. 
It uses TTSMP3 as a base, therefore the length of the messages 
is limited. This project is unofficial so it may fail in the future.

ARGUMENTS:
  -m, --message MESSAGE    Message to be played by the voice
  -v, --voice VOICE        Voice to be used
  --list-voices LANG       List all available voices by language        
  --list-langs             List all available languages
  -h, --help               Display this

EXAMPLES:
  ./prototts -m 'Hello World!'
  ./prototts -m 'Hello John!' -v Amy
  ./prototts --list-langs
  ./prototts --list-voices 'British English'

    \n|;

    print $options;

    return;

}


1;
