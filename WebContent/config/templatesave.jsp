<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.*" %>
<%@ page import="java.util.Date" %>
<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    if(!(user.IsSysAdmin() || user.IsLocalAdmin()))
       throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);
    
    int tmp_type = 0;
    int tmp_scope =0;
    String act = request.getParameter("act");
    if(act!=null) act=act.trim();
    String site_id = request.getParameter("site_id") ;
    if(site_id!=null) site_id = site_id.trim();
    String tmp_id =  request.getParameter("template_id");
    String tmp_name = request.getParameter("template_name");
    String s_tmp_scope = request.getParameter("template_scope");
    String tmp_data0 = request.getParameter("template_data_0");
    String tmp_data1 = request.getParameter("template_data_1");
    String tmp_data2 = request.getParameter("template_data_2");
    String tmp_outFileName = request.getParameter("template_outfilename") ;
    String templateType = request.getParameter("template_type") ;
    String tmp_suffix = request.getParameter("template_suffix");
    String s_tmp_currenttemplate = request.getParameter("template_current");
    int tmp_currenttemplate = 0;
    try{tmp_currenttemplate=Integer.parseInt(s_tmp_currenttemplate);}catch(Exception e){}
    String template_name0 = request.getParameter("name0");
    String template_name1 = request.getParameter("name1");
    String template_name2 = request.getParameter("name2");

    boolean bNew = (tmp_id==null || tmp_id.length()==0);

    if(tmp_name==null || tmp_name.length()==0 ) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    tmp_name = tmp_name.trim();

    if( (tmp_data0 == null || tmp_data0.length() == 0) && (tmp_data1 == null || tmp_data1.length() == 0) && (tmp_data2 == null || tmp_data2.length() == 0))throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

    if(tmp_outFileName!=null) tmp_outFileName = tmp_outFileName.trim();

    if(bNew)
    {
        if( templateType == null )  throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
        try{tmp_type = Integer.parseInt( templateType );}catch(Exception e){}
    }

    if( s_tmp_scope == null)   throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    try{tmp_scope = Integer.parseInt( s_tmp_scope );}catch(Exception e){}

    //适用范围为指定站点的，需要site_id
    if(tmp_scope==2)
    {
        if(site_id.length() == 0)   throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    }
    else
    {
        //其他情况清空site_id
        site_id = null;    
    }

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_templatesave",user.GetLocale(), Config.RES_CLASSLOADER);
    NpsWrapper wrapper = null;
    TemplateBase aTemplate = null;
    try
    {
        wrapper = new NpsWrapper(user);
        wrapper.SetErrorHandler(response.getWriter());
        wrapper.SetLineSeperator("<br>\n");
        if(!bNew)
        {
            aTemplate =  wrapper.GetTemplate(tmp_id);
            //校验权限
            //仅在以下情况下可以修改
            //1.系统管理员
            //2.作者
            //3.使用范围为指定站点且当前用户是该站点的管理员
            if(  user.IsSysAdmin()
              || user.GetId().equals(aTemplate.GetCreatorID())
              || (aTemplate.GetScope()==2 && user.IsLocalAdmin() && user.IsSiteAdmin(aTemplate.GetSiteId()))
              )
            {

            }
            else
            {
                throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);
            }
        }

        if("1".equals(act))
        {
            //删除模板
            aTemplate.Delete(wrapper.GetContext());
            out.println("<br>");
            out.print(bundle.getString("TEMPLATESAVE_DELETED"));
            return;
        }

        if("2".equals(act))
        {
            //重新编译模板
            if(aTemplate instanceof ArticleTemplate)
            {
                wrapper.GenerateArticleClassThenCompile((ArticleTemplate)aTemplate);
            }
            else
            {
                wrapper.GeneratePageClassThenCompile((PageTemplate)aTemplate);
            }
            out.println("<br>");
            out.print(bundle.getString("TEMPLATESAVE_COMPILED"));
            return;
        }

        if("3".equals(act))
        {
            //重新发布文章或页面
            if(aTemplate instanceof ArticleTemplate)
            {
                wrapper.GenerateArticle((ArticleTemplate)aTemplate);
            }
            else
            {
                wrapper.GeneratePages((PageTemplate)aTemplate);
            }
            out.println("<br>");
            out.print(bundle.getString("TEMPLATESAVE_BUILT"));
            return;
        }

        if(bNew)
        {
            switch(tmp_type)
            {
                case 0: //文章模版
                    aTemplate = wrapper.NewArticleTemplate(tmp_name,user,tmp_scope,site_id,tmp_suffix);
                    aTemplate.SetCreatedate(new Date());
                    aTemplate.SetCurrentTemplateNo(tmp_currenttemplate);
                    tmp_id = aTemplate.GetId();

                    if(template_name0!=null && template_name0.length()==0) template_name0 = null;
                    if(tmp_data0.length()==0 && "template0".equals(template_name0)) template_name0 = null;
                    if(template_name1!=null && template_name1.length()==0) template_name1 = null;
                    if(tmp_data1.length()==0 && "template1".equals(template_name1)) template_name1 = null;
                    if(template_name2!=null && template_name2.length()==0) template_name2 = null;
                    if(tmp_data2.length()==0 && "template2".equals(template_name2)) template_name2 = null;

                    aTemplate.SetTemplateName(0,template_name0);
                    aTemplate.SetTemplateName(1,template_name1);
                    aTemplate.SetTemplateName(2,template_name2);

                    aTemplate.Save(wrapper.GetContext(),true);
                    
                    aTemplate.UpdateTemplate(wrapper.GetContext(),0,tmp_data0);
                    aTemplate.UpdateTemplate(wrapper.GetContext(),1,tmp_data1);
                    aTemplate.UpdateTemplate(wrapper.GetContext(),2,tmp_data2);

                    //无论如何都保存成功
                    if(wrapper!=null)   wrapper.Commit();
                    
                    //保存后编译
                    wrapper.GenerateArticleClassThenCompile((ArticleTemplate)aTemplate);
                    break;
                case 2: //页面模版
                    aTemplate = wrapper.NewPageTemplate(tmp_name,tmp_outFileName,user,tmp_scope,site_id);
                    aTemplate.SetCreatedate(new Date());
                    aTemplate.SetCurrentTemplateNo(tmp_currenttemplate);
                    tmp_id = aTemplate.GetId();

                    if(tmp_data0.length()==0 && "template0".equals(template_name0)) template_name0 = null;
                    if(tmp_data1.length()==0 && "template1".equals(template_name1)) template_name1 = null;
                    if(tmp_data2.length()==0 && "template2".equals(template_name2)) template_name2 = null;

                    aTemplate.SetTemplateName(0,template_name0);
                    aTemplate.SetTemplateName(1,template_name1);
                    aTemplate.SetTemplateName(2,template_name2);

                    aTemplate.Save(wrapper.GetContext(),true);
                    
                    aTemplate.UpdateTemplate(wrapper.GetContext(),0,tmp_data0);
                    aTemplate.UpdateTemplate(wrapper.GetContext(),1,tmp_data1);
                    aTemplate.UpdateTemplate(wrapper.GetContext(),2,tmp_data2);

                    //无论如何都保存成功
                    if(wrapper!=null)   wrapper.Commit();                    

                    //保存后重新编译
                    wrapper.GeneratePageClassThenCompile((PageTemplate)aTemplate);
                    break;
            }
        }
        else
        {
             if(aTemplate instanceof ArticleTemplate)
             {
                 ArticleTemplate aArticleTemplate = (ArticleTemplate)aTemplate;
                 aArticleTemplate =  wrapper.GetArticleTemplate(tmp_id);
                 aArticleTemplate.SetScope(tmp_scope);
                 aArticleTemplate.SetSiteId(site_id);
                 aArticleTemplate.SetName(tmp_name);
                 aArticleTemplate.SetCurrentTemplateNo(tmp_currenttemplate);
                 aArticleTemplate.SetSuffix(tmp_suffix);

                 if(tmp_data0.length()==0 && "template0".equals(template_name0)) template_name0 = null;
                 if(tmp_data1.length()==0 && "template1".equals(template_name1)) template_name1 = null;
                 if(tmp_data2.length()==0 && "template2".equals(template_name2)) template_name2 = null;

                 aArticleTemplate.SetTemplateName(0,template_name0);
                 aArticleTemplate.SetTemplateName(1,template_name1);
                 aArticleTemplate.SetTemplateName(2,template_name2);

                 aArticleTemplate.Save(wrapper.GetContext(),false);
                 aArticleTemplate.UpdateTemplate(wrapper.GetContext(),0,tmp_data0);
                 aArticleTemplate.UpdateTemplate(wrapper.GetContext(),1,tmp_data1);
                 aArticleTemplate.UpdateTemplate(wrapper.GetContext(),2,tmp_data2);

                 //无论如何都保存成功
                 if(wrapper!=null)   wrapper.Commit();                    

                 //保存后编译
                 wrapper.GenerateArticleClassThenCompile(aArticleTemplate);
             }
             else
             {
                 PageTemplate aPageTemplate = (PageTemplate)aTemplate;
                 aPageTemplate.SetScope(tmp_scope);
                 aPageTemplate.SetSiteId(site_id);
                 aPageTemplate.SetName(tmp_name);
                 aTemplate.SetCurrentTemplateNo(tmp_currenttemplate);
                 aPageTemplate.SetOutputFileName(tmp_outFileName);

                 if(tmp_data0.length()==0 && "template0".equals(template_name0)) template_name0 = null;
                 if(tmp_data1.length()==0 && "template1".equals(template_name1)) template_name1 = null;
                 if(tmp_data2.length()==0 && "template2".equals(template_name2)) template_name2 = null;

                 aPageTemplate.SetTemplateName(0,template_name0);
                 aPageTemplate.SetTemplateName(1,template_name1);
                 aPageTemplate.SetTemplateName(2,template_name2);

                 aPageTemplate.Save(wrapper.GetContext(),false);
                 aTemplate.UpdateTemplate(wrapper.GetContext(),0,tmp_data0);
                 aTemplate.UpdateTemplate(wrapper.GetContext(),1,tmp_data1);
                 aTemplate.UpdateTemplate(wrapper.GetContext(),2,tmp_data2);

                 //无论如何都保存成功
                 if(wrapper!=null)   wrapper.Commit();

                 //保存后重新编译
                 wrapper.GeneratePageClassThenCompile(aPageTemplate);
             }
        }
        response.sendRedirect("templateinfo.jsp?id="+tmp_id);
    }
    catch(Exception e)
    {
        if(wrapper!=null) wrapper.Rollback();
        e.printStackTrace();
        throw e;
    }
    finally
    {
        if(aTemplate!=null) aTemplate.Clear();
        if(wrapper!=null)   wrapper.Clear();
        wrapper = null;
    }
%>  