<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.core.NpsWrapper" %>
<%@ page import="nps.core.Site" %>
<%@ page import="java.io.File" %>
<%@ page import="nps.util.Utils" %>
<%@ include file="/include/header.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    DiskFileItemFactory factory = new DiskFileItemFactory();
    factory.setSizeThreshold(8192000);
    factory.setRepository(new java.io.File(Config.TEMP_ROOTPATH));

    ServletFileUpload upload = new ServletFileUpload(factory);
    upload.setSizeMax(1024000000);
    List fileItems = upload.parseRequest(request);
    Iterator iter = fileItems.iterator();
    File temp_file = null;

    while (iter.hasNext())
    {
      FileItem item = (FileItem) iter.next();
      if (!item.isFormField())
      {
          String name = item.getName();
          if(name.endsWith(".zip"))
          {
              //只接收.zip类型文件
              while(temp_file==null)
              {
                  temp_file = new File(Config.TEMP_ROOTPATH + Utils.CreateUNID());
                  if(temp_file.exists()) temp_file = null;
              }

              item.write(temp_file);
              break;  
          }
      }
    }

    if(temp_file!=null)
    {
        NpsWrapper wrapper = null;
        try
        {
            wrapper = new NpsWrapper(user);
            Site site = wrapper.Import(temp_file);

            if(user.IsSysAdmin() || site.IsOwner(user.GetId()))
                user.Add2OwnSite(site);

            if(user.GetUnitId().equals(site.GetUnit().GetId()))
                user.Add2UnitSite(site);

            response.sendRedirect("sites.jsp");
         }
        catch(Exception e)
        {
            wrapper.Rollback();
            throw e;
        }
        finally
        {
             if(wrapper!=null) wrapper.Clear();
             temp_file.delete();
        }
    }    
%>