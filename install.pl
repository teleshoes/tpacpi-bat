#!/usr/bin/perl
use strict;
use warnings;

my $prefix = '/usr/local';
my $acpiCallGitRepo = 'git://github.com/teleshoes/acpi_call.git';

sub runOrDie(@){
  print "@_\n";
  system @_;
  die "error running '@_'\n" if $? != 0;
}

sub main(@){
  runOrDie "sudo", "cp", "tpacpi-bat", "$prefix/bin";

  my $acpiCallTag;
  my $version = `uname -r`;
  if(versionCmp("3.17", $version) >= 0){
    $acpiCallTag = "3.17";
  }else{
    $acpiCallTag = "v1.1.0";
  }

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

sub versionCmp($$){
  my ($v1, $v2) = @_;
  die "Malformed kernel version $v1\n" if $v1 !~ /^(\d+)\.(\d+)/;
  my ($v1Maj, $v1Min) = ($1, $2);
  die "Malformed kernel version $v2\n" if $v2 !~ /^(\d+)\.(\d+)/;
  my ($v2Maj, $v2Min) = ($1, $2);

  if($v1Maj > $v2Maj or ($v1Maj == $v2Maj and $v1Min > $v2Min)){
    return -1;
  }elsif($v1Maj < $v2Maj or ($v1Maj == $v2Maj and $v1Min < $v2Min)){
    return 1;
  }elsif($v1Maj == $v2Maj and $v1Min == $v2Min){
    return 0;
  }
}

&main(@ARGV);
