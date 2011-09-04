package Pinto::Server;

# ABSTRACT: Web interface to a Pinto repository

use Moose;

use Carp;
use Path::Class;
use File::Temp;

use Pinto 0.023;

use Pinto::Types qw(Dir);
use MooseX::Types::Moose qw(Int Bool);
use Pinto::Server::Routes;
use Dancer qw(:moose :script);

#-----------------------------------------------------------------------------

our $VERSION = '0.021'; # VERSION

#-----------------------------------------------------------------------------


has repos => (
    is       => 'ro',
    isa      => Dir,
    coerce   => 1,
    required => 1,
);

#-----------------------------------------------------------------------------


has port => (
    is       => 'ro',
    isa      => Int,
    default  => 3000,
);

#-----------------------------------------------------------------------------


has daemon => (
    is       => 'ro',
    isa      => Bool,
    default  => 0,
);

#-----------------------------------------------------------------------------


sub run {
    my ($self) = @_;

    Dancer::set( repos  => $self->repos()  );
    Dancer::set( port   => $self->port()   );
    Dancer::set( daemon => $self->daemon() );
    Dancer::set( logger => 'console'       );
    Dancer::set( log    => 'debug'         );

    $self->_initialize();
    return Dancer::dance();
}

#-----------------------------------------------------------------------------

sub _initialize {
    my ($self) = @_;

    print 'Initializing pinto ... ';
    my $pinto = Pinto::Server::Routes::pinto();
    $pinto->new_action_batch(noinit => 0);
    $pinto->add_action('Nop');
    my $result = $pinto->run_actions();
    die "\n" . $result->to_string() . "\n" if not $result->is_success();
    print "Done\n";

    return $self;
}

#----------------------------------------------------------------------------

1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems cpan testmatrix url
annocpan anno bugtracker rt cpants kwalitee diff irc mailto metadata
placeholders

=head1 NAME

Pinto::Server - Web interface to a Pinto repository

=head1 VERSION

version 0.021

=head1 DESCRIPTION

There is nothing to see here.

Look at L<pinto-server> instead.

Then you'll probably want to look at L<pinto-remote>.

See L<Pinto::Manual> for a complete guide.

=head1 ATTRIBUTES

=head2 repos

The path to your Pinto repository.  The repository must already exist
at this location.  This attribute is required.

=head2 port

The port number the server shall listen on.  The default is 3000.

=head2 daemon

If true, Pinto::Server will fork and run in a separate process.
Default is false.

=head1 METHODS

=head2 run()

Starts the Pinto::Server.  Returns a PSGI-compatible code reference.

=head1 SUPPORT

=head2 Perldoc

You can find documentation for this module with the perldoc command.

  perldoc Pinto::Server

=head2 Websites

The following websites have more information about this module, and may be of help to you. As always,
in addition to those websites please use your favorite search engine to discover more resources.

=over 4

=item *

Search CPAN

The default CPAN search engine, useful to view POD in HTML format.

L<http://search.cpan.org/dist/Pinto-Server>

=item *

RT: CPAN's Bug Tracker

The RT ( Request Tracker ) website is the default bug/issue tracking system for CPAN.

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Pinto-Server>

=item *

CPAN Ratings

The CPAN Ratings is a website that allows community ratings and reviews of Perl modules.

L<http://cpanratings.perl.org/d/Pinto-Server>

=item *

CPAN Testers

The CPAN Testers is a network of smokers who run automated tests on uploaded CPAN distributions.

L<http://www.cpantesters.org/distro/P/Pinto-Server>

=item *

CPAN Testers Matrix

The CPAN Testers Matrix is a website that provides a visual way to determine what Perls/platforms PASSed for a distribution.

L<http://matrix.cpantesters.org/?dist=Pinto-Server>

=item *

CPAN Testers Dependencies

The CPAN Testers Dependencies is a website that shows a chart of the test results of all dependencies for a distribution.

L<http://deps.cpantesters.org/?module=Pinto::Server>

=back

=head2 Bugs / Feature Requests

Please report any bugs or feature requests by email to C<bug-pinto-server at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Pinto-Server>. You will be automatically notified of any
progress on the request by the system.

=head2 Source Code


L<https://github.com/thaljef/Pinto-Server>

  git clone git://github.com/thaljef/Pinto-Server.git

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__


