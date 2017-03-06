March 2017 - justin.warwick@gmail.com
Shared under MIT license.

A few small modifications and utility scripts to make the blocking notification also a streamlined whitelisting utility using the excellent web proxy filter DansGuardian. Particularly useful if you wish to take a blanket-block/white-listing approach. Maybe something to put on http://dansguardian.org/?page=extras

Please note that at the time I put this together, I was using FreeBSD 10. Your configuration filepaths may vary. Also assumes that your whitelisting approach is to blanketblock in greysitelist or bannedsitelist (which is not as strong as you might think, if you use blanket) then filling this /usr/local/etc/dansguardian/lists/exceptionsitelist with stuff you trust totally.


Parts: 
 - a customized blocked template which includes a special link to call a white-list adding script. 
 - a white-list adding shell script and a wrapper CGI script. Because that is a privileged action, it is recommended that the script be protected by a password. (e.g., .htpasswd for apache)
 - a cronjob to call the white-list adding script periodically just in case of CGI script failure.
 - a simple dansguardian daemon restarting binary. This is so that we can give it setuid; many 'NIXs prohibit setuid on scripts.

Config & Install:
#Compile reload_dansguardian.c
#cd into your apache cgi-bin/scripts directory
mkdir admin
#populate /usr/local/www/apache24/cgi-bin/admin/.htpasswd  (configure this with the htpasswd utility. Try man htpasswd )
#Copy the binaries and scripts to respective destinations:
	/usr/local/sbin/reload_dansguardian
	/usr/local/share/dansguardian/scripts/whitelistadditions
	/usr/local/www/apache24/cgi-bin/admin/dansguardian-whitelist.pl
	/usr/local/share/dansguardian/languages/ukenglish/template.html



Sample apache configuration section:
```
<Directory "/usr/local/www/apache24/cgi-bin/admin">
    AuthType Basic
    AuthName "Restricted Administrative Action"
    AuthBasicProvider file
    AuthUserFile /usr/local/www/apache24/cgi-bin/admin/.htpasswd
    Require valid-user
	#This next one obviously needs to match your LAN ip subnet:
    Allow from 10.0.0
    AllowOverride None
    Options FollowSymLinks ExecCGI
    AddHandler cgi-script .pl
</Directory>
```
