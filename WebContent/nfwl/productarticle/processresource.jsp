<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>

<%@ page import="nps.core.*" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.job.html.ImageHelper" %>
<%@ page import="java.io.File" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    java.util.Hashtable fields = new java.util.Hashtable();

    DiskFileItemFactory factory = new DiskFileItemFactory();
    factory.setSizeThreshold(8192000);
    factory.setRepository(new java.io.File(Config.OUTPATH_ATTACH));

    ServletFileUpload upload = new ServletFileUpload(factory);
    upload.setSizeMax(1024000000);
    List fileItems = upload.parseRequest(request);
    Iterator iter = fileItems.iterator();
    while (iter.hasNext())
    {
      FileItem item = (FileItem) iter.next();
      if (item.isFormField())
      {
          fields.put(item.getFieldName(),item.getString("UTF-8"));
      }
    }

    String siteid = (String)fields.get("siteid");
    if(siteid!=null)  siteid=siteid.trim();
    if(siteid==null || siteid.length()==0) throw new NpsException(ErrorHelper.INPUT_ERROR);

    String func = (String)fields.get("func");
    if(func!=null)  func=func.trim();
    if(func==null || func.length()==0) func = "AddResource";

    String title = (String)fields.get("title");
    if(title!=null && title.length()==0) title=null;

    String sType = (String)fields.get("type");
    int type = -1;
    try{type=Integer.parseInt(sType);}catch(Exception e){}

    String sScope = (String)fields.get("scope");
    int scope = 1;
    try{scope=Integer.parseInt(sScope);}catch(Exception e){}

    int width=-1;
    String s_width = (String)fields.get("img_width");
    try{width=Integer.parseInt(s_width);}catch(Exception e){}

    int height=-1;
    String s_height = (String)fields.get("img_height");
    try{height=Integer.parseInt(s_height);}catch(Exception e){}

    NpsWrapper wrapper = null;
    Resource res = null;

    try
    {
        wrapper = new NpsWrapper(user,siteid);

        iter = fileItems.iterator();
        while (iter.hasNext())
        {
            FileItem item = (FileItem) iter.next();

            int j=0;
            if (!item.isFormField())
            {
              String name = item.getName();
              name = name.substring(name.lastIndexOf("\\")+1);

              long size = item.getSize();
              if((name==null||name.equals("")) && size==0)  continue;

              int i = name.lastIndexOf('.');
              String suffix = "";

              if (i >0 && i < name.length()-1)
              {
                  suffix = name.substring(i);
                  name = name.substring(0,i);
              }

              if(suffix.equalsIgnoreCase(".jsp") || suffix.equalsIgnoreCase(".jspx"))
              {
                  //不允许上传jsp等文件
                  throw new Exception("jsp files not allowed.");
              }

              //创建资源
              if(title==null) title = name;
              String id = Resource.GenerateId(wrapper.GetContext());
              if(   (width>0 || height>0)
                   && (suffix.equalsIgnoreCase(".JPG") || suffix.equalsIgnoreCase(".JPEG")
                        || suffix.equalsIgnoreCase(".BMP")
                        || suffix.equalsIgnoreCase(".GIF") || suffix.equalsIgnoreCase(".PNG") || suffix.equalsIgnoreCase(".TIF")
                  ))
                 {
                        //首先保存临时文件
                        File temp_file = new File(Config.OUTPATH_ATTACH,"resource"+id+suffix);
                        item.write(temp_file);

                        //转换
                        ImageHelper helper = new ImageHelper(temp_file);
                        res = new Resource(wrapper.GetContext(),id,title,".jpg");
                        res.SetCreator(user);

                        res.SetScope(scope);
                        helper.ScaleTo(res.GetOutputFile(),width,height);

                        //删除临时文件
                        try{temp_file.delete();}catch(Exception e){}
                 }
                 else
                 {
                     res = new Resource(wrapper.GetContext(),id,title,suffix);
                     res.SetCreator(user);

                     res.SetScope(scope);

                     if(type!=-1) res.SetType(type);

                     //写入本地文件，并FTP上传
                     item.write(res.GetOutputFile());
                 }

              //生成预览图片
              res.CreatePreviewImage(220,-1);
                
              //FTP上传
              res.Add2Ftp();

              //保存到数据库
              res.Save();
              res.UpdateRemark((String)fields.get("content"));

              //设置Tag
              res.AddTags((String)fields.get("tag"));

              wrapper.Commit();

              //返回
              out.println("<script language=\"javascript\">");

              //通过Javascript返回选定结果
              out.println("if(window.opener)");
              out.println("{");
              out.println("window.opener." + func + "(\""+res.GetId()+"\",\""+res.GetCaption()+res.GetSuffix()+"\",\""+res.GetURL()+"\");");
              out.println("window.opener.focus();");
              out.println("window.opener=null;");
              out.println("window.open('','_self','');");
              out.println("window.close();");
              out.println("}");
              out.println("</script>");
            }
        }
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