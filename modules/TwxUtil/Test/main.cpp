// argument_definitions.cpp
// compile with: /EHsc
#include <iostream>
#include <string.h>
#include <cstdlib>
#include <iomanip>

int main( int argc, char *argv[] )
{
  std::cout << "<argc>" << argc << "<argc/>";
  for (int ndx{}; ndx != argc; ++ndx) {
    std::cout << "<argv_" << ndx << ">"  << argv[ndx]
              << "<argv_" << ndx << "/>";
  }
  return argc == 3 ? EXIT_SUCCESS : EXIT_FAILURE; // optional return value
}
