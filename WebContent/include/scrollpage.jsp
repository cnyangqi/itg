<%
    java.util.ResourceBundle scroll_bundle = java.util.ResourceBundle.getBundle("langs.jsp_scroll",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);
%>
    <script language=javascript>
    <!--
       function f_scroll_check(frm){
            if(frm.page.value.length==""){
                alert("<%=scroll_bundle.getString("SCROLL_ALERT_NOPAGE")%>");
                frm.page.focus();
                return false;
            }
            else
            {
                if (parseInt(frm.page.value)>parseInt(frm.totalps.value))
                {
                    alert("<%=scroll_bundle.getString("SCROLL_ALERT_PAGENOTEXIST")%>");
                    frm.page.value="";
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

<table width="100%" border="0" cellspacing="0" cellpadding="0" class="ScrollBar">
<tbody>
  <tr>
    <td height="26" width="18" class="type" ><input type="hidden" name="totalps" value=<%=totalpages%> /></td>
    <td width="113" height="26" class="type"><STRONG style="COLOR: #990000"><%=totalrows%></STRONG><%=scroll_bundle.getString("SCROLL_RECORDS")%></td>
    <td width="86" height="26" class="type"><STRONG style="COLOR: #990000"><%=totalpages%></STRONG><%=scroll_bundle.getString("SCROLL_PAGES")%></td>
    <td width="80" height="26" class="type"><STRONG style="COLOR: #990000"><%=currpage%></STRONG></td>
    <td width="36" height="26" class="type">&nbsp;</td>
    <%
			if (currpage > 1) {
			%>
    <td width="47" height="26" class="type"><a href=<%=nextpage%>?page=1&<%=scrollstr%>><%=scroll_bundle.getString("SCROLL_FIRSTPAGE")%></a></td>
    <%	
			}
			else{
			%>
    <td width="47" height="26" class="type"><font color="#999999"><%=scroll_bundle.getString("SCROLL_FIRSTPAGE")%></font></td>
    <%		
			}
			%>
    <%
			if (currpage > 1) {
			%>
    <td width="47" height="26" class="type"><a href=<%=nextpage%>?page=<%=(currpage - 1)%>&<%=scrollstr%>><%=scroll_bundle.getString("SCROLL_PREVPAGE")%></a></td>
    <%	
			}
			else{
			%>
    <td width="47" height="26" class="type"><font color="#999999"><%=scroll_bundle.getString("SCROLL_PREVPAGE")%></font></td>
    <%		
			}
			%>
    <%
			if (currpage < totalpages) {
			%>
    <td width="47" height="26" class="type"><a href=<%=nextpage%>?page=<%=(currpage + 1)%>&<%=scrollstr%>><%=scroll_bundle.getString("SCROLL_NEXTPAGE")%></a></td>
    <%	
			}
			else{
			%>
    <td width="47" height="26" class="type"><font color="#999999"><%=scroll_bundle.getString("SCROLL_NEXTPAGE")%></font></td>
    <%		
			}
			%>
    <%
			if (currpage < totalpages) {
			%>
    <td width="47" height="26" class="type"><a href=<%=nextpage%>?page=<%=totalpages%>&<%=scrollstr%>><%=scroll_bundle.getString("SCROLL_LASTPAGE")%></a></td>
    <%	
			}
			else{
			%>
    <td width="49" height="26" class="type"><font color="#999999"><%=scroll_bundle.getString("SCROLL_LASTPAGE")%></font></td>
    <%		
			}
			%>
    <td width="78" height="26" class="type" > <div align="right"><%=scroll_bundle.getString("SCROLL_HINT_PAGEINPUT")%></div>
    </td>
    <td width="43" class="type" ><input type=text name=page size=5 maxlength=5></td>
    <td width="78" class="type" ><div align="left">
        <input name="image" type=image onClick="return f_scroll_check(this.form)" src="/images/go.gif">
      </div></td>
    <td width="61" class="type" >&nbsp;</td>
  </tr>
</tbody>    
</table>
</form>