#!/usr/bin/perl -w

use Getopt::Long;

my $path = '';
my $file = '';
my $useCutlist = '';
my $verbrose = '';
my $type_h264 = FALSE;

GetOptions('path=s'     => \$path,
           'file=s'     => \$file,
           'useCutlist' => \$useCutlist,
           'verbrose'   => \$verbrose,
           'h264'       => \$type_h264
	      );

if ( !$path || !$file ) {
    die "Useage --path /path/to/dir --file file.mpg and optional --useCutlist";
}

my $newfile     = $file;
$newfile        =~ s/mpg$/mp4/g;
my $acodec      = 'aac';
my $fps         = 30;
my $height      = 320;
my $width       = 480;
my $aspect      = "1.3333";
my $vbitrate    = 300;
my $niceval     = 1;
my $command     = '';

if ( system('which ffmpeg > /dev/null') != 0) {
    print "Can not find ffmpeg!\n\n";
    exit;
}

open (FFMPEG, "ffmpeg -v 2>&1 |");
while (<FFMPEG>) {
    if ($_ =~ m/libfaac/g) { $acodec = 'libfaac'; }
}
close FFMPEG;

if ( system('which mplayer > /dev/null') == 0) {

    $command = "mplayer"
              ." -vo null"
              ." -ao null"
              ." -frames 1"
              ." -identify"
              ." ${path}/${file}"
              ." 2>/dev/null"
              ." |"
              ;

    open (MPLAYER, $command);
    while (<MPLAYER>) {
        if ($_ =~ m/ID_VIDEO_WIDTH=(.*)/)  { $width  = $1; }
        if ($_ =~ m/ID_VIDEO_HEIGHT=(.*)/) { $height = $1; }
        if ($_ =~ m/ID_VIDEO_FPS=(.*)/)    { $fps    = $1; }
        if ($_ =~ m/ID_VIDEO_ASPECT=(.*)/) { $aspect = $1; }
    }
    close MPLAYER;
}

if ($aspect eq "1.3333") {
    $width    = 480;
    $height   = 320;
    $vbitrate = "300";
}
elsif ($aspect eq "1.78:1") {
    $width    = 432;
    $height   = 240;
    $vbitrate = "480k";
}
else {
    $width    = 480;
    $height   = 360;
    $vbitrate = "378k";
}

my $command_mpeg4 = "nice"
	             ." -n${niceval}"
	             ." ffmpeg"
	             ." -i ${path}/${file}"      # Input File
	             ." -acodec ${acodec}"       # Audio Codec
	             ." -ab 128k"                # Audio Bitrate
	             ." -ac 2"                   # Force Stereo Sound Output
	             ." -s ${width}x${height}"   # Set video size
	             ." -vcodec mpeg4"           # Video codec
	             ." -b ${vbitrate}"          # Video bitrate
	             ." -flags +aic+mv4+trell"   # Flags
	             ." -mbd 2"                  #
	             ." -cmp 2"                  #
	             ." -subcmp 2"               #
	             ." -g 250"                  #
	             ." -maxrate 512k"           #
	             ." -bufsize 2M"             #
	             ." -t 60"                   # Limit to 60 seconds for testing
	             ." -y"                      # Overwrite output file
                 ." -threads 2"." -threads 2"
	             ." ${path}/${newfile}"      # Output file
	             ." &>/dev/null"             # No output, sorry
                 ;

my $command_h264 = "nice"
                  ." -n${niceval}"
                  ." ffmpeg"
                  ." -i ${path}/${file}"        # Input File
                  ." -acodec ${acodec}"         # Audio Codec
                  ." -ab 128k"                  # Audio Bitrate
                  ." -ac 2"                     # Force Stereo Sound Output
                  ." -vcodec libx264"           # Video codec
                  ." -s ${width}x${height}"     # Set video size
                  ." -aspect ${aspect}"
                  ." -b ${vbitrate}"            # Video bitrate
#                  ." -bf 0"                     # No b frames
#                  ." -deinterlace"
                  ." -flags +loop"
                  ." -cmp +chroma"
                  ." -partitions +parti4x4+partp8x8+partb8x8"
#                  ." -flags2 +mixed_refs"
#                  ." -me_method umh"                   #Will be me_method in later versions of ffmpeg
#                  ." -me_range 16"
#                  ." -subq 6"
#                  ." -trellis 1"
                  ." -refs 5"
#                  ." -coder 0"
                  ." -g 250"
#                  ." -keyint_min 25"
#                  ." -sc_threshold 40"
#                  ." -i_qfactor 0.71"
#                  ." -bt ${vbitrate}"
                  ." -maxrate 768k"
                  ." -bufsize 10M"
#                  ." -qcomp 0.6"
#                  ." -qmin 10"
#                  ." -qmax 51"
#                  ." -qdiff 4"
                  ." -level 13"
                  ." -threads 2"
                  ." -y"                        # Overwrite output file
                  ." ${path}/${newfile}"        # Output file
#                  ." &>/dev/null"               # No output, sorry
                  ;

if ($type_h264) {
    system($command_h264);
}
else {
    system($command_mpeg4);
}

if ( system('which qt-faststart > /dev/null') == 0) {
    $command = "nice"
              ." -n${niceval}"
              ." qt-faststart"
              ." ${path}/${newfile}"
              ." ${path}/${newfile}.fs"
              ;
    system($command);

    $command = "mv ${path}/${newfile}.fs ${path}/${newfile}";
    system($command);
}
