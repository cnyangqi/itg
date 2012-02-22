package com.nfwl.itg.product;

import java.io.Writer;
import java.sql.Date;
import com.gemway.partner.JUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import com.gemway.partner.JLog;
import com.jado.JadoException;

import java.sql.ResultSet;
import java.util.Vector;

import nps.core.AutoLink;
import nps.exception.NpsException;
import nps.util.DefaultLog;
import oracle.sql.CLOB;

import tools.Pub;

public class SUBPRODUCT{
    
  //select ID,PRDID,NUM from subproduct
  private String id = null;
  private String parentid = null;
  private String prdid = null;
  private Integer num = null;
  
  //addSubProduct(subprd_id,subprd_name,subprd_num,subprd_unit);
  
  private String prd_name = null;
  private String unit = null;
  public String insert(Connection con) throws JadoException{
        PreparedStatement pstmt=null;
        try{
            String sql="insert into subproduct(ID,PRDID,parentid,NUM) values(?,?,?,?) ";
            if(Pub.isEmpty(id)) id= JUtil.createUNID();
            pstmt=con.prepareStatement(sql);
            int pos=1;
            pstmt.setString(pos++,this.id);
            pstmt.setString(pos++,this.prdid);
            pstmt.setString(pos++,this.parentid);
            if(this.num==null) pstmt.setNull(pos++,java.sql.Types.INTEGER);
            else pstmt.setInt(pos++,this.num.intValue());
            pstmt.executeUpdate();
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("写入子产品信息表时出错:",ex);
            throw new JadoException("写入子产品信息表时出错！");
        }
        finally{
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return id;
    }
    /**
     *  根据当前对象的内容往subproduct表中更新一条记录
     * @param con  数据库连接
     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public void update(Connection con) throws JadoException{
        PreparedStatement pstmt=null;
        try{
            String sql="update subproduct set PRDID=? ,parentid=? ,num=?  where id=? ";
            pstmt=con.prepareStatement(sql);
            int pos=1;
            pstmt.setString(pos++,this.prdid);
            pstmt.setString(pos++,this.parentid);
            if(this.num==null) pstmt.setNull(pos++,java.sql.Types.INTEGER);
            else pstmt.setInt(pos++,this.num.intValue());
            pstmt.setString(pos++,this.id);
            pstmt.executeUpdate();
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("更新子产品信息表时出错:",ex);
            throw new JadoException("更新子产品信息表时出错！");
        }
        finally{
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
    }
    /**
     * 根据ID号从subproduct中读取数据
     * @param con 数据库连接
     * @param id 指定的ID号
     * @return 新的subproduct对象
     * @throws JadoException error.jsp页面可以解析的错误对象
     */ 
    public static SUBPRODUCT get(Connection con,String id) throws JadoException {
        PreparedStatement pstmt=null;
        ResultSet rs=null;
        SUBPRODUCT subproduct=null;
        try{
            String sql="select ID,PRDID,parentid,NUM from subproduct where id = ? ";
            pstmt=con.prepareStatement(sql);
            rs=pstmt.executeQuery();
            if(rs.next()){
                subproduct=new SUBPRODUCT();
                subproduct.id=rs.getString("id");
                subproduct.prdid=rs.getString("prdid");
                subproduct.parentid=rs.getString("parentid");
                if(rs.getString("NUM")!=null)  subproduct.num=new Integer(rs.getInt("NUM"));
               
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
        return subproduct;
    }
    
    public static Vector getByParentid(Connection con,String parentid) throws JadoException{
      Vector vsp = null;
      PreparedStatement pstmt=null;
      ResultSet rs=null;
      SUBPRODUCT subproduct=null;
      try{
          String sql="select id,prdid,num,parentid, (select prd_name from article a where a.id = prdid ) prd_name, (select prd_unitname from article a where a.id = prdid ) prd_unitname from subproduct where parentid = ?";
          pstmt=con.prepareStatement(sql);
          pstmt.setString(1, parentid);
          rs=pstmt.executeQuery();
          while(rs.next()){
            if(vsp == null) vsp = new Vector();
              subproduct=new SUBPRODUCT();
              subproduct.id=rs.getString("id");
              subproduct.prdid=rs.getString("prdid");
              subproduct.parentid=rs.getString("parentid");
              if(rs.getString("NUM")!=null)  subproduct.num=new Integer(rs.getInt("NUM"));
              subproduct.prd_name=rs.getString("prd_name");
              subproduct.unit=rs.getString("prd_unitname");
              vsp.add(subproduct);
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
  
      return vsp;
    }
    
    public static void clear(Connection con,String parentid) throws JadoException {
      PreparedStatement pstmt=null;
      try{
          String sql="delete subproduct where parentid=? ";
          pstmt=con.prepareStatement(sql);
          int pos=1;
          pstmt.setString(pos++,parentid);
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
    /**
     * 根据指定ID号删除subproduct表中的数据
     * @param con 数据库连接
     * @param id 指定的ID号

     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public static void delete(Connection con,String id) throws JadoException {
        PreparedStatement pstmt=null;
        try{
            String sql="delete subproduct where id=? ";
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
    
    public String getId(){
        return this.id;
    }



    public Integer getNum() {
      return num;
    }

    public void setNum(Integer num) {
      this.num = num;
    }

    public void setId(String id) {
      this.id = id;
    }
    public String getParentid() {
      return parentid;
    }
    public void setParentid(String parentid) {
      this.parentid = parentid;
    }
    public String getPrdid() {
      return prdid;
    }
    public void setPrdid(String prdid) {
      this.prdid = prdid;
    }
    public String getPrd_name() {
      return prd_name;
    }
    public void setPrd_name(String prd_name) {
      this.prd_name = prd_name;
    }
    public String getUnit() {
      return unit;
    }
    public void setUnit(String unit) {
      this.unit = unit;
    }

   
}
