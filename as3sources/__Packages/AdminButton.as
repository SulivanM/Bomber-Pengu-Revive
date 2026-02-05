class AdminButton extends MovieClip
{
   var command;
   var text;
   function AdminButton()
   {
      super();
      this.stop();
   }
   function setValues(la, com)
   {
      this.text.text = la;
      this.command = com;
   }
   function onRelease()
   {
      var _loc3_ = this.command.split("$user");
      var _loc4_ = _loc3_.join(AdminMenu.selectedPlayerName);
      _root.chatBox.chatInput.text = _loc4_;
   }
   function onRollOver()
   {
      this.gotoAndStop(2);
   }
   function onRollOut()
   {
      this.gotoAndStop(1);
   }
}
