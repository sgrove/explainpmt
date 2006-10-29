// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
///Javascript for maintaining scroll
window.onload = function()
  {   var strCook = document.cookie; 
        if(strCook.indexOf("!~")!=0)
        { 
            var intS = strCook.indexOf("!~"); 
            var intE = strCook.indexOf("~!"); 
            var strPos = strCook.substring(intS+2,intE); 
            window.scrollTo(0,strPos); 
        } 
    }
    /// Function to set Scroll position of page before postback. 
    function SetScrollPosition()
    { 
        var scrollYPos;
		if (typeof window.pageYOffset != 'undefined') {
		scrollYPos = window.pageYOffset;
		}
		else if (document.compatMode && document.compatMode != 'BackCompat') {
		scrollYPos = document.documentElement.scrollTop;
		}
		else {
		scrollYPos = document.body.scrollTop;
		}
		if (typeof scrollYPos != 'undefined') {
		document.cookie = "yPos=!~" + scrollYPos + "~!"; 
		}
    }
    /// Attaching   SetScrollPosition() function to window.onscroll event.
    window.onscroll = SetScrollPosition;
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
function getCookie(NameOfCookie)
{ if (document.cookie.length > 0) 
{ begin = document.cookie.indexOf(NameOfCookie+"="); 
if (begin != -1) 
{ begin += NameOfCookie.length+1; 
end = document.cookie.indexOf(";", begin);
if (end == -1) end = document.cookie.length;
return unescape(document.cookie.substring(begin, end)); } 
}
return null; 
}

function setCookie(NameOfCookie, value, expiredays) 
{ var ExpireDate = new Date ();
ExpireDate.setTime(ExpireDate.getTime() + (expiredays * 24 * 3600 * 1000));
document.cookie = NameOfCookie + "=" + escape(value) + 
((expiredays == null) ? "" : "; expires=" + ExpireDate.toGMTString());
}

function delCookie (NameOfCookie) 
{ if (getCookie(NameOfCookie)) {
document.cookie = NameOfCookie + "=" +
"; expires=Thu, 01-Jan-70 00:00:01 GMT";
}

} 
 
function MaintainSort(sortableTable1){
	sort=getCookie('exPlainPMTSort' + sortableTable1.name);
	desc=getCookie('exPlainPMTSortDirection' + sortableTable1.name);
	test = desc == "false" ? false : true

	if (sort!=null){
		sortableTable1.sort(sort, test)
	}
	var rows = sortableTable1.tBody.rows;
	var l = rows.length;
	for (var i = 0; i < l; i++) {
		removeClassName(rows[i], i % 2 ? "odd_row" : "even_row");
		addClassName(rows[i], i % 2 ? "even_row" : "odd_row");
}

}