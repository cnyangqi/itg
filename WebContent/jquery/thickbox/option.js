/*************************************************
  Description:	某些按钮点击时显示操作提示
  @param:		str		显示提示内容
  @see:			被doSubmit调用
  History：             
				曾光		2007-1-9
*************************************************/
function showTip(str){
	// 创建临时层
	var tmp_div = document.createElement("DIV");
	if( tmp_div ){
		tmp_div.className = "div_tip";
		tmp_div.name = "div_tip";
		tmp_div.id = "div_tip";
		str = ( str ) ? str : "操作正在进行中，请稍候...";

		tmp_div.innerHTML = "<span class=\"tip_til\">系统提示</span>";
		tmp_div.innerHTML += "<span class=\"tip_content\"><span class=\"tip_image\"></span>"+ str+"<br></span>";
		document.body.appendChild(tmp_div);
	}
}
/*************************************************
  Description:	清除操作提示
  @see:			无关联函数
  History：             
				曾光		2007-1-9
*************************************************/
function clearTip(){
	var tmp_div = document.getElementById("div_tip");
	if( tmp_div )
		document.body.removeChild(tmp_div);
}


/*************************************************
  Description:	根据时间生成随机数
  @see:			被shortStr调用
  History：             
				曾光		2007-1-15
*************************************************/
function dateStr(){
	var today = new Date(); 
	var aaa = Math.random() + "";
	return today.getTime() + aaa.split(".")[1];
}

/*************************************************
  Description:	显示浮动操作层,thickbox版本，主接口
  @param:		url		地址
  				width	宽度
  				height	高度
  				title	窗口标题
  				path	显示的路径
  History：             
				曾光		2007-4-27
*************************************************/
function showTBInterface(url,title,path){
	title = title || "JCMS内容管理系统";
	var obj = getTBPath(path);
	var groupflag = getTBConfig("outGroupFlag",path);
	obj.TB_show(title, url, groupflag , obj);
}
/*************************************************
  Description:	显示浮动操作层,thickbox版本
  @param:		url		地址
  				width	宽度
  				height	高度
  				title	窗口标题
  				path	显示的路径
  History：             
				曾光		2007-4-5
*************************************************/
function showTB(url,width,height,title,path){
	str = (url.indexOf("?") >= 0) ? "&" : "?";
	showTBInterface(url+str+"TB_iframe=true&height="+height+"&width="+width,title,path);
}
/*************************************************
  Description:	显示浮动图片层,thickbox版本
  @param:		url		地址
  				title	窗口标题
  				path	显示的路径
  History：             
				曾光		2007-4-7
*************************************************/
function showTBPic(url,title,path){
	showTBInterface(url,title,path);
}
/*************************************************
  Description:	显示浮动操作层,thickbox版本
  @param:		url		地址
  				width	宽度
  				height	高度
  				title	窗口标题
  				path	显示的路径
  History：             
				曾光		2007-4-5
*************************************************/
function showTBSwf(url,width,height,title,path){
	str = (url.indexOf("?") >= 0) ? "&" : "?";
	showTBInterface(url+str+"TB_flash=true&height="+height+"&width="+width,title,path);
}
/*************************************************
  Description:	显示浮动操作层,thickbox版本
  @param:		url		地址
  				width	宽度
  				height	高度
  				title	窗口标题
  				path	显示的路径
  History：             
				曾光		2007-4-5
*************************************************/
function showTBMedia(url,width,height,title,path){
	str = (url.indexOf("?") >= 0) ? "&" : "?";
	showTBInterface(url+str+"TB_media=true&height="+height+"&width="+width,title,path);
}
/*************************************************
  Description:	显示浮动分页组,,thickbox版本
  @param:		url		地址
  				width	宽度
  				height	高度
  				title	窗口标题
  				path	显示的路径
  History：             
				曾光		2007-4-5
*************************************************/
function showTBGroup(title,url,ary,path){
	//打开组开关
	setTBConfig("outGroupFlag",true,path);
	//设置自定义组数据
	setTBConfig("outGroupAry",ary,path);
	//显示接口
	showTBInterface(url,title,path);
}
/*************************************************
  Description:	清除浮动操作层,thickbox版本	
  @param:		path	显示的路径
  				retval	返回值
  History：             
				曾光		2007-4-5
*************************************************/
function removeTB(path){
	if( getTBConfig("attachEventFlag",path) ){
		doTBAttachEvent(path);
	}
	var obj = getTBPath(path);
	obj.TB_remove();
}
/*************************************************
  Description:	返回属性值	
  @param:		path	显示的路径
  History：             
				曾光		2007-4-5
*************************************************/
function getTBConfig(name, path){
	var obj = getTBPath(path);
	return obj.TB_getConfig(name);
}
/*************************************************
  Description:	设置属性值	
  @param:		path	显示的路径
  				retval	返回值
  History：             
				曾光		2007-4-5
*************************************************/
function setTBConfig( name, value, path ){
	//当有附加事件时，自动打开附加事件开关
	if( name == "attachEvent" && value )
		setTBConfig("attachEventFlag", true, path);
	//当有并列事件时，自动打开并列事件开关
	if( name == "inEvent" && value )
		setTBConfig("inEventFlag", true, path);
	var obj = getTBPath(path);
	obj.TB_setConfig(name,value);
}
/*************************************************
  Description:	做事件	
  @param:		path	显示的路径
  				retval	返回值
  History：             
				曾光		2007-4-5
*************************************************/
function doTBAttachEvent(path){
	var obj = getTBPath(path);
	obj.TB_doEvent();
}
/*************************************************
  Description:	获取显示thickbox的默认框架对象	
  @param:		path	显示的路径
  				retval	返回值
  History：             
				曾光		2007-4-5
*************************************************/
function getTBPath(path){
	alert(path);
	path = path || "top";
	var obj = eval(path);
	if( !obj ){
		alert("对话框框架对象为空，请刷新或者关闭浏览器重新登录。");
		return false;
	}
	return obj;
}
/*************************************************
  Description:	鼠标拖动效果部分代码start
  History：             
				曾光		2007-4-4
*************************************************/
//可以打包为js文件;
var drag_x0=0,drag_y0=0,drag_x1=0,drag_y1=0;
var moveable=false;
//开始拖动;
function startDrag(obj){
	//锁定标题栏;
	obj.setCapture();
	//定义对象;
	var win = obj.parentNode;
	//记录鼠标和层位置;
	drag_x0 = event.clientX;
	drag_y0 = event.clientY;
	drag_x1 = parseInt(win.style.left);
	drag_y1 = parseInt(win.style.top);
	moveable = true;
}
//拖动;
function drag(obj){
	var win = obj.parentNode;
	if(moveable){
		win.style.left = drag_x1 + event.clientX - drag_x0;
		win.style.top = drag_y1 + event.clientY - drag_y0;
	}
}
//停止拖动;
function stopDrag(obj){
	//放开标题栏;
	var win = obj.parentNode;
	var t = win.style.top;
	t = parseInt(t.substring(0,t.length - 2));
	if( t < 0 ){
		win.style.top = 5;
	}
	if( top ){
		var h = parseInt(top.document.body.offsetHeight);
	}else{
		var h = parseInt(top.document.body.offsetHeight);
	}
	if( t >= h ){
		win.style.top = 5;
	}
	obj.releaseCapture();
	moveable = false;
}
/*************************************************
  Description:	鼠标拖动效果部分代码end
*************************************************/
// 弹出日历的框架
// format 默认完全格式　1=yyyy-mm-dd 2=yyyy-mm-dd HH:ii 
function popUpCalendarDlg(ctrlobj,format,path,defaulttime){
	if (!path)
		path = "..";
	showx = event.screenX - event.offsetX;
	showy = event.screenY - event.offsetY; 
	retval = window.showModalDialog(path+"/script/calendar.htm?format="+format+"&defaulttime="+defaulttime, "", "dialogWidth:380px;dialogHeight:280px;dialogLeft:"+showx+"px; dialogTop:"+showy+"px; status:no;directories:yes;scrollbars:no;Resizable=no;");
	if( retval != null ){
		ctrlobj.value = retval;
	}
}
// 弹出颜色的框架
function callColorDlg(formo,o){		
	var sInitColor = null;
	if (sInitColor == null) 
		var sColor = formo.colorHelper.ChooseColorDlg();
	else
		var sColor = formo.colorHelper.ChooseColorDlg(sInitColor);
	sColor = sColor.toString(16);	
	if (sColor.length < 6)
	{
		var sTempString = "FFFFFF".substring(0,6-sColor.length);
		sColor = sTempString.concat(sColor);
	}
	o.value = "#"+sColor;
}
//根据格式显示预览图片
function getFileType(s,path){
	var str = s.toLowerCase();
	var newstr = "no";
	switch( str ){
		case "avi":
		case "doc":
		case "ppt":
		case "swf":
		case "xls":
		case "mp3":
		case "txt":
		case "psd":
		case "mpp":
		case "mdb":
		case "pdf":
		case "wav":
		case "wmv":
		case "wma":
		case "jpg":
		case "bmp":
		case "png":
		case "gif":
			newstr = str;
			break;
		case "rar":
		case "zip":
			newstr = "rar";
			break;
		case "rmvb":
		case "rm":
			newstr = "rm";
			break;
		case "wm":
		case "asf":
		case "mid":
			newstr = "wm";
			break;
		case "mp4":
		case "3gp":
			newstr = "mp4";
			break;
		case "htm":
		case "html":
			newstr = "htm";
			break;
		case "mpg":
		case "mpeg":
			newstr = "mpg";
			break;
		default:
			newstr = "no";
	}
	return "<img src='"+path+"/images/filetype/"+newstr+".gif' align='absmiddle'>";
}
//图片切换
function switchImg(target,idsArray){
	if (idsArray==null)
		return;
	for (i = 0; i < idsArray.length; i++){
		var id = idsArray[i][0];
		var flag = idsArray[i][1];
		var src = document.getElementById(target+id).src;
		if (flag==0){
			document.getElementById(target+id).src = src.substring(0,src.lastIndexOf("/"))+"/no"+target+".gif";
		}
		else{
			document.getElementById(target+id).src = src;
		}
	}
}
