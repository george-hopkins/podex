#!/usr/bin/perl

while (<>) {
    s/^(.*)\.word(.*)$/\1dw\2/;
    s/^(.*)\.byte(.*)$/\1db\2/;
    s/^\s*\.equ\s+([^,]+),(.+)$/\1 equ \2/;
    s/^\s*(\.(text|data|bss).*)/; \1/;

    print $_;
}
