package com.nfwl.itg.product;

import java.sql.Date;
import com.gemway.partner.JUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import com.gemway.partner.JLog;
import com.jado.JadoException;

import java.sql.ResultSet;
import java.util.Vector;

import tools.Pub;

/**
 * 数据库表"品牌信息表(ITG_BRANDINFO)"的读写类
 * User: 谢智荣
 * Phone: 13858060816
 * Date: 2011-07-08
 */
public class ITG_BRANDINFO{
    /**
     * ID号
     */
    private String  id;
    /**
     * 编码
     */
    private String  code;
    /**
     * 名称
     */
    private String  name;
    /**
     * 登记人
     */
    private String  registerid;
    /**
     * 登记时间
     */
    private Date  time;

    
    public static Vector getAll(Connection con) throws JadoException{
      Vector vBrand = null;
      PreparedStatement pstmt=null;
      ResultSet rs=null;
      
      try{
          String sql="select bi_id,bi_code,bi_name,bi_registerid,bi_time            from ITG_BRANDINFO";
          pstmt=con.prepareStatement(sql);
          rs=pstmt.executeQuery();
          while(rs.next()){
            if(vBrand == null) vBrand = new Vector();
            ITG_BRANDINFO itg_brandinfo=null;
              itg_brandinfo=new ITG_BRANDINFO();
              itg_brandinfo.id=rs.getString("bi_id");
              itg_brandinfo.code=rs.getString("bi_code");
              itg_brandinfo.name=rs.getString("bi_name");
              itg_brandinfo.registerid=rs.getString("bi_registerid");
              itg_brandinfo.time=rs.getDate("bi_time");
              vBrand.add(itg_brandinfo);
          }
      }
      catch(Exception ex){
          if(ex instanceof JadoException) throw (JadoException)ex;
          JLog.getLogger().error("读取品牌信息表时出错:",ex);
          throw new JadoException("读取品牌信息表时出错！");
      }
      finally{
          if(rs!=null) try{rs.close();}catch(Exception ex){}
          if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
      }
      return vBrand;
    }
    /**
     *  根据当前对象的内容往ITG_BRANDINFO表中写入一条新的数据
     * @param con  数据库连接
     * @return  新记录的ID号
     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public String insert(Connection con) throws JadoException{
        PreparedStatement pstmt=null;
        try{
            String sql="insert into ITG_BRANDINFO(bi_id,bi_code,bi_name,bi_registerid,bi_time)" +
                        "values(?,?,?,?,?) ";
            if(Pub.isEmpty(id)) id= JUtil.createUNID();
            pstmt=con.prepareStatement(sql);
            int pos=1;
            pstmt.setString(pos++,this.id);
            pstmt.setString(pos++,this.code);
            pstmt.setString(pos++,this.name);
            pstmt.setString(pos++,this.registerid);
            if(this.time==null) pstmt.setNull(pos++,java.sql.Types.TIMESTAMP);
            else pstmt.setDate(pos++,this.time);
            pstmt.executeUpdate();
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("写入品牌信息表时出错:",ex);
            throw new JadoException("写入品牌信息表时出错！");
        }
        finally{
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return id;
    }
    /**
     *  根据当前对象的内容往ITG_BRANDINFO表中更新一条记录
     * @param con  数据库连接
     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public void update(Connection con) throws JadoException{
        PreparedStatement pstmt=null;
        try{
            String sql="update ITG_BRANDINFO set bi_code=? ,bi_name=? ,bi_registerid=? ,bi_time=? "+
               " where bi_id=? ";
            pstmt=con.prepareStatement(sql);
            int pos=1;
            pstmt.setString(pos++,this.code);
            pstmt.setString(pos++,this.name);
            pstmt.setString(pos++,this.registerid);
            if(this.time==null) pstmt.setNull(pos++,java.sql.Types.TIMESTAMP);
            else pstmt.setDate(pos++,this.time);
            pstmt.setString(pos++,this.id);
            pstmt.executeUpdate();
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("更新品牌信息表时出错:",ex);
            throw new JadoException("更新品牌信息表时出错！");
        }
        finally{
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
    }
    /**
     * 根据ID号从ITG_BRANDINFO中读取数据
     * @param con 数据库连接
     * @param id 指定的ID号
     * @return 新的ITG_BRANDINFO对象
     * @throws JadoException error.jsp页面可以解析的错误对象
     */ 
    public static ITG_BRANDINFO get(Connection con,String id) throws JadoException {
        PreparedStatement pstmt=null;
        ResultSet rs=null;
        ITG_BRANDINFO itg_brandinfo=null;
        try{
            String sql="select bi_id,bi_code,bi_name,bi_registerid,bi_time            from ITG_BRANDINFO";
            sql+=" where bi_id='"+id+"' ";
            pstmt=con.prepareStatement(sql);
            rs=pstmt.executeQuery();
            if(rs.next()){
                itg_brandinfo=new ITG_BRANDINFO();
                itg_brandinfo.id=rs.getString("bi_id");
                itg_brandinfo.code=rs.getString("bi_code");
                itg_brandinfo.name=rs.getString("bi_name");
                itg_brandinfo.registerid=rs.getString("bi_registerid");
                itg_brandinfo.time=rs.getDate("bi_time");
            }
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("读取品牌信息表时出错:",ex);
            throw new JadoException("读取品牌信息表时出错！");
        }
        finally{
            if(rs!=null) try{rs.close();}catch(Exception ex){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return itg_brandinfo;
    }
    /**
     * 根据指定ID号删除ITG_BRANDINFO表中的数据
     * @param con 数据库连接
     * @param id 指定的ID号

     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public static void delete(Connection con,String id) throws JadoException {
        PreparedStatement pstmt=null;
        try{
            String sql="delete ITG_BRANDINFO where bi_id=? ";
            pstmt=con.prepareStatement(sql);
            int pos=1;
            pstmt.setString(pos++,id);
            pstmt.executeUpdate();
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("删除品牌信息表时出错:",ex);
            throw new JadoException("删除品牌信息表时出错！");
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
    public String getCode(){
        return this.code;
    }

    public void setCode(String code){
        this.code=code;
    }
    public String getName(){
        return this.name;
    }

    public void setName(String name){
        this.name=name;
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
}
