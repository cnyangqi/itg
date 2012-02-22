<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.*" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="com.nfwl.itg.product.*" %>
<%@ page import="java.util.*" %>
<%@ page import="nps.event.*" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.app_productsave",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);


    String id=request.getParameter("prd_id");//如果为null，将在保存时使用序列生成ID号
    if(id!=null) id=id.trim();
    //id = "7";
    int act=0; //默认保存处理，//0发布 1修改重发布
    try
    {
       act=Integer.parseInt(request.getParameter("act"));
    }
    catch(Exception e1)
    {
    }
    //act = 2;
    boolean bNew = false;
    ProductArticle particle = null;
    Product product = null;
    NpsWrapper wrapper = null;
    Site site = null;
    TopicTree tree = null;
    Topic top = null;
    Topic old_top = null;

    try
    {
        wrapper = new NpsWrapper(user,"xxzx");
        site = wrapper.GetSite();
        if(site==null) throw new NpsException(ErrorHelper.SYS_NOSITE);
        tree = site.GetTopicTree();
        if(tree==null) throw new NpsException(ErrorHelper.SYS_NOTOPICTREE);
        top = tree.GetTopic("27");
        if(top==null) throw new NpsException(ErrorHelper.SYS_NOTOPIC);
        
        if(id==null || id.length()==0)
        {
          ;
        }
        else
        {
            particle = ProductArticle.GetProduct(wrapper.GetContext(),id,top);
            //删除产品
            if(act==1)
            {
               // if(product!=null) product.Delete();

                //out.println(product.GetName()+bundle.getString("PRODUCT_HINT_DELETED"));
                return;
            }

        }
  
        //product.insert(bNew);
        particle.Publish();
        

        response.sendRedirect("productInfo.jsp?prd_id="+id);
    }
    catch(Exception e)
    {
        if(wrapper!=null) wrapper.Rollback();
        e.printStackTrace();
        throw e;
    }
    finally
    {
        //if(product!=null) product.Clear();
        if(wrapper!=null) wrapper.Clear();
    }
%>