# ABSTRACT: Responder for static files

package Pinto::Server::Responder::File;

use Moose;

use Path::Class;
use Plack::Response;
use Plack::Mime;

#-------------------------------------------------------------------------------

our $VERSION = '0.042'; # VERSION

#-------------------------------------------------------------------------------

extends qw(Pinto::Server::Responder);

#-------------------------------------------------------------------------------

sub respond {
    my ($self) = @_;

    my (undef, @path_parts) = split '/', $self->request->path_info;

    # HACK: The first element of @path_parts could be the start of an
    # actual path, or just a stack name (which we don't need).  We
    # look at it and the following element to decide which it is.
    if ($path_parts[0] ne 'authors' and $path_parts[1] ne 'id') { shift @path_parts }
    my $file = Path::Class::file($self->root, @path_parts);

    return [404, [], ["File $file not found"]] if not (-e $file and -f $file);

    my $response = Plack::Response->new;
    $response->content_type( Plack::MIME->mime_type($file) );
    $response->content_length(-s $file);
    $response->body($file->openr);
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

Pinto::Server::Responder::File - Responder for static files

=head1 VERSION

version 0.042

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
