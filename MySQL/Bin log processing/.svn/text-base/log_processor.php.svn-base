#!/usr/bin/php
<?php
ob_implicit_flush(true);
set_time_limit(0);

function usage() {
    global $argv;
    echo "Usage is:\n";
    echo $argv[0]." [-v] [-q] [-h] [-i] search_string file.sql [file2.sql ...]\n";
    exit;
}

$invert             = false;
$silent             = false;
$case_insensitive   = false;

$options = getopt("vqhVi");
foreach($options as $option => $value) {
    switch($option) {
        case 'v':   $invert           = true; break;
        case 'q':   $silent           = true; break;
        case 'i':   $case_insensitive = true; break;
        case 'h':   case 'V':                 default: usage();
    }
}

for ($i = 1; $i<$argc; $i++) {
    if (strpos($argv[$i], '-') !== 0)
     break;
}

$search = $argv[$i];
for ($i++; $i < $argc; $i++)
 $files[] = $argv[$i];

if (count($files) == 0)
    usage();

$stderr = fopen("php://stderr", "w");

foreach ($files as $filename) {
    fputs($stderr, "Processing $filename\n");
    $start_timestamp = time();
    $num_of_matches = 0;

    $file_size = filesize($filename);
    $file = fopen($filename, 'r');
    if ($file === FALSE)
        continue;
        
    while(!feof($file)) {
        $line = trim(fgets($file));
        $matches = array();
        if (preg_match('/^SET TIMESTAMP=(\d+)/', $line, $matches)) {
            if (   (   !$case_insensitive
                     && (strstr($lines, $search)  != $invert))
                || (    $case_inensitive
                     && (stristr($lines, $search) != $invert))
               ) {
                echo $lines;
                $num_of_matches++;
            }
            if (strpos($line, '--') === FALSE)
                $line .= ' -- '.date('Y-m-d H:i:s', $matches[1]);
            $lines = $line."\n";
        }
        elseif(substr($line, 0, 1) != '#') {
            $lines .= $line."\n";
        }

        $cur_timestamp = time();
        if(!$silent && ($cur_timestamp > $last_timestamp || feof($file))) {
            $curloc         = ftell($file);
            $rate           = $curloc / ($cur_timestamp - $start_timestamp + 1);
            $expected_end   = $file_size / $rate;
            $eta_raw        = ($start_timestamp + $expected_end) - $cur_timestamp - 1;
            $eta_sec        = $eta_raw % 60;
            $eta_min        = ($eta_raw - $eta_sec) / 60;
            $elapsed_min    = floor(($cur_timestamp - $start_timestamp)/60);
            $elapsed_sec    = ($cur_timestamp - $start_timestamp) % 60;
            $strlen         = strlen(number_format($file_size));
            $percent        = ($curloc / $file_size) * 100;
            if ($last_timestamp)
                fputs($stderr, sprintf(" %".$strlen."s / %s (%6.2f%%) ETA: %02d:%02d Elapsed: %02d:%02d Matches: %d\r", number_format($curloc), number_format($file_size), $percent, $eta_min, $eta_sec, $elapsed_min, $elapsed_sec, $num_of_matches));
            $last_timestamp = $cur_timestamp;
        }
    }
    fclose($file);
    fputs($stderr,"\n");
}
fclose($stderr);
