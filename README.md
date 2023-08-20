<p align="center">
  <img width="230" src="https://i.imgur.com/uMDqBq4.png">
</p>

<div align="center">

  <a href="https://github.com/grepmam">![grepmam](https://img.shields.io/badge/Created%20by-Grepmam-red)</a>
  <a href="https://www.perl.org/">![perl](https://img.shields.io/badge/Written%20in-Perl-green)</a>
  <a>![version](https://img.shields.io/badge/Version-1.0-yellow)</a>

</div>

ProtoTTS is a small module for converting text to speech. It uses TTSMP3 as a base, therefore the length of the messages is limited. This project is unofficial so it may fail in the future.

## Install dependencies

```bash
sudo apt install mpv
cpan LWP::UserAgent JSON IO::Socket::SSL IO::Socket::SSL::Utils LWP::Protocol::https
```

## Test Script

#### Play message

```perl
use ProtoTTS;

my $prototts = ProtoTTS->new;
$prototts->set_message( 'This is a test' );
$prototts->play;
```

#### Change voice

```perl
$prototts->set_voice( 'Lucia' );
```

#### List voices

```perl
ProtoTTS->List_Voices( 'US English' );
```

#### List languages

```perl
ProtoTTS->List_Langs;
```
