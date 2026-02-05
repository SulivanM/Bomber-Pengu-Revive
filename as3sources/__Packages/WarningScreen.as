class WarningScreen extends MovieClip
{
   var modMsg;
   var modName;
   var startTime = 0;
   var showUpTime = 8000;
   function WarningScreen()
   {
      super();
      this._visible = false;
      this.stop();
   }
   function doWarn(mod, msg)
   {
      this.modName.text = "Moderator " + mod + " zegt:";
      this.modMsg.text = msg;
      this.startTime = getTimer();
      this._visible = true;
   }
   function onEnterFrame()
   {
      if(this._visible)
      {
         if(getTimer() > this.startTime + this.showUpTime)
         {
            this._visible = false;
         }
      }
   }
}
