class StartButton extends MovieClip
{
   function StartButton()
   {
      super();
      _root.stop();
   }
   function onPress()
   {
      _root.gotoAndStop(5);
   }
}
