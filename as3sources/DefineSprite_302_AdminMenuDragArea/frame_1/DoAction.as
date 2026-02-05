function onPress()
{
   trace("test");
   xPos = _root._xmouse - _parent._x;
   yPos = _root._ymouse - _parent._y;
   pressed = true;
}
function onRelease()
{
   pressed = false;
}
function onEnterFrame()
{
   if(pressed)
   {
      _parent._x = _root._xmouse - xPos;
      _parent._y = _root._ymouse - yPos;
   }
}
var xPos;
var yPos;
var pressed = false;
