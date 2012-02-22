<%@ page contentType="text/html;charset=UTF-8" language="java" errorPage="/error.jsp"%>

<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.core.Site" %>
<%@ page import="nps.core.Topic" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="nps.util.Utils" %>

<%@ include file="/include/header.jsp" %>

<script type="text/javascript">
<%
    request.setCharacterEncoding("UTF-8");

    String table_name = request.getParameter("t");
    if( table_name == null) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    String siteid = request.getParameter("siteid");
    if( siteid == null) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    siteid = siteid.trim();

    String topid = request.getParameter("topid");
    if(topid!=null) topid = topid.trim();

    NpsWrapper wrapper = null;
    Site site = null;
    try
    {
        wrapper = new NpsWrapper(user,siteid);
        site = wrapper.GetSite();
        if(site==null) throw new NpsException(ErrorHelper.SYS_NOSITE);

        //校验权限
        if(!user.IsSysAdmin() && !user.IsSiteAdmin(siteid))
        {
            Topic topic = site.GetTopicTree().GetTopic(topid);
            if(topic==null) throw new NpsException(ErrorHelper.SYS_NOTOPIC);
            if(!topic.IsOwner(user.GetId())) throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);
        }

        String sql = "select column_name,comments from user_col_comments where table_name=?";
        PreparedStatement pstmt = wrapper.GetContext().GetConnection().prepareStatement(sql);
        pstmt.setString(1,table_name.toUpperCase());
        ResultSet rs = pstmt.executeQuery();
        while(rs.next())
        {
            out.println("parent.opener.f_addsolrfield(\"" + rs.getString("column_name") + "\",\"" + Utils.Null2Empty(rs.getString("comments")) + "\");");
        }
    }
    finally
    {
       if(wrapper!=null) wrapper.Clear();
    }
%>
    window.close();
</script>    