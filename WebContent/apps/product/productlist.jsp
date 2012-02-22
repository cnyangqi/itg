<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="nps.core.Database" %>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.extra.trade.Product" %>
<%@ page import="nps.extra.trade.ProductLanguage" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.Locale" %>

<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    int rowperpage = 100;
    int currpage = 1, startnum = 0, endnum = 0, totalrows = 0, totalpages = 0, rownum=0;
    String scrollstr = "", nextpage = "productlist.jsp";
    String currpg    = request.getParameter("page");
    try{ currpage = Integer.parseInt(currpg);	}catch (Exception e){currpage = 1;	}
    String id = null;
    Connection con   = null;
    PreparedStatement pstmt   = null;
    ResultSet rs     = null;
    String sql 		 = null;

    String act = request.getParameter("act");
    if(act!=null)  act = act.trim();
    String job = request.getParameter("job");

    String current_rowperpage = request.getParameter("rowperpage");
    if(current_rowperpage!=null)
    {
        try{rowperpage = Integer.parseInt(current_rowperpage);}catch(Exception e1){}
    }

    //query parameters
    String qry_name = request.getParameter("qry_name");
    if(qry_name!=null)
    {
        qry_name = qry_name.trim();
        if(qry_name.length()==0) qry_name = null;
    }    
    String qry_code = request.getParameter("qry_code");
    if(qry_code!=null)
    {
        qry_code =qry_code.trim();
        if(qry_code.length()==0) qry_code = null;        
    }
    String qry_producer = request.getParameter("qry_producer");
    if(qry_producer!=null)
    {
        qry_producer =qry_producer.trim();
        if(qry_producer.length()==0) qry_producer = null;        
    }
    String qry_category = request.getParameter("qry_category");
    if(qry_category!=null)
    {
        qry_category =qry_category.trim();
        if(qry_category.length()==0) qry_category = null;
    }
    String qry_status = request.getParameter("qry_status");
    try{Integer.parseInt(qry_status);}catch(Exception e){qry_status = null;}
    String qry_fob_from = request.getParameter("qry_fob_from");
    if(qry_fob_from!=null)
    {
        qry_fob_from =qry_fob_from.trim();
        try{Float.parseFloat(qry_fob_from);}catch(Exception e){qry_fob_from = null;}
    }
    String qry_fob_to = request.getParameter("qry_fob_to");
    if(qry_fob_to!=null)
    {
        qry_fob_to =qry_fob_to.trim();
        try{Float.parseFloat(qry_fob_to);}catch(Exception e){qry_fob_to = null;}                
    }
    String qry_moq_from = request.getParameter("qry_moq_from");
    if(qry_moq_from!=null)
    {
        qry_moq_from =qry_moq_from.trim();
        try{Float.parseFloat(qry_moq_from);}catch(Exception e){qry_moq_from = null;}
    }
    String qry_moq_to = request.getParameter("qry_moq_to");
    if(qry_moq_to!=null)
    {
        qry_moq_to =qry_moq_to.trim();
        try{Float.parseFloat(qry_moq_to);}catch(Exception e){qry_moq_to = null;}
    }
    String qry_lead_time_from = request.getParameter("qry_lead_time_from");
    if(qry_lead_time_from!=null)
    {
        qry_lead_time_from =qry_lead_time_from.trim();
        try{Float.parseFloat(qry_lead_time_from);}catch(Exception e){qry_lead_time_from = null;}
    }
    String qry_lead_time_to = request.getParameter("qry_lead_time_to");
    if(qry_lead_time_to!=null)
    {
        qry_lead_time_to =qry_lead_time_to.trim();
        try{Float.parseFloat(qry_lead_time_to);}catch(Exception e){qry_lead_time_to = null;}
    }
    String qry_update_date_from = request.getParameter("qry_update_date_from");
    if(qry_update_date_from!=null)
    {
        qry_update_date_from =qry_update_date_from.trim();
        try{new SimpleDateFormat("yyyyMMdd").parse(qry_update_date_from);}catch(Exception e){qry_update_date_from = null;}        
    }
    String qry_update_date_to = request.getParameter("qry_update_date_to");
    if(qry_update_date_to!=null)
    {
        qry_update_date_to =qry_update_date_to.trim();
        try{new SimpleDateFormat("yyyyMMdd").parse(qry_update_date_to);}catch(Exception e){qry_update_date_to = null;}                
    }

    String lang = request.getParameter("lang");
    if(lang==null) lang= user.GetLocale().getLanguage();

    ResourceBundle bundle = ResourceBundle.getBundle("langs.app_productlist",user.GetLocale(), Config.RES_CLASSLOADER);    

    if("delete".equalsIgnoreCase(job))
    {
        String[] rownos = request.getParameterValues("rowno");
        NpsWrapper wrapper = null;
        try
        {
            wrapper = new NpsWrapper(user);

            for(int i=0;i<rownos.length;i++)
            {
                String delete_product_id = request.getParameter("product_id_" + rownos[i]);

                Product product = Product.GetProduct(wrapper.GetContext(),delete_product_id);
                if(product==null) continue;
                product.Delete();
            }
        }
        catch(Exception e)
        {
            if(wrapper!=null) wrapper.Rollback();
            e.printStackTrace();
        }
        finally
        {
            if(wrapper!=null) wrapper.Clear();
        }
    }   
%>

<HTML>
	<HEAD>
		<TITLE><%=bundle.getString("PRODUCTLIST_HTMLTILE")%></TITLE>
        <script type="text/javascript" src="/jscript/global.js"></script>
        <LINK href="/css/style.css" rel = stylesheet>
		<script langauge = "javascript">
			function f_new()
			{
				document.listFrm.action	= "productinfo.jsp";
                document.listFrm.target="_blank";
                document.listFrm.submit();
            }

            function f_delete()
            {
                var rows = document.getElementsByName("rowno");
                var hasChecked = false;
                for(var i=0;i<rows.length;i++)
                {
                   if(rows[i].checked)
                   {
                       hasChecked = true;
                       break;
                   }
                }

                if(!hasChecked)  return;
                var r=confirm("<%=bundle.getString("PRODUCTLIST_ALTER_DELETE")%>");
                if(r==1)
                {
                   document.listFrm.action = "productlist.jsp?job=delete";
                   document.listFrm.target="_self";
                   document.listFrm.submit();
                }
            }

            function showfields()
            {
               var oSon=document.getElementById("exp_fields");
               if (oSon==null) return;
               with (oSon)
               {
                  style.display="block";
                  style.pixelLeft=window.event.clientX+window.document.body.scrollLeft;
                  style.pixelTop=window.event.clientY+window.document.body.scrollTop+9;
                  style.position="absolute";
               }
            }
            function hidefields()
            {
               var oSon=document.getElementById("exp_fields");
               if (oSon==null) return;
               oSon.style.display="none";
            }

            function f_import()
            {

            }

            function f_trueexport()
            {
                document.listFrm.action="productexp.jsp";
                document.listFrm.target="_blank";
                document.listFrm.submit();
            }

            function f_export()
            {
                var oSon=window.document.getElementById("exp_fields");
                if(oSon.style.display=="none")
                   showfields();
                else
                   hidefields();
            }


            function f_query()
            {
               document.listFrm.action = "productlist.jsp";
               document.listFrm.target="_self";
               document.listFrm.submit(); 
            }

            function langchanged()
            {
                document.listFrm.action	= "productlist.jsp";
                document.listFrm.target="_self";
                document.listFrm.submit();
            }
            
            function openProduct(idvalue)
            {
              document.frmOpen.id.value = idvalue;
              document.frmOpen.submit();
            }

            function selectproducts()
            {
                var rownos = document.getElementsByName("rowno");
                for (var i = 0; i < rownos.length; i++)
                {
                   rownos[i].checked = document.listFrm.AllId.checked;
                }                
            }
            
        </script>
	</HEAD>

  <BODY leftMargin="20" topMargin = "0">
  <form name = "listFrm" method = "post">
     <input type="hidden" name="act" value="">
  <table width = "90%" border = "0" align = "center" cellpadding = "0" cellspacing = "1">
  <tr>
     <td width="120" align="center"><%=bundle.getString("PRODUCTLIST_NAME")%></td>
     <td><input name="qry_name" type="text" value="<%=Utils.Null2Empty(Utils.TransferToHtmlEntity(qry_name))%>"> </td>
     <td width="120" align="center"><%=bundle.getString("PRODUCTLIST_CODE")%></td>
     <td colspan="3"><input name="qry_code" type="text" value="<%=Utils.Null2Empty(Utils.TransferToHtmlEntity(qry_code))%>"> </td>
  </tr>
  <tr>
      <td width="120" align="center"><%=bundle.getString("PRODUCTLIST_CATEGORY")%></td>
      <td><input name="qry_category" type="text" value="<%=Utils.Null2Empty(Utils.TransferToHtmlEntity(qry_category))%>"> </td>
      <td width="120" align="center"><%=bundle.getString("PRODUCTLIST_PRODUCER")%></td>
      <td><input name="qry_producer" type="text" value="<%=Utils.Null2Empty(Utils.TransferToHtmlEntity(qry_producer))%>"> </td>
      <td width="60" align="center"><%=bundle.getString("PRODUCTLIST_STATUS")%></td>
      <td>
          <select name="qry_status">
              <option></option>
              <option value="0" <% if("0".equals(qry_status)) out.print("selected");%>><%=bundle.getString("PRODUCTLIST_STATUS_ON")%></option>
              <option value="1" <% if("1".equals(qry_status)) out.print("selected");%>><%=bundle.getString("PRODUCTLIST_STATUS_STOP")%></option>
          </select>
      </td>
  </tr>
  <tr>
     <td width="120" align="center"><%=bundle.getString("PRODUCTLIST_FOB")%></td>
     <td>
       <input name="qry_fob_from" type="text" value="<%=Utils.Null2Empty(qry_fob_from)%>" style="width:80px">
       - <input name="qry_fob_to" type="text" value="<%=Utils.Null2Empty(qry_fob_to)%>" style="width:80px">
     </td>
      <td width="120" align="center"><%=bundle.getString("PRODUCTLIST_MOQ")%></td>
      <td colspan="3">
        <input name="qry_moq_from" type="text"  style="width:80px" value="<%=Utils.Null2Empty(qry_moq_from)%>">
         - <input name="qry_moq_to" type="text"  style="width:80px" value="<%=Utils.Null2Empty(qry_moq_to)%>">
      </td>
  </tr>
  <tr>
      <td width="120" align="center"><%=bundle.getString("PRODUCTLIST_LEAD_TIME")%></td>
      <td>
        <input name="qry_lead_time_from" type="text"  style="width:80px"value="<%=Utils.Null2Empty(qry_lead_time_from)%>">
         - <input name="qry_lead_time_to" type="text"  style="width:80px" value="<%=Utils.Null2Empty(qry_lead_time_to)%>">
      </td>
     <td width="120" align="center"><%=bundle.getString("PRODUCTLIST_UPDATE_DATE")%></td>
     <td colspan="3">
       <input name="qry_update_date_from" type="text" style="width:80px" value="<%=Utils.Null2Empty(qry_update_date_from)%>">
       - <input name="qry_update_date_to" type="text" style="width:80px" value="<%=Utils.Null2Empty(qry_update_date_to)%>">&nbsp;&nbsp;yyyyMMdd(20080131)
     </td>
  </tr>
  </table>

  <div id=exp_fields style="display:none;background-color:White;z-index:0">
     <%=bundle.getString("PRODUCTLIST_HINT_EXPORT")%><br> 
     &nbsp;&nbsp;&nbsp;&nbsp;
     <input type="checkbox" name="exp_name" checked><%=bundle.getString("PRODUCTLIST_NAME_LOCAL")%>
     <input type="checkbox" name="exp_code" checked><%=bundle.getString("PRODUCTLIST_CODE")%>
     <input type="checkbox" name="exp_fob" checked><%=bundle.getString("PRODUCTLIST_FOB")%>
     <input type="checkbox" name="exp_lead_time" checked><%=bundle.getString("PRODUCTLIST_LEAD_TIME")%>
     <input type="checkbox" name="exp_moq" checked><%=bundle.getString("PRODUCTLIST_MOQ")%>
     &nbsp;&nbsp;&nbsp;&nbsp;
     <br>
     &nbsp;&nbsp;&nbsp;&nbsp;
     <input type="checkbox" name="exp_category" checked><%=bundle.getString("PRODUCTLIST_CATEGORY")%>
     <input type="checkbox" name="exp_brand" checked><%=bundle.getString("PRODUCTLIST_BRAND")%>
     <input type="checkbox" name="exp_material" checked><%=bundle.getString("PRODUCTLIST_MATERIAL")%>
     &nbsp;&nbsp;&nbsp;&nbsp;
     <br>
     &nbsp;&nbsp;&nbsp;&nbsp;
     <input type="checkbox" name="exp_product_size" checked><%=bundle.getString("PRODUCTLIST_SIZE")%>
     <input type="checkbox" name="exp_product_weight" checked><%=bundle.getString("PRODUCTLIST_WEIGHT")%>
     <input type="checkbox" name="exp_product_spec" checked><%=bundle.getString("PRODUCTLIST_PRODUCT_SPEC")%>
     &nbsp;&nbsp;&nbsp;&nbsp;
     <br>
     &nbsp;&nbsp;&nbsp;&nbsp;
     <input type="checkbox" name="exp_carton" checked><%=bundle.getString("PRODUCTLIST_CARTON")%>
     <input type="checkbox" name="exp_carton_weight" checked><%=bundle.getString("PRODUCTLIST_CARTON_WEIGHT")%>
     <input type="checkbox" name="exp_package_quantity" checked><%=bundle.getString("PRODUCTLIST_PACKAGE_QUANTITY")%>
     <input type="checkbox" name="exp_package_spec" checked><%=bundle.getString("PRODUCTLIST_PACKAGE_SPEC")%>
     &nbsp;&nbsp;&nbsp;&nbsp;
     <br>
     &nbsp;&nbsp;&nbsp;&nbsp;
     <input type="checkbox" name="exp_producer"><%=bundle.getString("PRODUCTLIST_PRODUCER")%>
     <input type="checkbox" name="exp_origin"><%=bundle.getString("PRODUCTLIST_ORIGIN")%>
     <input type="checkbox" name="exp_exporter"><%=bundle.getString("PRODUCTLIST_EXPORTER")%>
     <input type="checkbox" name="exp_purchase_price"><%=bundle.getString("PRODUCTLIST_PURCHASE_PRICE")%>
     &nbsp;&nbsp;&nbsp;&nbsp;
     <br>      
     &nbsp;&nbsp;&nbsp;&nbsp;
     <input type="checkbox" name="exp_intro"><%=bundle.getString("PRODUCTLIST_INTRO")%>
     &nbsp;&nbsp;&nbsp;&nbsp;
     <br>
     &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
     &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <input type="button" name="trueexpBtn" onclick="f_trueexport()" class=button value="<%=bundle.getString("PRODUCTLIST_BUTTON_EXPORT")%>">
  </div>

  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "0" class="positionbar">
    <tr>
      <td valign="middle">&nbsp;
        <input name="qryBtn" type="button" onClick="f_query()" value="<%=bundle.getString("PRODUCTLIST_BUTTON_QUERY")%>" class="button">
        <input name="newBtn" type="button" onClick="f_new()" value="<%=bundle.getString("PRODUCTLIST_BUTTON_NEW")%>" class="button">
        <input name="delBtn" type="button" onClick="f_delete()" value="<%=bundle.getString("PRODUCTLIST_BUTTON_DELETE")%>" class="button">
        <input name="expBtn" type="button" onClick="f_export()" value="<%=bundle.getString("PRODUCTLIST_BUTTON_EXPORT")%>" class="button">
        &nbsp;&nbsp;
          <%=bundle.getString("PRODUCTLIST_HINT_LANG")%>
          <select name="lang" onchange="langchanged();">
            <%
                List langs = ProductLanguage.GetKnownLanguages();
                for(Object obj:langs)
                {
                    Locale alang = (Locale)obj;
                    String key = alang.toString();
            %>
              <option value="<%=key%>" <%if(lang.equalsIgnoreCase(key)) out.print("selected");%>><%=bundle.getString("PRODUCTLIST_LANG_"+key.toUpperCase())%></option>
            <%
                }
            %>
          </select>
        &nbsp;&nbsp;
          <input type="text" name="rowperpage" style="width:40px" value="<%=rowperpage%>">
          <%=bundle.getString("PRODUCTLIST_HINT_ROWPERPAGE")%>
      </td>
    </tr>
  </table>


  <table width = "100% " border = "0" align = "center" cellpadding = "0" cellspacing = "1" class="titlebar">
      <tr height=30>
	      <td width="25">
    		<input type = "checkBox" name = "AllId" value = "0" onclick = "selectproducts()">
		  </td>
 	      <td width="100"><%=bundle.getString("PRODUCTLIST_NAME")%></td>
          <td width="100"><%=bundle.getString("PRODUCTLIST_NAME_LOCAL")%></td>          
          <td><%=bundle.getString("PRODUCTLIST_CODE")%></td>
          <td><%=bundle.getString("PRODUCTLIST_FOB")%></td>
          <td><%=bundle.getString("PRODUCTLIST_MOQ")%></td>
          <td><%=bundle.getString("PRODUCTLIST_LEAD_TIME")%></td>
          
          <td><%=bundle.getString("PRODUCTLIST_CATEGORY")%></td>
          <td><%=bundle.getString("PRODUCTLIST_SIZE")%></td>
          <td><%=bundle.getString("PRODUCTLIST_WEIGHT")%></td>
          <td><%=bundle.getString("PRODUCTLIST_CARTON")%></td>
          <td><%=bundle.getString("PRODUCTLIST_CARTON_WEIGHT")%></td>
          <td><%=bundle.getString("PRODUCTLIST_PACKAGE_QUANTITY")%></td>
          <td><%=bundle.getString("PRODUCTLIST_PRODUCER")%></td>
          <td><%=bundle.getString("PRODUCTLIST_PURCHASE_PRICE")%></td>
          <td width = "80"><%=bundle.getString("PRODUCTLIST_UPDATE_DATE")%></td>
      </tr>
<%
    try
    {
        //只能编辑自己单位的产品信息
        con = Database.GetDatabase("nps").GetConnection();

        //clause string
        String clause = "";
        if(qry_name!=null) clause += " and (a.name like ? or b.name like ?)";
        if(qry_code!=null) clause += " and b.code like ?";
        if(qry_producer!=null) clause += " and b.producer like ?";
        if(qry_category!=null) clause += " and b.category like ?";
        if(qry_status!=null) clause += " and a.status=?";
        if(qry_fob_from!=null) clause += " and b.fob>=?";
        if(qry_fob_to!=null) clause += " and b.fob<=?";
        if(qry_moq_from!=null) clause += " and b.moq>=?";
        if(qry_moq_to!=null) clause += " and b.moq<=?";
        if(qry_lead_time_from!=null) clause += " and b.lead_time>=?";
        if(qry_lead_time_to!=null) clause += " and b.lead_time<=?";
        if(qry_update_date_from!=null) clause += " and a.update_date>=to_date(?,'yyyymmdd')";
        if(qry_update_date_to!=null) clause += " and a.update_date<=to_date(?,'yyyymmdd')";
        
        //
        int i = 1;
        if(user.IsSysAdmin())
        {
            sql = "select count(*) from FT_PRODUCT a,FT_PRODUCT_"+lang+" b where a.id=b.id";
        }
        else
        {
            sql = "select count(*) from FT_PRODUCT a,FT_PRODUCT_"+lang+" b  where a.id=b.id and a.unitid=?";
        }

        pstmt = con.prepareStatement(sql+clause);
        if(!user.IsSysAdmin())
        {
            pstmt.setString(i++,user.GetUnitId());
        }

        if(qry_name!=null)
        {
            pstmt.setString(i++,"%"+qry_name+"%");
            pstmt.setString(i++,"%"+qry_name+"%");
        }
        if(qry_code!=null) pstmt.setString(i++,"%"+qry_code+"%");
        if(qry_producer!=null) pstmt.setString(i++,"%"+qry_producer+"%");
        if(qry_category!=null) pstmt.setString(i++,"%"+qry_category+"%");
        if(qry_status!=null) pstmt.setInt(i++,Integer.parseInt(qry_status));
        if(qry_fob_from!=null) pstmt.setBigDecimal(i++,new BigDecimal(qry_fob_from));
        if(qry_fob_to!=null) pstmt.setBigDecimal(i++,new BigDecimal(qry_fob_to));
        if(qry_moq_from!=null) pstmt.setBigDecimal(i++,new BigDecimal(qry_moq_from));
        if(qry_moq_to!=null) pstmt.setBigDecimal(i++,new BigDecimal(qry_moq_to));
        if(qry_lead_time_from!=null) pstmt.setBigDecimal(i++,new BigDecimal(qry_lead_time_from));
        if(qry_lead_time_to!=null) pstmt.setBigDecimal(i++,new BigDecimal(qry_lead_time_to));
        if(qry_update_date_from!=null) pstmt.setString(i++,qry_update_date_from);
        if(qry_update_date_to!=null) pstmt.setString(i++,qry_update_date_to);

        //query search now
        rs = pstmt.executeQuery();
        if (rs.next())  totalrows = rs.getInt(1);
        try{rs.close();}catch(Exception e){}
        try{pstmt.close();}catch(Exception e){}

        if (totalrows > 0)
        {
            totalpages = (int )((totalrows - 1) / rowperpage) + 1;
            startnum = rowperpage * (currpage - 1) + 1;
            endnum = currpage * rowperpage;
            i=1;
            if(user.IsSysAdmin())
            {
                sql = "select a.name common_name,a.update_date,b.* from FT_PRODUCT a,FT_PRODUCT_"+lang+" b where a.id=b.id";
            }
            else
            {
                sql = "select a.name common_name,a.update_date,b.* from FT_PRODUCT a,FT_PRODUCT_"+lang+" b where a.id=b.id and a.unitid=?";
            }

            String orderby = " order by a.update_date desc";
            pstmt = con.prepareStatement(sql+clause+orderby);
                                       
            if(!user.IsSysAdmin())
            {
                pstmt.setString(i++,user.GetUnitId());
            }
            
            if(qry_name!=null)
            {
                pstmt.setString(i++,"%"+qry_name+"%");
                pstmt.setString(i++,"%"+qry_name+"%");
            }
            if(qry_code!=null) pstmt.setString(i++,"%"+qry_code+"%");
            if(qry_producer!=null) pstmt.setString(i++,"%"+qry_producer+"%");
            if(qry_category!=null) pstmt.setString(i++,"%"+qry_category+"%");
            if(qry_status!=null) pstmt.setInt(i++,Integer.parseInt(qry_status));
            if(qry_fob_from!=null) pstmt.setBigDecimal(i++,new BigDecimal(qry_fob_from));
            if(qry_fob_to!=null) pstmt.setBigDecimal(i++,new BigDecimal(qry_fob_to));
            if(qry_moq_from!=null) pstmt.setBigDecimal(i++,new BigDecimal(qry_moq_from));
            if(qry_moq_to!=null) pstmt.setBigDecimal(i++,new BigDecimal(qry_moq_to));
            if(qry_lead_time_from!=null) pstmt.setBigDecimal(i++,new BigDecimal(qry_lead_time_from));
            if(qry_lead_time_to!=null) pstmt.setBigDecimal(i++,new BigDecimal(qry_lead_time_to));
            if(qry_update_date_from!=null) pstmt.setString(i++,qry_update_date_from);
            if(qry_update_date_to!=null) pstmt.setString(i++,qry_update_date_to);

            rs = pstmt.executeQuery();

            String productId = null;
            rownum = 0;
            while (rs.next() && (rs.getRow() <= endnum))
            {
                if (rs.getRow() < startnum) continue;

                productId = rs.getString("id");
%>
	          <tr class="detailbar">
				<td>
                  <input type = "checkBox" id="rowno" name="rowno" value = "<%= rs.getRow() %>">
                  <input type = "hidden" name = "product_id_<%= rs.getRow() %>" value = "<%= productId %>">
				</td>
				<td align="left">
                  <a href="javascript:openProduct('<%= productId %>');"><%= Utils.Null2Empty(Utils.TransferToHtmlEntity(rs.getString("common_name"))) %></a>
				</td>
                <td align="left">
                    <%= Utils.Null2Empty(Utils.TransferToHtmlEntity(rs.getString("name")))%>
                </td>
                <td align="center">
                  <%= Utils.Null2Empty(Utils.TransferToHtmlEntity(rs.getString("code")))%>
                </td>
                <td align="right">
                   <%= Utils.Null2Empty(rs.getBigDecimal("fob"))%>
                </td>
                <td align="right">
                   <%= Utils.Null2Empty(rs.getBigDecimal("moq"))%>
                </td>
                <td align="right">
                   <%= Utils.Null2Empty(rs.getBigDecimal("lead_time"))%>
                </td>

                <td align="center">
                  <%= Utils.Null2Empty(Utils.TransferToHtmlEntity(rs.getString("category")))%>
                </td>
                <td align="center">
                    <%= Utils.Null2Empty(Utils.TransferToHtmlEntity(rs.getString("product_size")))%>
                </td>
                <td align="center">
                    <%= Utils.Null2Empty(Utils.TransferToHtmlEntity(rs.getString("product_weight")))%>
                </td>
                <td align="center">
                    <%= Utils.Null2Empty(Utils.TransferToHtmlEntity(rs.getString("carton")))%>
                </td>
                <td align="center">
                    <%= Utils.Null2Empty(Utils.TransferToHtmlEntity(rs.getString("carton_weight")))%>
                </td>
                <td align="right">
                      <%= Utils.Null2Empty(rs.getBigDecimal("PACKAGE_QUANTITY"))%>
                </td>

                <td align="center">
                  <%= Utils.Null2Empty(rs.getString("producer"))%>
                </td>
                <td align="right">
                    <%= Utils.Null2Empty(rs.getBigDecimal("purchase_price"))%>
                </td>
                <td align="center">
	      		   <%= Utils.FormateDate(rs.getDate("update_date"),"yyyy-MM-dd") %>
                </td>
              </tr>
          <%
              }
			}  //end of if (totalrows >0)
    }
    catch (Exception ee)
    {
         throw ee;
    }
    finally
    {
        if (pstmt != null) try{ pstmt.close();}catch(Exception e){}
        if (con != null)  try{ con.close(); }catch(Exception e){}
    }
 %>
 </table>
</form>
<form name=frmOpen action="productinfo.jsp" target="_blank">
  <input type = "hidden" name = "id">
</form>
<%@ include file = "/include/scrollpage.jsp" %>
</body>
</html>