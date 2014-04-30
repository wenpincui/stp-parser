#!/usr/bin/perl
use 5.10.0;

@apks = glob "*.o";

foreach(@apks) {
    `mipsel-linux-objdump -D $_ > $_.s`;

    open INPUT, "< $_.s";
    open OUTPUT, "> $_.txt";

    while(<INPUT>) {
        chomp;

        if (m/Disassembly of section \.([a-zA-Z0-9_-]+)/) {
            if ($1 =~ m/text/) {
            }
            else {
                last;
            }
        }

        if (m/[a-f0-9]:\s+([0-9a-f]+)/) {
           print OUTPUT $1."\n";
        }
    }

    close OUTPUT;
    close INPUT;
}

