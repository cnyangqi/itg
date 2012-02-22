<%@page import="tools.Pub"%>
<%@page import="java.sql.Date"%>
<%@page import="java.sql.Connection"%>
<%@page import="com.nfwl.itg.product.ITG_PRODUCTIMAGE"%>
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
    
    String func = (String)fields.get("func");
    if(func!=null)  func=func.trim();
    if(func==null || func.length()==0) func = "AddResource";
    
    
    String pi_id = (String)fields.get("pi_id");
    if(pi_id!=null)  pi_id=pi_id.trim();
    

    String prd_id = (String)fields.get("prd_id");
    if(prd_id!=null)  prd_id=prd_id.trim();
    

    String pi_pos = (String)fields.get("pi_pos");
    if(pi_pos!=null)  pi_pos=pi_pos.trim();
    
    String title = (String)fields.get("title");
    if(title!=null && title.length()==0) title=null;


    
//System.out.println(filepath);

  
//"src/com/nfwl/itg/product/ITG_PRODUCTIMAGE.java"
Connection con = null;
ITG_PRODUCTIMAGE pimage = null;
    try
    {
      con = nps.core.Database.GetDatabase("nfwl").GetConnection();
      Date nowDate = Pub.currentDate(con); 
      if(pi_id!=null && pi_id.length()>0){
        pimage = ITG_PRODUCTIMAGE.get(con,pi_id);
      }else{
        pimage = new ITG_PRODUCTIMAGE();
        //pimage.createFilename(request.getRealPath("/"),title,);
      }     
      
      
      String filepath = "prdimages/"+(nowDate.getYear()+1900)+"/"+(nowDate.getMonth()+1)+"/";
      System.out.println(filepath);
      
      java.util.StringTokenizer   st=new   java.util.StringTokenizer(filepath,"/");
      String   path1=st.nextToken()+"/";
      String   path2 =path1;
      while(st.hasMoreTokens())
      {
            path1=st.nextToken()+"/";
            path2+=path1;
            File inbox   =   new File(path2);
            if(!inbox.exists())
                 inbox.mkdir();
      }

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
              if(suffix.equalsIgnoreCase(".JPG") || suffix.equalsIgnoreCase(".JPEG")
                        || suffix.equalsIgnoreCase(".BMP")
                        || suffix.equalsIgnoreCase(".GIF") || suffix.equalsIgnoreCase(".PNG") || suffix.equalsIgnoreCase(".TIF")
                  )
                 {
                        //首先保存临时文件//filepath
                        //File temp_file = new File(Config.OUTPATH_ATTACH,"resource"+id+suffix);
                        
                        pimage.setExt(suffix);
                        pimage.setFilename(title);
                        pimage.setPos(Pub.getInteger(pi_pos));
                        pimage.setPrdid(prd_id);
                        pimage.setRegisterid(user.GetUID());
                        pimage.setTime(Pub.currentDate(con));
                        pimage.setFilepath(filepath);
                        
                        pimage.insert(con);
                        
                        File temp_file = new File(request.getRealPath("/")+filepath,pimage.getId()+suffix);
                        item.write(temp_file);

                       
                 }
                 else
                 {
                     
                 }

             
              //返回
              out.println("<script language=\"javascript\">");

              //通过Javascript返回选定结果
              out.println("if(window.opener)");
              out.println("{");
              out.println("window.opener.location.href=window.opener.location.href;");
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
        throw e;
    }
    finally
    {
      if(con!=null) try{con.close();}catch(Exception e){}
    }
%>