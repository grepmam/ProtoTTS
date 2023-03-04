package ProtoTTS;

use strict;
use warnings;

use JSON;
use File::Temp;
use LWP::UserAgent;
use Audio::Play::MPG123;



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


sub play {

    my $self = shift;

    my $audio_url = $self->_get_audio_url;
    my $audio_content = $self->_get_audio_content( $audio_url );

    return unless $audio_content;

    my $tempfile = File::Temp->new( SUFFIX => '.mp3' );
    print $tempfile $audio_content;
    close $tempfile;

    my $player = Audio::Play::MPG123->new;
    $player->load($tempfile->filename);
    $player->poll(1) until $player->state == 0;

    return;

}


sub _get_audio_url {

    my $self = shift;
    my $message = $self->{_message};
    my $voice = $self->{_voice};
    my $source = $self->{_source};

    my $ttsmp3_url = 'https://ttsmp3.com/makemp3_new.php';
    my $data = "msg=$message&lang=$voice&source=$source";

    my $response = $ua->post( $ttsmp3_url, Content => $data );

    my $ttsmp3_json = $response->is_success ? decode_json( $response->decoded_content ) : {};

    return '' unless $ttsmp3_json;
    return $ttsmp3_json->{URL};

}


sub _get_audio_content {

    my $self = shift;
    my $url = shift;

    my $response = $ua->get( $url );

    return '' unless $response->is_success;
    return $response->decoded_content;

}


1;
