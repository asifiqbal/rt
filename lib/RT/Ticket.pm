# BEGIN LICENSE BLOCK
# 
# Copyright (c) 1996-2003 Jesse Vincent <jesse@bestpractical.com>
# 
# (Except where explictly superceded by other copyright notices)
# 
# This work is made available to you under the terms of Version 2 of
# the GNU General Public License. A copy of that license should have
# been provided with this software, but in any event can be snarfed
# from www.gnu.org.
# 
# This work is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# Unless otherwise specified, all modifications, corrections or
# extensions to this work which alter its source code become the
# property of Best Practical Solutions, LLC when submitted for
# inclusion in the work.
# 
# 
# END LICENSE BLOCK

# Autogenerated by DBIx::SearchBuilder factory (by <jesse@bestpractical.com>)
# WARNING: THIS FILE IS AUTOGENERATED. ALL CHANGES TO THIS FILE WILL BE LOST.  
# 
# !! DO NOT EDIT THIS FILE !!
#

use strict;


=head1 NAME

RT::Ticket


=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut

package RT::Ticket;
use RT::Record; 
use RT::Queue;


use vars qw( @ISA );
@ISA= qw( RT::Record );

sub _Init {
  my $self = shift; 

  $self->Table('Tickets');
  $self->SUPER::_Init(@_);
}





=head2 Create PARAMHASH

Create takes a hash of values and creates a row in the database:

  int(11) 'EffectiveId'.
  int(11) 'Queue'.
  varchar(16) 'Type'.
  int(11) 'IssueStatement'.
  int(11) 'Resolution'.
  int(11) 'Owner'.
  varchar(200) 'Subject' defaults to '[no subject]'.
  int(11) 'InitialPriority'.
  int(11) 'FinalPriority'.
  int(11) 'Priority'.
  int(11) 'TimeEstimated'.
  int(11) 'TimeWorked'.
  varchar(10) 'Status'.
  int(11) 'TimeLeft'.
  datetime 'Told'.
  datetime 'Starts'.
  datetime 'Started'.
  datetime 'Due'.
  datetime 'Resolved'.
  smallint(6) 'Disabled'.

=cut




sub Create {
    my $self = shift;
    my %args = ( 
                EffectiveId => '0',
                Queue => '0',
                Type => '',
                IssueStatement => '0',
                Resolution => '0',
                Owner => '0',
                Subject => '[no subject]',
                InitialPriority => '0',
                FinalPriority => '0',
                Priority => '0',
                TimeEstimated => '0',
                TimeWorked => '0',
                Status => '',
                TimeLeft => '0',
                Told => '',
                Starts => '',
                Started => '',
                Due => '',
                Resolved => '',
                Disabled => '0',

		  @_);
    $self->SUPER::Create(
                         EffectiveId => $args{'EffectiveId'},
                         Queue => $args{'Queue'},
                         Type => $args{'Type'},
                         IssueStatement => $args{'IssueStatement'},
                         Resolution => $args{'Resolution'},
                         Owner => $args{'Owner'},
                         Subject => $args{'Subject'},
                         InitialPriority => $args{'InitialPriority'},
                         FinalPriority => $args{'FinalPriority'},
                         Priority => $args{'Priority'},
                         TimeEstimated => $args{'TimeEstimated'},
                         TimeWorked => $args{'TimeWorked'},
                         Status => $args{'Status'},
                         TimeLeft => $args{'TimeLeft'},
                         Told => $args{'Told'},
                         Starts => $args{'Starts'},
                         Started => $args{'Started'},
                         Due => $args{'Due'},
                         Resolved => $args{'Resolved'},
                         Disabled => $args{'Disabled'},
);

}



=head2 id

Returns the current value of id. 
(In the database, id is stored as int(11).)


=cut


=head2 EffectiveId

Returns the current value of EffectiveId. 
(In the database, EffectiveId is stored as int(11).)



=head2 SetEffectiveId VALUE


Set EffectiveId to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, EffectiveId will be stored as a int(11).)


=cut


=head2 Queue

Returns the current value of Queue. 
(In the database, Queue is stored as int(11).)



=head2 SetQueue VALUE


Set Queue to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, Queue will be stored as a int(11).)


=cut


=head2 QueueObj

Returns the Queue Object which has the id returned by Queue


=cut

sub QueueObj {
	my $self = shift;
	my $Queue =  RT::Queue->new($self->CurrentUser);
	$Queue->Load($self->__Value('Queue'));
	return($Queue);
}

=head2 Type

Returns the current value of Type. 
(In the database, Type is stored as varchar(16).)



=head2 SetType VALUE


Set Type to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, Type will be stored as a varchar(16).)


=cut


=head2 IssueStatement

Returns the current value of IssueStatement. 
(In the database, IssueStatement is stored as int(11).)



=head2 SetIssueStatement VALUE


Set IssueStatement to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, IssueStatement will be stored as a int(11).)


=cut


=head2 Resolution

Returns the current value of Resolution. 
(In the database, Resolution is stored as int(11).)



=head2 SetResolution VALUE


Set Resolution to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, Resolution will be stored as a int(11).)


=cut


=head2 Owner

Returns the current value of Owner. 
(In the database, Owner is stored as int(11).)



=head2 SetOwner VALUE


Set Owner to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, Owner will be stored as a int(11).)


=cut


=head2 Subject

Returns the current value of Subject. 
(In the database, Subject is stored as varchar(200).)



=head2 SetSubject VALUE


Set Subject to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, Subject will be stored as a varchar(200).)


=cut


=head2 InitialPriority

Returns the current value of InitialPriority. 
(In the database, InitialPriority is stored as int(11).)



=head2 SetInitialPriority VALUE


Set InitialPriority to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, InitialPriority will be stored as a int(11).)


=cut


=head2 FinalPriority

Returns the current value of FinalPriority. 
(In the database, FinalPriority is stored as int(11).)



=head2 SetFinalPriority VALUE


Set FinalPriority to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, FinalPriority will be stored as a int(11).)


=cut


=head2 Priority

Returns the current value of Priority. 
(In the database, Priority is stored as int(11).)



=head2 SetPriority VALUE


Set Priority to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, Priority will be stored as a int(11).)


=cut


=head2 TimeEstimated

Returns the current value of TimeEstimated. 
(In the database, TimeEstimated is stored as int(11).)



=head2 SetTimeEstimated VALUE


Set TimeEstimated to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, TimeEstimated will be stored as a int(11).)


=cut


=head2 TimeWorked

Returns the current value of TimeWorked. 
(In the database, TimeWorked is stored as int(11).)



=head2 SetTimeWorked VALUE


Set TimeWorked to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, TimeWorked will be stored as a int(11).)


=cut


=head2 Status

Returns the current value of Status. 
(In the database, Status is stored as varchar(10).)



=head2 SetStatus VALUE


Set Status to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, Status will be stored as a varchar(10).)


=cut


=head2 TimeLeft

Returns the current value of TimeLeft. 
(In the database, TimeLeft is stored as int(11).)



=head2 SetTimeLeft VALUE


Set TimeLeft to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, TimeLeft will be stored as a int(11).)


=cut


=head2 Told

Returns the current value of Told. 
(In the database, Told is stored as datetime.)



=head2 SetTold VALUE


Set Told to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, Told will be stored as a datetime.)


=cut


=head2 Starts

Returns the current value of Starts. 
(In the database, Starts is stored as datetime.)



=head2 SetStarts VALUE


Set Starts to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, Starts will be stored as a datetime.)


=cut


=head2 Started

Returns the current value of Started. 
(In the database, Started is stored as datetime.)



=head2 SetStarted VALUE


Set Started to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, Started will be stored as a datetime.)


=cut


=head2 Due

Returns the current value of Due. 
(In the database, Due is stored as datetime.)



=head2 SetDue VALUE


Set Due to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, Due will be stored as a datetime.)


=cut


=head2 Resolved

Returns the current value of Resolved. 
(In the database, Resolved is stored as datetime.)



=head2 SetResolved VALUE


Set Resolved to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, Resolved will be stored as a datetime.)


=cut


=head2 LastUpdatedBy

Returns the current value of LastUpdatedBy. 
(In the database, LastUpdatedBy is stored as int(11).)


=cut


=head2 LastUpdated

Returns the current value of LastUpdated. 
(In the database, LastUpdated is stored as datetime.)


=cut


=head2 Creator

Returns the current value of Creator. 
(In the database, Creator is stored as int(11).)


=cut


=head2 Created

Returns the current value of Created. 
(In the database, Created is stored as datetime.)


=cut


=head2 Disabled

Returns the current value of Disabled. 
(In the database, Disabled is stored as smallint(6).)



=head2 SetDisabled VALUE


Set Disabled to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, Disabled will be stored as a smallint(6).)


=cut



sub _CoreAccessible {
    {
     
        id =>
		{read => 1, type => 'int(11)', default => ''},
        EffectiveId => 
		{read => 1, write => 1, type => 'int(11)', default => '0'},
        Queue => 
		{read => 1, write => 1, type => 'int(11)', default => '0'},
        Type => 
		{read => 1, write => 1, type => 'varchar(16)', default => ''},
        IssueStatement => 
		{read => 1, write => 1, type => 'int(11)', default => '0'},
        Resolution => 
		{read => 1, write => 1, type => 'int(11)', default => '0'},
        Owner => 
		{read => 1, write => 1, type => 'int(11)', default => '0'},
        Subject => 
		{read => 1, write => 1, type => 'varchar(200)', default => '[no subject]'},
        InitialPriority => 
		{read => 1, write => 1, type => 'int(11)', default => '0'},
        FinalPriority => 
		{read => 1, write => 1, type => 'int(11)', default => '0'},
        Priority => 
		{read => 1, write => 1, type => 'int(11)', default => '0'},
        TimeEstimated => 
		{read => 1, write => 1, type => 'int(11)', default => '0'},
        TimeWorked => 
		{read => 1, write => 1, type => 'int(11)', default => '0'},
        Status => 
		{read => 1, write => 1, type => 'varchar(10)', default => ''},
        TimeLeft => 
		{read => 1, write => 1, type => 'int(11)', default => '0'},
        Told => 
		{read => 1, write => 1, type => 'datetime', default => ''},
        Starts => 
		{read => 1, write => 1, type => 'datetime', default => ''},
        Started => 
		{read => 1, write => 1, type => 'datetime', default => ''},
        Due => 
		{read => 1, write => 1, type => 'datetime', default => ''},
        Resolved => 
		{read => 1, write => 1, type => 'datetime', default => ''},
        LastUpdatedBy => 
		{read => 1, auto => 1, type => 'int(11)', default => '0'},
        LastUpdated => 
		{read => 1, auto => 1, type => 'datetime', default => ''},
        Creator => 
		{read => 1, auto => 1, type => 'int(11)', default => '0'},
        Created => 
		{read => 1, auto => 1, type => 'datetime', default => ''},
        Disabled => 
		{read => 1, write => 1, type => 'smallint(6)', default => '0'},

 }
};


        eval "require RT::Ticket_Overlay";
        if ($@ && $@ !~ qr{^Can't locate RT/Ticket_Overlay.pm}) {
            die $@;
        };

        eval "require RT::Ticket_Vendor";
        if ($@ && $@ !~ qr{^Can't locate RT/Ticket_Vendor.pm}) {
            die $@;
        };

        eval "require RT::Ticket_Local";
        if ($@ && $@ !~ qr{^Can't locate RT/Ticket_Local.pm}) {
            die $@;
        };




=head1 SEE ALSO

This class allows "overlay" methods to be placed
into the following files _Overlay is for a System overlay by the original author,
_Vendor is for 3rd-party vendor add-ons, while _Local is for site-local customizations.  

These overlay files can contain new subs or subs to replace existing subs in this module.

If you'll be working with perl 5.6.0 or greater, each of these files should begin with the line 

   no warnings qw(redefine);

so that perl does not kick and scream when you redefine a subroutine or variable in your overlay.

RT::Ticket_Overlay, RT::Ticket_Vendor, RT::Ticket_Local

=cut


1;
