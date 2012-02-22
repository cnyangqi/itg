<script language=javascript>
<!--
   function f_scroll_check(frm){
    if(frm.currPage.value.length==""){
      alert("请输入要跳转到的页面");
      frm.currPage.focus();
      return false;
    }
    else
    {
      if (frm.currPage.value>frm.totalps.value)
      {
        alert("该页不存在");
        frm.currPage.value="";
        return false;
      }
    }
    return true;  
  }
-->
</script>
<% 
  if( scrollstr.length() >0 ){
    out.println("<form name=scrollfrm method=post action='" + nextpage + "?" + scrollstr + "'>");
  }else{
    out.println("<form name=scrollfrm method=post action='" + nextpage + "'>");
  }   
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" height="27" class="ScrollBar">
  <tr class="ScrollBar"> 
    <td height="26" width="18" class="type" ><input type="hidden" name="totalps" value='<%=TotalPages%>' /></td>
    <td width="113" height="26" class="type">有<font color=red><%=RecCount%></font>条记录</td>
    <td width="86" height="26" class="type">共<font color=red><%=TotalPages%></font>页</td>
    <td width="80" height="26" class="type">第<font color=red><%=currPage%></font>页</td>
    <td width="36" height="26" class="type">&nbsp;</td>
    <%
      if (currPage > 1) {
      %>
    <td width="47" height="26" class="type"><a href='<%=nextpage%>?currPage=1&<%=scrollstr%>'>首页</a></td>
    <%  
      }
      else{
      %>
    <td width="47" height="26" class="type"><font color="#999999">首页</font></td>
    <%    
      }
      %>
    <%
      if (currPage > 1) {
      %>
    <td width="47" height="26" class="type"><a href='<%=nextpage%>?currPage=<%=(currPage - 1)%>&<%=scrollstr%>'>前页</a></td>
    <%  
      }
      else{
      %>
    <td width="47" height="26" class="type"><font color="#999999">前页</font></td>
    <%    
      }
      %>
    <%
      if (currPage < TotalPages) {
      %>
    <td width="47" height="26" class="type"><a href='<%=nextpage%>?currPage=<%=(currPage + 1)%>&<%=scrollstr%>'>后页</a></td>
    <%  
      }
      else{
      %>
    <td width="47" height="26" class="type"><font color="#999999">后页</font></td>
    <%    
      }
      %>
    <%
      if (currPage < TotalPages) {
      %>
    <td width="47" height="26" class="type"><a href='<%=nextpage%>?currPage=<%=TotalPages%>&<%=scrollstr%>'>尾页</a></td>
    <%  
      }
      else{
      %>
    <td width="49" height="26" class="type"><font color="#999999">尾页</font></td>
    <%    
      }
      %>
    <td width="78" height="26" class="type" > <div align="right">跳转到第 </div>
    </td>
    <td width="43"><input type=text name=currPage size=5 maxlength=3></td>
    <td width="23"> <div align="left">页 </div></td>
    <td width="78"><div align="left">
        <input name="image" type=image onClick="return f_scroll_check(this.form)" src="<%=skin.imagepath%>oa/go.gif">
      </div></td>
    <td width="61">&nbsp;</td>
  </tr>
</table>
</form>