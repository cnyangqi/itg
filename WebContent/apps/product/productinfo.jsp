<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="com.fredck.FCKeditor.FCKeditor" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.extra.trade.Product" %>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.core.Attach" %>
<%@ page import="nps.extra.trade.ProductLanguage" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.List" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.util.Locale" %>
<%@ page import="nps.extra.trade.ProductAttach" %>
<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.app_productinfo",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);

    String id=request.getParameter("id");//如果为null，将在保存时使用序列生成ID号
    if(id!=null) id=id.trim();

    String site_id = "xxzx";
    if(site_id!=null) site_id = site_id.trim();

    String creator = user.GetName()+"("+user.GetDeptName()+ "/" +user.GetUnitName()+")";
    String create_date = nps.util.Utils.FormateDate(new java.util.Date(),"yyyy-MM-dd HH:mm:ss");

    boolean  bNew=(id==null || id.length()==0);

    Product product = null;
    NpsWrapper wrapper = null;
    Site site = null;
    TopicTree tree = null;
    Topic top = null;
    Topic old_top = null;


    if(!bNew)  //需要从数据库中加载信息
    {
        try
        {
            wrapper = new NpsWrapper(user,"xxzx");
            
            site = wrapper.GetSite();
            if(site==null) throw new NpsException(ErrorHelper.SYS_NOSITE);
            tree = site.GetTopicTree();
            if(tree==null) throw new NpsException(ErrorHelper.SYS_NOTOPICTREE);
            top = tree.GetTopic("28");
            if(top==null) throw new NpsException(ErrorHelper.SYS_NOTOPIC);

            product = Product.GetProduct(wrapper.GetContext(),id,top);
            if(product==null) throw new NpsException(ErrorHelper.SYS_NOARTICLE);
        }
        catch(Exception e)
        {
            product = null;
            if(wrapper!=null) wrapper.Clear();

            java.io.CharArrayWriter cw = new java.io.CharArrayWriter();
            java.io.PrintWriter pw = new java.io.PrintWriter(cw,true);
            e.printStackTrace(pw);
            out.println(cw.toString());

            return;
        }
    }  //if(!bNew)
%>

<html>
<head>
    <title><%=bNew?bundle.getString("PRODUCT_HTMLTITLE"):product.GetName()%></title>
    <script type="text/javascript" src="/jscript/global.js"></script>
    <script type="text/javascript" src="/FCKeditor/fckeditor.js"></script>
    <script type="text/javascript" src="/dhtmlxtabbar/dhtmlxcommon.js"></script>
    <script type="text/javascript" src="/dhtmlxtabbar/dhtmlxtabbar.js"></script>
    <script type="text/javascript" src="/dhtmlxtabbar/dhtmlxtabbar_start.js"></script>

    <link rel="STYLESHEET" type="text/css" href="/dhtmlxtabbar/dhtmlxtabbar.css">
    <LINK href="/css/style.css" rel = stylesheet>

    <script language="Javascript">
        var email_rowno = 1;
        function accMul(arg1,arg2)
        {
            var m=0,s1=arg1.toString(),s2=arg2.toString();
            try{m+=s1.split(".")[1].length}catch(e){}
            try{m+=s2.split(".")[1].length}catch(e){}
            return Number(s1.replace(".",""))*Number(s2.replace(".",""))/Math.pow(10,m);
        }
       
        function formatFloat(flag,bit,strDecimal)
        {
            var i=0;
            var strFill="";

            strDecimal=strDecimal.toString();
            var addDecimal="0.";
            while(i<bit)
            {
               strFill=strFill+"0";
               if(flag&&(i==bit-1))
               {
                  addDecimal=addDecimal+"1";
               }
               else
               {
                  addDecimal=addDecimal+"0";
               }
               i=i+1;
            }
            i=0;
            var beginPlace=strDecimal.indexOf(".");

            if(beginPlace==-1)
            {
                 if(bit==0)  return strDecimal;
                 return strDecimal+"."+strFill;
            }
            var strDecimalC=strDecimal+strFill;

            var str= strDecimalC.split(/[.]/);
            var strInt=str[0];
            var strDecimal=str[1]+strFill;
            var IntDecimal=parseFloat("0."+strDecimal);
            var validPlace=beginPlace+bit+1;
            var validData=strDecimalC.substring(validPlace,validPlace+1);

            if(parseInt(validData)>4)
            {
                 if(bit==0)   return parseInt(strInt)+1;
                 var differents="0."+strFill+strDecimal.substring(bit,strDecimal.length);
                 IntDecimal=IntDecimal-parseFloat(differents);
                 IntDecimal=IntDecimal+parseFloat(addDecimal);

                 var DecimalValue=parseInt(strInt)+IntDecimal;

                 if(DecimalValue.toString().indexOf(".")== -1 )
                    DecimalValue=DecimalValue.toString()+".";

                 strDecimalC=DecimalValue.toString(10)+strFill;
            }

            var beginPlace=strDecimalC.indexOf(".");

            var beginStr=strDecimalC.substring(0,beginPlace);
            if(bit==0)
            {
                return beginStr;
            }
            return strDecimalC.substring(0, beginPlace+bit+1);
        }

      function computer_price_money(field_suffix)
      {
         var fob = document.getElementById("fob_"+field_suffix).value;
         var moq = document.getElementById("moq_"+field_suffix).value;
         var product_minimum_money = document.getElementById("product_minimum_money_"+field_suffix);
         if(product_minimum_money!=null)
         {
            product_minimum_money.innerHTML = formatFloat(false,2,accMul(fob,moq));
         }
      }

      function fill_check()
      {
        if (document.getElementById("name").value.trim() == ""){
          alert("<%=bundle.getString("PRODUCT_ALERT_NO_NAME")%>");
          document.getElementById("name").focus();
          return false;
        }

        //Get the editor contents in XHTML.
<%
        List langs = ProductLanguage.GetKnownLanguages();
        for(Object obj:langs)
        {
            Locale lang = (Locale)obj;
            String suffix = lang.toString();
%>
            var oEditor_<%=suffix%> = FCKeditorAPI.GetInstance('DataFCKeditor_<%=suffix%>') ;
            if( oEditor_<%=suffix%>.GetXHTML(true) != "")
            {
                document.getElementById("intro_<%=suffix%>").value = oEditor_<%=suffix%>.GetXHTML(true);
            }
<%
        }
%>

        return true;
      }

      function delatt(attid)
      {
         if(!fill_check()) return;
         document.inputFrm.del_att_id.value = attid;
         document.inputFrm.act.value=0;
         document.inputFrm.submit();
      }

      function selectemail()
      {
          var urownos = document.getElementsByName("emailno");

          for(var i = 0; i < urownos.length; i++)
          {
              urownos[i].checked = document.inputFrm.emailAllId.checked;
          }
      }

    function add_email()
    {
       var rc = popupDialog("/config/selectuser.jsp");

       if (rc == null || rc.length==0) return false;
       f_adduser(rc[0],rc[1]);
    }

    function f_adduser(uid,uname)
    {
        var userids = document.getElementsByName("email_userid");
        for(var i=0;i<userids.length;i++)
        {
            if(userids[0].value == uid)  return;    
        }

        email_rowno = email_rowno + 1;
        var tbody = document.getElementById("notify_email").getElementsByTagName("TBODY")[0];

         var row = document.createElement("TR");
         row.setAttribute("id","email_" + email_rowno);

         var td = document.createElement("TD");
         var input1 = document.createElement("INPUT");
         input1.setAttribute("id","emailno");
         input1.setAttribute("name","emailno");
         input1.setAttribute("type","checkbox");
         input1.setAttribute("value",email_rowno);
         td.appendChild(input1);
         input1 = document.createElement("INPUT");
         input1.setAttribute("id","email_userid");
         input1.setAttribute("name","email_userid");
         input1.setAttribute("type","hidden");
         input1.setAttribute("value",uid);
         td.appendChild(input1);
         row.appendChild(td);

         td = document.createElement("TD");
         input1 = document.createElement("INPUT");
         input1.setAttribute("name","email_username");
         input1.setAttribute("type","text");
         input1.setAttribute("readOnly","true");
         input1.setAttribute("value",uname);
         input1.setAttribute("size","25");
         td.appendChild(input1);
         row.appendChild(td);

         td = document.createElement("TD");
         input1 = document.createElement("INPUT");
         input1.setAttribute("name","email");
         input1.setAttribute("type","text");
         input1.setAttribute("size","25");
         td.appendChild(input1);
         row.appendChild(td);

         td = document.createElement("TD");
         input1 = document.createElement("INPUT");
         input1.setAttribute("name","sms");
         input1.setAttribute("type","text");
         input1.setAttribute("size","25");
         td.appendChild(input1);
         row.appendChild(td);

         tbody.appendChild(row);
    }

    function del_email()
    {
        //if (document.getElementsByName("emailno") == null) return false;
        var emailnos = document.getElementsByName("emailno");
        for(var i = 0; i < emailnos.length; i++)
        {
            if(emailnos[i].checked)
            {
                var row=document.getElementById("email_" + emailnos[i].value);
                if( row == null) return;
                row.parentNode.removeChild(row);
            }
        }
    }

    function popupDialog(url)
    {
         var isMSIE= (navigator.appName == "Microsoft Internet Explorer");

         if (isMSIE)
         {
             return window.showModalDialog(url);
         }
         else
         {
             var win = window.open(url, "mcePopup","dialog=yes,modal=yes" );
             win.focus();
         }
    }

    function delatt(attid)
    {
         if(!fill_check()) return;
         document.inputFrm.del_att_id.value = attid;
         document.inputFrm.act.value=0;
         document.inputFrm.submit();
    }

    function saveProduct()
    {
         if(!fill_check()) return;
         document.inputFrm.act.value=0;
         document.inputFrm.submit();
    }

    function publishProduct()
    {
        if(!fill_check()) return;
        document.inputFrm.act.value=2;
        document.inputFrm.submit();
    }

    function deleteProduct()
    {
        var r=confirm('<%=bundle.getString("PRODUCT_ALERT_DELETE")%>');
        if( r ==1 )
        {
            document.inputFrm.act.value=1;
            document.inputFrm.submit();
        }
    }

    var fjarray = new Array(0);
    var tdNum = 0;
    var tdIndex = 0;
    function getFileName(str)
    {
    	return str.match(/[^\\]+$/);
    }


    Object.reEvent = function ()
    {
    	return window.event ? window.event : (function (o) {
    		do {
    			o = o.caller;
    		} while (o && !/^\[object[ A-Za-z]*Event\]$/.test(o.arguments[0]));
    		return o.arguments[0];
    	})(this.reEvent);
    };

    var $P =
    {
    	reMouse : function ()
    	{
    		var e = Object.reEvent();
    		return {
    			x : (document.documentElement.scrollLeft || document.body.scrollLeft) + e.clientX,
    			y : (document.documentElement.scrollTop || document.body.scrollTop) + e.clientY
    		};
    	}
    };

    function show()
    {
        var mos = $P.reMouse();
        var wc = document.getElementById("wc");

    	wc.style.left = mos.x - 200 + "px";
    	wc.style.top = mos.y - 10 + "px";

    	wc.onchange = function ()
        {
            wc.parentNode.appendChild(wc.cloneNode(true));
        	wc.parentNode.lastChild.style.top=0+"px";
        	wc.parentNode.lastChild.style.left=0+"px";
        	wc.id = "file"+tdNum;
        	wc.name="file"+	tdNum;
        	wc.style.display = "none";
            var fileName = getFileName(wc.value);

        	var intRowIndex = tr_fj.cells.length;
        	var tdnew=tr_fj.insertCell(intRowIndex);
        	tdnew.innerHTML='<img src="/images/fujian.gif">'+
        	fileName+' <a href="javascript:delCell('+tdNum+')">X</a>';
        	tdnew.id = "td_fj"+tdNum;
        	fjarray[tdNum]=wc.value;
        	tdNum = tdNum + 1;
        	wc.style.top="0px";
        	wc.style.left="500px";
    	};
    };

    function delCell(tdId)
    {
    	tdIndex = 0;
    	for (i=0;i<fjarray.length;i++)
    	{
    		if (fjarray[i]!="")
    			if (i!=tdId)
    				tdIndex = tdIndex+1;
    			else
    				break;
    	}
    	tr_fj.deleteCell(tdIndex);
    	fjarray[tdId]="";
    }

      var req = false;
      function executeXhr(callback, url)
      {
          // branch for native XMLHttpRequest object
          if (window.XMLHttpRequest) {
            req = new XMLHttpRequest();
            req.onreadystatechange = callback;
            req.open("GET", url, true);
            req.send(null);
          } // branch for IE/Windows ActiveX version
          else if (window.ActiveXObject) {
            req = new ActiveXObject("Microsoft.XMLHTTP");
            if (req) {
              req.onreadystatechange = callback;
              req.open("GET", url, true);
              req.send();
            }
          }
      }

      function processAjaxResponse()
      {
          if (req.readyState == 4) {
              if (req.status == 200) {
        		alert(req.responseText);
              } else {
                alert("<%=bundle.getString("PRODUCT_ALERT_AJAX_ERROR")%>");
              }
          }
      }
    </script>
</head>

<body leftmargin=20 topmargin=0>
<table border="0" class="positionbar" cellpadding="0" cellspacing="0">
  <tr>
    <td>&nbsp;
      <input type="button" class="button" name="save" value="<%=bundle.getString("PRODUCT_BUTTON_SAVE")%>" onClick="saveProduct()" >
      <input type="button" class="button" name="publish" value="<%=bundle.getString("PRODUCT_BUTTON_PUBLISH")%>" onClick="publishProduct()" >        
      <input type="button" class="button" name="delete" value="<%=bundle.getString("PRODUCT_BUTTON_DELETE")%>" onClick="deleteProduct()" >
      <input type="button" class="button" name="close" value="<%=bundle.getString("PRODUCT_BUTTON_CLOSE")%>" onclick="javascript:window.close();">
    </td>
  </tr>
</table>

<table width="100%" cellpadding="0" border="1" cellspacing="0">
    <form name="inputFrm" method="post" action="productsave.jsp" encType="multipart/form-data">
        <input type="hidden" name="id"  value="<%= id==null?"":id %>">
        <input type="hidden" name="del_att_id" value="">
        <input type="hidden" name="act" value="0">
        <input type="file" name="fileselect" id="wc" style="top:0px;left:500px;height:20px;position:absolute;opacity:0;filter:alpha(opacity=0);">    <tr height="25">
        <td width="80" align=center><font color=red><%=bundle.getString("PRODUCT_NAME")%></font></td>
        <td>
          <input type="text" name="name" style="width:100%" value= "<%= (product==null || product.GetName()==null)?"":product.GetName() %>">
        </td>
        <td width="80" align=center><%=bundle.getString("PRODUCT_STATUS")%></td>
        <td colspan="3">
            <select name="status">
                <option value="0" <% if(product!=null && product.GetStatus()==0) out.print("selected");%>><%=bundle.getString("PRODUCT_STATUS_ON")%></option>
                <option value="1" <% if(product!=null && product.GetStatus()==1) out.print("selected");%>><%=bundle.getString("PRODUCT_STATUS_STOP")%></option>
            </select>
        </td>
    </tr>
    <tr height="25">
        <td width="80" align=center><%=bundle.getString("PRODUCT_CREATOR")%></td>
        <td><%= bNew?creator:product.GetCreator()%></td>
        <td width="80" align=center><%=bundle.getString("PRODUCT_CREATEDATE")%></td>
        <td>
            <%= bNew?create_date:product.GetCreateDate()%>
        </td>
        <td width="80" align=center><%=bundle.getString("PRODUCT_UPDATEDATE")%></td>
        <td>
            <%= bNew?create_date:product.GetUpdateDate()%>
        </td>
    </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td>
    <div id="langs" class="dhtmlxTabBar" imgpath="/dhtmlxtabbar/imgs/" style="width:100%; height:1000;overflow:hidden;" mode="top" align="left" offset="20" margin="-10" tabheight="25" skinColors="#FFFACD,#F4F3EE">
        <%
            for(Object obj:langs)
            {
                Locale lang = (Locale)obj;
                String field_suffix = lang.getLanguage();
                Product.LocalInfo local = null;
                if(product!=null) local = product.GetLocalInfo(field_suffix);
        %>
        <div id="langs_<%=field_suffix%>" name="<%=bundle.getString("PRODUCT_LANG_"+field_suffix.toUpperCase())%>">
            <input type="hidden" name="intro_<%=field_suffix%>" id="intro_<%=field_suffix%>" value="">
            <table width="100%" cellpadding="0" cellspacing="0" border="1">
                <tr height="25">
                    <td width="120" align=center><%=bundle.getString("PRODUCT_NAME")%></td>
                    <td colspan="3"><input type="text" maxlength=500 style="width:100%" name="name_<%=field_suffix%>" value="<%=local==null?"":Utils.Null2Empty(local.GetField("name"))%>"></td>
                    <td width="120" align=center><%=bundle.getString("PRODUCT_CODE")%></td>
                    <td><input type="text" maxlength="100" name="code_<%=field_suffix%>" value= "<%=local==null?"":Utils.Null2Empty(local.GetField("code"))%>"></td>
                </tr>
                <tr height="25">
                    <td align=center><%=bundle.getString("PRODUCT_CATEGORY")%></td>
                    <td><input type="text" maxlength=100 name="category_<%=field_suffix%>" value="<%=local==null?"":Utils.Null2Empty(local.GetField("category"))%>"></td>
                    <td width=120 align=center><%=bundle.getString("PRODUCT_BRAND")%></td>
                    <td><input type="text" maxlength="100"  name="brand_<%=field_suffix%>" value="<%=local==null?"":Utils.Null2Empty(local.GetField("brand"))%>"></td>
                    <td align=center><%=bundle.getString("PRODUCT_MATERIAL")%></td>
                    <td><input type="text" maxlength="100"  name="material_<%=field_suffix%>" value="<%=local==null?"":Utils.Null2Empty(local.GetField("material"))%>"></td>
                </tr>
                <tr height="25">
                    <td align=center><%=bundle.getString("PRODUCT_ORIGIN")%></td>
                    <td><input type="text" maxlength=250  name="origin_<%=field_suffix%>" value="<%=local==null?"":Utils.Null2Empty(local.GetField("origin"))%>"></td>
                    <td align=center><%=bundle.getString("PRODUCT_EXPORTER")%></td>
                    <td colspan="3"><input type="text" maxlength=500 style="width:100%"  name="exporter_<%=field_suffix%>" value="<%=local==null?"":Utils.Null2Empty(local.GetField("exporter"))%>"></td>
                </tr>
                <tr height="25">
                    <td align=center><%=bundle.getString("PRODUCT_SIZE")%></td>
                    <td><input type="text" maxlength=100  name="product_size_<%=field_suffix%>" value="<%=local==null?"":Utils.Null2Empty(local.GetField("product_size"))%>"></td>
                    <td align=center><%=bundle.getString("PRODUCT_WEIGHT")%></td>
                    <td><input type="text" maxlength=100 style="width:100%"  name="product_weight_<%=field_suffix%>" value="<%=local==null?"":Utils.Null2Empty(local.GetField("product_weight"))%>"></td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                </tr>
                <tr height="25">
                    <td align=center><%=bundle.getString("PRODUCT_PRODUCT_SPEC")%></td>
                    <td colspan="5">
                        <textarea name="product_spec_<%=field_suffix%>" style="width:100%" rows="2"><%=local==null?"":Utils.Null2Empty(local.GetField("product_spec"))%></textarea>
                     </td>
                </tr>                
                <tr height="25">
                    <td align=center><%=bundle.getString("PRODUCT_PRODUCER")%></td>
                    <td><input type="text" maxlength=250  name="producer_<%=field_suffix%>" value="<%=local==null?"":Utils.Null2Empty(local.GetField("producer"))%>"></td>
                    <td align=center><%=bundle.getString("PRODUCT_PURCHASE_PRICE")%></td>
                    <td >
                        <input type="text"  maxlength=50 id="purchase_price_<%=field_suffix%>" name="purchase_price_<%=field_suffix%>"  value="<%= local==null?"":Utils.Null2Empty(local.GetField("purchase_price")) %>">
                    </td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                </tr>

                <tr height="25">
                    <td align=center><%=bundle.getString("PRODUCT_FOB")%></td>
                    <td >
                        <input type="text"  maxlength=50 id="fob_<%=field_suffix%>" name="fob_<%=field_suffix%>"  value="<%= local==null?"":Utils.Null2Empty(local.GetField("fob")) %>" onchange="computer_price_money('<%=field_suffix%>');">
                    </td>
                    <td align=center><%=bundle.getString("PRODUCT_MOQ")%></td>
                    <td >
                        <input type="text" maxlength="100"  id="moq_<%=field_suffix%>" name="moq_<%=field_suffix%>"  value="<%= local==null?"1":local.GetField("moq") %>"  onchange="computer_price_money('<%=field_suffix%>');">
                    </td>
                    <td align=center><%=bundle.getString("PRODUCT_MINIMUM_MONEY")%></td>
                    <td>
                        <span id="product_minimum_money_<%=field_suffix%>"><%=local==null?"":local.GetMinimumMoney()%></span><br>
                        (=<%=bundle.getString("PRODUCT_FOB")%>*<%=bundle.getString("PRODUCT_MOQ")%>)
                    </td>
                </tr>
                <tr height="25">
                    <td align=center><%=bundle.getString("PRODUCT_LEAD_TIME")%></td>
                    <td colspan="5"><input type="text" maxlength=500 style="width:100%"  name="lead_time_<%=field_suffix%>" value="<%=local==null?"":Utils.Null2Empty(local.GetField("lead_time"))%>"></td>
                </tr>
                <tr height="25">
                    <td align=center><%=bundle.getString("PRODUCT_CARTON")%></td>
                    <td><input type="text" maxlength=100  name="carton_<%=field_suffix%>" value="<%=local==null?"":Utils.Null2Empty(local.GetField("carton"))%>"></td>
                    <td align=center><%=bundle.getString("PRODUCT_CARTON_WEIGHT")%></td>
                    <td><input type="text" maxlength=100 style="width:100%"  name="carton_weight_<%=field_suffix%>" value="<%=local==null?"":Utils.Null2Empty(local.GetField("carton_weight"))%>"></td>
                    <td align=center><%=bundle.getString("PRODUCT_PACKAGE_QUANTITY")%></td>
                    <td>
                        <input type="text" maxlength="100" id="package_quantity_<%=field_suffix%>" name="package_quantity_<%=field_suffix%>" value="<%= local==null?"":Utils.Null2Empty(local.GetField("package_quantity")) %>">
                    </td>
                </tr>
                <tr height="25">
                    <td align=center><%=bundle.getString("PRODUCT_PACKAGE_SPEC")%></td>
                    <td colspan="5">
                        <textarea name="package_spec_<%=field_suffix%>" style="width:100%" rows="2"><%=local==null?"":Utils.Null2Empty(local.GetField("package_spec"))%></textarea>
                    </td>
                </tr>
                <tr height="25">
                    <td colspan="6" align="left">&nbsp;&nbsp;&nbsp;&nbsp;<%=bundle.getString("PRODUCT_HINT_INTRO")%></td>
                </tr>
            </table>

            <div id="FCKeditor_<%=field_suffix%>">
                <textarea id="DataFCKeditor_<%=field_suffix%>" cols="80" rows="20"><%if(product!=null) product.GetIntroduction(lang,out);%></textarea>
            </div>
            <script type="text/javascript">
                var oFCKeditor_<%=field_suffix%> = new FCKeditor( 'DataFCKeditor_<%=field_suffix%>' ) ;
                oFCKeditor_<%=field_suffix%>.BasePath = "/FCKeditor/";
                oFCKeditor_<%=field_suffix%>.Width = '100%' ;
                oFCKeditor_<%=field_suffix%>.Height = '800' ;
                oFCKeditor_<%=field_suffix%>.ReplaceTextarea() ;
            </script>
        </div>
      <%
        }
      %>
       <div id="attaches_div" name="<%=bundle.getString("PRODUCT_ATTACHES")%>">
           <div>
                &nbsp;&nbsp;
                <a onmouseover="show()"><%=bundle.getString("PRODUCT_ADDATTACH")%></a>
               <input type="hidden" name="tFj" value="">
           </div>
           <table id="tbl_fj" width=100% border="0" cellpadding="0" cellspacing="1">
               <tr id="tr_fj">
                  <%
                    if(!bNew)
                    {
                        java.util.List attaches = product.GetAttaches();
                        if(attaches!=null)
                        {
                            for(Object obj:attaches)
                            {
                                ProductAttach att = (ProductAttach) obj;
                                out.print("<td><img src='/images/fujian.gif'>");
                                out.print("<a href='");
                                //out.print(att.GetURL());
                                out.print("viewattach.jsp?id="+id+"&attid="+att.GetId());
                                out.print("' target='_blank'>");
                                out.print(att.GetName());
                                if(att.GetSuffix()!=null) out.print(att.GetSuffix());
                                out.print("</a>&nbsp;");

                                out.print("<a href=\"");
                                out.print("javascript:delatt('"+ att.GetId()+"');");
                                out.print("\">X");
                                out.print("</a>");

                                out.print("</td>");
                            }
                        }
                    }
                  %>
               </tr>
           </table>
       </div>
       <div id="notify_div" name="<%=bundle.getString("PRODUCT_NOTIFY")%>">
          <table id="notify_email" width=100% border="0" cellpadding="0" cellspacing="1">
             <tbody> 
             <tr height="25">
                 <td colspan="4">
                     <b>&nbsp;&nbsp;<%=bundle.getString("PRODUCT_HINT_EMAIL")%></b>
                 </td>
             </tr>
             <tr height="25">
                 <td colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;
                     <input type="button" name="addNotify" class="button" value="<%=bundle.getString("PRODUCT_BUTTON_ADD_NOTIFY")%>"  onclick="add_email()">
                     <input type="button" name="delNotify" class="button" value="<%=bundle.getString("PRODUCT_BUTTON_DEL_NOTIFY")%>"  onclick="del_email()">
                 </td>
             </tr>
             <tr height=25>
                <td>
                    <input type = "checkBox" name = "emailAllId" value="0" onclick = "javascript:selectemail();">
                </td>
                <td width=120><%=bundle.getString("PRODUCT_NOTIFY_USERNAME")%></td>
                <td width=50><%=bundle.getString("PRODUCT_NOTIFY_EMAIL")%></td>
                <td width=50><%=bundle.getString("PRODUCT_NOTIFY_SMS")%></td>
             </tr>
              <%
                  int rows=0;
                  if(product!=null)
                  {
                      Enumeration notify_infos = product.GetNotifyInfo();
                      if(notify_infos!=null)
                      {
                          while(notify_infos.hasMoreElements())
                          {
                              Product.NotifyInfo notify_info = (Product.NotifyInfo)notify_infos.nextElement();
                              rows++;
              %>
             <tr id="email_<%=rows%>" height=25>
                <td>
                    <input type="checkBox" id="emailno" name="emailno" value = "<%= rows %>">
                    <input type=hidden name=email_userid value="<%=notify_info.GetUID()%>">
                </td>
				<td>
                    <input type=text name=email_username value="<%=notify_info.GetUName()%>" size=25>
				</td>
				<td>
                    <input type=text name=email value="<%=Utils.Null2Empty(notify_info.GetEmail())%>" size=50 maxlength=250>
                </td>
                <td>
                    <input type=text name=sms value="<%=Utils.Null2Empty(notify_info.GetSMS())%>" size=50 maxlength=250>
                </td>
              </tr>
              <%
                      }
              %>
                      <script language="javascript"> email_rowno = <%= rows %>;</script>
              <%
                     }
                  }                  
              %>
           </tbody>
         </table>
       </div>
       <div id="memo_div" name="<%=bundle.getString("PRODUCT_MEMO")%>">
            &nbsp;&nbsp;<b><%=bundle.getString("PRODUCT_HINT_MEMO")%></b>
            <textarea name="memo" style="width:100%" rows="10"><%= (product==null || product.GetMemo()==null)?"":product.GetMemo() %></textarea>
       </div>
    </div>
    </td>
  </tr>
</table>
</form>
</body>
</html>

<%
    if(product!=null) product.Clear();
    if(wrapper!=null) wrapper.Clear();
%>