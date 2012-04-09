# ABSTRACT: Handles requests to the Pinto server.

package Pinto::Server::Handler;

use Moose;

use Carp;
use Plack::MIME;
use Path::Class;
use File::Copy;
use Plack::Response;

use Pinto::Types qw(Dir);


#-------------------------------------------------------------------------------

our $VERSION = '0.037'; # VERSION

#-------------------------------------------------------------------------------


has root  => (
   is       => 'ro',
   isa      => Dir,
   required => 1,
   coerce   => 1,
);

#-------------------------------------------------------------------------------


sub handle {
    my ($self, $request) = @_;

    my $method = $request->method();
    return $self->_handle_post($request) if $method eq 'POST';
    return $self->_handle_get($request)  if $method eq 'GET';
    return $self->_error_response(500, "Unable to process method $method");
}

#-------------------------------------------------------------------------------

sub _handle_post {
    my ($self, $request) = @_;

    my %params = %{ $request->parameters() };
    my $action = _parse_action_from_path($request->path_info);

    if (my $uploads = $request->uploads) {
        for my $upload_name ( $uploads->keys ) {
            my $upload   = $uploads->{$upload_name};
            my $filename = $upload->filename;
            my $file     = file($upload->path)->dir->file($filename);
            File::Copy::move( $upload->path, $file); #TODO: autodie
            $params{$upload_name} = $file;
        }
    }

    my $responder;
    if ( $request->env->{'psgi.streaming'} && !$params{nostream} ) {
        require Pinto::Server::ActionResponder::Streaming;
        $responder = Pinto::Server::ActionResponder::Streaming->new(root => $self->root);
    }
    else {
        require Pinto::Server::ActionResponder::Splatting;
        $responder = Pinto::Server::ActionResponder::Splatting->new(root => $self->root);
    }

    return $responder->respond(action => $action, params => \%params);
}

#-------------------------------------------------------------------------------

sub _handle_get {
    my ($self, $request) = @_;

    my $file = file( $self->root(), $request->path_info() );
    return $self->_error_response(404, "File $file not found") if not -e $file;

    my $response = Plack::Response->new();
    $response->content_type( Plack::MIME->mime_type($file) );
    $response->content_length( -s $file );
    $response->body( $file->openr() );
    $response->status(200);

    return $response;
}

#-------------------------------------------------------------------------------

sub _parse_action_from_path {
    my ($path) = @_;
    $path =~ m{^ /action/ ([^/]*) }mx or confess "Cannot parse path: $path";
    return ucfirst $1;
}

#-----------------------------------------------------------------------------

sub _error_response {
    my ($self, $code, $message) = @_;

    $code    ||= 500;
    $message ||= 'Unkown error';

    return Plack::Response->new($code, undef, $message);
}

#-----------------------------------------------------------------------------
1;



=pod

=for :stopwords Jeffrey Ryan Thalhammer Imaginative Software Systems

=head1 NAME

Pinto::Server::Handler - Handles requests to the Pinto server.

=head1 VERSION

version 0.037

=head1 ATTRIBUTES

=head2 root

The path to the root directory of your Pinto repository.  The
repository must already exist at this location.  This attribute is
required.

=head1 METHODS

=head2 handle($request)

Handles one L<Plack::Request>, returning a PSGI-compatible array
reference.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
