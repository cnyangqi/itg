<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import=
                                    "
                                     org.jdom.Document,
                                     com.gemway.partner.*,
                                     java.sql.*, org.jdom.Element,
                                     com.nfwl.itg.product.ProductClassTree,
                                     com.gemway.util.JUtil"
%>

<%@ include file = "/include/header.jsp" %>
<%
    String productclasscontrol=request.getParameter("productclasscontrol");
    String productclassidcontrol=request.getParameter("productclassidcontrol");
    String sql_post = JUtil.convertChinese(JUtil.convertNull(request.getParameter("sql")));

    Connection con=null;
    Statement stat=null;
    ResultSet rs=null;
    String sql=null;

  try
  {
      con= nps.core.Database.GetDatabase("nfwl").GetConnection();
      Element   root = ProductClassTree.getProductClassTree(con, sql_post);
 %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=gb2312">
    <title></title>

    <LINK href="/css/style.css" rel = stylesheet>
    <script language=javascript>
     var DIR_IMAGES = "/nfwl/images/treeview/";
    <%if(productclassidcontrol==null||productclassidcontrol.trim().length()<=0){%>
      var productclasscontrol='';
      var productclassidcontrol='';
    <%}else{%>
      var productclasscontrol='<%=productclasscontrol%>';
      var productclassidcontrol='<%=productclassidcontrol%>';
    <%}%>
      var initVal='';
      var productclass_name='';
      var productclassid='';
      var productClassList=new Array();

    function checkAll() {
        for (var i=0;i<document.frm.elements.length;i++)
        {
            var e = document.frm.elements[i];
            if ((e.name != 'chkall') && (e.type == 'checkbox'))
              e.checked = document.frm.chkall.checked;
        }
    }
    function doExit(){
        if(!confirm('您确定要退出吗?')) return;
        window.close();
    }

    function doChoose(){
      //debugger;
     // alert("1");
        productclassid='';
//getElementsByName
        //if(frm.productClass.length)
          if(document.getElementsByName('productClass').length)
        {//alert("2");
            for(var i=document.getElementsByName('productClass').length-1;i>=0;i--)
            {//alert("3");
                if(document.getElementsByName('productClass')[i].checked)
                {//alert("4");
                    if(productclassid.length>0)  productclassid+=' ';
                    productclassid+=document.getElementsByName('productClass')[i].value;
                    if(productclass_name.length>0)productclass_name+=' ';
                    productclass_name+=document.getElementsByName('productClassName')[i].value;
                }
            }
        }
        else if(document.getElementsByName('productClass').checked)
        {//alert("5");
            productclassid+=document.getElementsByName('productClass').value;
            productclass_name+=document.getElementsByName('productClassName').value;
        }

        if(productclassidcontrol==''){
            //opener.doc.relationalUnit.value=productclass_name;
            //opener.doc.relationalproductclassid.value=productclassid;
        }
        else{//alert("6");
            opener.setValue(productclasscontrol,productclass_name,productclassidcontrol,productclassid);
        }
        window.close();
    }
    </script>
    <script type="text/javascript" src="/nfwl/js/document.js"></script>
    <script type="text/javascript" src="/nfwl/js/selectTree.js"></script>
    <script type="text/javascript">
                  <%= com.gemway.util.JUtil.drawTree(root) %>
    </script>
</head>
<body onload="javascript:objTree.buildDOM(document.getElementById('tree_td'));"  leftmargin="0" topmargin="0" class="NavigatorTreeBar">
<table width="100%" border="0" cellspacing=0 cellpadding=0 valign=top class="ToolBar">
<form name="frm">
   <tr>
      <td>
          <input type="button" name="choose" value="选定并返回" onClick="javascript:doChoose();" class="button">
          <input type="button" name="exit" value="关闭" onClick="doExit();" class="button">
      </td>
  </tr>
</table>
<table width="100%" border="0" valign=top cellspacing=0 cellpadding=0 class="PositionBar">
    <tr class='color1'>
        <td id="tree_td" align="left" colspan="2">
        </td>
    </tr>
</table>
</form>
</body>
</html>
<%
  }
  catch(Exception e){e.printStackTrace();}
  finally
  {
    if( con != null) con.close();
  }
%>