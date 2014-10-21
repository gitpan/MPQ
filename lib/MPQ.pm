package MPQ;

=head1 NAME

MPQ - Perl module to parse MoPaQ Archive Format

=head1 SYNOPSIS

    use MPQ;

    my $mpq = MPQ->new(filename => 'my_game.sc2replay');
    $mpq->parse;

    my $archive = $mpq->archive;
    print for $archive->list_file;
    print $archive->file('(listfile)')->slurp;

=head1 DESCRIPTION

This module give you a raw access to MPQ archive files.

MPQ, is an archiving file format used in several of Blizzard Entertainment's
games.

=head1 METHODS

=cut

use strict;
use warnings;

use MPQ::File;
use MPQ::Constants;
use MPQ::Archive;
use MPQ::Shunt;

our $VERSION = '0.02';

=head2 new

Constructor for the MPQ class. Has only one input parameter:

    filename - path to the mpq archive file

=cut

sub new {
    my ($class, %param) = @_;

    $param{'_file'} = MPQ::File->new(
        filename => $param{'filename'}
    );

    return bless(\%param, $class);
}

=head2 parse

Method to do the parse of the MPQ file

=cut

sub parse {
    my $self = shift;

    $self->{'_file'}->open;
    $self->_do_magic;

    $self->_recognize_type;
}

sub _recognize_type {
    my $self = shift;
    my $str = $self->{'_file'}->read_str(1);

    if ($str eq ARCHIVE_TYPE) {
        $self->{'_archive'} = MPQ::Archive->new(
            offset => 0x4,
            file   => $self->{'_file'}
        );
    } elsif ($str eq SHUNT_TYPE) {
        $self->{'_shunt'} = MPQ::Shunt->new(
            offset => 0x4,
            file   => $self->{'_file'}
        );
        $self->{'_shunt'}->parse;
        $self->{'_archive'} = MPQ::Archive->new(
            offset => $self->{'_shunt'}->archive_header_offset,
            file   => $self->{'_file'}
        );
    } else {
        my $hex = unpack("H*", $str);
        die "Undefined type 0x$hex";
    }

    $self->{'_archive'}->parse;
}

sub _do_magic {
    my $self = shift;
    my $str = $self->{'_file'}->read_str(3);

    die "File is not a MPQ format (wrong magic)" unless $str eq MAGIC;
}

=head2 shunt

Accessor to the L<MPQ::Shunt> object (could be without it)

=cut

sub shunt { $_[0]->{'_shunt'} }

=head2 archive

Accessor to the L<MPQ::Archive> object - heart of the MPQ file.

=cut

sub archive { $_[0]->{'_archive'} }

1;

=head1 AUTHOR

cono C<q@cono.org.ua>

C corporation (c)

