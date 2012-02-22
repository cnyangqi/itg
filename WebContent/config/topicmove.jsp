<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ include file="/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    String site_fromid = request.getParameter("site_fromid");
    if(site_fromid!=null) site_fromid = site_fromid.trim();

    String top_fromid = request.getParameter("top_fromid");
    if(top_fromid!=null) top_fromid = top_fromid.trim();

    String site_toid = request.getParameter("site_toid");
    if(site_toid!=null) site_toid = site_toid.trim();

    String top_toid = request.getParameter("top_toid");
    if(top_toid!=null) top_toid = top_toid.trim();

    int move_mode = 0;
    String s_move_mode = request.getParameter("move_mode"); //0复制 1移动
    if(s_move_mode!=null) s_move_mode = s_move_mode.trim();    
    try{move_mode=Integer.parseInt(s_move_mode);}catch(Exception e){}

    if( site_fromid == null || site_fromid.length() == 0 || site_toid == null || site_toid.length() == 0)
        throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    if(s_move_mode==null || s_move_mode.length()==0)
        throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    if(!(user.IsSiteAdmin(site_fromid) && user.IsSiteAdmin(site_toid)))
        throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_topicmove",user.GetLocale(), Config.RES_CLASSLOADER);    
    NpsWrapper wrapper = null;
    try
    {
         wrapper = new NpsWrapper(user,site_fromid);
         wrapper.SetErrorHandler(response.getWriter());
         wrapper.SetLineSeperator("\n<br>\n");
        
         Site site_from = wrapper.GetSite(site_fromid);
         if(site_from==null) throw new NpsException(ErrorHelper.SYS_NOSITE);
        
         TopicTree topictree_src = site_from.GetTopicTree();
         if(topictree_src==null) throw new NpsException(ErrorHelper.SYS_NOTOPICTREE);

         Site site_to = wrapper.GetSite(site_toid);
         if(site_to==null) throw new NpsException(ErrorHelper.SYS_NOSITE);

         TopicTree topictree_dest = site_to.GetTopicTree();
         if(topictree_dest==null) throw new NpsException(ErrorHelper.SYS_NOTOPICTREE);
        
         switch(move_mode)
         {
             case 0:  //复制            
                 topictree_src.CopyTo(wrapper.GetContext(),top_fromid,topictree_dest,top_toid);
                 break;
             case 1:  //移动
                 topictree_src.MoveTo(wrapper.GetContext(),top_fromid,topictree_dest,top_toid);
                 break;
         }

        wrapper.Commit();
        out.println(bundle.getString("TOPICMOVE_SUCCESS"));
%>
            <script type="text/javascript">
                if(parent)
                {
                    parent.frames["topicList"].window.location.reload();
                }
            </script>
<%
    }
    catch(Exception e)
    {
        wrapper.Rollback();
        throw e;
    }
    finally
    {
        if(wrapper!=null) wrapper.Clear();
    }    
%>