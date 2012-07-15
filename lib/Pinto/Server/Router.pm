# ABSTRACT: Routes server requests

package Pinto::Server::Router;

use Moose;

use Scalar::Util;
use Plack::Request;
use Router::Simple;

#-------------------------------------------------------------------------------

our $VERSION = '0.042'; # VERSION

#-------------------------------------------------------------------------------

has route_handler => (
    is      => 'ro',
    isa     => 'Router::Simple',
    default => sub { Router::Simple->new },
);

#-------------------------------------------------------------------------------

sub BUILD {
  my ($self) = @_;

  my $r = $self->route_handler;

  $r->connect( '/action/{action}',
               {responder => 'Action'}, {method => 'POST'} );

  # Route for index of the named stack
  $r->connect( '/{stack}/modules/02packages.details.txt.gz',
               {responder => 'Index' }, {method => 'GET' } );

  # Route for index of the default (unamed) stack
  $r->connect( '/modules/02packages.details.txt.gz',
               {responder => 'File' }, {method => 'GET' } );

  # Route for distributions on the named stack
  $r->connect( '/{stack}/authors/id/*',
               {responder => 'File'  }, {method => 'GET' } );

  # Route for distributions on the default (unamed) stack
  $r->connect( '/authors/id/*',
               {responder => 'File'  }, {method => 'GET' } );

  return $self;
}

#-------------------------------------------------------------------------------


sub route {
    my ($self, $env, $root) = @_;

    my $p = $self->route_handler->match($env)
      or return [404, [], ['Not Found']];

    my $responder_class = 'Pinto::Server::Responder::' . $p->{responder};
    Class::Load::load_class($responder_class);

    my $request   = Plack::Request->new($env);
    my $responder = $responder_class->new(request => $request, root => $root);

    return $responder->respond;
};

#-------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-------------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems responder

=head1 NAME

Pinto::Server::Router - Routes server requests

=head1 VERSION

version 0.042

=head1 METHODS

=head2 route( $env, $root )

Given the request environment and the path to the repository root,
dispatches the request to the appropriate responder and returns the
response.

=for Pod::Coverage BUILD

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

