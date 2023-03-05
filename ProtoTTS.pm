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

use constant TTS_SERVICE_URL => 'https://ttsmp3.com';


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
        _voice   => 'Lucia',
        _source  => 'ttsmp3'

    }, $class;

}


sub set_message {

    my $self = shift;
    my $message = shift;

    $self->{_message} = $message;

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
#   Subroutine PLAY
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
#   Subroutine _GET_AUDIO_URL
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

    my $ttsmp3_json = $response->is_success ? decode_json( $response->decoded_content ) : {};

    return '' unless $ttsmp3_json;
    return $ttsmp3_json->{URL};

}


# --------------------------------------------
#
#   Subroutine _GET_PAGE_CONTENT
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
#   Subroutine LIST_SPEAKERS
#
# --------------------------------------------     
#
#   [Description]
# 
#   Gets a list of available voices from a TTS service
#
# --------------------------------------------
#
#   @return voices -> arrayref: voices available in the TTS service.
#
# --------------------------------------------


sub List_Speakers {

    my $response = $ua->get( TTS_SERVICE_URL );

    return unless $response->is_success;

    my $content = $response->decoded_content;

    my $voices = [];

    while ( $content =~ m/<option[^>]*>(.+?)<\/option>/ig ){
        my $voice = encode( 'utf-8', $1);
        push @$voices, $voice;
    }

    return $voices;

}


1;
