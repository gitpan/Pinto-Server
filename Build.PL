
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Apache::Htpasswd" => 0,
    "ExtUtils::MakeMaker" => 0,
    "File::Find" => 0,
    "File::Spec::Functions" => 0,
    "HTTP::Request" => 0,
    "HTTP::Request::Common" => 0,
    "List::Util" => 0,
    "Module::Build" => "0.3601",
    "PerlIO::gzip" => 0,
    "Pinto::Tester::Util" => 0,
    "Plack::Test" => 0,
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
  "dist_version" => "0.50",
  "license" => "perl",
  "module_name" => "Pinto::Server",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Authen::Simple::Passwd" => 0,
    "Carp" => 0,
    "Class::Load" => 0,
    "File::Copy" => 0,
    "File::Temp" => 0,
    "File::Which" => 0,
    "Getopt::Long" => 0,
    "IO::Handle::Util" => 0,
    "IO::Interactive" => 0,
    "IO::Pipe" => 0,
    "IPC::Run" => 0,
    "JSON" => 0,
    "List::MoreUtils" => 0,
    "Log::Dispatch::Handle" => 0,
    "Moose" => 0,
    "MooseX::ClassAttribute" => 0,
    "MooseX::Types::Moose" => 0,
    "POSIX" => 0,
    "Path::Class" => 0,
    "Pinto" => "0.052",
    "Pinto::Constants" => 0,
    "Pinto::Result" => 0,
    "Pinto::Tester" => 0,
    "Pinto::Types" => 0,
    "Plack::MIME" => 0,
    "Plack::Middleware::Auth::Basic" => 0,
    "Plack::Request" => 0,
    "Plack::Response" => 0,
    "Plack::Runner" => 0,
    "Pod::Usage" => 0,
    "Proc::Fork" => 0,
    "Router::Simple" => 0,
    "Scalar::Util" => 0,
    "Test::TCP" => 0,
    "Try::Tiny" => 0,
    "perl" => "5.006",
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => [
    "bin/pintod"
  ]
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
