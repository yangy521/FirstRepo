#include "CBox.hpp"
using namespace std;

double MyBox::get(void)
{
return length*width*height;

}

double MyBox::set(double len,double wid,double hei)
{
   length =len;
   width = wid;
   height = hei;

}
