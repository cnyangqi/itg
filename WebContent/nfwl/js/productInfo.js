var rows = 1;
function addSubProduct(subprd_id,subprd_name,subprd_num,subprd_unit){
	
	if(subprd_id == null)subprd_id = "";
	if(subprd_name == null)subprd_name = "";
	if(subprd_num == null)subprd_num = "";
	if(subprd_unit == null)subprd_unit = "";
	
	//alert("add product");
	var tab_subproduct = document.getElementById('tab_subproduct');
	//var cell = 
	
	var newRow=tab_subproduct.insertRow(-1); 
	rows += tab_subproduct.rows.length; 
	
	var cellProd=newRow.insertCell(); 
  cellProd.align='center'; 
  cellProd.innerHTML ='<input type="hidden"  name="subprd_id" id="subprd_id'+rows+'" value="'+subprd_id+'"  /> ';
	cellProd.innerHTML +='<input type="text" readonly name="subprd_name" id="subprd_name'+rows+'"  value="'+subprd_name+'" onclick="selectProduct(\'subprd_id'+rows+'\',\'subprd_name'+rows+'\',\'subprd_unit'+rows+'\')"  />';

  var cellnum=newRow.insertCell(); 
  cellnum.align='center'; 
  cellnum.innerHTML='<input type="text"  name="subprd_num" id="subprd_num'+rows+'" value="'+subprd_num+'"  /> ';
  
  var cellunit=newRow.insertCell(); 
  cellunit.align='center'; 
  cellunit.innerHTML='<input type="text"  readonly name="subprd_unit" id="subprd_unit'+rows+'" value="'+subprd_unit+'"  /> ';
  
  
  var celldele=newRow.insertCell(); 
  celldele.align='center'; 
  celldele.innerHTML='<input type="button" value="删除" onclick="deleteProduct()" />';
  
	tab_subproduct.focus(); 
}

function selectProduct(prdid,prdname,prdunit){
	//alert(prdname);
	//debugger;
	  page='/nfwl/productarticle/selectproduct.jsp?prdid='+prdid+'&prdname='+prdname+'&prdunit='+prdunit;
    bWin = window.open(page,'browseWin','resizable=yes,scrollbars=yes,status=yes,width=500,height=500,screenX=300,screenY=400');
    bWin.focus();

}
function setSubProduct(prdid,prdidvalue,prdname,prdnamevalue,prdunit,prdunitvalue){
 // alert(prdname);
  //alert(prdnamevalue);
	//debugger;
  var oprdid = document.getElementById(prdid);
  if(oprdid) oprdid.value = prdidvalue;

  var oprdname = document.getElementById(prdname);
  if(oprdname) oprdname.value = prdnamevalue;

  var oprdunit = document.getElementById(prdunit);
  if(oprdunit) oprdunit.value = prdunitvalue;

	
}


function deleteProduct(){
	//删除当前行
 var currRowIndex=event.srcElement.parentNode.parentNode.rowIndex; 
 var tab_subproduct = document.getElementById('tab_subproduct');
tab_subproduct.deleteRow(currRowIndex);//table10--表格id 
}


function selectType(topname){

    if (topname == '' || topname.split('#').length < 2) {
        return;
    }
    var top_code = topname.split('#')[1];
    //alert(top_code.substring(0,2));
    if (top_code == '1') {
        document.getElementById('div_prd_info').style.display = 'block';
        document.getElementById('isBusiness').value = '1';
        
    }
    else {
        document.getElementById('div_prd_info').style.display = 'none';
        document.getElementById('isBusiness').value = '0';
    }
    
}



function FCKeditor_OnComplete(editorInstance){
    document.getElementById("pbar").style.display = 'block';
}

function endsWith(str, suffix){
    return str.indexOf(suffix, str.length - suffix.length) !== -1;
}

function FCKeditor_addImage(src, title){
    var oFckeditor = FCKeditorAPI.GetInstance('DataFCKeditor');
    var html = "";
    if (endsWith(src, ".jpg") || endsWith(src, ".gif") || endsWith(src, ".bmp") || endsWith(src, ".png") || endsWith(src, ".jpeg") || endsWith(src, ".tif")) {
        html = '<img src="' + src + '" alt="' + title + '"><br /><span>' + title + '</span>';
    }
    else {
        html = '<a href="' + src + '" target=_blank>' + title + '</a>';
    }
    oFckeditor.InsertHtml(html);
}

function popupDialog(url){
    var isMSIE = (navigator.appName == "Microsoft Internet Explorer");
    
    if (isMSIE) {
        return window.showModalDialog(url);
    }
    else {
        var win = window.open(url, "mcePopup", "dialog=yes,modal=yes");
        win.focus();
    }
}

function selectTopics(){
    var rc = popupDialog("selecttopics.jsp?isBusiness=1");
    if (rc == null || rc.length == 0) 
        return false;
    
    f_settopic(rc[0], rc[1], rc[2], rc[3]);
}


function f_settopic(siteid, sitename, topid, topname){
    // alert(topname);
    //debugger;
    document.inputFrm.site_id.value = siteid;
    document.inputFrm.topic.value = topname.split('#')[0] + "(" + sitename + ")";
    document.inputFrm.top_id.value = topid;
    selectType(topname);
    
    
    if ('礼包产品' == topname) {
        f_showLBCP();
    }
    else {
        f_hideLBCP();
    }
    //var template =  document.inputFrm.template;
    //while(template.hasChildNodes()) template.removeChild(template.lastChild);

    //template.options.add(new Option("<%=bundle.getString("TEMPLATE_HINT")%>",""));
    //xmlGet('./ajaxtopictemplates.jsp?control=template&site=' + siteid + "&top=" + topid + "&callback=template_callback");
}

function f_showLBCP(){
    var divlbcp = document.getElementById("div_lbcp");
    divlbcp.style.display = "block";
}

function f_hideLBCP(){
    var divlbcp = document.getElementById("div_lbcp");
    divlbcp.style.display = "none";
}

function template_callback(objName, id, text){
    var ctrl = document.getElementById(objName);
    if (ctrl) 
        ctrl.options.add(new Option(text, id));
}

function addTopics(){
    var rc = popupDialog("selectmycompanytopics.jsp");
    if (rc == null || rc.length == 0) 
        return false;
    
    f_addslavetopic(rc[0], rc[1], rc[2], rc[3]);
}

var slavetopics = 0;
function f_addslavetopic(siteid, sitename, topid, topname){
    var tr_st = document.getElementById("tr_st");
    var intRowIndex = tr_st.cells.length;
    var tdnew = tr_st.insertCell(intRowIndex);
    
    for (var i = 0; i < slavetopics; i++) {
        var ele_topic = document.getElementById("slave_topic_" + i);
        if (ele_topic) {
            if (topid == ele_topic.value) {
                return false;
            }
        }
    }
    
    tdnew.innerHTML = "<input type=hidden name='slave_site_" + slavetopics + "' value='" + siteid + "'>" +
    "<input type=hidden name='slave_topic_" +
    slavetopics +
    "' value='" +
    topid +
    "'>" +
    "<input type=checkbox name='slave_idx' value='" +
    slavetopics +
    "'>" +
    topname +
    "(" +
    sitename +
    ")";
    
    slavetopics = slavetopics + 1;
}

function fill_check(){

    if (document.inputFrm.top_id.value == "") {
        alert("请选择商品类别");
        document.inputFrm.topic.focus();
        return false;
    }
    
    if (!CheckIsNull('document.inputFrm', 'title')) {
        alert("请输入名称");
        return false;
    }
    
    if (!CheckIsEnCode('document.inputFrm', 'prd_code')) {
        alert("编号请输入数字或字母");
        return false;
    }
    if (!CheckIsNum('document.inputFrm', 'prd_localprice')) {
        alert("请正确输入想购价");
        return false;
    }
    
    if (!CheckIsNum('document.inputFrm', 'prd_marketprice')) {
        alert("请正确输入市场价");
        return false;
    }
    if (!CheckIsNum('document.inputFrm', 'prd_shipfee')) {
        alert("请正确输入运费");
        return false;
    }
    if (!CheckIsNum('document.inputFrm', 'prd_point')) {
        alert("请正确输入积分");
        return false;
    }
    var oEditor = FCKeditorAPI.GetInstance('DataFCKeditor');
    
    
    document.inputFrm.content.value = oEditor.GetXHTML(true);
    return true;
}

function delatt(attid){
    var elements_new = document.getElementsByName("new_" + attid);
    if (elements_new && elements_new.length > 0) {
        var span = document.getElementById("row_" + attid);
        if (span != null) 
            span.parentNode.removeChild(span);
    }
    else {
        if (!fill_check()) 
            return;
        document.inputFrm.del_att_id.value = attid;
        document.inputFrm.act.value = 0;
        document.inputFrm.action = 'productsave.jsp';
        document.inputFrm.target = "_self";
        document.inputFrm.submit();
    }
}

function saveArticle(){
    if (!fill_check()) 
        return;
    document.inputFrm.act.value = 0;
    document.inputFrm.action = 'productsave.jsp';
    document.inputFrm.target = "_self";
    document.inputFrm.submit();
}

function submitArticle(){
    if (!fill_check()) 
        return;
    document.inputFrm.act.value = 1;
    document.inputFrm.action = 'productsave.jsp';
    document.inputFrm.target = "_self";
    document.inputFrm.submit();
}

function previewArticle(){
    document.inputFrm.action = 'productpreview.jsp';
    document.inputFrm.target = "_blank";
    document.inputFrm.submit();
}

function checkArticle(){
    if (!fill_check()) 
        return;
    document.inputFrm.act.value = 2;
    document.inputFrm.action = 'productsave.jsp';
    document.inputFrm.target = "_self";
    document.inputFrm.submit();
}

function publishArticle(){
    if (!fill_check()) 
        return;
    document.inputFrm.act.value = 3;
    document.inputFrm.action = 'productsave.jsp';
    document.inputFrm.target = "_self";
    document.inputFrm.submit();
}

function timedPublish(){
    if (!fill_check()) 
        return;
    document.getElementById("div_time").style.display = "block";
}

function submitTimedPublish(){
    if (!fill_check()) 
        return;
    if (document.inputFrm.job_year.value.trim() == "") {
        alert("请填写4位数年份");
        document.inputFrm.job_year.focus();
        return;
    }
    if (document.inputFrm.job_month.value.trim() == "") {
        alert("请填写月份(1-12)");
        document.inputFrm.job_month.focus();
        return;
    }
    if (document.inputFrm.job_day.value.trim() == "") {
        alert("请填写日期(1-31)");
        document.inputFrm.job_day.focus();
        return;
    }
    if (document.inputFrm.job_hour.value.trim() == "") {
        alert("请填写小时(0-23)");
        document.inputFrm.job_hour.focus();
        return;
    }
    if (document.inputFrm.job_minute.value.trim() == "") {
        alert("请填写分钟(0-59)");
        document.inputFrm.job_minute.focus();
        return;
    }
    if (document.inputFrm.job_second.value.trim() == "") {
        alert("请填写秒(0-59)");
        document.inputFrm.job_second.focus();
        return;
    }
    document.inputFrm.act.value = 7;
    document.inputFrm.action = 'productsave.jsp';
    document.inputFrm.target = "_self";
    document.inputFrm.submit();
}

function cancelTimedPublish(){
    document.getElementById("div_time").style.display = "none";
}

function deleteArticle(){
    var r = confirm('确实要删除该文章吗?');
    if (r == 1) {
        document.inputFrm.act.value = 4;
        document.inputFrm.action = 'productsave.jsp';
        document.inputFrm.target = "_self";
        document.inputFrm.submit();
    }
}

function republishArticle(){
    if (!fill_check()) 
        return;
    document.inputFrm.act.value = 5;
    document.inputFrm.action = 'productsave.jsp';
    document.inputFrm.target = "_self";
    document.inputFrm.submit();
}

function cancelArticle(){
    document.inputFrm.act.value = 6;
    document.inputFrm.action = 'productsave.jsp';
    document.inputFrm.target = "_self";
    document.inputFrm.submit();
}

function downArticle(){
    document.inputFrm.act.value = 9;
    document.inputFrm.action = 'productsave.jsp';
    document.inputFrm.target = "_self";
    document.inputFrm.submit();
}

function upArticle(){
    document.inputFrm.act.value = 3;
    document.inputFrm.action = 'productsave.jsp';
    document.inputFrm.target = "_self";
    document.inputFrm.submit();
}

function uploadimage(){
    var siteid = document.inputFrm.site_id.value;
    if (siteid == "") {
        alert("请选择模版");
        document.inputFrm.topic.focus();
        return false;
    }
    
    document.resFrm.siteid.value = siteid;
    document.resFrm.multiple.value = "0";
    document.resFrm.func.value = "SetImage";
    document.resFrm.action = "uploadresource.jsp";
    document.resFrm.submit();
}

function attachimage(){
    var siteid = document.inputFrm.site_id.value;
    if (siteid == "") {
        alert("请选择模版");
        document.inputFrm.topic.focus();
        return false;
    }
    
    document.resFrm.siteid.value = siteid;
    document.resFrm.multiple.value = "0";
    document.resFrm.type.value = "0";
    document.resFrm.func.value = "SetImage";
    document.resFrm.action = "selectresource.jsp";
    document.resFrm.submit();
}

function SetImage(res_id, res_name, res_url){
    if (endsWith(res_url, ".jpg") || endsWith(res_url, ".gif") || endsWith(res_url, ".bmp") || endsWith(res_url, ".png") || endsWith(res_url, ".jpeg") || endsWith(res_url, ".tif")) {
        document.inputFrm.pic_url.value = res_url;
    }
    else {
        alert('请选择图片');
    }
}

function attachlist(){
    var siteid = document.inputFrm.site_id.value;
    if (siteid == "") {
        alert("请选择模版");
        document.inputFrm.topic.focus();
        return false;
    }
    
    document.resFrm.siteid.value = siteid;
    document.resFrm.multiple.value = "1";
    document.resFrm.func.value = "AddResource";
    document.resFrm.action = "selectresource.jsp";
    document.resFrm.submit();
}

function uploadfiles(){
    var siteid = document.inputFrm.site_id.value;
    if (siteid == "") {
        alert("请填写4位数年份");
        document.inputFrm.topic.focus();
        return false;
    }
    
    document.resFrm.siteid.value = siteid;
    document.resFrm.multiple.value = "1";
    document.resFrm.func.value = "AddResource";
    document.resFrm.action = "uploadresource.jsp";
    document.resFrm.submit();
}

var max_index_att = 0;
function AddResource(res_id, res_name, res_url){
    max_index_att++;
    var table_fj = document.getElementById("table_fj");
    var span = document.createElement("SPAN");
    span.setAttribute("id", "row_" + res_id);
    span.setAttribute("style", "padding: 5px 10px;");
    span.innerHTML = '&nbsp;<input type="text" name="att_idx_' + res_id + '" value="' + max_index_att + '"  style="width:20px;text-align:center;">' +
    '<input type="hidden" name="att_id" value="' +
    res_id +
    '">' +
    '<input type="hidden" name="new_' +
    res_id +
    '" value="">' +
    '&nbsp;<a href="/resource/viewattach.jsp?id=' +
    res_id +
    '" target="_blank">' +
    res_name +
    '</a>' +
    '<a href=\'javascript:FCKeditor_addImage("' +
    res_url +
    '","' +
    res_name +
    '")\' title="插入图片到正文"><img src="/images/arrow_down.gif" border="0"></a>' +
    '<a href="javascript:delatt(' +
    res_id +
    ')" title="删除附件"><img src="/images/delete.gif" border="0"></a>';
    
    table_fj.appendChild(span);
}

