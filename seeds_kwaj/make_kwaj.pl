#!/usr/bin/perl -w
use strict;
use warnings;
use Getopt::Long;

# Set default payload length
my $payload_length = 0;
GetOptions("payload=i" => \$payload_length)
    or die "Usage: $0 --payload=<size>\n";

# A base name for file name/extension fields
my $name = '123456789';

# Generate a series of KWaj files with varying header fields.
for my $file (0 .. 9) {
    for my $ext (0 .. 4) {
        my $filename = "f$file$ext.kwj";
        open my $fh, '>', $filename or die "Can't open $filename: $!";
        
        # Compute offset and flags based on loop indices.
        my $offset = 14 + $file + $ext;
        my $flags  = ($file > 0 ? 8 : 0) | ($ext > 0 ? 16 : 0);
        
        # Write header: 
        # 'A4' => 4-byte signature ("KWAJ"),
        # 'V'  => 32-bit little-endian magic number,
        # 'vvv' => three 16-bit values (zero, offset, flags)
        print $fh pack('A4Vvvv', 'KWAJ', 0xD127F088, 0, $offset, $flags);
        
        # Write optional filename if $file > 0
        if ($file > 0) {
            print $fh substr($name, 0, $file);
            print $fh "\0" if ($file < 9);
        }
        
        # Write optional extension if $ext > 0
        if ($ext > 0) {
            print $fh substr($name, 0, $ext);
            print $fh "\0" if ($ext < 4);
        }
        
        # Write a trailing marker byte (0xFF)
        print $fh "\xFF";
        
        # Append a random payload if desired.
        if ($payload_length > 0) {
            for (my $i = 0; $i < $payload_length; $i++) {
                print $fh chr(int(rand(256)));
            }
        }
        
        close $fh;
        print "Created $filename with payload length $payload_length\n";
    }
}
