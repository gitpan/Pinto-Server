
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  'build_requires' => {
    'File::Find' => '0',
    'Module::Build' => '0.3601',
    'Test::More' => '0'
  },
  'configure_requires' => {
    'Module::Build' => '0.3601'
  },
  'dist_abstract' => 'Web interface to a Pinto repository',
  'dist_author' => [
    'Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>'
  ],
  'dist_name' => 'Pinto-Server',
  'dist_version' => '0.001',
  'license' => 'perl',
  'module_name' => 'Pinto::Server',
  'recommends' => {},
  'recursive_test_files' => 1,
  'requires' => {
    'Carp' => '0',
    'Dancer' => '0',
    'Dancer::GetOpt' => '0',
    'Data::Dumper' => '0',
    'File::Temp' => '0',
    'Path::Class' => '0',
    'Pinto' => '0',
    'Pinto::Config' => '0',
    'Pinto::Logger' => '0',
    'perl' => '5.006'
  },
  'script_files' => [
    'bin/pinto-server'
  ]
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
