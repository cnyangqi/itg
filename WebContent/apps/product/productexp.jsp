<%@ page language = "java" contentType = "text/html;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="nps.core.Config" %>
<%@ page import="nps.core.Database" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.Locale" %>
<%@ page import="jxl.WorkbookSettings" %>
<%@ page import="jxl.Workbook" %>
<%@ page import="jxl.write.WritableFont" %>
<%@ page import="jxl.write.WritableCellFormat" %>
<%@ page import="jxl.format.Border" %>
<%@ page import="jxl.format.BorderLineStyle" %>
<%@ page import="jxl.write.Label" %>
<%@ page import="oracle.sql.CLOB" %>
<%@ page import="oracle.jdbc.driver.OracleResultSet" %>
<%@ page import="java.io.*" %>
<%@ page import="nps.util.Utils" %>
<%@ page import="nps.compiler.WordLimitWriter" %>

<%@ include file="/include/header.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    Connection con   = null;
    PreparedStatement pstmt   = null;
    ResultSet rs     = null;
    jxl.write.WritableWorkbook wwb = null;
    String sql 		 = null;

    //query parameters
    String qry_name = request.getParameter("qry_name");
    if(qry_name!=null)
    {
        qry_name = qry_name.trim();
        if(qry_name.length()==0) qry_name = null;
    }
    String qry_code = request.getParameter("qry_code");
    if(qry_code!=null)
    {
        qry_code =qry_code.trim();
        if(qry_code.length()==0) qry_code = null;
    }
    String qry_producer = request.getParameter("qry_producer");
    if(qry_producer!=null)
    {
        qry_producer =qry_producer.trim();
        if(qry_producer.length()==0) qry_producer = null;
    }
    String qry_category = request.getParameter("qry_category");
    if(qry_category!=null)
    {
        qry_category =qry_category.trim();
        if(qry_category.length()==0) qry_category = null;
    }
    String qry_status = request.getParameter("qry_status");
    try{Integer.parseInt(qry_status);}catch(Exception e){qry_status = null;}
    String qry_fob_from = request.getParameter("qry_fob_from");
    if(qry_fob_from!=null)
    {
        qry_fob_from =qry_fob_from.trim();
        try{Float.parseFloat(qry_fob_from);}catch(Exception e){qry_fob_from = null;}
    }
    String qry_fob_to = request.getParameter("qry_fob_to");
    if(qry_fob_to!=null)
    {
        qry_fob_to =qry_fob_to.trim();
        try{Float.parseFloat(qry_fob_to);}catch(Exception e){qry_fob_to = null;}
    }
    String qry_moq_from = request.getParameter("qry_moq_from");
    if(qry_moq_from!=null)
    {
        qry_moq_from =qry_moq_from.trim();
        try{Float.parseFloat(qry_moq_from);}catch(Exception e){qry_moq_from = null;}
    }
    String qry_moq_to = request.getParameter("qry_moq_to");
    if(qry_moq_to!=null)
    {
        qry_moq_to =qry_moq_to.trim();
        try{Float.parseFloat(qry_moq_to);}catch(Exception e){qry_moq_to = null;}
    }
    String qry_lead_time_from = request.getParameter("qry_lead_time_from");
    if(qry_lead_time_from!=null)
    {
        qry_lead_time_from =qry_lead_time_from.trim();
        try{Float.parseFloat(qry_lead_time_from);}catch(Exception e){qry_lead_time_from = null;}
    }
    String qry_lead_time_to = request.getParameter("qry_lead_time_to");
    if(qry_lead_time_to!=null)
    {
        qry_lead_time_to =qry_lead_time_to.trim();
        try{Float.parseFloat(qry_lead_time_to);}catch(Exception e){qry_lead_time_to = null;}
    }
    String qry_update_date_from = request.getParameter("qry_update_date_from");
    if(qry_update_date_from!=null)
    {
        qry_update_date_from =qry_update_date_from.trim();
        try{new SimpleDateFormat("yyyyMMdd").parse(qry_update_date_from);}catch(Exception e){qry_update_date_from = null;}
    }
    String qry_update_date_to = request.getParameter("qry_update_date_to");
    if(qry_update_date_to!=null)
    {
        qry_update_date_to =qry_update_date_to.trim();
        try{new SimpleDateFormat("yyyyMMdd").parse(qry_update_date_to);}catch(Exception e){qry_update_date_to = null;}
    }

    boolean exp_name=request.getParameter("exp_name")!=null;
    boolean exp_code=request.getParameter("exp_code")!=null;
    boolean exp_fob=request.getParameter("exp_fob")!=null;
    boolean exp_moq=request.getParameter("exp_moq")!=null;
    boolean exp_lead_time=request.getParameter("exp_lead_time")!=null;
    boolean exp_category=request.getParameter("exp_category")!=null;
    boolean exp_brand=request.getParameter("exp_brand")!=null;
    boolean exp_material=request.getParameter("exp_material")!=null;
    boolean exp_product_size=request.getParameter("exp_product_size")!=null;
    boolean exp_product_weight=request.getParameter("exp_product_weight")!=null;
    boolean exp_product_spec=request.getParameter("exp_product_spec")!=null;
    boolean exp_carton=request.getParameter("exp_carton")!=null;
    boolean exp_carton_weight=request.getParameter("exp_carton_weight")!=null;
    boolean exp_package_quantity=request.getParameter("exp_package_quantity")!=null;
    boolean exp_package_spec=request.getParameter("exp_package_spec")!=null;
    boolean exp_origin=request.getParameter("exp_origin")!=null;
    boolean exp_producer=request.getParameter("exp_producer")!=null;
    boolean exp_exporter=request.getParameter("exp_exporter")!=null;
    boolean exp_purchase_price=request.getParameter("exp_purchase_price")!=null;
    boolean exp_intro=request.getParameter("exp_intro")!=null;

    String lang = request.getParameter("lang");
    Locale local = user.GetLocale();
    if(lang!=null) local = new Locale(lang);

    ResourceBundle bundle = ResourceBundle.getBundle("langs.app_productexp",local, Config.RES_CLASSLOADER);

    response.reset();
    response.setContentType("application/vnd.ms-excel");
    response.setHeader("Content-disposition","inline;filename="+ java.net.URLEncoder.encode(user.GetUnitName(), "UTF-8") +"_"+local.getLanguage()+".xls");

    try
    {
        //只能编辑自己单位的产品信息
        con = Database.GetDatabase("nps").GetConnection();

        //clause string
        int i=1;
        String clause = "";
        if(!user.IsSysAdmin())   clause += " and a.unitid=?";
        if(qry_name!=null) clause += " and (a.name like ? or b.name like ?)";
        if(qry_code!=null) clause += " and b.code like ?";
        if(qry_producer!=null) clause += " and b.producer like ?";
        if(qry_category!=null) clause += " and b.category like ?";
        if(qry_status!=null) clause += " and a.status=?";
        if(qry_fob_from!=null) clause += " and b.fob>=?";
        if(qry_fob_to!=null) clause += " and b.fob<=?";
        if(qry_moq_from!=null) clause += " and b.moq>=?";
        if(qry_moq_to!=null) clause += " and b.moq<=?";
        if(qry_lead_time_from!=null) clause += " and b.lead_time>=?";
        if(qry_lead_time_to!=null) clause += " and b.lead_time<=?";
        if(qry_update_date_from!=null) clause += " and a.update_date>=to_date(?,'yyyymmdd')";
        if(qry_update_date_to!=null) clause += " and a.update_date<=to_date(?,'yyyymmdd')";
 
        sql = "select b.* from FT_PRODUCT a,FT_PRODUCT_"+local.getLanguage()+" b  where a.id=b.id";
        String orderby = " order by a.update_date desc";
        
        pstmt = con.prepareStatement(sql + clause + orderby);


        if(!user.IsSysAdmin())   pstmt.setString(i++,user.GetUnitId());
        if(qry_name!=null)
        {
            pstmt.setString(i++,"%"+qry_name+"%");
            pstmt.setString(i++,"%"+qry_name+"%");
        }
        if(qry_code!=null) pstmt.setString(i++,"%"+qry_code+"%");
        if(qry_producer!=null) pstmt.setString(i++,"%"+qry_producer+"%");
        if(qry_category!=null) pstmt.setString(i++,"%"+qry_category+"%");
        if(qry_status!=null) pstmt.setInt(i++,Integer.parseInt(qry_status));
        if(qry_fob_from!=null) pstmt.setBigDecimal(i++,new BigDecimal(qry_fob_from));
        if(qry_fob_to!=null) pstmt.setBigDecimal(i++,new BigDecimal(qry_fob_to));
        if(qry_moq_from!=null) pstmt.setBigDecimal(i++,new BigDecimal(qry_moq_from));
        if(qry_moq_to!=null) pstmt.setBigDecimal(i++,new BigDecimal(qry_moq_to));
        if(qry_lead_time_from!=null) pstmt.setBigDecimal(i++,new BigDecimal(qry_lead_time_from));
        if(qry_lead_time_to!=null) pstmt.setBigDecimal(i++,new BigDecimal(qry_lead_time_to));
        if(qry_update_date_from!=null) pstmt.setString(i++,qry_update_date_from);
        if(qry_update_date_to!=null) pstmt.setString(i++,qry_update_date_to);
        rs = pstmt.executeQuery();

        WorkbookSettings ws = new WorkbookSettings();
        ws.setLocale(local);

        wwb = Workbook.createWorkbook(response.getOutputStream(),ws);

        jxl.write.WritableSheet sheet = wwb.createSheet(local.toString(),0);

        WritableFont font_header= new WritableFont(WritableFont.TIMES,11,WritableFont.BOLD);
        WritableCellFormat styles_header = new WritableCellFormat(font_header);
        styles_header.setBorder(Border.ALL, BorderLineStyle.THIN);
        styles_header.setAlignment(jxl.format.Alignment.CENTRE);
        styles_header.setVerticalAlignment(jxl.format.VerticalAlignment.CENTRE);
        styles_header.setWrap(true);

        WritableFont font= new WritableFont(WritableFont.TIMES,9);
        WritableCellFormat styles = new WritableCellFormat(font);
        styles.setBorder(Border.ALL, BorderLineStyle.THIN);
        styles.setVerticalAlignment(jxl.format.VerticalAlignment.CENTRE);
        styles.setWrap(true);

        WritableCellFormat styles_intro = new WritableCellFormat(font);
        styles_intro.setBorder(Border.ALL, BorderLineStyle.THIN);
        styles_intro.setVerticalAlignment(jxl.format.VerticalAlignment.CENTRE);
        styles_intro.setWrap(true);


        //1.添加Label对象
        int row = 0;
        int col = 0;
        sheet.setColumnView(col,0);
        sheet.addCell(new Label(col++,row, bundle.getString("PRODUCT_ID"),styles_header));
        if(exp_name)
        {
            sheet.setColumnView(col,20);
            sheet.addCell(new Label(col++,row,bundle.getString("PRODUCT_NAME"),styles_header));
        }
        if(exp_code)
            sheet.addCell(new Label(col++,row,bundle.getString("PRODUCT_CODE"),styles_header));
        if(exp_fob)
           sheet.addCell(new Label(col++,row,bundle.getString("PRODUCT_FOB"),styles_header));
        if(exp_moq)
           sheet.addCell(new Label(col++,row,bundle.getString("PRODUCT_MOQ"),styles_header));
        if(exp_lead_time)
           sheet.addCell(new Label(col++,row,bundle.getString("PRODUCT_LEAD_TIME"),styles_header));
        if(exp_category)
           sheet.addCell(new Label(col++,row,bundle.getString("PRODUCT_CATEGORY"),styles_header));
        if(exp_brand)
           sheet.addCell(new Label(col++,row,bundle.getString("PRODUCT_BRAND"),styles_header));
        if(exp_material)
            sheet.addCell(new Label(col++,row,bundle.getString("PRODUCT_MATERIAL"),styles_header));
        if(exp_product_size)
           sheet.addCell(new Label(col++,row,bundle.getString("PRODUCT_SIZE"),styles_header));
        if(exp_product_weight)
           sheet.addCell(new Label(col++,row,bundle.getString("PRODUCT_WEIGHT"),styles_header));
        if(exp_product_spec)
           sheet.addCell(new Label(col++,row,bundle.getString("PRODUCT_SPEC"),styles_header));
        if(exp_carton)
           sheet.addCell(new Label(col++,row,bundle.getString("PRODUCT_CARTON"),styles_header));
        if(exp_carton_weight)
           sheet.addCell(new Label(col++,row,bundle.getString("PRODUCT_CARTON_WEIGHT"),styles_header));
        if(exp_package_quantity)
           sheet.addCell(new Label(col++,row,bundle.getString("PRODUCT_PACKAGE_QUANTITY"),styles_header));
        if(exp_package_spec)
           sheet.addCell(new Label(col++,row,bundle.getString("PRODUCT_PACKAGE_SPEC"),styles_header));
        if(exp_origin)
           sheet.addCell(new Label(col++,row,bundle.getString("PRODUCT_ORIGIN"),styles_header));
        if(exp_producer)
           sheet.addCell(new Label(col++,row,bundle.getString("PRODUCT_PRODUCER"),styles_header));
        if(exp_exporter)
           sheet.addCell(new Label(col++,row,bundle.getString("PRODUCT_EXPORTER"),styles_header));
        if(exp_purchase_price)
           sheet.addCell(new Label(col++,row,bundle.getString("PRODUCT_PURCHASE_PRICE"),styles_header));
        if(exp_intro)
        {
           sheet.setColumnView(col,100);
           sheet.addCell(new Label(col++,row,bundle.getString("PRODUCT_INTRO"),styles_header));
        }

        while(rs.next())
        {
            col=0;
            row++;

            sheet.addCell(new Label(col++,row, rs.getString("id"),styles));
            if(exp_name)
                sheet.addCell(new Label(col++,row,rs.getString("name"),styles));
            if(exp_code)
                sheet.addCell(new Label(col++,row,rs.getString("code"),styles));
            if(exp_fob)
               sheet.addCell(new jxl.write.Number(col++,row,rs.getFloat("fob"),styles));
            if(exp_moq)
               sheet.addCell(new jxl.write.Number(col++,row,rs.getFloat("moq"),styles));
            if(exp_lead_time)
               sheet.addCell(new jxl.write.Number(col++,row,rs.getFloat("lead_time"),styles));
            if(exp_category)
               sheet.addCell(new Label(col++,row,rs.getString("category"),styles));
            if(exp_brand)
               sheet.addCell(new Label(col++,row,rs.getString("brand"),styles));
            if(exp_material)
                sheet.addCell(new Label(col++,row,rs.getString("material"),styles));
            if(exp_product_size)
               sheet.addCell(new Label(col++,row,rs.getString("product_size"),styles));
            if(exp_product_weight)
               sheet.addCell(new Label(col++,row,rs.getString("product_weight"),styles));
            if(exp_product_spec)
               sheet.addCell(new Label(col++,row,rs.getString("product_spec"),styles));
            if(exp_carton)
               sheet.addCell(new Label(col++,row,rs.getString("carton"),styles));
            if(exp_carton_weight)
               sheet.addCell(new Label(col++,row,rs.getString("carton_weight"),styles));
            if(exp_package_quantity)
               sheet.addCell(new jxl.write.Number(col++,row,rs.getFloat("package_quantity"),styles));
            if(exp_package_spec)
               sheet.addCell(new Label(col++,row,rs.getString("package_spec"),styles));
            if(exp_origin)
               sheet.addCell(new Label(col++,row,rs.getString("origin"),styles));
            if(exp_producer)
               sheet.addCell(new Label(col++,row,rs.getString("producer"),styles));
            if(exp_exporter)
               sheet.addCell(new Label(col++,row,rs.getString("exporter"),styles));
            if(exp_purchase_price)
               sheet.addCell(new jxl.write.Number(col++,row,rs.getFloat("purchase_price"),styles));
            if(exp_intro)
            {
               CLOB clob = ((OracleResultSet)rs).getCLOB("intro");
                 if(clob!=null)
                 {
                     StringWriter so = null;
                     Reader is = null;
                     try
                     {
                         is = clob.getCharacterStream();
                         so = new StringWriter();
                         Utils.GetFlatText(is,new WordLimitWriter(new PrintWriter(so)));
                         sheet.addCell(new Label(col++,row,so.toString(),styles_intro));
                     }
                     catch(Exception e)
                     {
                         throw e;
                     }
                     finally
                     {
                         try{so.close();}catch(Exception e){}
                         try{is.close();}catch(Exception e){}
                     }
                }
            }
        }

        wwb.write();

        response.flushBuffer();
        out.clear();
        out = pageContext.pushBody();        
    }
    catch (Exception ee)
    {
         throw ee;
    }
    finally
    {
        if(wwb!=null) try{wwb.close();}catch(Exception e){}
        if (rs != null) try{ rs.close();}catch(Exception e){}
        if (pstmt != null) try{ pstmt.close();}catch(Exception e){}
        if (con != null)  try{ con.close(); }catch(Exception e){}
    }
 %>