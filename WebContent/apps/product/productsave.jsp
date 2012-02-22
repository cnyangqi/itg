<%@ page contentType="text/html; charset=UTF-8" errorPage="/error.jsp" %>
<%@ page import="nps.core.*" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="nps.exception.NpsException" %>
<%@ page import="nps.exception.ErrorHelper" %>
<%@ page import="nps.extra.trade.Product" %>
<%@ page import="nps.extra.trade.ProductLanguage" %>
<%@ page import="java.util.*" %>
<%@ page import="nps.extra.trade.ProductAttach" %>
<%@ include file = "/include/header.jsp" %>
<%!
    java.util.Hashtable fields = new java.util.Hashtable();
    java.util.Hashtable fields_multi = new java.util.Hashtable();

    public String GetField(String field_name)
    {
        if(fields.containsKey(field_name))  return (String)fields.get(field_name);
        if(fields_multi.containsKey(field_name))
        {
            List list = (List)fields_multi.get(field_name);
            if(list!=null && !list.isEmpty())  return (String)list.get(0);
        }

        return null;
    }

    public List GetFields(String field_name)
    {
        if(fields_multi.containsKey(field_name))
        {
            return (List)fields_multi.get(field_name);
        }

        if(fields.containsKey(field_name))
        {
            List ret = new ArrayList(1);
            ret.add(fields.get(field_name));
            return ret;
        }

        return null;
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    ResourceBundle bundle = ResourceBundle.getBundle("langs.app_productsave",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);

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
          if(fields_multi.containsKey(item.getFieldName()))
          {
              List list = (List)fields_multi.get(item.getFieldName());
              list.add(item.getString("UTF-8"));
          }
          else if(fields.containsKey(item.getFieldName()))
          {
              List list = new ArrayList(10);
              list.add(item.getString("UTF-8"));
              fields_multi.put(item.getFieldName(),list);
              fields.remove(item.getFieldName());
          }
          else
          {
              fields.put(item.getFieldName(),item.getString("UTF-8"));
          }
      }
    }

    String id=GetField("id");//如果为null，将在保存时使用序列生成ID号
    if(id!=null) id=id.trim();

    int act=0; //默认保存处理，//0保存 1删除
    try
    {
       act=Integer.parseInt(GetField("act"));
    }
    catch(Exception e1)
    {
    }

    boolean bNew = false;
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
        top = tree.GetTopic("28");
        if(top==null) throw new NpsException(ErrorHelper.SYS_NOTOPIC);
        
        if(id==null || id.length()==0)
        {
            bNew = true;

            id = Product.GenerateProductId(wrapper.GetContext());
            product = new Product(wrapper.GetContext(),
                                  id,
                                  GetField("name"),
                                  user);

            //设置创建人信息
            product.SetCreator(user.GetName(),user.GetDeptName(),user.GetUnitName());
        }
        else
        {
            product = Product.GetProduct(wrapper.GetContext(),id,top);
            if(!user.IsSysAdmin())
            {
                //只能管理本单位的产品
                if(!user.GetUnitId().equals(product.GetUnitID()))
                   throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);
            }

            //删除产品
            if(act==1)
            {
                if(product!=null) product.Delete();

                out.println(product.GetName()+bundle.getString("PRODUCT_HINT_DELETED"));
                return;
            }

            //处理待删除附件
            String del_att_id = GetField("del_att_id");
            if(del_att_id!=null && del_att_id.length()>0)
            {
                product.DeleteAttach(del_att_id);
            }

            product.SetName(GetField("name"));
            product.SetUpdater(user);
        }

        //保存本地化信息
        product.ClearLocalInfo();
        List langs = ProductLanguage.GetKnownLanguages();
        for(Object obj:langs)
        {
            Locale lang = (Locale)obj;
            String field_suffix = lang.toString();
            Product.LocalInfo local = product.new LocalInfo(lang);

            local.SetName(GetField("name_"+field_suffix));
            local.SetCode(GetField("code_"+field_suffix));
            local.SetCategory(GetField("category_"+field_suffix));
            local.SetOrigin(GetField("origin_"+field_suffix));
            local.SetProducer(GetField("producer_"+field_suffix));
            local.SetExporter(GetField("exporter_"+field_suffix));
            local.SetBrand(GetField("brand_"+field_suffix));
            local.SetMaterial(GetField("material_"+field_suffix));
            local.SetProductSize(GetField("product_size_"+field_suffix));
            local.SetProductWeight(GetField("product_weight_"+field_suffix));
            local.SetCarton(GetField("carton_"+field_suffix));
            local.SetCartonWeight(GetField("carton_weight_"+field_suffix));
            local.SetPurchasePrice(GetField("purchase_price_"+field_suffix));
            local.SetFob(GetField("fob_"+field_suffix));                        
            local.SetPackageQuantity(GetField("package_quantity_"+field_suffix));
            local.SetLeadTime(GetField("lead_time_"+field_suffix));
            local.SetMoq(GetField("moq_"+field_suffix));
            local.SetProductSpec(GetField("product_spec_"+field_suffix));
            local.SetPackageSpec(GetField("package_spec_"+field_suffix));
            local.SetIntro(GetField("intro_"+field_suffix));

            product.AddLocalInfo(local);
        }

        //处理通知用户
        product.ClearNotifyInfo();

        List uids = GetFields("email_userid");
        List unames = GetFields("email_username");
        List emails = GetFields("email");
        List smss = GetFields("sms");
        if(uids!=null && uids.size()>0)
        {
            int i=0;
            for(Object obj:uids)
            {
                String uid = (String)obj;
                String uname = (String)unames.get(i);
                String email = (String)emails.get(i);
                String sms = (String)smss.get(i);

                Product.NotifyInfo aNotify = product.new NotifyInfo(uid,uname,email,sms);
                product.AddNotifyInfo(aNotify);

                i++;
            }
        }

        //处理新增附件
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

            ProductAttach att = product.AddAttach(name,suffix,j++);
            item.write(att.GetOutputFile());
          }
        }

        product.Save(bNew);

        //发布产品
        if(act==2)
        {
            product.Publish();
        }

        response.sendRedirect("productinfo.jsp?id="+id);
    }
    catch(Exception e)
    {
        if(wrapper!=null) wrapper.Rollback();
        e.printStackTrace();
        throw e;
    }
    finally
    {
        if(product!=null) product.Clear();
        if(wrapper!=null) wrapper.Clear();
    }
%>