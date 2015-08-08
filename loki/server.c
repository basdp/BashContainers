/*
    C socket server example, handles multiple clients using threads
    Compile
    gcc server.c -lpthread -o server
*/
 
#include<stdio.h>
#include<string.h>    //strlen
#include<stdlib.h>    //strlen
#include<sys/socket.h>
#include<arpa/inet.h> //inet_addr
#include<unistd.h>    //write
#include<pthread.h> //for threading , link with lpthread
#include <netdb.h>
#include <netinet/in.h>
 
//the thread function
void *connection_handler(void *);
 
int main(int argc , char *argv[])
{
    int socket_desc , client_sock , c;
    struct sockaddr_in server , client;
     
    //Create socket
    socket_desc = socket(AF_INET , SOCK_STREAM , 0);
    if (socket_desc == -1)
    {
        printf("Could not create socket");
    }
    puts("Socket created");
     
    //Prepare the sockaddr_in structure
    server.sin_family = AF_INET;
    server.sin_addr.s_addr = INADDR_ANY;
    server.sin_port = htons( 8888 );
     
    //Bind
    if( bind(socket_desc,(struct sockaddr *)&server , sizeof(server)) < 0)
    {
        //print the error message
        perror("bind failed. Error");
        return 1;
    }
    puts("bind done");
     
    //Listen
    listen(socket_desc , 3);
     
    //Accept and incoming connection
    puts("Waiting for incoming connections...");
    c = sizeof(struct sockaddr_in);
	pthread_t thread_id;
	
    while( (client_sock = accept(socket_desc, (struct sockaddr *)&client, (socklen_t*)&c)) )
    {
        puts("Connection accepted");
         
        if( pthread_create( &thread_id , NULL ,  connection_handler , (void*) &client_sock) < 0)
        {
            perror("could not create thread");
            return 1;
        }
         
        //Now join the thread , so that we dont terminate before the thread
        //pthread_join( thread_id , NULL);
        puts("Handler assigned");
    }
     
    if (client_sock < 0)
    {
        perror("accept failed");
        return 1;
    }
     
    return 0;
}
 
/*
 * This will handle connection for each client
 * */
void *connection_handler(void *socket_desc)
{
    //Get the socket descriptor
    int sock = *(int*)socket_desc;
    int read_size;
    char *message , client_message[2000];
     
    //Send some messages to the client
    /*message = "Greetings! I am your connection handler\n";
    write(sock , message , strlen(message));
     
    message = "Now type something and i shall repeat what you type \n";
    write(sock , message , strlen(message));*/
    
    char *host = malloc(sizeof(char) * 1024);
    strcpy(host, "");
    
    int requestsize = sizeof(char) * 4096 * 2;
    char *request = malloc(requestsize);
    int requestlen = 0;
    
	int buffersize = sizeof(char) * 4096;
	char *buffer = malloc(buffersize);
	int bufferlen = 0;
	char lastchar = '\0';
	
    //Receive a message from client
    while((read_size = recv(sock, (void*)&buffer[bufferlen], 1, 0)) > 0)
    {
        bufferlen++;
		if (buffer[bufferlen - 1] == '\n' && lastchar == '\r') {
			
            buffer[bufferlen - 2] = '\0';
			//printf("line received: \"%s\"\n", buffer);
            
            if (strcmp(buffer, "") == 0) {
                // end of headers
                break;
            }
            
            if (strncmp(buffer, "Host: ", 6) == 0) {
                strcpy(host, &buffer[6]);
            }
            
            buffer[bufferlen - 2] = '\r';
            
            if (requestlen + bufferlen > requestsize) {
                request = realloc(request, requestsize * 2);
                requestsize *= 2;
            }
            memcpy((void*)&request[requestlen], buffer, bufferlen);
            requestlen += bufferlen;
            
            memset(buffer, 0, buffersize);
			bufferlen = 0;
            lastchar = '\n';
		} else {
            //end of string marker
    		//client_message[read_size] = '\0';
    		
    		//Send the message back to client
            //write(sock , client_message , strlen(client_message));
    		//puts(client_message);
    		
    		//clear the message buffer
    		//memset(client_message, 0, 2000);
    		lastchar = buffer[bufferlen - 1];
        }
    }
    
    request[requestlen] = '\0';
    int port = 80;
    char portstr[8] = "80";
    char* sep = strchr(host, ':');
    if (sep != NULL) {
        port = atoi(sep + 1);
        strcpy(portstr, sep + 1);
        *sep = '\0';
    }
    printf("hostname: %s\nport: %i\n", host, port);
    if (requestlen + 4096 > requestsize) {
        request = realloc(request, requestsize + 4096);
        requestsize += 4096;
    }
    struct sockaddr_in address;
    int c = sizeof(address);
    getpeername(sock, (struct sockaddr*)&address, (socklen_t*)&c);
    char dst[256] = { 0 };
    
    strcat(request, "X-Forwarded-For: ");
    strcat(request, inet_ntop(AF_INET, &address.sin_addr, dst, 256));
    strcat(request, "\r\n");
    strcat(request, "X-Forwarded-Host: ");
    strcat(request, host);
    strcat(request, ":");    
    strcat(request, portstr);
    strcat(request, "\r\n");
    strcat(request, "\r\n");
    
	//printf("request: \"%s\"\n", request);
    printf("host is %s\n", host); 
    
    int sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0)
    {
      perror("ERROR opening socket");
      exit(1);
    }
        
    struct hostent* server = gethostbyname(host);
    if (server == NULL) {
      fprintf(stderr,"ERROR, no such host\n");
      exit(1);
    }
    struct sockaddr_in serv_addr;
    bzero((char *) &serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    bcopy((char *)server->h_addr, (char *)&serv_addr.sin_addr.s_addr, server->h_length);
    serv_addr.sin_port = htons(port);

    
    if(read_size == 0)
    {
        puts("Client disconnected");
        fflush(stdout);
    }
    else if(read_size == -1)
    {
        perror("recv failed");
    }
         
    return 0;
} 