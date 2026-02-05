class PlayerRoom extends MovieClip
{
   var amPlayers;
   var playerAction;
   var playerDrawn;
   var playerList;
   var playerLost;
   var playerTotal;
   var playerWinP;
   var playerWon;
   var selPlayer;
   var firstEnter = true;
   var active = false;
   function PlayerRoom()
   {
      super();
      Connector.gameStarted = false;
      Connector.oppName = "0";
      this.playerList = _root.playerRoom.playerList;
      this.playerList.backgroundColor = 16777215;
      this.playerList.borderColor = 16777215;
      this.playerList.rollOverColor = 10027008;
      this.playerList.selectionColor = 16777215;
      this.playerList.textSelectedColor = 0;
      this.playerList.textRollOverColor = 16777215;
      this.playerList.fontFamily = "arial";
      this.playerList.fontSize = 12;
      this.playerList.fontWeight = "bold";
      this.playerList.fontStyle = "italic";
      this.playerList.color = 0;
      this.active = true;
      trace("PR-Constructor: " + Connector.players);
   }
   function init()
   {
      this.playerList.addEventListener("change",this);
      this.playerList.addEventListener("itemRollOver",this);
      this.initPlayerList();
      this.sortPlayerList();
   }
   function onEnterFrame()
   {
      if(this.firstEnter)
      {
         this.init();
         this.firstEnter = false;
      }
   }
   function change()
   {
      switch(this.playerList.selectedItem.data.pStatus)
      {
         case "0":
            Connector.updatePlayer2(this.playerList.selectedItem.data.pName,"2");
            Connector.sendChallenge(this.playerList.selectedItem.data.pName);
            if(_root.array_search(this.playerList.selectedItem.data.pName,deAdmins) == true)
            {
               this.playerList.setPropertiesAt(this.playerList.selectedIndex,{icon:"Challenged_MOD"});
            }
            else
            {
               this.playerList.setPropertiesAt(this.playerList.selectedIndex,{icon:"Challenged"});
            }
            break;
         case "1":
            Connector.updatePlayer2(this.playerList.selectedItem.data.pName,"3");
            Connector.sendStartGame(this.playerList.selectedItem.data.pName);
            if(_root.array_search(this.playerList.selectedItem.data.pName,deAdmins) == true)
            {
               this.playerList.setPropertiesAt(this.playerList.selectedIndex,{icon:"Playing_MOD"});
            }
            else
            {
               this.playerList.setPropertiesAt(this.playerList.selectedIndex,{icon:"Playing"});
            }
            break;
         case "2":
            Connector.updatePlayer2(this.playerList.selectedItem.data.pName,"0");
            Connector.sendRemChallenge(this.playerList.selectedItem.data.pName);
            if(_root.array_search(this.playerList.selectedItem.data.pName,deAdmins) == true)
            {
               this.playerList.setPropertiesAt(this.playerList.selectedIndex,{icon:"Available_MOD"});
            }
            else
            {
               this.playerList.setPropertiesAt(this.playerList.selectedIndex,{icon:"Available"});
            }
            break;
         case "3":
            Connector.updatePlayer2(this.playerList.selectedItem.data.pName,"23");
            Connector.sendChallenge(this.playerList.selectedItem.data.pName);
            if(_root.array_search(this.playerList.selectedItem.data.pName,deAdmins) == true)
            {
               this.playerList.setPropertiesAt(this.playerList.selectedIndex,{icon:"ChallengedPlaying_MOD"});
            }
            else
            {
               this.playerList.setPropertiesAt(this.playerList.selectedIndex,{icon:"ChallengedPlaying"});
            }
            break;
         case "23":
            Connector.updatePlayer2(this.playerList.selectedItem.data.pName,"3");
            Connector.sendRemChallenge(this.playerList.selectedItem.data.pName);
            if(_root.array_search(this.playerList.selectedItem.data.pName,deAdmins) == true)
            {
               this.playerList.setPropertiesAt(this.playerList.selectedIndex,{icon:"Playing_MOD"});
            }
            else
            {
               this.playerList.setPropertiesAt(this.playerList.selectedIndex,{icon:"Playing"});
            }
         case "13":
         case "5":
         default:
            return;
      }
   }
   function itemRollOver(eventObject)
   {
      var _loc2_ = this.playerList.getItemAt(eventObject.index).data;
      if(this.playerList.getItemAt(eventObject.index) != undefined)
      {
         this.selPlayer.text = _loc2_.pName;
         AdminMenu.inst.setSelectedPlayerName(_loc2_.pName);
         this.playerTotal.text = _loc2_.total;
         this.playerWon.text = _loc2_.won;
         this.playerLost.text = _loc2_.lost;
         this.playerDrawn.text = _loc2_.drawn;
         this.playerWinP.text = _loc2_.winP;
         switch(_loc2_.pStatus)
         {
            case "0":
               this.playerAction.text = "Deze speler uitdagen";
               break;
            case "1":
               this.playerAction.text = "Uitdaging aannemen";
               break;
            case "2":
               this.playerAction.text = "Uitdaging terugtrekken";
               break;
            case "3":
               this.playerAction.text = "Deze speler uitdagen";
               break;
            case "13":
               this.playerAction.text = "Er is geen actie mogelijk";
               break;
            case "23":
               this.playerAction.text = "Uitdaging terugtrekken";
               break;
            case "5":
               this.playerAction.text = "Dat ben jij...";
            default:
               return;
         }
      }
   }
   function addPlayer(newPlayer)
   {
      trace("PlayerRoom: addPlayer");
      this.playerList.addItem({label:newPlayer.pName,data:newPlayer});
      switch(newPlayer.pStatus)
      {
         case "0":
            if(_root.array_search(newPlayer.pName,deAdmins) == true)
            {
               this.playerList.setPropertiesAt(this.playerList.length - 1,{icon:"Available_MOD"});
               break;
            }
            this.playerList.setPropertiesAt(this.playerList.length - 1,{icon:"Available"});
            break;
         case "1":
            if(_root.array_search(newPlayer.pName,deAdmins) == true)
            {
               this.playerList.setPropertiesAt(this.playerList.length - 1,{icon:"Request_MOD"});
               break;
            }
            this.playerList.setPropertiesAt(this.playerList.length - 1,{icon:"Request"});
            break;
         case "2":
            if(_root.array_search(newPlayer.pName,deAdmins) == true)
            {
               this.playerList.setPropertiesAt(this.playerList.length - 1,{icon:"Challenged_MOD"});
               break;
            }
            this.playerList.setPropertiesAt(this.playerList.length - 1,{icon:"Challenged"});
            break;
         case "3":
            if(_root.array_search(newPlayer.pName,deAdmins) == true)
            {
               this.playerList.setPropertiesAt(this.playerList.length - 1,{icon:"Playing_MOD"});
               break;
            }
            this.playerList.setPropertiesAt(this.playerList.length - 1,{icon:"Playing"});
            break;
         case "13":
            if(_root.array_search(newPlayer.pName,deAdmins) == true)
            {
               this.playerList.setPropertiesAt(this.playerList.length - 1,{icon:"RequestPlaying_MOD"});
               break;
            }
            this.playerList.setPropertiesAt(this.playerList.length - 1,{icon:"RequestPlaying"});
            break;
         case "23":
            if(_root.array_search(newPlayer.pName,deAdmins) == true)
            {
               this.playerList.setPropertiesAt(this.playerList.length - 1,{icon:"ChallengedPlaying_MOD"});
               break;
            }
            this.playerList.setPropertiesAt(this.playerList.length - 1,{icon:"ChallengedPlaying"});
            break;
         case "5":
            if(_root.array_search(newPlayer.pName,deAdmins) == true)
            {
               this.playerList.setPropertiesAt(this.playerList.length - 1,{icon:"Myself_MOD"});
               break;
            }
            this.playerList.setPropertiesAt(this.playerList.length - 1,{icon:"Myself"});
      }
      this.amPlayers.text = this.playerList.length;
   }
   function updatePlayer(player)
   {
      trace("PlayerRoom: updatePlayer");
      var _loc3_ = 0;
      for(; _loc3_ < this.playerList.length; _loc3_ = _loc3_ + 1)
      {
         if(this.playerList.getItemAt(_loc3_).label != player.pName)
         {
            continue;
         }
         switch(player.pStatus)
         {
            case "0":
               if(_root.array_search(player.pName,deAdmins) == true)
               {
                  this.playerList.setPropertiesAt(_loc3_,{icon:"Available_MOD"});
                  return;
               }
               this.playerList.setPropertiesAt(_loc3_,{icon:"Available"});
               return;
            case "1":
               if(_root.array_search(player.pName,deAdmins) == true)
               {
                  this.playerList.setPropertiesAt(_loc3_,{icon:"Request_MOD"});
                  return;
               }
               this.playerList.setPropertiesAt(_loc3_,{icon:"Request"});
               return;
            case "2":
               if(_root.array_search(player.pName,deAdmins) == true)
               {
                  this.playerList.setPropertiesAt(_loc3_,{icon:"Challenged_MOD"});
                  return;
               }
               this.playerList.setPropertiesAt(_loc3_,{icon:"Challenged"});
               return;
            case "3":
               if(_root.array_search(player.pName,deAdmins) == true)
               {
                  this.playerList.setPropertiesAt(_loc3_,{icon:"Playing_MOD"});
                  return;
               }
               this.playerList.setPropertiesAt(_loc3_,{icon:"Playing"});
               return;
            case "13":
               if(_root.array_search(player.pName,deAdmins) == true)
               {
                  this.playerList.setPropertiesAt(_loc3_,{icon:"RequestPlaying_MOD"});
                  return;
               }
               this.playerList.setPropertiesAt(_loc3_,{icon:"RequestPlaying"});
               return;
            case "23":
               if(_root.array_search(player.pName,deAdmins) == true)
               {
                  this.playerList.setPropertiesAt(_loc3_,{icon:"ChallengedPlaying_MOD"});
                  return;
               }
               this.playerList.setPropertiesAt(_loc3_,{icon:"ChallengedPlaying"});
               return;
            case "5":
               if(_root.array_search(player.pName,deAdmins) == true)
               {
                  this.playerList.setPropertiesAt(_loc3_,{icon:"Myself_MOD"});
                  return;
               }
               this.playerList.setPropertiesAt(_loc3_,{icon:"Myself"});
               return;
            default:
               return;
         }
      }
   }
   function removePlayer(leftPlayer)
   {
      var _loc3_ = 0;
      trace("PlayerRoom: removePlayer");
      var _loc2_ = 0;
      while(_loc2_ < this.playerList.length)
      {
         if(this.playerList.getItemAt(_loc2_).label == leftPlayer)
         {
            _loc3_ = _loc2_;
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
      this.playerList.removeItemAt(_loc3_);
      this.amPlayers.text = this.playerList.length;
   }
   function initPlayerList()
   {
      this.playerList.removeAll();
      var _loc2_ = 0;
      while(_loc2_ < Connector.players.length)
      {
         trace("initPlayerList: " + Connector.players[_loc2_]);
         this.addPlayer(Connector.players[_loc2_]);
         _loc2_ = _loc2_ + 1;
      }
   }
   function sortPlayerList()
   {
      this.playerList.sortItems(this.sortFunc);
   }
   function sortFunc(player1, player2)
   {
      if(player1.label.substr(0,4) == "Gast" && player2.label.substr(0,4) == "Gast")
      {
         return player1.label > player2.label;
      }
      if(player1.label.substr(0,4) != "Gast" && player2.label.substr(0,4) == "Gast")
      {
         return -1;
      }
      if(player1.label.substr(0,4) == "Gast" && player2.label.substr(0,4) != "Gast")
      {
         return 1;
      }
      if(player1.label.substr(0,4) != "Gast" && player2.label.substr(0,4) != "Gast")
      {
         return player1.label.toUpperCase() > player2.label.toUpperCase();
      }
   }
}
