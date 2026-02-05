function onRelease()
{
   if(pos)
   {
      _parent.nextFrame();
      nextFrame();
   }
   else
   {
      _parent.prevFrame();
      prevFrame();
      AdminMenu.inst.firstEnter = true;
   }
   pos = !pos;
}
stop();
var pos = true;
