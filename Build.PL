
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Dancer::Test" => 0,
    "File::Find" => 0,
    "FindBin" => 0,
    "Module::Build" => "0.3601",
    "Pinto::Tester" => 0,
    "Test::More" => 0
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Web interface to a Pinto repository",
  "dist_author" => [
    "Jeffrey Ryan Thalhammer <jeff\@imaginative-software.com>"
  ],
  "dist_name" => "Pinto-Server",
  "dist_version" => "0.026",
  "license" => "perl",
  "module_name" => "Pinto::Server",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Dancer" => 0,
    "File::Temp" => 0,
    "Getopt::Long" => 0,
    "Moose" => 0,
    "MooseX::Types::Moose" => 0,
    "Path::Class" => 0,
    "Pinto" => "0.026",
    "Pinto::Types" => 0,
    "Pod::Usage" => 0,
    "perl" => "5.006",
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => [
    "bin/pinto-server"
  ]
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
