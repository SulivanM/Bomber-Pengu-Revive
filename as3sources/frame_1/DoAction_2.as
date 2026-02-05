function array_search(needle, haystack)
{
   if(needle != undefined)
   {
      i = 0;
      while(i < haystack.length)
      {
         if(haystack[i] == needle)
         {
            return true;
         }
         i++;
      }
      return false;
   }
}
loader_txt = String(Math.round(_root.getBytesLoaded() / _root.getBytesTotal() * 100)) + " % geladen";
preloader.maske._yscale = String(Math.round(_root.getBytesLoaded() / _root.getBytesTotal() * 100));
var deAdmins = [];
adminData = new LoadVars();
adminData.load("http://bomberman.speeleiland.nl/admins.txt");
adminData.onLoad = function()
{
   if(adminData.len != undefined)
   {
      if(adminData.len < 200)
      {
         i = 1;
         while(i <= adminData.len)
         {
            deAdmins[i] = eval("adminData.naam" + i);
            trace(deAdmins[i]);
            i++;
         }
      }
   }
};
