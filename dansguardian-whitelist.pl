#!/usr/local/bin/perl -w -T

use strict;
use warnings;
use CGI;
use HTML::Entities;
use Apache::Htpasswd;

$ENV{'PATH'} = '/bin:/usr/bin:/usr/local/bin:/usr/local/sbin';
#my $SAFECHARS = 'a-zA-Z0-9 .,-_';
my $SAFECHARS = 'a-zA-Z0-9.-'; #RFC 1035
my $spool = "/var/spool/whitelist/";
my $filetag = "add";

my $q = CGI->new;
my $domainname = HTML::Entities::decode(substr($q->param("domain"), 0, 256));
my $cmd = HTML::Entities::decode(substr($q->param("cmd"), 0, 16));

print $q->header();

$domainname =~ s/[^$SAFECHARS]//go;
$cmd =~ s/[^$SAFECHARS]//go;
if ( $domainname =~ /^([^$SAFECHARS])+$/) { $domainname = $1 }; #UNtaint
if ( $cmd =~ /^([^$SAFECHARS])+$/)  { $cmd = $1 }; #UNtaint
	
if (!length($domainname)) {
	print "No valid domainname supplied.";
	die "No valid domainname supplied.";
} else {
	$domainname =~ s/^www\.//;
}



my $htpasswd = new Apache::Htpasswd({passwdFile => "/usr/local/www/apache24/cgi-bin/admin/.htpasswd", ReadOnly => 1});
if ($ENV{"REMOTE_USER"} =~ /restricted/i || ! $htpasswd->htCheckPassword("admin",$q->param("adminkey")) ) {
	print "Only an administratively privileged user may perform a whitelisting.";
	die "Only an administratively privileged user may perform a whitelisting.";
}

if (!chdir "${spool}") {
	print "Spool error!";
	die "$! - Could not get into the spool to deliver the additions";
} else {
	#actually, let the scheduled process do rolling
	#rename "${filetag}.0", "${filetag}.1";
	#rename "${filetag}.txt", "${filetag}.0";
	
	open SPOOLFILE , ">>${filetag}.txt";
	print SPOOLFILE "$domainname\n";
	close SPOOLFILE;

	print $q->start_html(-title=>'HTTP Proxy Whitelist Addition Submitted',-style=>{-src=>'/css/positive.css'}) . 
		"<p>Domain name &quot;<a href=\"http://${domainname}\">${domainname}</a>&quot; has been added to the whitelist. It should take effect immediately, but if you find that you still cannot reach the site, wait for a few minutes and try again.</p>\n<p>If you still cannot reach the site, check the domain name on the denial page; the origninal site may have automatically forwarded you to another, related domain name that must also be added. If all else fails, please <a href=\"mailto:justin.warwick+netadmin\@gmail.com?subject=http proxy whitelist management trouble with domain ${domainname}&body=Please assist with whitelisting of ${domainname}  .\">notify tech suport</a>.</p>" .
		"<img src=\"/img/unlocked.png\" />".
		"<script>var tid=setTimeout(function() {".
		"  var r = new XMLHttpRequest(); r.open('get','https://restricted:on@".$ENV{'SERVER_NAME'}."/cgi-bin/admin/dansguardian-whitelist.pl?cmd=restrict',true); r.send();" .
		"  }, 1500);".
		"</script>".
		$q->end_html;

	system '/usr/local/sbin/reload_dansguardian';
}
