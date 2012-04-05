# ABSTRACT: Base class for responding to Action requests

package Pinto::Server::ActionResponder;

use Moose;

use Carp;
use Try::Tiny;

use Pinto;
use Pinto::Result;
use Pinto::Types qw(Dir);
use Pinto::Constants qw(:all);

#------------------------------------------------------------------------------

our $VERSION = '0.035'; # VERSION

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
    my ($self, $action, $out, %args) = @_;

    $args{root} = $self->root;
    $args{log_prefix} = $PINTO_SERVER_RESPONSE_LINE_PREFIX;

    print { $out } "$PINTO_SERVER_RESPONSE_PROLOGUE\n";

    my $result;
    try   {
        my $pinto = Pinto->new(%args);
        $pinto->new_batch(%args, noinit => 1);
        $pinto->add_action($action, %args);
        $result = $pinto->run_actions();
    }
    catch {
        print { $out } $_;
        $result = Pinto::Result->new();
        $result->add_exception($_);
    };

    print { $args{out} } "$PINTO_SERVER_RESPONSE_EPILOGUE\n"
        if $result->is_success();

    return $result->is_success() ? 1 : 0;
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

version 0.035

=head1 ATTRIBUTES

=head2 root => $directory

The root directory of your L<Pinto> repository.  This attribute is
required.

=head1 METHODS

=head2 respond( action => $action_name, params => \%params );

Given an action name and a hash reference request parameters, performs
the action and returns a PSGI-compatible response.  This is an
abstract method that you must implement in a subclass.

=head2 run_pinto( $action_name, $output_handle, %pinto_args )

Given an action name and a hash of arguments for L<Pinto> runs the
action and writes the output to the output handle.  This method takes
care of adding the prologue and epilogue to the output.  Returns a
true value if the action was entirely successful.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__


