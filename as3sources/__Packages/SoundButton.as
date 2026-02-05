class SoundButton extends MovieClip
{
   var soundOn = true;
   function SoundButton()
   {
      super();
      SoundPlayer.init();
      this.update();
      this.stop();
   }
   function onPress()
   {
      SoundPlayer.onOff();
      this.update();
   }
   function update()
   {
      if(SoundPlayer.soundOn == true)
      {
         this.gotoAndStop(1);
      }
      else
      {
         this.gotoAndStop(2);
      }
   }
}
