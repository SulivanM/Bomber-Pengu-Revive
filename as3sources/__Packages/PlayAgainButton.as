class PlayAgainButton extends MovieClip
{
   function PlayAgainButton()
   {
      super();
   }
   function onPress()
   {
      if(Connector.playAgainReq)
      {
         Connector.sendStartGame(Connector.oppName);
      }
      else
      {
         Connector.sendGameMsg("<playAgain/>\n");
         _root.afterMatch.oppStatus.gotoAndStop(4);
      }
   }
}
