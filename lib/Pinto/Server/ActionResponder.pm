# ABSTRACT: Base class for responding to Action requests

package Pinto::Server::ActionResponder;

use Moose;

use Carp;
use Try::Tiny;
use List::Util qw(min);

use Log::Dispatch::Handle;

use Pinto;
use Pinto::Result;
use Pinto::Types qw(Dir);
use Pinto::Constants qw(:all);

#------------------------------------------------------------------------------

our $VERSION = '0.037'; # VERSION

#------------------------------------------------------------------------------


has root  => (
   is       => 'ro',
   isa      => Dir,
   required => 1,
   coerce   => 1,
);

#-----------------------------------------------------------------------------


sub respond { confess 'Abstract method' };

#-----------------------------------------------------------------------------


sub run_pinto {
    my ($self, $action, $output_handle, %args) = @_;

    $args{root} ||= $self->root;

    print { $output_handle } "$PINTO_SERVER_RESPONSE_PROLOGUE\n";

    my $result;
    try   {
        my $pinto = Pinto->new(%args);
        $pinto->add_logger($self->_make_logger($output_handle));
        $pinto->new_batch(%args, noinit => 1);
        $pinto->add_action($action, %args);
        $result = $pinto->run_actions();
    }
    catch {
        print { $output_handle } $_;
        $result = Pinto::Result->new();
        $result->add_exception($_);
    };

    print { $output_handle } "$PINTO_SERVER_RESPONSE_EPILOGUE\n"
        if $result->is_success();

    return $result->is_success() ? 1 : 0;
}

#------------------------------------------------------------------------------

sub _make_logger {
    my ($self, $out) = @_;

    # Prepend all server log messages with a prefix so clients can
    # distiguish log messages from regular output from the Action.

    my $cb = sub {
        my %args = @_;
        my $level = uc $args{level};
        chomp (my $msg = $args{message});
        my @lines = split m{\n}x, $msg;
        $msg = join "\n" . $PINTO_SERVER_RESPONSE_LINE_PREFIX, @lines;
        return $PINTO_SERVER_RESPONSE_LINE_PREFIX . "$level: $msg" . "\n";
    };

    # We're going to send all log messages to the client and let
    # it decide which ones it wants to record or display.

    my $logger = Log::Dispatch::Handle->new( min_level => 0,
                                             handle    => $out,
                                             callbacks => $cb );

    return $logger;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems params

=head1 NAME

Pinto::Server::ActionResponder - Base class for responding to Action requests

=head1 VERSION

version 0.037

=head1 ATTRIBUTES

=head2 root => $directory

The root directory of your L<Pinto> repository.  This attribute is
required.

=head1 METHODS

=head2 respond( action => $action_name, params => \%params );

Given a Pinto Action name and a hash reference request parameters,
performs the Action and returns a PSGI-compatible response.  This is
an abstract method that you must implement in a subclass.

=head2 run_pinto( $action_name, $output_handle, %pinto_args )

Given an Action name and a hash of arguments for L<Pinto>, runs the
Action.  Any output and log messages from the Action will be written
to the output handle.  This method takes care of adding the prologue
and epilogue to the output handle.  Returns a true value if the action
was entirely successful.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__


