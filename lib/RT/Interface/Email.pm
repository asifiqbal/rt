# $Header: /raid/cvsroot/rt/lib/RT/Interface/Email.pm,v 1.3.2.1 2002/01/28 05:27:14 jesse Exp $
# RT is (c) 1996-2002 Jesse Vincent <jesse@bestpractical.com>

use RT;
package RT::Interface::Email;

use strict;
use Mail::Address;
use MIME::Entity;

BEGIN {
    use Exporter();
    use vars qw ($VERSION  @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

    # set the version for version checking
    $VERSION = do { my @r = (q$Revision: 1.3.2.1 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r }; # must be all one line, for MakeMaker

    @ISA = qw(Exporter);

    # your exported package globals go here,
    # as well as any optionally exported functions
    @EXPORT_OK = qw(&CleanEnv
      &GetCurrentUser
      &GetMessageContent
      &CheckForLoops
      &CheckForSuspiciousSender
      &CheckForAutoGenerated
      &ParseMIMEEntityFromSTDIN
      &ParseMIMEEntityFromFileHandle
      &ParseTicketId
      &MailError
      &ParseCcAddressesFromHead
      &ParseSenderAddressFromHead
      &ParseErrorsToAddressFromHead
      &loc

      &debug);
}

=head1 NAME

  RT::Interface::CLI - helper functions for creating a commandline RT interface

=head1 SYNOPSIS

  use lib "!!RT_LIB_PATH!!";
  use lib "!!RT_ETC_PATH!!";

  use RT;
  use RT::Interface::Email  qw(CleanEnv 
			      );

  #Clean out all the nasties from the environment
  CleanEnv();

  # Load RT's config file

  RT::LoadConfig();
 #  connect to the database
  RT::Init();

  #Get the current user all loaded
  my $CurrentUser = GetCurrentUser();

=head1 DESCRIPTION


=begin testing

ok(require RT::Interface::Email);

=end testing


=head1 METHODS

=cut

=head2 CleanEnv

Removes some of the nastiest nasties from the user\'s environment.

=cut

sub CleanEnv {
    $ENV{'PATH'}   = '/bin:/usr/bin';                     # or whatever you need
    $ENV{'CDPATH'} = '' if defined $ENV{'CDPATH'};
    $ENV{'SHELL'}  = '/bin/sh' if defined $ENV{'SHELL'};
    $ENV{'ENV'}    = '' if defined $ENV{'ENV'};
    $ENV{'IFS'}    = '' if defined $ENV{'IFS'};
}


# {{{ sub debug

sub debug {
    my $val = shift;
    my ($debug);
    if ($val) {
        $RT::Logger->debug( $val . "\n" );
        if ($debug) {
            print STDERR "$val\n";
        }
    }
    if ($debug) {
        return (1);
    }
}

# }}}

# {{{ sub CheckForLoops 

sub CheckForLoops {
    my $head = shift;

    #If this instance of RT sent it our, we don't want to take it in
    my $RTLoop = $head->get("X-RT-Loop-Prevention") || "";
    chomp($RTLoop);    #remove that newline
    if ( $RTLoop eq "$RT::rtname" ) {
        return (1);
    }

    # TODO: We might not trap the case where RT instance A sends a mail
    # to RT instance B which sends a mail to ...
    return (undef);
}

# }}}

# {{{ sub CheckForSuspiciousSender

sub CheckForSuspiciousSender {
    my $head = shift;

    #if it's from a postmaster or mailer daemon, it's likely a bounce.

    #TODO: better algorithms needed here - there is no standards for
    #bounces, so it's very difficult to separate them from anything
    #else.  At the other hand, the Return-To address is only ment to be
    #used as an error channel, we might want to put up a separate
    #Return-To address which is treated differently.

    #TODO: search through the whole email and find the right Ticket ID.

    my ( $From, $junk ) = ParseSenderAddressFromHead($head);

    if ( ( $From =~ /^mailer-daemon/i ) or ( $From =~ /^postmaster/i ) ) {
        return (1);

    }

    return (undef);

}

# }}}

# {{{ sub CheckForAutoGenerated
sub CheckForAutoGenerated {
    my $head = shift;

    my $Precedence = $head->get("Precedence") || "";
    if ( $Precedence =~ /^(bulk|junk)/i ) {
        return (1);
    }
    else {
        return (0);
    }
}

# }}}

# {{{ sub ParseMIMEEntityFromSTDIN

sub ParseMIMEEntityFromSTDIN {

    return ParseMIMEEntityFromFileHandle(\*STDIN);
}

sub ParseMIMEEntityFromFileHandle {

    my $filehandle = shift;

    # Create a new parser object:

    my $parser = new MIME::Parser;

    # {{{ Config $parser to store large attacments in temp dir

    ## TODO: Does it make sense storing to disk at all?  After all, we
    ## need to put each msg as an in-core scalar before saving it to
    ## the database, don't we?

    ## At the same time, we should make sure that we nuke attachments 
    ## Over max size and return them

    ## TODO: Remove the temp dir when we don't need it any more.

    my $AttachmentDir = File::Temp::tempdir( TMPDIR => 1, CLEANUP => 1 );

    # Set up output directory for files:
    $parser->output_dir("$AttachmentDir");

    #If someone includes a message, don't extract it
    $parser->extract_nested_messages(1);

    # Set up the prefix for files with auto-generated names:
    $parser->output_prefix("part");

    # If content length is <= 20000 bytes, store each msg as in-core scalar;
    # Else, write to a disk file (the default action):

    $parser->output_to_core(20000);

    # }}} (temporary directory)

    #Ok. now that we're set up, let's get the MIME entity
    my $entity;
    unless ( $entity = $parser->read($filehandle) ) {

        # Try again, this time without extracting nested messages
        $parser->extract_nested_messages(0);
        unless ( $entity = $parser->read($filehandle) ) {
            $RT::Logger->crit("couldn't parse MIME stream");
            return ( undef, undef );
        }
    }

    #Now we've got a parsed mime object. 

    # Get the head, a MIME::Head:
    my $head = $entity->head;

    # Unfold headers that are have embedded newlines
    $head->unfold;

    # TODO - information about the charset is lost here!
    $head->decode;

    return ( $entity, $head );

}

# }}}

# {{{ sub ParseTicketId 

sub ParseTicketId {
    my $Subject = shift;
    my ($Id);

    if ( $Subject =~ s/\[$RT::rtname \#(\d+)\]//i ) {
        $Id = $1;
        $RT::Logger->debug("Found a ticket ID. It's $Id");
        return ($Id);
    }
    else {
        return (undef);
    }
}

# }}}

# {{{ sub MailError 
sub MailError {
    my %args = (
        To          => $RT::OwnerEmail,
        Bcc         => undef,
        From        => $RT::CorrespondAddress,
        Subject     => 'There has been an error',
        Explanation => 'Unexplained error',
        MIMEObj     => undef,
        LogLevel    => 'crit',
        @_
    );

    $RT::Logger->log(
        level   => $args{'LogLevel'},
        message => $args{'Explanation'}
    );
    my $entity = MIME::Entity->build(
        Type                   => "multipart/mixed",
        From                   => $args{'From'},
        Bcc                    => $args{'Bcc'},
        To                     => $args{'To'},
        Subject                => $args{'Subject'},
        'X-RT-Loop-Prevention' => $RT::rtname,
    );

    $entity->attach( Data => $args{'Explanation'} . "\n" );

    my $mimeobj = $args{'MIMEObj'};
    $mimeobj->sync_headers();
    $entity->add_part($mimeobj);

    if ( $RT::MailCommand eq 'sendmailpipe' ) {
        open( MAIL, "|$RT::SendmailPath $RT::SendmailArguments" ) || return (0);
        print MAIL $entity->as_string;
        close(MAIL);
    }
    else {
        $entity->send( $RT::MailCommand, $RT::MailParams );
    }
}

# }}}

{

    my $CurrentUser; # shared betwen GetCurrentUser and loc

# {{{ sub GetCurrentUser 

sub GetCurrentUser {
    my $head     = shift;
    my $entity   = shift;
    my $ErrorsTo = shift;

    my %UserInfo = ();

    #Suck the address of the sender out of the header
    my ( $Address, $Name ) = ParseSenderAddressFromHead($head);

    #Get us a currentuser object to work with. 
    $CurrentUser = RT::CurrentUser->new();


    #This will apply local address canonicalization rules
    $Address = $CurrentUser->CanonicalizeAddress($Address);

    #If desired, synchronize with an external database
    my $UserFoundInExternalDatabase = 0;

    # Username is the 'Name' attribute of the user that RT uses for things
    # like authentication
    my $Username = undef;
        ( $UserFoundInExternalDatabase, %UserInfo ) =
          LookupExternalUserInfo( $Address, $Name );

        $Address  = $UserInfo{'EmailAddress'};
        $Username = $UserInfo{'Name'};


    # First try looking up by a username, if we got one from the external
    # db lookup. Next, try looking up by email address. Failing that,
    # try looking up by users who have this user's email address as their
    # username.

    if ($Username) {
        $CurrentUser->LoadByName($Username);
    }

    unless ( $CurrentUser->Id ) {
        $CurrentUser->LoadByEmail($Address);
    }

    #If we can't get it by email address, try by name.  
    unless ( $CurrentUser->Id ) {
        $CurrentUser->LoadByName($Address);
    }

    unless ( $CurrentUser->Id ) {

        #If we couldn't load a user, determine whether to create a user

        # {{{ If we require an incoming address to be found in the external
        # user database, reject the incoming message appropriately
        if ( $RT::SenderMustExistInExternalDatabase
            && !$UserFoundInExternalDatabase )
        {

            my $Message =
              "Sender's email address was not found in the user database.";

            # {{{  This code useful only if you've defined an AutoRejectRequest template

            require RT::Template;
            my $template = new RT::Template($RT::Nobody);
            $template->Load('AutoRejectRequest');
            $Message = $template->Content || $Message;

            # }}}

            MailError(
                To      => $ErrorsTo,
                Subject => "Ticket Creation failed: user could not be created",
                Explanation => $Message,
                MIMEObj     => $entity,
                LogLevel    => 'notice'
            );

            return ($CurrentUser);

        }

        # }}}

        else {
            my $NewUser = RT::User->new($RT::SystemUser);

            my ( $Val, $Message ) = $NewUser->Create(
                Name => ( $Username || $Address ),
                EmailAddress => $Address,
                RealName     => "$Name",
                Password     => undef,
                Privileged   => 0,
                Comments     => 'Autocreated on ticket submission'
            );

            unless ($Val) {

                # Deal with the race condition of two account creations at once
                #
                if ($Username) {
                    $NewUser->LoadByName($Username);
                }

                unless ( $NewUser->Id ) {
                    $NewUser->LoadByEmail($Address);
                }

                unless ( $NewUser->Id ) {
                    MailError(
                        To          => $ErrorsTo,
                        Subject     => "User could not be created",
                        Explanation =>
                        "User creation failed in mailgateway: $Message",
                        MIMEObj  => $entity,
                        LogLevel => 'crit'
                    );
                }
            }
        }

        #Load the new user object
        $CurrentUser->LoadByEmail($Address);

        unless ( $CurrentUser->id ) {
            $RT::Logger->warning(
                "Couldn't load user '$Address'." . "giving up" );
            MailError(
                To          => $ErrorsTo,
                Subject     => "User could not be loaded",
                Explanation =>
                "User  '$Address' could not be loaded in the mail gateway",
                MIMEObj  => $entity,
                LogLevel => 'crit'
            );

        }
    }

    return ($CurrentUser);

}

# }}}

# {{{ sub loc 

=head2 loc

  Synonym of $CurrentUser->loc().

=cut

sub loc {
    die "No current user yet" unless $CurrentUser;
    return $CurrentUser->loc(@_);
}
# }}}

}

# {{{ ParseCcAddressesFromHead 

=head2 ParseCcAddressesFromHead HASHREF

Takes a hashref object containing QueueObj, Head and CurrentUser objects.
Returns a list of all email addresses in the To and Cc 
headers b<except> the current Queue\'s email addresses, the CurrentUser\'s 
email address  and anything that the $RTAddressRegexp matches.

=cut

sub ParseCcAddressesFromHead {
    my %args = (
        Head        => undef,
        QueueObj    => undef,
        CurrentUser => undef,
        @_
    );

    my (@Addresses);

    my @ToObjs = Mail::Address->parse( $args{'Head'}->get('To') );
    my @CcObjs = Mail::Address->parse( $args{'Head'}->get('Cc') );

    foreach my $AddrObj ( @ToObjs, @CcObjs ) {
        my $Address = $AddrObj->address;
        $Address = RT::CanonicalizeAddress($Address);
        next if ( $args{'CurrentUser'}->EmailAddress   =~ /^$Address$/i );
        next if ( $args{'QueueObj'}->CorrespondAddress =~ /^$Address$/i );
        next if ( $args{'QueueObj'}->CommentAddress    =~ /^$Address$/i );
        next if ( IsRTAddress($Address) );

        push ( @Addresses, $Address );
    }
    return (@Addresses);
}

# }}}

# {{{ ParseSenderAdddressFromHead

=head2 ParseSenderAddressFromHead

Takes a MIME::Header object. Returns a tuple: (user@host, friendly name) 
of the From (evaluated in order of Reply-To:, From:, Sender)

=cut

sub ParseSenderAddressFromHead {
    my $head = shift;

    #Figure out who's sending this message.
    my $From = $head->get('Reply-To')
      || $head->get('From')
      || $head->get('Sender');
    return ( ParseAddressFromHeader($From) );
}

# }}}

# {{{ ParseErrorsToAdddressFromHead

=head2 ParseErrorsToAddressFromHead

Takes a MIME::Header object. Return a single value : user@host
of the From (evaluated in order of Errors-To:,Reply-To:, From:, Sender)

=cut

sub ParseErrorsToAddressFromHead {
    my $head = shift;

    #Figure out who's sending this message.

    foreach my $header ( 'Errors-To', 'Reply-To', 'From', 'Sender' ) {

        # If there's a header of that name
        my $headerobj = $head->get($header);
        if ($headerobj) {
            my ( $addr, $name ) = ParseAddressFromHeader($headerobj);

            # If it's got actual useful content...
            return ($addr) if ($addr);
        }
    }
}

# }}}

# {{{ ParseAddressFromHeader

=head2 ParseAddressFromHeader ADDRESS

Takes an address from $head->get('Line') and returns a tuple: user@host, friendly name

=cut

sub ParseAddressFromHeader {
    my $Addr = shift;

    my @Addresses = Mail::Address->parse($Addr);

    my $AddrObj = $Addresses[0];

    unless ( ref($AddrObj) ) {
        return ( undef, undef );
    }

    my $Name = ( $AddrObj->phrase || $AddrObj->comment || $AddrObj->address );

    #Lets take the from and load a user object.
    my $Address = $AddrObj->address;

    return ( $Address, $Name );
}

# }}}

# {{{ IsRTAddress

=item IsRTaddress ADDRESS

Takes a single parameter, an email address. 
Returns true if that address matches the $RTAddressRegexp.  
Returns false, otherwise.

=cut

sub IsRTAddress {
    my $address = shift;

    # Example: the following rule would tell RT not to Cc 
    #   "tickets@noc.example.com"
    return (1) if ( defined($RT::RTAddressRegexp) &&
                       $address =~ /$RT::RTAddressRegexp/ );
    return (undef);
}

=for testing
is(RT::Interface::Email::IsRTAddress("rt\@example.com"),1, "Regexp matched rt address" );
is(RT::Interface::Email::IsRTAddress("frt\@example.com"),undef, "Regexp didn't match non-rt address" );

=cut

# }}}
=item LookupExternalUserInfo

# LookupExternalUserInfo is a site-definable method for synchronizing
# incoming users with an external data source. 
#
# This routine takes a tuple of EmailAddress and FriendlyName
#   EmailAddress is the user's email address, ususally taken from
#       an email message's From: header.
#   FriendlyName is a freeform string, ususally taken from the "comment" 
#       portion of an email message's From: header.
#
# If you define an AutoRejectRequest template, RT will use this   
# template for the rejection message.

$SenderMustExistInExternalDatabase = undef;;

# {{{ LookupExternalUserInfo
=item LookupExternalUserInfo

 LookupExternalUserInfo is a site-definable method for synchronizing
 incoming users with an external data source. 

 This routine takes a tuple of EmailAddress and FriendlyName
    EmailAddress is the user's email address, ususally taken from
        an email message's From: header.
    FriendlyName is a freeform string, ususally taken from the "comment" 
        portion of an email message's From: header.

 It returns (FoundInExternalDatabase, ParamHash);

   FoundInExternalDatabase must  be set to 1 before return if the user was
   found in the external database.

   ParamHash is a Perl parameter hash which can contain at least the following
   fields. These fields are used to populate RT's users database when the user 
   is created

    EmailAddress is the email address that RT should use for this user.  
    Name is the 'Name' attribute RT should use for this user. 
         'Name' is used for things like access control and user lookups.
    RealName is what RT should display as the user's name when displaying 
         'friendly' names

=cut

sub LookupExternalUserInfo {
  my ($EmailAddress, $RealName) = @_;

  my $FoundInExternalDatabase = 1;
  my %params = {};

  #Name is the RT username you want to use for this user.
  $params{'Name'} = $EmailAddress;
  $params{'EmailAddress'} = $EmailAddress;
  $params{'RealName'} = $RealName;

  # See RT's contributed code for examples.
  # http://www.fsck.com/pub/rt/contrib/
  return ($FoundInExternalDatabase, %params);
}

# }}}
1;
