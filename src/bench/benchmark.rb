CMD_PREFIX = ENV['MTODIC'] + '/../src'
PRGRMS = [
  ["Python3", "python3", "mto.py"],
  ["Perl5", "perl", "mto.pl"],
  ["PHP7", "php", "mto.php"],
  ["Ruby", "ruby", "mto.rb"],
  ["JS", "node", "mto-node.js"],
  ["C#", "mono", "bin/mto-mono"],
  ["C", "", "bin/mto-c"],
  ["C++", "", "bin/mto-cc"],
  ["Go", "", "bin/mto-go"]
]

if ARGV.size != 0
  for x in PRGRMS
    print "#{x[0]}:\n"
    `/usr/bin/time #{x[1]} #{CMD_PREFIX}/#{x[2]} tradkana #{ARGV[0]}`
  end
else
  puts "Usage: #{File.basename($0)} inputfile"
end
