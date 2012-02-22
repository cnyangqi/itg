package com.nfwl.itg.product;

import java.io.Writer;
import java.sql.Date;
import com.gemway.partner.JUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import com.gemway.partner.JLog;
import com.jado.JadoException;

import java.sql.ResultSet;

import nps.core.AutoLink;
import nps.exception.NpsException;
import nps.util.DefaultLog;
import oracle.sql.CLOB;

import tools.Pub;

/**
 * 数据库表"产品信息表(ITG_PRODUCT)"的读写类
 * User: 谢智荣
 * Phone: 13858060816
 * Date: 2011-07-08
 */
public class ITG_PRODUCT{
    /**
     * ID号
     */
    private String  id;
    /**
     * 商品名称
     */
    private String  name;
    /**
     * 商品类别
     */
    private String  psid;
    /**
     * 商品类别名称
     */
    private String  psname;
    /**
     * 商品编号
     */
    private String  code;
    /**
     * 新鲜程度
     */
    private Integer  newlevel;
    /**
     * 市场价格
     */
    private Double  marketprice;
    /**
     * 想购价
     */
    private Double  localprice;
    /**
     * 积分
     */
    private Integer  point;
    /**
     * 品牌ID
     */
    private String  brandid;
    /**
     * 品牌名称
     */
    private String  brandname;
    /**
     * 单位ID
     */
    private String  unitid;
    /**
     * 单位名称
     */
    private String  unitname;
    /**
     * 规格
     */
    private String  spec;
    /**
     * 产地_国家ID
     */
    private String  origincountryid;
    /**
     * 产地_国家名称
     */
    private String  origincountryname;
    /**
     * 产地_省ID
     */
    private String  originprovinceid;
    /**
     * 产地_省名称
     */
    private String  originprovincename;
    /**
     * 运费
     */
    private Double  shipfee;
    /**
     * 详细介绍
     */
    private String  content;
    /**
     * 详细参数
     */
    private String  parameter;
    /**
     * 登记人ID号
     */
    private String  registerid;
    /**
     * 登记时间
     */
    private Date  time;
    /**
     * 最近编辑人
     */
    private String  editorid;
    /**
     * 最近编辑时间
     */
    private Date  edittime;

    public void updateOrigin(Connection con) throws JadoException{
      String sql =  "update itg_product t set( t.prd_origincountryid,t.prd_origincountryname,t.prd_originprovincename ,t.prd_originprovinceid)=(\n" +
        "select z2.ui_id,z2.ui_name,z1.ui_name,z1.ui_id from  itg_zoneinfo z1,itg_zoneinfo z2 where substr(z1.ui_id,0,2) = z2.ui_id and z1.ui_id = t.prd_originprovinceid)\n" + 
        "where t.prd_id = ?";
      

      PreparedStatement pstmt=null;
      try{
          pstmt=con.prepareStatement(sql);
          int pos=1;
          pstmt.setString(pos++,id);
          pstmt.executeUpdate();
      }
      catch(Exception ex){
          if(ex instanceof JadoException) throw (JadoException)ex;
          JLog.getLogger().error("删除产品信息表时出错:",ex);
          throw new JadoException("删除产品信息表时出错！");
      }
      finally{
          if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
      }
  

    }
    
    public void updateParameter(Connection con,String content) throws NpsException {
      if (content == null) return;
      
      PreparedStatement pstmt = null;
      ResultSet rs = null;
      try
      {
        String sql = "select prd_parameter from itg_product where prd_id=? for update";
        pstmt = con.prepareStatement(sql);
        pstmt.setString(1, this.id);
        rs = pstmt.executeQuery();
        if (rs.next())
        {
          CLOB clob = (CLOB)rs.getClob(1);
          clob.truncate(0L);
          Writer writer = clob.setCharacterStream(0L);
          writer.write(content);
         
          writer.flush();
          try { writer.close();
          } catch (Exception e1) {
          }
        }
  
        
      }
      catch (Exception e)
      {
        DefaultLog.error(e);
      }
      finally
      {
        if (rs != null) try { rs.close(); } catch (Exception e1) { }
        if (pstmt != null) try { pstmt.close(); } catch (Exception e1) {
          }
      }
    }
    public void updateContent(Connection con,String content) throws NpsException {
      if (content == null) return;
      
      PreparedStatement pstmt = null;
      ResultSet rs = null;
      try
      {
        String sql = "select prd_content from itg_product where prd_id=? for update";
        pstmt = con.prepareStatement(sql);
        pstmt.setString(1, this.id);
        rs = pstmt.executeQuery();
        if (rs.next())
        {
          CLOB clob = (CLOB)rs.getClob(1);
          clob.truncate(0L);
          Writer writer = clob.setCharacterStream(0L);
          writer.write(content);
         
          writer.flush();
          try { writer.close();
          } catch (Exception e1) {
          }
        }
  
        
      }
      catch (Exception e)
      {
        DefaultLog.error(e);
      }
      finally
      {
        if (rs != null) try { rs.close(); } catch (Exception e1) { }
        if (pstmt != null) try { pstmt.close(); } catch (Exception e1) {
          }
      }
    }
    /**
     *  根据当前对象的内容往ITG_PRODUCT表中写入一条新的数据
     * @param con  数据库连接
     * @return  新记录的ID号
     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public String insert(Connection con) throws JadoException{
        PreparedStatement pstmt=null;
        try{
            String sql="insert into ITG_PRODUCT(prd_id,prd_name,prd_psid,prd_psname,prd_code,prd_newlevel,prd_marketprice,prd_localprice,prd_point,prd_brandid,prd_brandname,prd_unitid,prd_unitname,prd_spec,prd_origincountryid,prd_origincountryname,prd_originprovinceid,prd_originprovincename,prd_shipfee,prd_content,prd_parameter,prd_registerid,prd_time,prd_editorid,prd_edittime)" +
                        "values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) ";
            if(Pub.isEmpty(id)) id= JUtil.createUNID();
            pstmt=con.prepareStatement(sql);
            int pos=1;
            pstmt.setString(pos++,this.id);
            pstmt.setString(pos++,this.name);
            pstmt.setString(pos++,this.psid);
            pstmt.setString(pos++,this.psname);
            pstmt.setString(pos++,this.code);
            if(this.newlevel==null) pstmt.setNull(pos++,java.sql.Types.INTEGER);
            else pstmt.setInt(pos++,this.newlevel.intValue());
            if(this.marketprice==null) pstmt.setNull(pos++,java.sql.Types.DOUBLE);
            else pstmt.setDouble(pos++,this.marketprice.doubleValue());
            if(this.localprice==null) pstmt.setNull(pos++,java.sql.Types.DOUBLE);
            else pstmt.setDouble(pos++,this.localprice.doubleValue());
            if(this.point==null) pstmt.setNull(pos++,java.sql.Types.INTEGER);
            else pstmt.setInt(pos++,this.point.intValue());
            pstmt.setString(pos++,this.brandid);
            pstmt.setString(pos++,this.brandname);
            pstmt.setString(pos++,this.unitid);
            pstmt.setString(pos++,this.unitname);
            pstmt.setString(pos++,this.spec);
            pstmt.setString(pos++,this.origincountryid);
            pstmt.setString(pos++,this.origincountryname);
            pstmt.setString(pos++,this.originprovinceid);
            pstmt.setString(pos++,this.originprovincename);
            if(this.shipfee==null) pstmt.setNull(pos++,java.sql.Types.INTEGER);
            else pstmt.setInt(pos++,this.shipfee.intValue());
            pstmt.setString(pos++,this.content);
            pstmt.setString(pos++,this.parameter);
            pstmt.setString(pos++,this.registerid);
            if(this.time==null) pstmt.setNull(pos++,java.sql.Types.TIMESTAMP);
            else pstmt.setDate(pos++,this.time);
            pstmt.setString(pos++,this.editorid);
            if(this.edittime==null) pstmt.setNull(pos++,java.sql.Types.TIMESTAMP);
            else pstmt.setDate(pos++,this.edittime);
            pstmt.executeUpdate();
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("写入产品信息表时出错:",ex);
            throw new JadoException("写入产品信息表时出错！");
        }
        finally{
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return id;
    }
    /**
     *  根据当前对象的内容往ITG_PRODUCT表中更新一条记录
     * @param con  数据库连接
     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public void update(Connection con) throws JadoException{
        PreparedStatement pstmt=null;
        try{
            String sql="update ITG_PRODUCT set prd_name=? ,prd_psid=? ,prd_psname=? ,prd_code=? ,prd_newlevel=? ,prd_marketprice=? ,prd_localprice=? ,prd_point=? ,prd_brandid=? ,prd_brandname=? ,prd_unitid=? ,prd_unitname=? ,prd_spec=? ,prd_origincountryid=? ,prd_origincountryname=? ,prd_originprovinceid=? ,prd_originprovincename=? ,prd_shipfee=? ,prd_content=? ,prd_parameter=? ,prd_registerid=? ,prd_time=? ,prd_editorid=? ,prd_edittime=? "+
               " where prd_id=? ";
            pstmt=con.prepareStatement(sql);
            int pos=1;
            pstmt.setString(pos++,this.name);
            pstmt.setString(pos++,this.psid);
            pstmt.setString(pos++,this.psname);
            pstmt.setString(pos++,this.code);
            if(this.newlevel==null) pstmt.setNull(pos++,java.sql.Types.INTEGER);
            else pstmt.setInt(pos++,this.newlevel.intValue());
            if(this.marketprice==null) pstmt.setNull(pos++,java.sql.Types.DOUBLE);
            else pstmt.setDouble(pos++,this.marketprice.doubleValue());
            if(this.localprice==null) pstmt.setNull(pos++,java.sql.Types.DOUBLE);
            else pstmt.setDouble(pos++,this.localprice.doubleValue());
            if(this.point==null) pstmt.setNull(pos++,java.sql.Types.INTEGER);
            else pstmt.setInt(pos++,this.point.intValue());
            pstmt.setString(pos++,this.brandid);
            pstmt.setString(pos++,this.brandname);
            pstmt.setString(pos++,this.unitid);
            pstmt.setString(pos++,this.unitname);
            pstmt.setString(pos++,this.spec);
            pstmt.setString(pos++,this.origincountryid);
            pstmt.setString(pos++,this.origincountryname);
            pstmt.setString(pos++,this.originprovinceid);
            pstmt.setString(pos++,this.originprovincename);
            if(this.shipfee==null) pstmt.setNull(pos++,java.sql.Types.DOUBLE);
            else pstmt.setDouble(pos++,this.shipfee.doubleValue());
            pstmt.setString(pos++,this.content);
            pstmt.setString(pos++,this.parameter);
            pstmt.setString(pos++,this.registerid);
            if(this.time==null) pstmt.setNull(pos++,java.sql.Types.TIMESTAMP);
            else pstmt.setDate(pos++,this.time);
            pstmt.setString(pos++,this.editorid);
            if(this.edittime==null) pstmt.setNull(pos++,java.sql.Types.TIMESTAMP);
            else pstmt.setDate(pos++,this.edittime);
            pstmt.setString(pos++,this.id);
            pstmt.executeUpdate();
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("更新产品信息表时出错:",ex);
            throw new JadoException("更新产品信息表时出错！");
        }
        finally{
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
    }
    /**
     * 根据ID号从ITG_PRODUCT中读取数据
     * @param con 数据库连接
     * @param id 指定的ID号
     * @return 新的ITG_PRODUCT对象
     * @throws JadoException error.jsp页面可以解析的错误对象
     */ 
    public static ITG_PRODUCT get(Connection con,String id) throws JadoException {
        PreparedStatement pstmt=null;
        ResultSet rs=null;
        ITG_PRODUCT itg_product=null;
        try{
            String sql="select prd_id,prd_name,prd_psid,prd_psname,prd_code,prd_newlevel,prd_marketprice,prd_localprice,prd_point,prd_brandid,prd_brandname,prd_unitid,prd_unitname,prd_spec,prd_origincountryid,prd_origincountryname,prd_originprovinceid,prd_originprovincename,prd_shipfee,prd_content,prd_parameter,prd_registerid,prd_time,prd_editorid,prd_edittime            from ITG_PRODUCT";
            sql+=" where prd_id='"+id+"' ";
            pstmt=con.prepareStatement(sql);
            rs=pstmt.executeQuery();
            if(rs.next()){
                itg_product=new ITG_PRODUCT();
                itg_product.id=rs.getString("prd_id");
                itg_product.name=rs.getString("prd_name");
                itg_product.psid=rs.getString("prd_psid");
                itg_product.psname=rs.getString("prd_psname");
                itg_product.code=rs.getString("prd_code");
                if(rs.getString("prd_newlevel")!=null)  itg_product.newlevel=new Integer(rs.getInt("prd_newlevel"));
                if(rs.getString("prd_marketprice")!=null)  itg_product.marketprice=new Double(rs.getDouble("prd_marketprice"));
                if(rs.getString("prd_localprice")!=null)  itg_product.localprice=new Double(rs.getDouble("prd_localprice"));
                if(rs.getString("prd_point")!=null)  itg_product.point=new Integer(rs.getInt("prd_point"));
                itg_product.brandid=rs.getString("prd_brandid");
                itg_product.brandname=rs.getString("prd_brandname");
                itg_product.unitid=rs.getString("prd_unitid");
                itg_product.unitname=rs.getString("prd_unitname");
                itg_product.spec=rs.getString("prd_spec");
                itg_product.origincountryid=rs.getString("prd_origincountryid");
                itg_product.origincountryname=rs.getString("prd_origincountryname");
                itg_product.originprovinceid=rs.getString("prd_originprovinceid");
                itg_product.originprovincename=rs.getString("prd_originprovincename");
                if(rs.getString("prd_shipfee")!=null)  itg_product.shipfee=new Double(rs.getDouble("prd_shipfee"));
                itg_product.content=rs.getString("prd_content");
                itg_product.parameter=rs.getString("prd_parameter");
                itg_product.registerid=rs.getString("prd_registerid");
                itg_product.time=rs.getDate("prd_time");
                itg_product.editorid=rs.getString("prd_editorid");
                itg_product.edittime=rs.getDate("prd_edittime");
            }
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("读取产品信息表时出错:",ex);
            throw new JadoException("读取产品信息表时出错！");
        }
        finally{
            if(rs!=null) try{rs.close();}catch(Exception ex){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return itg_product;
    }
    /**
     * 根据指定ID号删除ITG_PRODUCT表中的数据
     * @param con 数据库连接
     * @param id 指定的ID号

     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public static void delete(Connection con,String id) throws JadoException {
        PreparedStatement pstmt=null;
        try{
            String sql="delete ITG_PRODUCT where prd_id=? ";
            pstmt=con.prepareStatement(sql);
            int pos=1;
            pstmt.setString(pos++,id);
            pstmt.executeUpdate();
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("删除产品信息表时出错:",ex);
            throw new JadoException("删除产品信息表时出错！");
        }
        finally{
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
    }    public String getId(){
        return this.id;
    }

    public void setId(String id){
        this.id=id;
    }
    public String getName(){
        return this.name;
    }

    public void setName(String name){
        this.name=name;
    }
    public String getPsid(){
        return this.psid;
    }

    public String getPsname() {
      return psname;
    }

    public void setPsname(String psname) {
      this.psname = psname;
    }

    public void setPsid(String psid){
        this.psid=psid;
    }
    public String getCode(){
        return this.code;
    }

    public void setCode(String code){
        this.code=code;
    }
    public Integer getNewlevel(){
        return this.newlevel;
    }

    public void setNewlevel(Integer newlevel){
        this.newlevel=newlevel;
    }
    public Double getMarketprice(){
        return this.marketprice;
    }

    public void setMarketprice(Double marketprice){
        this.marketprice=marketprice;
    }
    public Double getLocalprice(){
        return this.localprice;
    }

    public void setLocalprice(Double localprice){
        this.localprice=localprice;
    }
    public Integer getPoint(){
        return this.point;
    }

    public void setPoint(Integer point){
        this.point=point;
    }
    public String getBrandid(){
        return this.brandid;
    }

    public void setBrandid(String brandid){
        this.brandid=brandid;
    }
    public String getBrandname(){
        return this.brandname;
    }

    public void setBrandname(String brandname){
        this.brandname=brandname;
    }
    public String getUnitid(){
        return this.unitid;
    }

    public void setUnitid(String unitid){
        this.unitid=unitid;
    }
    public String getUnitname(){
        return this.unitname;
    }

    public void setUnitname(String unitname){
        this.unitname=unitname;
    }
    public String getSpec(){
        return this.spec;
    }

    public void setSpec(String spec){
        this.spec=spec;
    }
    public String getOrigincountryid(){
        return this.origincountryid;
    }

    public void setOrigincountryid(String origincountryid){
        this.origincountryid=origincountryid;
    }
    public String getOrigincountryname(){
        return this.origincountryname;
    }

    public void setOrigincountryname(String origincountryname){
        this.origincountryname=origincountryname;
    }
    public String getOriginprovinceid(){
        return this.originprovinceid;
    }

    public void setOriginprovinceid(String originprovinceid){
        this.originprovinceid=originprovinceid;
    }
    public String getOriginprovincename(){
        return this.originprovincename;
    }

    public void setOriginprovincename(String originprovincename){
        this.originprovincename=originprovincename;
    }
    public Double getShipfee(){
        return this.shipfee;
    }

    public void setShipfee(Double shipfee){
        this.shipfee=shipfee;
    }
    public String getContent(){
        return this.content;
    }

    public void setContent(String content){
        this.content=content;
    }
    public String getParameter(){
        return this.parameter;
    }

    public void setParameter(String parameter){
        this.parameter=parameter;
    }
    public String getRegisterid(){
        return this.registerid;
    }

    public void setRegisterid(String registerid){
        this.registerid=registerid;
    }
    public Date getTime(){
        return this.time;
    }

    public void setTime(Date time){
        this.time=time;
    }
    public String getEditorid(){
        return this.editorid;
    }

    public void setEditorid(String editorid){
        this.editorid=editorid;
    }
    public Date getEdittime(){
        return this.edittime;
    }

    public void setEdittime(Date edittime){
        this.edittime=edittime;
    }
}
