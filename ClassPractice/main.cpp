#include <iostream>
#include "CBox.hpp"
using namespace std;

int main()
{
MyBox Box1; //声明Box1，类型为Box
MyBox Box2;
MyBox Box3;
double volume=0.0;

//Box1单述
Box1.length=6.0;
Box1.width =7.0;
Box1.height=8.0;

//Box2单述
Box2.length =12.0;
Box2.width =13.0;
Box2.height =14.0;

  // box 1 的体积
   volume = Box1.height * Box1.length * Box1.width;
   cout << "Box1 的体积：" << volume <<endl;
 
   // box 2 的体积
   volume = Box2.height * Box2.length * Box2.width;
   cout << "Box2 的体积：" << volume <<endl;
 
 
   // box 3 详述
   Box3.set(16.0, 8.0, 12.0); 
   volume = Box3.get(); 
   cout << "Box3 的体积：" << volume <<endl;

return 0;
}
