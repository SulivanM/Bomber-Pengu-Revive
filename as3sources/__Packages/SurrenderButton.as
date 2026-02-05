class SurrenderButton extends MovieClip
{
   function SurrenderButton()
   {
      super();
      _root.stop();
   }
   function onPress()
   {
      _root.surrenderAck._visible = true;
   }
}
