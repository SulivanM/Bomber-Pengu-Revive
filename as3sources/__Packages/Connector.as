class Connector extends MovieClip
{
   static var matchResult;
   static var myName;
   static var players;
   static var xmlSocket;
   static var versionNr = "1.1.0.speil";
   static var server = "192.168.1.2";
   static var port = "6897";
   static var connected = false;
   static var disConTxt = "";
   static var challengedAll = false;
   static var oppName = "0";
   static var myTurn = false;
   static var gameStarted = false;
   static var playAgainReq = false;
   static var startPlayer = false;
   static var lastMsg = 0;
   static var msgInt = 15000;
   function Connector()
   {
      super();
      Connector.doConnect();
   }
   static function doConnect()
   {
      trace("Connector.doConnect()");
      var _loc2_ = new ContextMenu();
      _loc2_.hideBuiltInItems();
      _loc2_.builtInItems.quality = true;
      _root.menu = _loc2_;
      if(_root.user == undefined)
      {
         Connector.myName = "Gast" + Math.round(Math.random() * 100000);
      }
      else
      {
         Connector.myName = _root.user;
      }
      if(_root.surl != undefined)
      {
         Connector.server = _root.surl;
      }
      if(_root.sport != undefined)
      {
         Connector.port = _root.sport;
      }
      Connector.players = new Array();
      Connector.xmlSocket = new XMLSocket();
      Connector.xmlSocket.connect(Connector.server,Connector.port);
      Connector.xmlSocket.onConnect = Connector.onSockConnect;
      Connector.xmlSocket.onClose = Connector.onSockClose;
      Connector.xmlSocket.onXML = Connector.onSockXML;
   }
   function onEnterFrame()
   {
      if(getTimer() > Connector.lastMsg + Connector.msgInt)
      {
         Connector.xmlSocket.send("<beat/>\n");
         Connector.lastMsg = getTimer();
      }
   }
   static function addPlayer(pName, pSkill, pStatus)
   {
      if(pName == Connector.myName)
      {
         pStatus = "5";
      }
      var _loc2_ = new Player(pName,pSkill,pStatus);
      Connector.players.push(_loc2_);
      if(_root.playerRoom.active)
      {
         _root.playerRoom.addPlayer(_loc2_);
      }
   }
   static function updatePlayer(pName, pSkill, pStatus)
   {
      var _loc2_ = 0;
      while(_loc2_ < Connector.players.length)
      {
         if(Connector.players[_loc2_].pName == pName)
         {
            if(Connector.challengedAll)
            {
               switch(Connector.players[_loc2_].pStatus)
               {
                  case "0":
                     Connector.players[_loc2_].pStatus = "2";
                     break;
                  case "3":
                     Connector.players[_loc2_].pStatus = "23";
               }
            }
            if(pStatus == "0")
            {
               switch(Connector.players[_loc2_].pStatus)
               {
                  case "23":
                     Connector.players[_loc2_].pStatus = "2";
                     break;
                  case "13":
                     Connector.players[_loc2_].pStatus = "1";
                     break;
                  case "1":
                     Connector.players[_loc2_].pStatus = "1";
                     break;
                  case "2":
                     Connector.players[_loc2_].pStatus = "2";
                     break;
                  default:
                     Connector.players[_loc2_].pStatus = pStatus;
               }
            }
            else if(pStatus == "3")
            {
               switch(Connector.players[_loc2_].pStatus)
               {
                  case "1":
                     Connector.players[_loc2_].pStatus = "13";
                     break;
                  case "2":
                     Connector.players[_loc2_].pStatus = "23";
                     break;
                  case "13":
                     Connector.players[_loc2_].pStatus = "13";
                     break;
                  case "23":
                     Connector.players[_loc2_].pStatus = "23";
                     break;
                  default:
                     Connector.players[_loc2_].pStatus = pStatus;
               }
            }
            else
            {
               Connector.players[_loc2_].pStatus = pStatus;
            }
            Connector.players[_loc2_].pSkill = pSkill;
            Connector.players[_loc2_].update();
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
      if(_root.playerRoom.active)
      {
         _root.playerRoom.updatePlayer(Connector.players[_loc2_]);
      }
   }
   static function updatePlayer2(pName, pStatus)
   {
      var _loc2_ = 0;
      while(_loc2_ < Connector.players.length)
      {
         if(Connector.players[_loc2_].pName == pName)
         {
            Connector.players[_loc2_].pStatus = pStatus;
            if(_root.playerRoom.active)
            {
               _root.playerRoom.updatePlayer(Connector.players[_loc2_]);
            }
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   static function removePlayer(pName)
   {
      var _loc3_;
      _loc3_ = new Array();
      var _loc2_ = 0;
      while(_loc2_ < Connector.players.length)
      {
         if(Connector.players[_loc2_].pName != pName)
         {
            _loc3_.push(Connector.players[_loc2_]);
         }
         _loc2_ = _loc2_ + 1;
      }
      Connector.players = _loc3_;
      if(_root.playerRoom.active)
      {
         _root.playerRoom.removePlayer(pName);
      }
   }
   static function getPlayerStatus(pName)
   {
      var _loc1_ = 0;
      while(_loc1_ < Connector.players.length)
      {
         if(Connector.players[_loc1_].pName == pName)
         {
            return Connector.players[_loc1_].pStatus;
         }
         _loc1_ = _loc1_ + 1;
      }
      return "-1";
   }
   static function getPlayerId(pName)
   {
      var _loc1_ = 0;
      while(_loc1_ < Connector.players.length)
      {
         if(Connector.players[_loc1_].pName == pName)
         {
            return _loc1_;
         }
         _loc1_ = _loc1_ + 1;
      }
      return -1;
   }
   static function onSockClose()
   {
      trace("onSockClose()");
      Connector.connected = false;
      _root.gotoAndStop("ConnLost");
   }
   static function onSockXML(input)
   {
      var _loc2_ = input.lastChild;
      var _loc9_ = _loc2_.nodeName;
      var _loc27_;
      var _loc26_;
      var _loc5_;
      var _loc19_;
      var _loc28_;
      var _loc14_;
      var _loc21_;
      var _loc20_;
      var _loc15_;
      var _loc17_;
      var _loc16_;
      var _loc13_;
      var _loc3_;
      var _loc29_;
      var _loc4_;
      var _loc10_;
      var _loc8_;
      var _loc11_;
      var _loc30_;
      var _loc7_;
      var _loc12_;
      var _loc22_;
      var _loc23_;
      var _loc18_;
      var _loc25_;
      var _loc24_;
      var _loc6_;
      switch(_loc9_)
      {
         case "12":
            _loc27_ = _loc2_.attributes.x;
            _loc26_ = _loc2_.attributes.y;
            _loc5_ = _loc2_.attributes.c;
            Game.remotePlayer.remoteCommand(_loc5_,_loc27_,_loc26_);
            return;
         case "14":
            _loc19_ = Number(_loc2_.attributes.p);
            _loc28_ = Number(_loc2_.attributes.f);
            Game.setPingRemotePlayer(_loc19_,_loc28_);
            return;
         case "16":
            _loc14_ = Number(_loc2_.attributes.s);
            Game.receiveRandomSeed(_loc14_);
            return;
         case "17":
            _loc21_ = Number(_loc2_.attributes.xp);
            _loc20_ = Number(_loc2_.attributes.yp);
            Game.grid.setBomb(_loc21_,_loc20_,Game.remotePlayer);
            _loc27_ = _loc2_.attributes.x;
            _loc26_ = _loc2_.attributes.y;
            _loc5_ = _loc2_.attributes.c;
            Game.remotePlayer.remoteCommand(_loc5_,_loc27_,_loc26_);
            SoundPlayer.playV("Donk.wav",80);
            return;
         case "18":
            _loc21_ = Number(_loc2_.attributes.xp);
            _loc20_ = Number(_loc2_.attributes.yp);
            _loc14_ = Number(_loc2_.attributes.s);
            _loc15_ = Number(_loc2_.attributes.b);
            Game.remotePlayer.removePowerUp(_loc21_,_loc20_,_loc14_,_loc15_);
            _loc27_ = _loc2_.attributes.x;
            _loc26_ = _loc2_.attributes.y;
            _loc5_ = _loc2_.attributes.c;
            Game.remotePlayer.remoteCommand(_loc5_,_loc27_,_loc26_);
            return;
         case "19":
            _loc21_ = Number(_loc2_.attributes.xp);
            _loc20_ = Number(_loc2_.attributes.yp);
            _loc17_ = Number(_loc2_.attributes.dx);
            _loc16_ = Number(_loc2_.attributes.dy);
            _loc13_ = Number(_loc2_.attributes.t);
            _loc3_ = Number(_loc2_.attributes.i);
            Game.grid.remoteKickBomb(_loc21_,_loc20_,_loc17_,_loc16_,_loc13_,_loc3_);
            _loc27_ = _loc2_.attributes.x;
            _loc26_ = _loc2_.attributes.y;
            _loc5_ = _loc2_.attributes.c;
            Game.remotePlayer.remoteCommand(_loc5_,_loc27_,_loc26_);
            return;
         case "11":
            _loc21_ = Number(_loc2_.attributes.xp);
            _loc20_ = Number(_loc2_.attributes.yp);
            _loc29_ = Number(_loc2_.attributes.i);
            _loc13_ = Number(_loc2_.attributes.t);
            BombManager.remoteStopBomb(_loc21_,_loc20_,_loc29_,_loc13_);
            _loc27_ = _loc2_.attributes.x;
            _loc26_ = _loc2_.attributes.y;
            _loc5_ = _loc2_.attributes.c;
            Game.remotePlayer.remoteCommand(_loc5_,_loc27_,_loc26_);
            return;
         case "10":
            _loc21_ = Number(_loc2_.attributes.xp);
            _loc20_ = Number(_loc2_.attributes.yp);
            _loc29_ = Number(_loc2_.attributes.i);
            BombManager.remoteExplode(_loc21_,_loc20_,_loc29_);
            _loc27_ = _loc2_.attributes.x;
            _loc26_ = _loc2_.attributes.y;
            _loc5_ = _loc2_.attributes.c;
            Game.remotePlayer.remoteCommand(_loc5_,_loc27_,_loc26_);
            return;
         case "die":
            _loc27_ = Number(_loc2_.attributes.x);
            _loc26_ = Number(_loc2_.attributes.y);
            Game.remotePlayerDie(_loc27_,_loc26_);
            return;
         case "draw":
            Game.drawn = true;
            Game.thisPlayer.die();
            Game.remotePlayer.die();
            return;
         case "pong":
            Game.pingReturn();
            return;
         case "errorMsg":
            trace("case: errorMsg");
            Connector.disConTxt = _loc2_.lastChild.nodeValue;
            _root.gotoAndStop("ConnLost");
            return;
         case "userList":
            trace("case: userList");
            _loc4_ = _loc2_.childNodes;
            _loc3_ = 0;
            while(_loc3_ < _loc4_.length)
            {
               _loc10_ = _loc4_[_loc3_].attributes.name;
               _loc8_ = _loc4_[_loc3_].attributes.skill;
               _loc11_ = _loc4_[_loc3_].attributes.state;
               Connector.addPlayer(_loc10_,_loc8_,_loc11_);
               trace(_loc10_);
               trace(_loc8_);
               trace(_loc11_);
               _loc3_ = _loc3_ + 1;
            }
            _root.playerRoom.sortPlayerList();
            return;
         case "playerUpdate":
            trace("case: playerUpdate");
            _loc10_ = _loc2_.attributes.name;
            _loc8_ = _loc2_.attributes.skill;
            _loc11_ = _loc2_.attributes.state;
            trace(_loc10_);
            trace(_loc8_);
            trace(_loc11_);
            Connector.updatePlayer(_loc10_,_loc8_,_loc11_);
            return;
         case "newPlayer":
            trace("case: newPlayer");
            _loc10_ = _loc2_.attributes.name;
            _loc8_ = _loc2_.attributes.skill;
            _loc11_ = _loc2_.attributes.state;
            if(Connector.challengedAll)
            {
               Connector.addPlayer(_loc10_,_loc8_,"2");
            }
            else
            {
               Connector.addPlayer(_loc10_,_loc8_,_loc11_);
            }
            _root.playerRoom.sortPlayerList();
            trace(_loc10_);
            trace(_loc8_);
            trace(_loc11_);
            return;
         case "playerLeft":
            trace("case: playerLeft");
            _loc10_ = _loc2_.attributes.name;
            trace(_loc10_);
            Connector.removePlayer(_loc10_);
            if(Connector.gameStarted && _loc10_ == Connector.oppName)
            {
               trace("lost opponent");
               _root.game.win();
               return;
            }
            return;
            break;
         case "request":
            trace("case: request");
            _loc10_ = _loc2_.attributes.name;
            Connector.updatePlayer2(_loc10_,"1");
            if(!Connector.gameStarted)
            {
               SoundPlayer.play("Request.wav");
            }
            trace(_loc10_);
            return;
         case "remRequest":
            trace("case: remRequest");
            _loc10_ = _loc2_.attributes.name;
            _loc30_ = Connector.getPlayerId(_loc10_);
            switch(Connector.getPlayerStatus(_loc10_))
            {
               case "0":
               case "1":
                  Connector.updatePlayer2(_loc10_,"0");
                  break;
               case "3":
               case "13":
                  Connector.updatePlayer2(_loc10_,"3");
                  break;
               default:
                  Connector.updatePlayer2(_loc10_,"0");
            }
            trace(_loc10_);
            return;
         case "startGame":
            trace("case: startGame");
            Game.playerNr = 2;
            _loc10_ = _loc2_.attributes.name;
            trace(_loc10_);
            Connector.oppName = _loc10_;
            Connector.updatePlayer2(Connector.oppName,"3");
            if(Connector.challengedAll)
            {
               Connector.sendRemChallengeAll();
               _loc3_ = 0;
               while(_loc3_ < Connector.players.length)
               {
                  if(Connector.players[_loc3_].pStatus == "2")
                  {
                     Connector.updatePlayer2(Connector.players[_loc3_].pName,"0");
                  }
                  else if(Connector.players[_loc3_].pStatus == "23")
                  {
                     Connector.updatePlayer2(Connector.players[_loc3_].pName,"3");
                  }
                  _loc3_ = _loc3_ + 1;
               }
            }
            if(!Connector.gameStarted)
            {
               _root.chatBox.clearChatList();
            }
            Connector.myTurn = false;
            Connector.gameStarted = true;
            Connector.playAgainReq = false;
            Connector.challengedAll = false;
            Connector.startPlayer = false;
            _root.gotoAndStop("gameFrame");
            return;
         case "endGame":
            trace("case: endGame");
            _loc7_ = _loc2_.attributes.winner;
            trace("winner: " + _loc7_);
            return;
         case "timeout":
            trace("case: timeout");
            _loc7_ = _loc2_.attributes.winner;
            trace("winner: " + _loc7_);
            _root.game.doGameOver(_loc7_);
            return;
         case "surrender":
            trace("case: surrender");
            _loc7_ = _loc2_.attributes.winner;
            trace("winner: " + _loc7_ + "; " + Connector.oppName + " surrendered");
            if(_loc7_ == Connector.myName)
            {
               _root.game.win();
               return;
            }
            if(_loc7_ == Connector.oppName)
            {
               _root.game.loose();
               return;
            }
            _root.game.drawn();
            return;
            break;
         case "turn":
            trace("case: turn");
            return;
         case "playAgain":
            trace("case: playAgain");
            Connector.playAgainReq = true;
            return;
         case "msgPlayer":
            trace("case: msgPlayer");
            _loc12_ = _loc2_.attributes.name;
            _loc22_ = _loc2_.attributes.msg;
            if(Connector.gameStarted)
            {
               _root.chatBox.addMsg(_loc12_,_loc22_);
               return;
            }
            return;
            break;
         case "msgAll":
            trace("case: msgAll");
            _loc12_ = _loc2_.attributes.name;
            _loc22_ = _loc2_.attributes.msg;
            if(!Connector.gameStarted)
            {
               _root.chatBox.addMsg(_loc12_,_loc22_);
               return;
            }
            return;
            break;
         case "clrChat":
            trace("case: clrChat");
            if(!Connector.gameStarted)
            {
               _root.chatBox.clearChatList();
               return;
            }
            return;
            break;
         case "warning":
            trace("case: warning");
            _loc12_ = _loc2_.attributes.name;
            _loc22_ = _loc2_.attributes.msg;
            _root.warningScreen.doWarn(_loc12_,_loc22_);
            return;
         case "config":
            trace("case: config");
            _loc23_ = _loc2_.attributes.badWordsUrl;
            _loc18_ = _loc2_.attributes.replacementChar;
            _loc25_ = _loc2_.attributes.deleteLine;
            _loc24_ = Number(_loc2_.attributes.floodLimit);
            CensorManager.setConfig(_loc23_,_loc18_,_loc25_,_loc24_);
            return;
         case "adminButtons":
            trace("case: adminButtons");
            _loc4_ = _loc2_.childNodes;
            _loc3_ = 0;
            while(_loc3_ < _loc4_.length)
            {
               _loc6_ = String(_loc4_[_loc3_].attributes.l);
               _loc5_ = String(_loc4_[_loc3_].attributes.c);
               AdminMenu.addButton(_loc6_,_loc5_);
               _loc3_ = _loc3_ + 1;
            }
            AdminMenu.ready = true;
            return;
         default:
            trace("error unknown command: " + _loc9_);
            return;
      }
   }
   static function onSockConnect(success)
   {
      trace("onSockConnect()");
      if(success)
      {
         trace("sockConnect success");
         Connector.connected = true;
         Connector.xmlSocket.send("<auth name=\"" + Connector.myName + "\" version=\"" + Connector.versionNr + "\" hash=\"" + _root.hash + "\"/>\n");
         Connector.lastMsg = getTimer();
      }
      else
      {
         trace("sockConnect failed");
         Connector.connected = false;
         _root.gotoAndStop("ConnLost");
      }
   }
   static function sendChallenge(targetPlayer)
   {
      trace("send challenge to " + targetPlayer);
      Connector.xmlSocket.send("<challenge name=\"" + targetPlayer + "\" hash=\"xxxxxx\"/>\n");
      Connector.lastMsg = getTimer();
   }
   static function sendRemChallenge(targetPlayer)
   {
      trace("send remChallenge to " + targetPlayer);
      Connector.xmlSocket.send("<remChallenge name=\"" + targetPlayer + "\" hash=\"xxxxxx\"/>\n");
      Connector.lastMsg = getTimer();
   }
   static function sendStartGame(targetPlayer)
   {
      trace("send startGame to " + targetPlayer);
      Connector.oppName = targetPlayer;
      Connector.updatePlayer2(Connector.oppName,"3");
      if(!Connector.gameStarted)
      {
         _root.chatBox.clearChatList();
      }
      Connector.myTurn = true;
      Connector.gameStarted = true;
      Connector.playAgainReq = false;
      Connector.challengedAll = false;
      Connector.startPlayer = true;
      Game.playerNr = 1;
      Connector.xmlSocket.send("<startGame name=\"" + targetPlayer + "\" hash=\"xxxxxx\"/>\n");
      Connector.lastMsg = getTimer();
      _root.gotoAndStop("gameFrame");
   }
   static function sendGameMsg(command)
   {
      Connector.xmlSocket.send(command);
      Connector.lastMsg = getTimer();
   }
   static function sendChallengeAll()
   {
      trace("send challengeAll");
      Connector.xmlSocket.send("<challengeAll/>\n");
      Connector.lastMsg = getTimer();
   }
   static function sendRemChallengeAll()
   {
      trace("send RemChallengeAll");
      Connector.xmlSocket.send("<remChallengeAll/>\n");
      Connector.lastMsg = getTimer();
   }
   static function sendChatMsg(msg)
   {
      var _loc2_ = false;
      msg = Util.cleanMsg(msg);
      msg = CensorManager.removeMails(msg);
      msg = CensorManager.removeAddresses(msg);
      if(CensorManager.checkBadWords(msg))
      {
         if(CensorManager.deleteLine)
         {
            _loc2_ = true;
         }
         else
         {
            msg = CensorManager.censorMsg(msg);
         }
      }
      if(!_loc2_ && !CensorManager.checkFlooding(msg))
      {
         if(Connector.gameStarted)
         {
            trace("send msgPlayer");
            Connector.xmlSocket.send("<msgPlayer name=\"" + Connector.myName + "\" msg=\"" + msg + "\"/>\n");
            Connector.lastMsg = getTimer();
         }
         else
         {
            trace("send msgAll");
            Connector.xmlSocket.send("<msgAll name=\"" + Connector.myName + "\" msg=\"" + msg + "\"/>\n");
            Connector.lastMsg = getTimer();
         }
      }
   }
}
