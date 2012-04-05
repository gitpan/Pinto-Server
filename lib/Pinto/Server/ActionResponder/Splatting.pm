# ABSTRACT: An ActionResponder that returns the entire response in one shot

package Pinto::Server::ActionResponder::Splatting;

use Moose;

use IO::String;
use Plack::Response;

#------------------------------------------------------------------------------

our $VERSION = '0.035'; # VERSION

#------------------------------------------------------------------------------

extends qw(Pinto::Server::ActionResponder);

#------------------------------------------------------------------------------

override respond => sub {
    my ($self, %args) = @_;

    my $action = $args{action};
    my %params = %{ $args{params} };

    my $buffer   = '';
    my $out      = IO::String->new( \$buffer );
    $params{out} = $out;

    $self->run_pinto($action, $out, %params);
    my $response = Plack::Response->new(200, undef, $buffer);
    $response->content_length(length $buffer);
    $response->content_type('text/plain');

    return $response->finalize();
};

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Server::ActionResponder::Splatting - An ActionResponder that returns the entire response in one shot

=head1 VERSION

version 0.035

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
