#!/usr/bin/perl
use strict;
use warnings;

my $prefix = '/usr/local';
my $acpiCallGitRepo = 'git://github.com/mkottman/acpi_call.git';
my $acpiCallTag = "v1.1.0";

sub runOrDie(@){
  print "@_\n";
  system @_;
  die "error running '@_'\n" if $? != 0;
}

sub main(@){
  runOrDie "sudo", "cp", "tpacpi-bat", "$prefix/bin";

  my $localRepo = '/tmp/acpi_call';
  if(not -d $localRepo){
    runOrDie "git", "clone", $acpiCallGitRepo, $localRepo;
  }
  chdir $localRepo;
  runOrDie "git", "fetch";
  runOrDie "git", "reset", "HEAD", "--hard";
  runOrDie "git", "clean", "-fd";
  runOrDie "git", "checkout", $acpiCallTag;
  runOrDie "make";
  runOrDie "sudo", "make", "install";
  runOrDie "sudo", "depmod";
  runOrDie "sudo", "modprobe", "acpi_call";
}

&main(@ARGV);
