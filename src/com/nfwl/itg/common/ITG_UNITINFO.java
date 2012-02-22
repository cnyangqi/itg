package com.nfwl.itg.common;

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
 * 数据库表"单位信息表(ITG_UNITINFO)"的读写类
 * User: 谢智荣
 * Phone: 13858060816
 * Date: 2011-07-08
 */
public class ITG_UNITINFO{
    /**
     * ID号
     */
    private String  id;
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
      Vector vUnit = null;
      
      PreparedStatement pstmt=null;
      ResultSet rs=null;

      try{
          String sql="select ui_id,ui_name,ui_registerid,ui_time   from ITG_UNITINFO ";
          pstmt=con.prepareStatement(sql);
          rs=pstmt.executeQuery();
          while(rs.next()){
            if(vUnit == null)vUnit = new Vector();
            ITG_UNITINFO itg_unitinfo=null;
              itg_unitinfo=new ITG_UNITINFO();
              itg_unitinfo.id=rs.getString("ui_id");
              itg_unitinfo.name=rs.getString("ui_name");
              itg_unitinfo.registerid=rs.getString("ui_registerid");
              itg_unitinfo.time=rs.getDate("ui_time");
              vUnit.add(itg_unitinfo);
          }
      }
      catch(Exception ex){
          if(ex instanceof JadoException) throw (JadoException)ex;
          JLog.getLogger().error("读取单位信息表时出错:",ex);
          throw new JadoException("读取单位信息表时出错！");
      }
      finally{
          if(rs!=null) try{rs.close();}catch(Exception ex){}
          if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
      }
      return vUnit;
      
    }
    
    

    /**
     *  根据当前对象的内容往ITG_UNITINFO表中写入一条新的数据
     * @param con  数据库连接
     * @return  新记录的ID号
     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public String insert(Connection con) throws JadoException{
        PreparedStatement pstmt=null;
        try{
            String sql="insert into ITG_UNITINFO(ui_id,ui_name,ui_registerid,ui_time)" +
                        "values(?,?,?,?) ";
            if(Pub.isEmpty(id)) id= JUtil.createUNID();
            pstmt=con.prepareStatement(sql);
            int pos=1;
            pstmt.setString(pos++,this.id);
            pstmt.setString(pos++,this.name);
            pstmt.setString(pos++,this.registerid);
            if(this.time==null) pstmt.setNull(pos++,java.sql.Types.TIMESTAMP);
            else pstmt.setDate(pos++,this.time);
            pstmt.executeUpdate();
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("写入单位信息表时出错:",ex);
            throw new JadoException("写入单位信息表时出错！");
        }
        finally{
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return id;
    }
    /**
     *  根据当前对象的内容往ITG_UNITINFO表中更新一条记录
     * @param con  数据库连接
     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public void update(Connection con) throws JadoException{
        PreparedStatement pstmt=null;
        try{
            String sql="update ITG_UNITINFO set ui_name=? ,ui_registerid=? ,ui_time=? "+
               " where ui_id=? ";
            pstmt=con.prepareStatement(sql);
            int pos=1;
            pstmt.setString(pos++,this.name);
            pstmt.setString(pos++,this.registerid);
            if(this.time==null) pstmt.setNull(pos++,java.sql.Types.TIMESTAMP);
            else pstmt.setDate(pos++,this.time);
            pstmt.setString(pos++,this.id);
            pstmt.executeUpdate();
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("更新单位信息表时出错:",ex);
            throw new JadoException("更新单位信息表时出错！");
        }
        finally{
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
    }
    /**
     * 根据ID号从ITG_UNITINFO中读取数据
     * @param con 数据库连接
     * @param id 指定的ID号
     * @return 新的ITG_UNITINFO对象
     * @throws JadoException error.jsp页面可以解析的错误对象
     */ 
    public static ITG_UNITINFO get(Connection con,String id) throws JadoException {
        PreparedStatement pstmt=null;
        ResultSet rs=null;
        ITG_UNITINFO itg_unitinfo=null;
        try{
            String sql="select ui_id,ui_name,ui_registerid,ui_time            from ITG_UNITINFO";
            sql+=" where ui_id='"+id+"' ";
            pstmt=con.prepareStatement(sql);
            rs=pstmt.executeQuery();
            if(rs.next()){
                itg_unitinfo=new ITG_UNITINFO();
                itg_unitinfo.id=rs.getString("ui_id");
                itg_unitinfo.name=rs.getString("ui_name");
                itg_unitinfo.registerid=rs.getString("ui_registerid");
                itg_unitinfo.time=rs.getDate("ui_time");
            }
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("读取单位信息表时出错:",ex);
            throw new JadoException("读取单位信息表时出错！");
        }
        finally{
            if(rs!=null) try{rs.close();}catch(Exception ex){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return itg_unitinfo;
    }
    /**
     * 根据指定ID号删除ITG_UNITINFO表中的数据
     * @param con 数据库连接
     * @param id 指定的ID号

     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public static void delete(Connection con,String id) throws JadoException {
        PreparedStatement pstmt=null;
        try{
            String sql="delete ITG_UNITINFO where ui_id=? ";
            pstmt=con.prepareStatement(sql);
            int pos=1;
            pstmt.setString(pos++,id);
            pstmt.executeUpdate();
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("删除单位信息表时出错:",ex);
            throw new JadoException("删除单位信息表时出错！");
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
