/*
Simple Image Trail script- By JavaScriptKit.com
Visit http://www.javascriptkit.com for this script and more
This notice must stay intact
*/

var offsetfrommouse=[15,25]; //image x,y offsets from cursor position in pixels. Enter 0,0 for no offset
var displayduration=0; //duration in seconds image should remain visible. 0 for always.

var defaultimageheight = 220;	// maximum image size.
var defaultimagewidth = 220;	// maximum image size.

var timer;

function gettrailobj(){
if (document.getElementById)
return document.getElementById("preview_div").style
}

function gettrailobjnostyle(){
if (document.getElementById)
return document.getElementById("preview_div")
}


function truebody(){
return (!window.opera && document.compatMode && document.compatMode!="BackCompat")? document.documentElement : document.body
}


function hidetrail(){	
	gettrailobj().display= "none";
	document.onmousemove="";
	gettrailobj().left="-500px";
	clearTimeout(timer);
}

function showtrail(imagename,title,width,height){
	i = imagename;
	t = title;
	w = width;
	h = height;
	timer = setTimeout("show('"+i+"',t,w,h);",200);
}
function show(imagename,title,width,height){
    var docwidth=document.all? truebody().scrollLeft+truebody().clientWidth : pageXOffset+window.innerWidth - offsetfrommouse[0]
	var docheight=document.all? Math.min(truebody().scrollHeight, truebody().clientHeight) : Math.min(window.innerHeight)
	if( (navigator.userAgent.indexOf("Konqueror")==-1  || navigator.userAgent.indexOf("Firefox")!=-1 || (navigator.userAgent.indexOf("Opera")==-1 && navigator.appVersion.indexOf("MSIE")!=-1)) && (docwidth>650 && docheight>500)) {
		( width == 0 ) ? width = defaultimagewidth: '';
		( height == 0 ) ? height = defaultimageheight: '';
			
		width+=55
		height+=55
		defaultimageheight = height
		defaultimagewidth = width
	
		document.onmousemove=followmouse; 

		
		newHTML = '<div class="border_preview" style="width:'+  width +'px;height:'+ height +'px"><div id="loader_container"><div id="loader"><div id="loader_bg"><div id="progress"> </div></div></div></div>';
		//newHTML = newHTML + '<h2 class="title_h2">' + ' '+title + '</h2>'
		
        newHTML = newHTML + '<div class="preview_temp_load"><img onload="javascript:remove_loading();" src="' + imagename + '" border="0"></div>';
		newHTML = newHTML + '</div>'; 
		
		if(navigator.userAgent.indexOf("MSIE")!=-1 && navigator.userAgent.indexOf("Opera")==-1 ){
			newHTML = newHTML+'<iframe src="about:blank" scrolling="no" frameborder="0" width="'+width+'" height="'+height+'"></iframe>';
		}		

		gettrailobjnostyle().innerHTML = newHTML;
		gettrailobj().display="block";
    }
}

function followmouse(e){

	var xcoord=offsetfrommouse[0]
	var ycoord=offsetfrommouse[1]

	var docwidth=document.all? truebody().scrollLeft+truebody().clientWidth : pageXOffset+window.innerWidth-15
	var docheight=document.all? Math.min(truebody().scrollHeight, truebody().clientHeight) : Math.min(window.innerHeight)

	if (typeof e != "undefined"){
		if (docwidth - e.pageX < defaultimagewidth + 2*offsetfrommouse[0]){
			xcoord = e.pageX - xcoord - defaultimagewidth; // Move to the left side of the cursor
		} else {
			xcoord += e.pageX;
		}
		if (docheight - e.pageY < defaultimageheight + 2*offsetfrommouse[1]){
			ycoord += e.pageY - Math.max(0,(2*offsetfrommouse[1] + defaultimageheight + e.pageY - docheight - truebody().scrollTop));
		} else {
			ycoord += e.pageY;
		}

	} else if (typeof window.event != "undefined"){
		if (docwidth - event.clientX < defaultimagewidth + 2*offsetfrommouse[0]){
			xcoord = event.clientX + truebody().scrollLeft - xcoord - defaultimagewidth; // Move to the left side of the cursor
		} else {
			xcoord += truebody().scrollLeft+event.clientX
		}
		if (docheight - event.clientY < (defaultimageheight + 2*offsetfrommouse[1])){
			ycoord += event.clientY + truebody().scrollTop - Math.max(0,(2*offsetfrommouse[1] + defaultimageheight + event.clientY - docheight));
		} else {
			ycoord += truebody().scrollTop + event.clientY;
		}
	}
	gettrailobj().left=xcoord+"px"
	gettrailobj().top=ycoord+"px"

}



var t_id = setInterval(animate,20);
var pos=0;
var dir=2;
var len=0;

function animate()
{
var elem = document.getElementById('progress');
if(elem != null) {
if (pos==0) len += dir;
if (len>32 || pos>79) pos += dir;
if (pos>79) len -= dir;
if (pos>79 && len==0) pos=0;
elem.style.left = pos;
elem.style.width = len;
}
}

function remove_loading() {
this.clearInterval(t_id);
var targelem = document.getElementById('loader_container');
targelem.style.display='none';
targelem.style.visibility='hidden';
var t_id = setInterval(animate,60);
}
