var switch_tab = function(obj) {
    if($(obj).hasClassName('current')) return false;
    if(!$(obj).hasAttribute('tabid')) return false;
    var tabid = $(obj).readAttribute("tabid");
    var titlebar = $(obj).up(0);
    titlebar.childElements().each(function(o) {
    	if(o.hasAttribute('tabid')) {
         o.removeClassName('current');
      }
    });
    $(obj).addClassName('current');
    titlebar.nextSiblings().each(function(o) {
        if(o.hasClassName('tabs_tab')) {
            o.removeClassName('current');
            if(o.readAttribute("tabid")==tabid) {
                o.removeClassName('normal');
                o.addClassName('current');
            } else {
                o.removeClassName('current');
                o.addClassName('normal');
            }
        }
    });
    return false;
}