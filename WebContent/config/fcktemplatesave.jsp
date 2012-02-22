<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.io.File" %>
<%@ page import="java.awt.image.BufferedImage" %>
<%@ page import="com.sun.image.codec.jpeg.JPEGImageEncoder" %>
<%@ page import="com.sun.image.codec.jpeg.JPEGCodec" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    File fcktemplate_image_dir = new java.io.File(Config.USER_DIR+"/fcktemplate/");
    fcktemplate_image_dir.mkdirs();
    
    java.util.Hashtable fields = new java.util.Hashtable();

    DiskFileItemFactory factory = new DiskFileItemFactory();
    factory.setSizeThreshold(8192000);
    factory.setRepository(fcktemplate_image_dir);

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
    
    int tmp_scope =0;
    String act = (String)fields.get("act");
    if(act!=null) act=act.trim();
    String tmp_id = (String)fields.get("template_id");
    String tmp_title = (String)fields.get("template_title");
    String tmp_desc = (String)fields.get("template_desc");
    String s_tmp_scope = (String)fields.get("template_scope");
    String tmp_data = (String)fields.get("template_data");
    boolean bNew = (tmp_id==null || tmp_id.length()==0);
    
    if(tmp_title==null || tmp_title.length()==0 ) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    tmp_title = tmp_title.trim();

    if(tmp_desc==null || tmp_desc.length()==0 ) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    tmp_desc = tmp_desc.trim();

    if( tmp_data == null || tmp_data.length() == 0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    tmp_data = tmp_data;

    if( s_tmp_scope == null)   throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);
    try{tmp_scope = Integer.parseInt( s_tmp_scope );}catch(Exception e){}

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_fcktemplatesave",user.GetLocale(), Config.RES_CLASSLOADER);
    NpsWrapper wrapper = null;
    FCKTemplate aTemplate = null;
    try
    {
        wrapper = new NpsWrapper(user);

        if("1".equals(act))
        {
            //删除模板
            aTemplate =  FCKTemplate.GetTemplate(wrapper.GetContext(),tmp_id);
            aTemplate.Delete(wrapper.GetContext());
            out.print(bundle.getString("FCKTEMPLATESAVE_DELETED"));
            return;
        }

        if(bNew)
        {
            aTemplate = new FCKTemplate(wrapper.GetContext(),tmp_title,tmp_scope,user);
            aTemplate.SetDescription(tmp_desc);
            aTemplate.Save(wrapper.GetContext(),true);
            aTemplate.UpdateHtml(wrapper.GetContext(),tmp_data);
            tmp_id = aTemplate.GetId();
        }
        else
        {
             aTemplate = FCKTemplate.GetTemplate(wrapper.GetContext(),tmp_id);
             aTemplate.SetTitle(tmp_title);
             aTemplate.SetDescription(tmp_desc);
             aTemplate.SetScope(tmp_scope);
             aTemplate.Save(wrapper.GetContext(),false);
             aTemplate.UpdateHtml(wrapper.GetContext(),tmp_data);
        }

       //处理附件
       iter = fileItems.iterator();
       while (iter.hasNext())
       {
         FileItem item = (FileItem) iter.next();

         //忽略其他不是文件域的所有表单信息
         int j=0;
         if (!item.isFormField())
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
           }

           //只处理图片
           if(!(".bmp".equalsIgnoreCase(suffix)
               || ".jpg".equalsIgnoreCase(suffix)
               || ".gif".equalsIgnoreCase(suffix)
               || ".png".equalsIgnoreCase(suffix)
               || ".tif".equalsIgnoreCase(suffix)
              ))
           {
               continue;
           }

           String old_filename = tmp_id+suffix+".src";
           File  old_file = new File(fcktemplate_image_dir,old_filename);

           String new_filename = tmp_id+".jpg";
           File  new_file = new File(fcktemplate_image_dir,new_filename);  

           item.write(old_file);
           //构造Image对象
           BufferedImage src = javax.imageio.ImageIO.read(old_file);
           int i_old_w = src.getWidth(null); //得到源图宽
           int i_old_h = src.getHeight(null);
           float fRatio = -1; //缩小比率

           if(i_old_w>100) fRatio = 100f/(new Integer(i_old_w)).floatValue();

           //计算新图长宽
           int new_w = i_old_w;
           int new_h = i_old_h;

           if(fRatio!=-1)
           {
               new_w = Math.round(i_old_w * fRatio);
               new_h = Math.round(i_old_h * fRatio);
           }

           //绘制缩小后的图
           BufferedImage newimg = new BufferedImage(new_w,
                                                    new_h,
                                                    BufferedImage.TYPE_INT_RGB);
           newimg.getGraphics().drawImage(src, 0, 0, new_w, new_h, null);


           //输出到文件流
           java.io.FileOutputStream out_newimg = new java.io.FileOutputStream(new_file);
           JPEGImageEncoder encoder = JPEGCodec.createJPEGEncoder(out_newimg);
           encoder.encode(newimg);
           try{out_newimg.close();}catch(Exception e){}
           try{old_file.delete();}catch(Exception e){}
         }
       }

        //无论如何都保存成功
        if(wrapper!=null)   wrapper.Commit();

        response.sendRedirect("fcktemplateinfo.jsp?id="+tmp_id);
    }
    catch(Exception e)
    {
        if(wrapper!=null) wrapper.Rollback();
        e.printStackTrace();
        throw e;
    }
    finally
    {
        if(wrapper!=null)   wrapper.Clear();
    }
%>