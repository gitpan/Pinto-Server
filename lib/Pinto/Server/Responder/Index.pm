# ABSTRACT: Responder for the 02packages index

package Pinto::Server::Responder::Index;

use Moose;

use File::Temp;
use Path::Class;
use Plack::Response;

use Pinto;

#-------------------------------------------------------------------------------

our $VERSION = '0.047'; # VERSION

#-------------------------------------------------------------------------------

extends qw(Pinto::Server::Responder);

#-------------------------------------------------------------------------------

sub respond {
    my ($self) = @_;

    # path_info always has a leading slash
    my (undef, $stk_name, @path_parts) = split '/', $self->request->path_info;

    my $temp_handle = File::Temp->new;
    my $temp_file   = file($temp_handle->filename);
    my $pinto       = Pinto->new(root => $self->root);
    my $stack       = $pinto->repos->get_stack(name => $stk_name);

    $pinto->repos->write_index(stack => $stack, file  => $temp_file);

    my $response = Plack::Response->new;
    $response->content_type('application/x-gzip');
    $response->content_length(-s $temp_file);
    $response->body($temp_handle);
    $response->status(200);

    return $response;
 }

#-------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#-------------------------------------------------------------------------------

1;

__END__
=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Server::Responder::Index - Responder for the 02packages index

=head1 VERSION

version 0.047

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

