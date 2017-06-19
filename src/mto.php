<?php

/* Author: nakinor
 * Created: 2016-03-13
 * Revised: 2017-06-19
 */

$kana_jisyo  = getenv("MTODIC") . "/kana-jisyo";
$kanji_jisyo = getenv("MTODIC") . "/kanji-jisyo";

function create_dict($jisyo) {
    $tmp_arr = array();
    $fp = fopen($jisyo, 'r');
    while ($line = fgets($fp)) {
        if (preg_match('/^;.*|^$/', $line) != TRUE) {
            $string = preg_replace('/[ \t]+;.*/', "", $line);
            $pair = preg_split('/ \//', rtrim($string));
            array_push($tmp_arr, $pair);
        }
    }
    fclose($fp);
    return $tmp_arr;
}

function replace_strings($ifile, $jisyo, $flag) {
    $buf = file_get_contents($ifile);
    if ($buf === false) {
        echo "ファイルを開けません\n";
    }
    if ($flag == "car") {
        foreach($jisyo as $x) {
            $buf = str_replace($x[0], $x[1], $buf);
        }
        echo $buf;
    } else {
        foreach($jisyo as $x) {
            $buf = str_replace($x[1], $x[0], $buf);
        }
        echo $buf;
    }
}

function usage() {
    echo "usage: php mto.php option filename\n";
    echo "options:\n";
    echo "  tradkana      歴史的仮名使いに変換します\n";
    echo "  modernkana    現代仮名使いに変換します\n";
    echo "  oldkanji      旧字体に変換します\n";
    echo "  newkanji      新字体に変換します\n";
}

if (count($argv) == 1) {
    usage();
} elseif ($argv[1] == "tradkana") {
    $dic_arr = create_dict($kana_jisyo);
    replace_strings($argv[2], $dic_arr, "car");
} elseif ($argv[1] == "modernkana") {
    $dic_arr = create_dict($kana_jisyo);
    replace_strings($argv[2], $dic_arr, "cdr");
} elseif ($argv[1] == "oldkanji") {
    $dic_arr = create_dict($kanji_jisyo);
    replace_strings($argv[2], $dic_arr, "car");
} elseif ($argv[1] == "newkanji") {
    $dic_arr = create_dict($kanji_jisyo);
    replace_strings($argv[2], $dic_arr, "cdr");
} elseif ($argv[1] == "testkana") {
    $dic_arr = create_dict($kana_jisyo);
    var_dump($dic_arr);
    echo count($dic_arr) . "語\n";
} elseif ($argv[1] == "testkanji") {
    $dic_arr = create_dict($kanji_jisyo);
    var_dump($dic_arr);
    echo count($dic_arr) . "語\n";
} else {
    echo "オプションが違います\n";
}

?>
