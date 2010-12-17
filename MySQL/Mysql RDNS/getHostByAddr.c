#include <sys/socket.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char **argv)
{
struct hostent *hp; 
char *ip;
in_addr_t data; 

if (argc = 2) {
ip = argv[1];
data = inet_addr(ip);
hp = gethostbyaddr(&data, 4, AF_INET);

if (hp == NULL) {
printf("Unknown host\n");
exit(1);
}//why did i always get hp = NULL;
else {
printf("%s\n", hp->h_name);	
}
}
else printf("argv error");
}

