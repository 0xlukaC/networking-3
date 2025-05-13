#include "webserver.h"

void getRoot(Request *req, Response *res) { res->content.data = "yo"; }

int main(int argc, char **argv) {
  int port = 8080; // get the first argument from the command line
  if (argc) port = atoi(argv[1]);
  celp(port);
  addRoute("/", NULL, getRoot, GET);
  keepAlive();
  return 0;
}
