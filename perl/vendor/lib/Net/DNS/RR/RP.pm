package Net::DNS::RR::RP;

#
# $Id: RP.pm 1229 2014-07-09 07:07:42Z willem $
#
use vars qw($VERSION);
$VERSION = (qw$LastChangedRevision: 1229 $)[1];


use strict;
use base qw(Net::DNS::RR);

=head1 NAME

Net::DNS::RR::RP - DNS RP resource record

=cut


use integer;

use Net::DNS::DomainName;
use Net::DNS::Mailbox;


sub decode_rdata {			## decode rdata from wire-format octet string
	my $self = shift;
	my ( $data, $offset, @opaque ) = @_;

	( $self->{mbox}, $offset ) = decode Net::DNS::Mailbox2535( $data, $offset, @opaque );
	$self->{txtdname} = decode Net::DNS::DomainName2535( $data, $offset, @opaque );
}


sub encode_rdata {			## encode rdata as wire-format octet string
	my $self = shift;
	my ( $offset, @opaque ) = @_;

	return '' unless $self->{txtdname};
	my $rdata = $self->{mbox}->encode( $offset, @opaque );
	$rdata .= $self->{txtdname}->encode( $offset + length($rdata), @opaque );
}


sub format_rdata {			## format rdata portion of RR string.
	my $self = shift;

	my $mbx = $self->{mbox}	    || return '';
	my $txt = $self->{txtdname} || return '';
	join ' ', $mbx->string, $txt->string;
}


sub parse_rdata {			## populate RR from rdata in argument list
	my $self = shift;

	$self->mbox(shift);
	$self->txtdname(shift);
}


sub mbox {
	my $self = shift;

	$self->{mbox} = new Net::DNS::Mailbox2535(shift) if scalar @_;
	$self->{mbox}->address if defined wantarray;
}


sub txtdname {
	my $self = shift;

	$self->{txtdname} = new Net::DNS::DomainName2535(shift) if scalar @_;
	$self->{txtdname}->name if defined wantarray;
}

1;
__END__


=head1 SYNOPSIS

    use Net::DNS;
    $rr = new Net::DNS::RR('name RP mbox txtdname');

=head1 DESCRIPTION

Class for DNS Responsible Person (RP) resource records.

=head1 METHODS

The available methods are those inherited from the base class augmented
by the type-specific methods defined in this package.

Use of undocumented package features or direct access to internal data
structures is discouraged and could result in program termination or
other unpredictable behaviour.


=head2 mbox

    $mbox = $rr->mbox;
    $rr->mbox( $mbox );

A domain name which specifies the mailbox for the person responsible for
this domain. The format in master files uses the DNS encoding convention
for mailboxes, identical to that used for the RNAME mailbox field in the
SOA RR. The root domain name (just ".") may be specified to indicate that
no mailbox is available.

=head2 txtdname

    $txtdname = $rr->txtdname;
    $rr->txtdname( $txtdname );

A domain name identifying TXT RRs. A subsequent query can be performed to
retrieve the associated TXT records. This provides a level of indirection
so that the entity can be referred to from multiple places in the DNS. The
root domain name (just ".") may be specified to indicate that there is no
associated TXT RR.


=head1 COPYRIGHT

Copyright (c)1997-2002 Michael Fuhr. 

All rights reserved.

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

Package template (c)2009,2012 O.M.Kolkman and R.W.Franks.


=head1 SEE ALSO

L<perl>, L<Net::DNS>, L<Net::DNS::RR>, RFC1183 Section 2.2

=cut
