<%@ page contentType="text/html; charset=UTF-8" language="java" errorPage="/error.jsp" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="nps.core.Config" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>
<%@ page import="java.awt.image.BufferedImage" %>
<%@ page import="com.sun.image.codec.jpeg.JPEGImageEncoder" %>
<%@ page import="com.sun.image.codec.jpeg.JPEGCodec" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="nps.core.Database" %>

<%@ include file="/include/header.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");    
    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_myinfosave",user.GetLocale(), Config.RES_CLASSLOADER);
    java.util.Hashtable fields = new java.util.Hashtable();

    DiskFileItemFactory factory = new DiskFileItemFactory();
    factory.setSizeThreshold(8192000);
    factory.setRepository(new java.io.File(Config.OUTPATH_ATTACH));

    ServletFileUpload upload = new ServletFileUpload(factory);
    upload.setSizeMax(1024000);
    List fileItems = upload.parseRequest(request);
    Iterator iter = fileItems.iterator();

    //计算文件存放的根路径,request.getRequestURI()=/unit/myinfosave.jsp
    // 存放在/images/face/下
    String strDirPath = new File(application.getRealPath(request.getRequestURI())).getParentFile().getParent();
    String face_name = null;
    while (iter.hasNext())
    {
      FileItem item = (FileItem) iter.next();
      if (item.isFormField())
      {
          fields.put(item.getFieldName(),item.getString("UTF-8"));
      }
      else
      {
            String name = item.getName();
            name=name.substring(name.lastIndexOf("\\")+1);//从全路径中提取文件名

            long size = item.getSize();
            if((name==null||name.equals("")) && size==0)  continue;

            int i = name.lastIndexOf('.');
            String suffix = "";

            if (i >0 && i < name.length()-1)
            {
                suffix = name.substring(i);
                name = name.substring(0,i);
                suffix = suffix.toLowerCase();
            }

            if(!(".JPG".equalsIgnoreCase(suffix) || ".JPEG".equalsIgnoreCase(suffix)
                   || ".BMP".equalsIgnoreCase(suffix) || ".GIF".equalsIgnoreCase(suffix) ))
                continue;

            //写入临时文件            
            File out_path = new File(strDirPath+"/images/face/");
            File temp_face_file  = new File(out_path, user.GetUID()+suffix);
            if(!out_path.exists()) out_path.mkdirs();
            item.write(temp_face_file);

            //绘制缩小后的图，大小为100*100，并统一转换成JPG格式
            BufferedImage src = javax.imageio.ImageIO.read(temp_face_file);
            BufferedImage newimg = new BufferedImage(100, 100 , BufferedImage.TYPE_INT_RGB);
            newimg.getGraphics().drawImage(src, 0, 0, 100, 100, null);

            //输出到文件流
            java.io.FileOutputStream out_newimg = new java.io.FileOutputStream(new File(out_path,user.GetUID()+".jpg"));
            JPEGImageEncoder encoder = JPEGCodec.createJPEGEncoder(out_newimg);
            encoder.encode(newimg);
            try{out_newimg.close();}catch(Exception e){}

            if(!".JPG".equalsIgnoreCase(suffix))  try{temp_face_file.delete();}catch(Exception e){}
            face_name = user.GetUID()+".jpg";
      }
    }

   String name = (String)fields.get("name");
   if(name!=null) name = name.trim();

   String telephone = (String)fields.get("telephone");
   if(telephone!=null) telephone = telephone.trim();

   String email = (String)fields.get("email");
   if(email!=null) email = email.trim();

   String mobile = (String)fields.get("mobile");
   if(mobile!=null) mobile = mobile.trim();

   String fax = (String)fields.get("fax");
   if(fax!=null) fax = fax.trim();

   if(name==null || name.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
   user.SetName(name);
   user.SetTelephone(telephone);
   user.SetEmail(email);
   user.SetMobile(mobile);
   user.SetFax(fax);
   if(face_name!=null)  user.SetFace(face_name);

   Connection conn= null;
   try
   {
       conn = Database.GetDatabase("nps").GetConnection();
       conn.setAutoCommit(false);
       user.Save(conn,false);
       conn.commit();
   }
   finally
   {
       if(conn!=null) try{conn.close();}catch(Exception e1){}
   }


   out.println(bundle.getString("MYINFO_SUCCESS"));
%>
<script type="text/javascript">
    if(parent)
    {
        parent.frames["leftFrame"].window.location.reload(true); 
    }
</script>