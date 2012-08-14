# ABSTRACT: A class for testing a Pinto server

package Pinto::Server::Tester;

use Moose;
use IPC::Run;
use Test::TCP;
use File::Which;
use Carp;

use Pinto::Types qw(File);

#-------------------------------------------------------------------------------

our $VERSION = '0.046'; # VERSION

#-------------------------------------------------------------------------------

extends 'Pinto::Tester';

#-------------------------------------------------------------------------------


has server_port => (
  is         => 'ro',
  isa        => 'Int',
  default    => sub { empty_port },
);



has server_host => (
  is         => 'ro',
  isa        => 'Str',
  init_arg   => undef,
  default    => 'localhost',
);


has server_pid => (
  is         => 'rw',
  isa        => 'Int',
  init_arg   => undef,
  default    => 0,
);



has server_url => (
  is         => 'ro',
  isa        => 'Str',
  init_arg   => undef,
  default    => sub { 'http://' . $_[0]->server_host . ':' . $_[0]->server_port },
);



has pintod_exe => (
  is         => 'ro',
  isa        => File,
  default    => sub { which('pintod') || croak "Could not find pintod in PATH" },
  coerce     => 1,
);

#-------------------------------------------------------------------------------


sub start_server {
  my ($self) = @_;

  carp 'Server already started' and return if $self->server_pid;

  local $ENV{PLACK_SERVER} = '';          # Use the default backend
  local $ENV{PLACK_ENV}    = 'testing';   # Suppresses startup message
  local $ENV{PINTO_LOCKFILE_TIMEOUT} = 2; # Don't make tests wait!

  my $server_pid = fork;
  croak "Failed to fork: $!" if not defined $server_pid;

  if ($server_pid == 0) {
    my %opts = ('--port' => $self->server_port, '--root' => $self->root);
    my @cmd = ($^X, $self->pintod_exe, %opts);
    $self->tb->note(sprintf 'exec(%s)', join ' ', @cmd);
    exec @cmd;
  }

  $self->server_pid($server_pid);
  $self->server_running_ok or croak 'Sever startup failed';
  sleep 2; # Let the server warm up


  return $self;
}

#-------------------------------------------------------------------------------


sub stop_server {
  my ($self) = @_;

  my $server_pid = $self->server_pid;
  carp 'Server was never started' and return if not $server_pid;
  carp "Server $server_pid not running" and return if not kill 0, $server_pid;

  # TODO: Consider using Proc::Terminator instead
  $self->tb->note("Shutting down server $server_pid");
  kill 'TERM', $server_pid;
  sleep 2 and waitpid $server_pid, 0;

  $self->server_not_running_ok;

  return $self;
}

#-------------------------------------------------------------------------------


sub server_running_ok {
  my ($self) = @_;

  my $server_pid  = $self->server_pid;
  my $server_port = $self->server_port;

  my $ok = kill 0, $server_pid; # Is this portable?

  return $self->tb->ok($ok, "Server $server_pid is running on port $server_port");
}

#-------------------------------------------------------------------------------


sub server_not_running_ok {
  my ($self) = @_;

  my $server_pid = $self->server_pid;
  my $ok = not kill 0, $server_pid;  # Is this portable?

  return $self->tb->ok($ok, "Server is not running with pid $server_pid");
}

#-------------------------------------------------------------------------------

sub DEMOLISH {
  my ($self) = @_;

  $self->stop_server if $self->server_pid;

  return;
}

#-------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems responder

=head1 NAME

Pinto::Server::Tester - A class for testing a Pinto server

=head1 VERSION

version 0.046

=head1 ATTRIBUTES

=head2 server_port( $integer )

Sets the port that the server will listen on.  If not specified during
construction, defaults to a randomly generated but open port.

=head2 server_host( $hostname )

Sets the hostname that the server will bind to.  Defaults to C<localhost>.

=head2 server_pid

Returns the process id for the server (if it has been started).  Read-only.

=head2 server_url

Returns the full URL that the server will listen on.  Read-only.

=head2 pintod_exe

Sets the path to the C<pintod> executable.  If not specified, your
C<PATH> will be searched.  An exception is thrown if C<pintod> cannot
be found.

=head1 METHODS

=head2 start_server()

Starts the L<pintod> server.  Emits a warning if the server is already started.

=head2 stop_server()

Stops the L<pintod> server.  Emits a warning if the server is not
currently running.

=head2 server_running_ok()

Asserts that the server is running.

=head2 server_not_running_ok

Asserts that the server is not running.

=for Pod::Coverage DEMOLISH

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

