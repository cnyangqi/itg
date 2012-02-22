/*
 * Thickbox 2.0 - One Box To Rule Them All.
 * By Cody Lindley (http://www.codylindley.com)
 * Copyright (c) 2006 cody lindley
 * Licensed under the MIT License:
 *   http://www.opensource.org/licenses/mit-license.php
 * Thickbox is built on top of the very light weight jQuery library.
 */
/*
 * 增加的配置属性，可以扩展
 */
var TB_Config = {
	outClickFlag	:false,				//是否允许点击遮罩层
	switchFlag		:true,				//是否显示thickbox的开关，用于在特殊情况强制阻止thickbox
	outIFlag		:true,				//打开方式，true－否通过外部js接口调用方式打开；false－按照自身链接规则打开
	outGroupFlag	:false,				//在显示图片组、媒体组、flash组时，是否使用外部定义的数据标志位
	outGroupAry		:new Array(),		//外部组数据，在具体需要显示组时赋值
	attachEventFlag	:false,				//是否附加结束事件
	attachEvent		:new Function(),	//附加结束事件
	inEventFlag		:false,				//是否附加并列的事件
	inEvent			:new Function(),	//附加并列事件
	retVal			:""					//thickbox的模拟返回值，实际上是中间变量
};
//on page load call TB_init
$(document).ready(TB_init);
//add thickbox to href elements that have a class of .thickbox
function TB_init(){
	$("a.thickbox").click(function(){
	var t = this.title || this.name || "想购网";
	var g = this.rel || false;
	TB_setConfig("outIFlag", false);
	TB_show(t,this.href,g);
	TB_setConfig("outIFlag", true);
	this.blur();
	return false;
	});
}

function TB_show(caption, url, imageGroup, obj) {//function called when the user clicks on a thickbox link
	//修复thickbox不能输入
	var inputfix = "/script/thickbox/inputfix.html?rd="+Math.random();
	if(top.buttomFrame&&top.buttomFrame.hidden_frame)
		top.buttomFrame.hidden_frame.src = inputfix;
	else if(document.hidden_frame)
		hidden_frame.src = inputfix;
	
	if( !TB_getConfig("switchFlag") ){//阻止thickbox
		return;
	}
	caption = decodeURIComponent(caption);
	if( obj )
		var isexist = obj.document.getElementById("TB_window");
	if( isexist && TB_getConfig("outIFlag") ){
		return;
	}	
	try {
		if (document.getElementById("TB_HideSelect") == null) {
			$("body").append("<iframe id='TB_HideSelect'></iframe><div id='TB_overlay'></div><div id='TB_window'></div>");
			if(TB_getConfig("outClickFlag")){
				$("#TB_overlay").click(TB_remove);
			}
		}
		if(caption==null){caption=""};	
		$(window).scroll(TB_position);
		TB_overlaySize();
		$("body").append("<div id='TB_load'></div>");
		TB_load_position();
		var urlString = /\.jpg|\.jpeg|\.png|\.gif|\.html|\.htm|\.php|\.cfm|\.asp|\.aspx|\.jsp|\.jst|\.rb|\.txt|\.bmp|\.swf|\.wma|\.wmv|\.mp3|\.mp4|\.3gp|\.rm|\.rmvb|\.avi|\.mpg|\.asf/g;
		var urlType = url.toLowerCase().match(urlString);
		if(urlType == '.jpg' || urlType == '.jpeg' || urlType == '.png' || urlType == '.gif' || urlType == '.bmp'){//code to show images			
			TB_PrevCaption = "";
			TB_PrevID = "";
			TB_PrevURL = "";
			TB_PrevHTML = "";
			TB_NextCaption = "";
			TB_NextURL = "";
			TB_NextID = "";
			TB_NextHTML = "";
			TB_imageCount = "";
			TB_FoundURL = false;
			if(imageGroup){
				if( !TB_getConfig("outGroupFlag") ){
					TB_TempArray = $("a[@rel="+imageGroup+"]").get();
				}else{
					TB_TempArray = TB_myGroupAry();
				}
				for (TB_Counter = 0; ((TB_Counter < TB_TempArray.length) && (TB_NextHTML == "")); TB_Counter++) {
					var urlTypeTemp = TB_TempArray[TB_Counter].href.toLowerCase().match(urlString);
						if (!(TB_TempArray[TB_Counter].href == url)) {						
							if (TB_FoundURL) {
								TB_NextCaption = TB_TempArray[TB_Counter].title;
								TB_NextURL = TB_TempArray[TB_Counter].href;
								TB_NextHTML = "<span id='TB_next'>&nbsp;&nbsp;下一个&gt;</span>";
								TB_NextID = TB_TempArray[TB_Counter].recordId;
							} else {
								TB_PrevCaption = TB_TempArray[TB_Counter].title;
								TB_PrevURL = TB_TempArray[TB_Counter].href;
								TB_PrevID = TB_TempArray[TB_Counter].recordId;
								TB_PrevHTML = "<span id='TB_prev'>&nbsp;&nbsp;&lt;上一个</span>";
							}
						} else {
							TB_FoundURL = true;
							TB_imageCount = "<span id='TB_imgnum'>【第" + (TB_Counter + 1) +"个&nbsp;&nbsp;共"+ (TB_TempArray.length) + "个】 </span>";											
						}
				}
			}

			imgPreloader = new Image();
			imgPreloader.onload = function(){
				imgPreloader.onload = null;			
				// Resizing large images - orginal by Christian Montoya edited by me.
				var pagesize = TB_getPageSize();
				var x = pagesize[0] - 150;
				var y = pagesize[1] - 150;
				var imageWidth = imgPreloader.width;
				var imageHeight = imgPreloader.height;
				if (imageWidth > x) {
					imageHeight = imageHeight * (x / imageWidth); 
					imageWidth = x; 
					if (imageHeight > y) { 
						imageWidth = imageWidth * (y / imageHeight); 
						imageHeight = y; 
					}
				} else if (imageHeight > y) { 
					imageWidth = imageWidth * (y / imageHeight); 
					imageHeight = y; 
					if (imageWidth > x) { 
						imageHeight = imageHeight * (x / imageWidth); 
						imageWidth = x;
					}
				}
				// End Resizing
				TB_WIDTH = imageWidth + 30;
				TB_HEIGHT = imageHeight + 60;
				//adjust the width & height
				TB_WIDTH = TB_WIDTH < 320 ? 320 : TB_WIDTH;
				$("#TB_window").append("<div id='TB_title' onmousedown=\"startDrag(this)\" onmouseup=\"stopDrag(this)\" onmousemove=\"drag(this)\"><div id='TB_caption'>"+caption+"</div><div id='TB_closeWindow'><a href='#' id='TB_closeWindowButton' title='Close or Escape Button'>&nbsp;</a></div></div><a href='' id='TB_ImageOff' title='Close'><img id='TB_Image' src='"+url+"' width='"+imageWidth+"' height='"+imageHeight+"' alt='"+caption+"'/></a><div id='TB_secondLine'>" + TB_imageCount + TB_PrevHTML + TB_NextHTML +"</div>"); 		
				$("#TB_closeWindowButton").click(TB_remove);
				if (!(TB_PrevHTML == "")) {
					function goPrev(){
						//if($(document).unclick(goPrev)){$(document).unclick(goPrev)};
						TB_setConfig("recordId",TB_PrevID);
						TB_removeonly();
						//$("#TB_window").remove();
						$("body").append("<div id='TB_window'></div>");
						//$(document).unkeyup();
						TB_show(TB_PrevCaption, TB_PrevURL, imageGroup);
						return false;	
					}
					$("#TB_prev").click(goPrev);
					$(document).keyup( function(e){ var key = e.keyCode; if(key == 37){goPrev()} });
				}
				if (!(TB_NextHTML == "")) {		
					function goNext(){
						TB_setConfig("recordId",TB_NextID);
						TB_removeonly();
						//$("#TB_window").remove();
						$("body").append("<div id='TB_window'></div>");
						//$(document).unkeyup();
						TB_show(TB_NextCaption, TB_NextURL, imageGroup);				
						return false;	
					}
					
					$("#TB_next").click(goNext);
				
					$(document).keyup( function(e){ var key = e.keyCode; if(key == 39){goNext()} });
				}
				TB_position();
				$("#TB_load").remove();
				$("#TB_ImageOff").click(TB_remove);
				$("#TB_window").css({display:"block"}); //for safari using css instead of show
			}
	  
			imgPreloader.src = url;
		}
		
		if(urlType=='.htm'||urlType=='.html'||urlType=='.php'||urlType=='.asp'||urlType=='.aspx'||urlType=='.jsp'||urlType=='.jst'||urlType=='.rb'||urlType=='.txt'||urlType=='.cfm' || (url.indexOf('TB_inline') != -1) || (url.indexOf('TB_iframe') != -1) ){//code to show html pages
			
			var queryString = url.replace(/^[^\?]+\??/,'');
			var params = TB_parseQuery( queryString );
			
			TB_WIDTH = (params['width']*1) + 30;
			TB_HEIGHT = (params['height']*1) + 40;
			ajaxContentW = TB_WIDTH - 30;
			ajaxContentH = TB_HEIGHT - 45;
			
			if(url.indexOf('TB_iframe') != -1){				
					urlNoQuery = url.substr(0,TB_strpos(url, "TB_iframe"));	
					$("#TB_window").append("<div id='TB_title' onmousedown=\"startDrag(this)\" onmouseup=\"stopDrag(this)\" onmousemove=\"drag(this)\"><div id='TB_ajaxWindowTitle'>"+caption+"</div><div id='TB_closeAjaxWindow'><a href='#' id='TB_closeWindowButton'>&nbsp;</a></div></div><iframe frameborder=\"0\" src='"+url+"' id='TB_iframeContent' style='width:100%;height:"+(ajaxContentH + 18)+"px;'></iframe>");
				}else{
					$("#TB_window").append("<div id='TB_title' onmousedown=\"startDrag(this)\" onmouseup=\"stopDrag(this)\" onmousemove=\"drag(this)\"><div id='TB_ajaxWindowTitle'>"+caption+"</div><div id='TB_closeAjaxWindow'><a href='#' id='TB_closeWindowButton'>&nbsp;</a></div></div><div id='TB_ajaxContent' style='width:"+ajaxContentW+"px;height:"+ajaxContentH+"px;'></div>");
			}
					
			$("#TB_closeWindowButton").click(TB_remove);
			
			if(url.indexOf('TB_inline') != -1){	
				$("#TB_ajaxContent").html($('#' + params['inlineId']).html());
				TB_position();
				$("#TB_load").remove();
				$("#TB_window").css({display:"block"}); 
			}else if(url.indexOf('TB_iframe') != -1){
				TB_position();
				$("#TB_load").remove();
				$("#TB_window").css({display:"block"}); 
			}else{
				$("#TB_ajaxContent").load(url, function(){
					TB_position();
					$("#TB_load").remove();
					$("#TB_window").css({display:"block"}); 
				});
			}
			
		}
		if(urlType=='.swf' || (url.indexOf('TB_flash') != -1)){//code to show swf 
			var queryString = url.replace(/^[^\?]+\??/,'');
			var params = TB_parseQuery( queryString );
			TB_WIDTH = (params['width']*1);
			TB_HEIGHT = (params['height']*1);
			TB_PATH = params['path'] || "";
			TB_PrevCaption = "";
			TB_PrevURL = "";
			TB_PrevID = "";
			TB_PrevHTML = "";
			TB_NextCaption = "";
			TB_NextURL = "";
			TB_NextID = "";
			TB_NextHTML = "";
			TB_imageCount = "";
			TB_FoundURL = false;
			if(imageGroup){
				if( !TB_getConfig("outGroupFlag") ){
					TB_TempArray = $("a[@rel="+imageGroup+"]").get();
				}else{
					TB_TempArray = TB_myGroupAry();
				}
				for (TB_Counter = 0; ((TB_Counter < TB_TempArray.length) && (TB_NextHTML == "")); TB_Counter++) {
					var urlTypeTemp = TB_TempArray[TB_Counter].href.toLowerCase().match(urlString);
					if (!(TB_TempArray[TB_Counter].href == url)) {						
						if (TB_FoundURL) {
							TB_NextCaption = TB_TempArray[TB_Counter].title;
							TB_NextURL = TB_TempArray[TB_Counter].href;
							TB_NextID = TB_TempArray[TB_Counter].recordId;
							TB_NextHTML = "<span id='TB_next'>&nbsp;&nbsp;下一个&gt;</span>";
						} else {
							TB_PrevCaption = TB_TempArray[TB_Counter].title;
							TB_PrevURL = TB_TempArray[TB_Counter].href;
							TB_PrevID = TB_TempArray[TB_Counter].recordId;
							TB_PrevHTML = "<span id='TB_prev'>&nbsp;&nbsp;&lt;上一个</span>";
						}
					} else {
						TB_FoundURL = true;
						TB_imageCount = "<span id='TB_imgnum'>【第" + (TB_Counter + 1) +"个&nbsp;&nbsp;共"+ (TB_TempArray.length) + "个】 </span>";											
					}
				}
			}		
			imgPreloader = new Image();		
			imgPreloader.onload = function(){
				imgPreloader.onload = null;
				// Resizing large flash - orginal by Christian Montoya edited by me.
				var pagesize = TB_getPageSize();
				var x = pagesize[0] - 150;
				var y = pagesize[1] - 150;
				var imageWidth = TB_WIDTH;
				var imageHeight = TB_HEIGHT;
				if (imageWidth > x) {
					imageHeight = imageHeight * (x / imageWidth); 
					imageWidth = x; 
					if (imageHeight > y) { 
						imageWidth = imageWidth * (y / imageHeight); 
						imageHeight = y; 
					}
				} else if (imageHeight > y) { 
					imageWidth = imageWidth * (y / imageHeight); 
					imageHeight = y; 
					if (imageWidth > x) { 
						imageHeight = imageHeight * (x / imageWidth); 
						imageWidth = x;
					}
				}
				
				// End Resizing
				TB_WIDTH = imageWidth + 30;
				TB_HEIGHT = imageHeight + 60;
				//adjust the width & height
					
				if(url.indexOf('TB_flash') != -1){
					urlNoQuery = url.substr(0,TB_strpos(url, "TB_flash"));	
				}else{
					urlNoQuery = url;
				}
				
				$("#TB_window").append("<div id='TB_title' onmousedown=\"startDrag(this)\" onmouseup=\"stopDrag(this)\" onmousemove=\"drag(this)\"><div id='TB_caption'>"+caption+"</div><div id='TB_closeWindow'><a href='#' id='TB_closeWindowButton' title='Close or Escape Button'>&nbsp;</a></div></div><a href='' id='TB_ImageOff' title='Close'>"+TB_showFlash(TB_WIDTH,TB_HEIGHT,urlNoQuery)+"</a><div id='TB_secondLine'>" + TB_imageCount + TB_PrevHTML + TB_NextHTML +"</div>"); 		
				$("#TB_closeWindowButton").click(TB_remove);
				if (!(TB_PrevHTML == "")) {
					function goPrev(){
						//if($(document).unclick(goPrev)){$(document).unclick(goPrev)};
						TB_setConfig("recordId",TB_PrevID);
						TB_removeonly();
						//$("#TB_window").remove();
						$("body").append("<div id='TB_window'></div>");
						//$(document).unkeyup();
						TB_show(TB_PrevCaption, TB_PrevURL, imageGroup);
						return false;	
					}
					$("#TB_prev").click(goPrev);
					$(document).keyup( function(e){ var key = e.keyCode; if(key == 37){goPrev()} });
				}
				if (!(TB_NextHTML == "")) {		
					function goNext(){
						TB_setConfig("recordId",TB_NextID);
						TB_removeonly();
						//$("#TB_window").remove();
						$("body").append("<div id='TB_window'></div>");
						//$(document).unkeyup();;
						TB_show(TB_NextCaption, TB_NextURL, imageGroup);				
						return false;	
					}
					$("#TB_next").click(goNext);
					$(document).keyup( function(e){ var key = e.keyCode; if(key == 39){goNext()} });
				}
				TB_position();
				$("#TB_load").remove();
				$("#TB_ImageOff").click(TB_remove);
				$("#TB_window").css({display:"block"}); //for safari using css instead of show
			}
			imgPreloader.src = TB_PATH+"../images/thickbox/loading.gif";
			//imgPreloader.src = imgPreloader.src;
		}
		if(urlType=='.wma'||urlType=='.wmv'||urlType=='.mp3'||urlType=='.mp4'||urlType=='.rm'||urlType=='.3gp'||urlType=='.rmvb'||urlType=='.avi'||urlType=='.mpg'||urlType=='.asf'||(url.indexOf('TB_media') != -1)){//code to show media 
			var queryString = url.replace(/^[^\?]+\??/,'');
			var params = TB_parseQuery( queryString );
			TB_WIDTH = (params['width']*1);
			TB_HEIGHT = (params['height']*1);
			TB_PATH = params['path'] || "";
			
			TB_PrevCaption = "";
			TB_PrevURL = "";
			TB_PrevID = "";
			TB_PrevHTML = "";
			TB_NextCaption = "";
			TB_NextURL = "";
			TB_NextID = "";
			TB_NextHTML = "";
			TB_imageCount = "";
			TB_FoundURL = false;
			if(imageGroup){
				if( !TB_getConfig("outGroupFlag") ){
					TB_TempArray = $("a[@rel="+imageGroup+"]").get();
				}else{
					TB_TempArray = TB_myGroupAry();
				}
				for (TB_Counter = 0; ((TB_Counter < TB_TempArray.length) && (TB_NextHTML == "")); TB_Counter++) {
					var urlTypeTemp = TB_TempArray[TB_Counter].href.toLowerCase().match(urlString);
						if (!(TB_TempArray[TB_Counter].href == url)) {						
							if (TB_FoundURL) {
								TB_NextCaption = TB_TempArray[TB_Counter].title;
								TB_NextURL = TB_TempArray[TB_Counter].href;
								TB_NextID = TB_TempArray[TB_Counter].recordId;
								TB_NextHTML = "<span id='TB_next'>&nbsp;&nbsp;下一个&gt;</span>";
							} else {
								TB_PrevCaption = TB_TempArray[TB_Counter].title;
								TB_PrevURL = TB_TempArray[TB_Counter].href;
								TB_PrevID = TB_TempArray[TB_Counter].recordId;
								TB_PrevHTML = "<span id='TB_prev'>&nbsp;&nbsp;&lt;上一个</span>";
							}
						} else {
							TB_FoundURL = true;
							TB_imageCount = "<span id='TB_imgnum'>【第" + (TB_Counter + 1) +"个&nbsp;&nbsp;共"+ (TB_TempArray.length) + "个】 </span>";											
						}
				}
			}
			
			imgPreloader = new Image();
			imgPreloader.onload = function(){
				imgPreloader.onload = null;
				// Resizing large flash - orginal by Christian Montoya edited by me.
				var pagesize = TB_getPageSize();
				var x = pagesize[0] - 150;
				var y = pagesize[1] - 150;
				var imageWidth = TB_WIDTH;
				var imageHeight = TB_HEIGHT;
				if (imageWidth > x) {
					imageHeight = imageHeight * (x / imageWidth); 
					imageWidth = x; 
					if (imageHeight > y) { 
						imageWidth = imageWidth * (y / imageHeight); 
						imageHeight = y; 
					}
				} else if (imageHeight > y) { 
					imageWidth = imageWidth * (y / imageHeight); 
					imageHeight = y; 
					if (imageWidth > x) { 
						imageHeight = imageHeight * (x / imageWidth); 
						imageWidth = x;
					}
				}
				// End Resizing
				TB_WIDTH = imageWidth + 30;
				TB_HEIGHT = imageHeight + 60;
				//adjust the width & height
				if(url.indexOf('TB_media') != -1){
					urlNoQuery = url.substr(0,TB_strpos(url, "TB_media"));	
				}else{
					urlNoQuery = url;
				}
				$("#TB_window").append("<div id='TB_title' onmousedown=\"startDrag(this)\" onmouseup=\"stopDrag(this)\" onmousemove=\"drag(this)\"><div id='TB_caption'>"+caption+"</div><div id='TB_closeWindow'><a href='#' id='TB_closeWindowButton' title='Close or Escape Button'>&nbsp;</a></div></div><a href='' id='TB_ImageOff' title='Close'>"+TB_showMedia(TB_WIDTH,TB_HEIGHT,urlNoQuery)+"</a><div id='TB_secondLine'>" + TB_imageCount + TB_PrevHTML + TB_NextHTML +"</div>"); 		
				$("#TB_closeWindowButton").click(TB_remove);
				if (!(TB_PrevHTML == "")) {
					function goPrev(){
						//if($(document).unclick(goPrev)){$(document).unclick(goPrev)};
						TB_setConfig("recordId",TB_PrevID);
						TB_removeonly();
						//$("#TB_window").remove();
						$("body").append("<div id='TB_window'></div>");
						//$(document).unkeyup();;
						TB_setConfig("outGroupFlag", true)
						//TB_groupFlag = true;
						TB_show(TB_PrevCaption, TB_PrevURL, imageGroup);
						return false;	
					}
					$("#TB_prev").click(goPrev);
					$(document).keyup( function(e){ var key = e.keyCode; if(key == 37){goPrev()} });
				}
				if (!(TB_NextHTML == "")) {		
					function goNext(){
						TB_setConfig("recordId",TB_NextID);
						TB_removeonly();
						//$("#TB_window").remove();
						$("body").append("<div id='TB_window'></div>");
						//$(document).unkeyup();;
						TB_show(TB_NextCaption, TB_NextURL, imageGroup);				
						return false;	
					}
					$("#TB_next").click(goNext);
					$(document).keyup( function(e){ var key = e.keyCode; if(key == 39){goNext()} });
				}
				TB_position();
				$("#TB_load").remove();
				$("#TB_ImageOff").click(TB_remove);
				$("#TB_window").css({display:"block"}); //for safari using css instead of show
			}
			imgPreloader.src = TB_PATH+"../images/thickbox/loading.gif";
			//imgPreloader.src = imgPreloader.src;
		}
		$(window).resize(TB_position);
		//并列事件
		TB_doInEvent();
	} catch(e) {
		alert( e );
	}
}

//helper functions below

function TB_remove() {
	$("#TB_window").fadeOut("fast",function(){
		$(this).find("iframe").remove();
		$('#TB_window,#TB_overlay,#TB_HideSelect,#TB_load,#TB_obj').remove();
	});
	$(document).unbind("keyup");
	TB_setConfig("outGroupFlag",false);
	TB_doEvent();
	return false;
}
function TB_removeonly() {
	var tmp_div = document.getElementById("TB_obj");
	if( tmp_div )
		tmp_div.removeNode(true);
	var tmp_div = document.getElementById("TB_window");
	if( tmp_div )
		tmp_div.removeNode(true);
}

function TB_position() {
	var pagesize = TB_getPageSize();	
	var arrayPageScroll = TB_getPageScrollTop();
	var tp = arrayPageScroll[1] + ((pagesize[1]-TB_HEIGHT)/2);
	if( tp < 0 )
		tp = 5;
	$("#TB_window").css({width:TB_WIDTH+"px",left: ((pagesize[0] - TB_WIDTH)/2)+"px", top: (tp) +"px" });
	TB_overlaySize();
}

function TB_overlaySize(){
	if (window.innerHeight && window.scrollMaxY) {	
		yScroll = window.innerHeight + window.scrollMaxY;
	} else if (document.body.scrollHeight > document.body.offsetHeight){ // all but Explorer Mac
		yScroll = document.body.scrollHeight;
	} else { // Explorer Mac...would also work in Explorer 6 Strict, Mozilla and Safari
		yScroll = document.body.offsetHeight;
  	}
	$("#TB_overlay").css("height",yScroll +"px");
}

function TB_load_position() {
	var pagesize = TB_getPageSize();
	var arrayPageScroll = TB_getPageScrollTop();
	var tp = arrayPageScroll[1] + ((pagesize[1]-100)/2);
	if( tp < 0 )
		tp = 5; 
	$("#TB_load")
	.css({left: ((pagesize[0] - 100)/2)+"px", top: (tp)+"px" })
	.css({display:"block"});
}

function TB_parseQuery ( query ) {
   var Params = new Object ();
   if ( ! query ) return Params; // return empty object
   var Pairs = query.split(/[;&]/);
   for ( var i = 0; i < Pairs.length; i++ ) {
      var KeyVal = Pairs[i].split('=');
      if ( ! KeyVal || KeyVal.length != 2 ) continue;
      var key = unescape( KeyVal[0] );
      var val = unescape( KeyVal[1] );
      val = val.replace(/\+/g, ' ');
      Params[key] = val;
   }
   return Params;
}

function TB_getPageScrollTop(){
	var yScrolltop;
	if (self.pageYOffset) {
		yScrolltop = self.pageYOffset;
	} else if (document.documentElement && document.documentElement.scrollTop){	 // Explorer 6 Strict
		yScrolltop = document.documentElement.scrollTop;
	} else if (document.body) {// all other Explorers
		yScrolltop = document.body.scrollTop;
	}
	arrayPageScroll = new Array('',yScrolltop) 
	return arrayPageScroll;
}

function TB_getPageSize(){
	var de = document.documentElement;
	var w = window.innerWidth || self.innerWidth || (de&&de.clientWidth) || document.body.clientWidth;
	var h = window.innerHeight || self.innerHeight || (de&&de.clientHeight) || document.body.clientHeight;
	
	arrayPageSize = new Array(w,h) 
	return arrayPageSize;
}

function TB_strpos(str, ch) {
	if( ch.length <= 1 ){
		for (var i = 0; i < str.length; i++)
		if (str.substring(i, i+1) == ch) return i;
	}else{
		for (var i = 0; i < str.length; i++){
			if (str.substring(i, i+ch.length) == ch) 
				return i;
		}
	}
	return -1;

}

//以下为增加的接口及辅助函数
//根据属性动态设置值
function TB_setConfig(name, value){
	//alert(name+value);
	TB_Config[name] = value;
}
//根据属性动态获取值
function TB_getConfig(name){
	return TB_Config[name];
}
//做附加事件
function TB_doEvent(){
	if( TB_getConfig("attachEventFlag") ){
		var func = TB_getConfig("attachEvent");
		TB_setConfig("attachEventFlag", false);
		TB_setConfig("inEventFlag", false);
		new func;
		TB_setConfig("retVal", "");
	}
}
//做附加并列事件
function TB_doInEvent(){
	if( TB_getConfig("inEventFlag") ){
		var func = TB_getConfig("inEvent");
		new func;
	}
}

//显示flash
function TB_showFlash(w,h,u){
	var TB_write = "";
	w = w-2;
	TB_write ='<object id="TB_obj" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0" width="'+w+'" height="'+h+'">';
	TB_write +='<param name="movie" value="'+u+'">';
	TB_write +='<param name="quality" value="high">';
	TB_write +='<embed src="'+u+'" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" width="'+w+'" height="'+h+'">';
	TB_write +='</embed></object>';  
	return TB_write;
}
//显示媒体
function TB_showMedia(w,h,u){
	var TB_write = "";
	w = w-2;
	TB_write ='<embed id="TB_obj" src="'+u+'" width="'+w+'" height="'+h+'" align="absmiddle" units="pixels" autostart="true"></embed>'; 
	return TB_write;
}
//获取外部文件组信息
function TB_myGroupAry(){
	var ary = new Array(); 
	var iary = TB_getConfig("outGroupAry");
	for( i = 0; i < iary.length; i++ ){
		ary[i] = new TB_arySet(decodeURIComponent(iary[i][0]),iary[i][1],iary[i][2]);
	}
	return ary;
}
function TB_arySet(h,t,id) { 
	this.href = h; 
	this.title = t; 
	this.recordId = id;
}
