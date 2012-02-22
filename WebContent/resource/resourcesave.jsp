<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>

<%@ page import="nps.core.*" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.job.html.ImageHelper" %>
<%@ page import="java.io.File" %>
<%@ page import="java.net.URL" %>

<%@ include file = "/include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    ResourceBundle bundle = ResourceBundle.getBundle("langs.jsp_resourcesave",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);

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

    boolean bNew = false;
    String id = (String)fields.get("id");
    if(id==null || id.length()==0) bNew = true;
    
    String siteid = (String)fields.get("siteid");
    if(siteid!=null) siteid=siteid.trim();
    if(siteid==null || siteid.length()==0) throw new NpsException(ErrorHelper.INPUT_ERROR);

    String title = (String)fields.get("title");
    if(title==null || title.length()==0) throw new NpsException(ErrorHelper.INPUT_ERROR);

    String sType = (String)fields.get("type");
    int type = -1;
    try{type=Integer.parseInt(sType);}catch(Exception e){}

    String sScope = (String)fields.get("scope");
    int scope = 1;
    try{scope=Integer.parseInt(sScope);}catch(Exception e){}

    String sAct = (String)fields.get("act");
    int act = 0;
    try{act=Integer.parseInt(sAct);}catch(Exception e){}

    String sLocally = (String)fields.get("is_local");
    boolean bLocally = "0".equals(sLocally);
    
    String url = null;
    boolean bDownload = false;
    String url_filename = null;
    URL u_url = null;
    if(!bLocally)
    {
        url = (String)fields.get("url");
        bDownload = "0".equals(fields.get("bdownload"));

        if(url!=null && url.length()>0)
        {
            //校验URL是否合法
            try
            {
                u_url = new URL(url);
            }
            catch(Exception e)
            {
                throw new NpsException("URL="+url,ErrorHelper.INPUT_ERROR);
            }

            url_filename = u_url.getFile();
            if(url_filename==null || url_filename.length()==0 || "/".equals(url_filename))
            {
                throw new NpsException("URL="+url,ErrorHelper.INPUT_ERROR);
            }
        }
    }

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

        if(bNew)
        {
            //如果上传的是本地文件
            if(bLocally)
            {
                iter = fileItems.iterator();
                while (iter.hasNext())
                {
                    FileItem item = (FileItem) iter.next();
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
                      id = Resource.GenerateId(wrapper.GetContext());
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

                       res.Add2Ftp();

                       //保存到数据库
                       res.Save();
                       res.UpdateRemark((String)fields.get("content"));

                       //设置Tag
                       res.AddTags((String)fields.get("tag"));

                       wrapper.Commit();

                       response.sendRedirect("resource.jsp?id="+id);
                       break;
                    }
                }

                return;
            }
            else //远程URL路径
            {
                if(url==null || url.length()==0) throw new NpsException(ErrorHelper.INPUT_NOTENOUGH);

                //创建资源
                //开始分析文件名，注意，文件名中可能包括?开头的query string
                String name = null;
                String suffix = "";
                int pos_question = url_filename.indexOf('?');
                int pos_dot = -1;
                if(pos_question>-1)
                    pos_dot = url_filename.lastIndexOf('.',pos_question);
                else
                    pos_dot = url_filename.lastIndexOf('.');

                if(pos_dot>-1)
                {
                    name = url_filename.substring(0,pos_dot);
                    if(pos_question>-1)
                        suffix = url_filename.substring(pos_dot,pos_question);
                    else
                        suffix = url_filename.substring(pos_dot);
                }
                else
                {
                    if(pos_question>-1)
                        name = url_filename.substring(0,pos_question);
                    else
                        name = url_filename;
                }

                if("/".equals(name)) throw new NpsException("URL="+url,ErrorHelper.INPUT_ERROR);
                if(suffix.equalsIgnoreCase(".jsp") || suffix.equalsIgnoreCase(".jspx"))
                {
                    //不允许上传jsp等文件
                    throw new NpsException("jsp file not allowed",ErrorHelper.SYS_UNKOWN);
                }

                //创建附件
                id = Resource.GenerateId(wrapper.GetContext());
                if(bDownload) //需要自动下载的
                {
                    if(   (width>0 || height>0)
                       && (suffix.equalsIgnoreCase(".JPG") || suffix.equalsIgnoreCase(".JPEG")
                           || suffix.equalsIgnoreCase(".BMP")
                          || suffix.equalsIgnoreCase(".GIF") || suffix.equalsIgnoreCase(".PNG") || suffix.equalsIgnoreCase(".TIF")
                     ))
                    {
                        //首先保存临时文件
                        File temp_file = new File(Config.OUTPATH_ATTACH,"resource"+id+suffix);
                        res = new Resource(wrapper.GetContext(),id,title,".jpg");
                        res.Download(u_url,temp_file);

                        //转换
                        ImageHelper helper = new ImageHelper(temp_file);
                        res.SetCreator(user);

                        res.SetScope(scope);
                        helper.ScaleTo(res.GetOutputFile(),width,height);

                        //删除临时文件
                        try{temp_file.delete();}catch(Exception e){}
                    }
                    else
                    {
                        //无需转换，直接另存就可以了
                        res = new Resource(wrapper.GetContext(),id,title,suffix);
                        res.SetCreator(user);

                        res.SetScope(scope);

                        if(type!=-1) res.SetType(type);

                        //写入本地文件，并FTP上传
                        res.Download(u_url);
                    }
                    
                    //生成预览图片
                    res.CreatePreviewImage(220,-1);

                    res.Add2Ftp();

                    //保存到数据库
                    res.Save();
                    res.UpdateRemark((String)fields.get("content"));

                    //设置Tag
                    res.AddTags((String)fields.get("tag"));

                    wrapper.Commit();

                    response.sendRedirect("resource.jsp?id="+id);
                }
                else
                {
                    //直接引用该地址，是一个外部链接
                    res = new Resource(wrapper.GetContext(),id,title,suffix);
                    res.SetCreator(user);

                    res.SetScope(scope);

                    if(type!=-1) res.SetType(type);

                    res.SetURL(url);

                    //保存到数据库
                    res.Save();
                    res.UpdateRemark((String)fields.get("content"));

                    //设置Tag
                    res.AddTags((String)fields.get("tag"));

                    wrapper.Commit();

                    response.sendRedirect("resource.jsp?id="+id);
                }
                return;
            }
        }

        //不是新建
        res = new Resource(wrapper.GetContext(),id);
        switch(act)
        {
            case 0: //保存
                res.SetName(title);
                res.SetScope(scope);
                if(type!=-1) res.SetType(type);
                res.SetSite(wrapper.GetSite(siteid));

                //本地文件
                if(bLocally)
                {
                    iter = fileItems.iterator();
                    while (iter.hasNext())
                    {
                        FileItem item = (FileItem) iter.next();
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
                              continue;
                          }
                            
                          if(   (width>0 || height>0)
                             && (suffix.equalsIgnoreCase(".JPG") || suffix.equalsIgnoreCase(".JPEG")
                                || suffix.equalsIgnoreCase(".BMP")
                                || suffix.equalsIgnoreCase(".GIF") || suffix.equalsIgnoreCase(".PNG") || suffix.equalsIgnoreCase(".TIF")
                           ))
                         {
                            //首先保存临时文件
                            File temp_file = new File(Config.OUTPATH_ATTACH,"resource"+res.GetId()+suffix);
                            item.write(temp_file);

                            //转换
                            res.SetSuffix(".jpg");
                            res.SetType(Resource.IMAGE);
                            ImageHelper helper = new ImageHelper(temp_file);
                            helper.ScaleTo(res.GetOutputFile(),width,height);

                            //删除临时文件
                            try{temp_file.delete();}catch(Exception e){}
                         }
                         else
                         {
                              //如果有新附件传入，我们需要重新生成文件
                              if(type==-1) res.SetType(Resource.GuessType(suffix));

                              res.SetSuffix(suffix);
                              item.write(res.GetOutputFile());
                         }

                         //清除外部链接
                         res.SetURL(null);

                         //生成预览图片
                         res.CreatePreviewImage(220,-1);

                         res.Add2Ftp();
                       }
                    }
                }
                else if(url!=null && url.length()>0) //远程服务器地址
                {
                    //上传了一个新的地址，需要替换
                    //开始分析文件名，注意，文件名中可能包括?开头的query string
                    String name = null;
                    String suffix = "";
                    int pos_question = url_filename.indexOf('?');
                    int pos_dot = -1;
                    if(pos_question>-1)
                        pos_dot = url_filename.lastIndexOf('.',pos_question);
                    else
                        pos_dot = url_filename.lastIndexOf('.');

                    if(pos_dot>-1)
                    {
                        name = url_filename.substring(0,pos_dot);
                        if(pos_question>-1)
                            suffix = url_filename.substring(pos_dot,pos_question);
                        else
                            suffix = url_filename.substring(pos_dot);
                    }
                    else
                    {
                        if(pos_question>-1)
                            name = url_filename.substring(0,pos_question);
                        else
                            name = url_filename;
                    }

                    if("/".equals(name)) throw new NpsException("URL="+url,ErrorHelper.INPUT_ERROR);
                    if(suffix.equalsIgnoreCase(".jsp") || suffix.equalsIgnoreCase(".jspx"))
                    {
                        //不允许上传jsp等文件
                        throw new NpsException("jsp not allowed", ErrorHelper.SYS_UNKOWN);
                    }

                    if(bDownload) //需要自动下载的
                    {
                        if(   (width>0 || height>0)
                           && (suffix.equalsIgnoreCase(".JPG") || suffix.equalsIgnoreCase(".JPEG")
                               || suffix.equalsIgnoreCase(".BMP")
                              || suffix.equalsIgnoreCase(".GIF") || suffix.equalsIgnoreCase(".PNG") || suffix.equalsIgnoreCase(".TIF")
                         ))
                        {
                            //首先保存临时文件
                            File temp_file = new File(Config.OUTPATH_ATTACH,"resource"+id+suffix);
                            res.Download(u_url,temp_file);

                            //转换
                            res.SetSuffix(".jpg");
                            res.SetType(Resource.IMAGE);
                            ImageHelper helper = new ImageHelper(temp_file);
                            helper.ScaleTo(res.GetOutputFile(),width,height);

                            //删除临时文件
                            try{temp_file.delete();}catch(Exception e){}

                            //生成预览图片
                            res.CreatePreviewImage(220,-1);
                        }
                        else
                        {
                              //如果有新附件传入，我们需要重新生成文件
                              if(type==-1) res.SetType(Resource.GuessType(suffix));

                              res.SetSuffix(suffix);

                              //写入本地文件，并FTP上传
                              res.Download(u_url);
                        }

                        //清除外部链接
                        res.SetURL(null);
                    }
                    else
                    {
                        //删除原有文件
                        res.DeleteFile();

                        //设置外部链接
                        res.SetURL(url);
                    }
                }
                //保存到数据库
                res.Save();
                res.UpdateRemark((String)fields.get("content"));
                break;
            case 1://删除
                res.Delete(user);
                wrapper.Commit();
                out.println(res.GetTitle()+" "+bundle.getString("RES_HINT_DELETED"));
                return;
            case 2: //添加Tags
                res.AddTags((String)fields.get("tag"));
                break;
            case 3://发布到某个栏目
                String site_id = (String)fields.get("p_site_id");
                String top_id = (String)fields.get("p_top_id");
                Site site = wrapper.GetSite(site_id);
                if(site==null) throw new NpsException(ErrorHelper.SYS_NOSITE);
                Topic topic = site.GetTopicTree().GetTopic(top_id);
                res.PublishTo(topic,user);
                break;
        }

        wrapper.Commit();
        response.sendRedirect("resource.jsp?id="+id);
    }
    catch(Exception e)
    {
        wrapper.Rollback();
        throw e;
    }
    finally
    {
        if(res!=null) res.Clear();
        if(wrapper!=null) wrapper.Clear();
    }
%>