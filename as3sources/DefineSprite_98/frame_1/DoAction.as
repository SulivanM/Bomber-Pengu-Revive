var startTimer = getTimer();
onEnterFrame = function()
{
   if(getTimer() > startTimer + 3000)
   {
      _root.nextFrame();
   }
};
