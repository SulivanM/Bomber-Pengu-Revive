class Player
{
   var drawn;
   var lost;
   var pName;
   var pSkill;
   var pStatus;
   var total;
   var winP;
   var won;
   function Player(newName, newSkill, newStatus)
   {
      this.pName = newName;
      this.pStatus = newStatus;
      this.pSkill = newSkill;
      this.update();
      this.recalc();
   }
   function update()
   {
      this.won = Number(this.pSkill.split("/")[0]);
      this.lost = Number(this.pSkill.split("/")[1]);
      this.drawn = Number(this.pSkill.split("/")[2]);
      this.recalc();
   }
   function recalc()
   {
      trace("!");
      this.total = this.won + this.lost + this.drawn;
      if(this.total != 0)
      {
         this.winP = Math.round(this.won / this.total * 100);
      }
      else
      {
         this.winP = 0;
      }
   }
}
