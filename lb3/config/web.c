#include "webserver.h"
#include <stdio.h>

void getRoot(Request *req, Response *res) { res->content.data = "hello world"; }

int main(int argc, char **argv) {
  printf("Starting web server...\n"); // will I be able to see this in container logs?: answer yes 
  int port = 8080; // get the first argument from the command line
  if (argc > 1) port = atoi(argv[1]);
  printf("Port: %d\n", port);
  celp(port);
  // addRoute("/", NULL, getRoot, GET);
  addRoute("/", "config/index.html", NULL, GET);
  keepAlive();
  return 0;
}

// int main() { 
//   printf("hi");
//   return 0; }