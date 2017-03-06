/* For better security, most *nixs disallow the SUID access mode bit
*  for interpreted scripts. This is just meant to allow a CGI script
*  for adding white-list exceptions to dansguardian configs to re-
*  start the daemon safely.
*  justin.warwick@gmail.com Feb. 2015
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#define ROOT_UID   0
#define DGBINPATH  "/usr/local/sbin/dansguardian"
#define DGLISTADD  "/usr/local/share/dansguardian/scripts/whitelistadditions"
#define PATHLEN    60

int main()
{	int shret = 0;
	char cmd[64] = "";
	
	/* Only the reset if only need to do the restart, which assumes appending already done.
	strncat(cmd, DGBINPATH, PATHLEN);
	strncat(cmd, " -r", 4);
	*/

	strncat(cmd,DGLISTADD,PATHLEN);
	setuid(ROOT_UID);
	shret = system(cmd);

	return shret;
}
	
