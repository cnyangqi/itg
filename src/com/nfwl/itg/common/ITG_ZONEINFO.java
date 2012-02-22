package com.nfwl.itg.common;

import java.sql.Date;
import com.gemway.partner.JUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import com.gemway.partner.JLog;
import com.jado.JadoException;

import java.sql.ResultSet;

import tools.Pub;

/**
 * 数据库表"地区信息表(ITG_ZONEINFO)"的读写类
 * User: 谢智荣
 * Phone: 13858060816
 * Date: 2011-07-08
 */
public class ITG_ZONEINFO{
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
    public static boolean Contains(String [] as,String s){
      if(JUtil.convertNull(s).equals(""))return false;;
      if(as == null||as.length<1) return false;
      for(int i=0;i<as.length;i++){
        if(s.equals(as[i])) return true;
      }
      return false;
      
    }
    /**
     * 获取javascript代码
     * @param con
     * @return
     *    var tree_1 = new WebFXTree(0,'全体员工','000000000',"ONLY_LEAF_ELEMENT");
          var childNode_01 = new WebFXTreeItem('软件开发部','01');
          tree_1.add(childNode_01);
          
          var childNode_0111 = new WebFXTreeItem('管清鹏','0111');
          childNode_01.add(childNode_0111);
          CreateTreeSelect('TaxTrade',tree_1,'管清鹏','0111',200);

     */
    public static String getJSString(Connection con,String treeName,String zone,String defaultName,String defaultValue,String selectType){
      StringBuffer sb = new StringBuffer(1024);
      sb.append("var "+treeName+" = new WebFXTree(0,'全部','',\""+selectType+"\");\n");
      
      String sql = " select ui_id, ui_name, ui_registerid, ui_time from itg_zoneinfo where 1=1   order by ui_id  ";
      PreparedStatement pstmt = null;
      ResultSet rs = null;
      try {
        pstmt = con.prepareStatement(sql);
        rs = pstmt.executeQuery();
        String idvalue = null;
        while (rs.next()){
          idvalue = rs.getString("ui_id");
          sb.append("var childNode_"+idvalue+" = new WebFXTreeItem('"+rs.getString("ui_name")+"','"+idvalue+"');\n");
          
         
          if(idvalue.length()<4){
            sb.append(treeName+".add(childNode_"+idvalue+");");
          }else{
            sb.append("childNode_"+idvalue.substring(0,idvalue.length()-2)+".add(childNode_"+idvalue+");\n");
          }
          
          
        }
        sb.append("CreateTreeSelect('"+zone+"',"+treeName+",'"+defaultName+"','"+defaultValue+"',200);\n");
        
       
      } catch (SQLException e) {
        // TODO Auto-generated catch block
        e.printStackTrace();
      }
      
      return sb.toString();
    }
    /**
     *  根据当前对象的内容往ITG_ZONEINFO表中写入一条新的数据
     * @param con  数据库连接
     * @return  新记录的ID号
     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public String insert(Connection con) throws JadoException{
        PreparedStatement pstmt=null;
        try{
            String sql="insert into ITG_ZONEINFO(ui_id,ui_name,ui_registerid,ui_time)" +
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
            JLog.getLogger().error("写入地区信息表时出错:",ex);
            throw new JadoException("写入地区信息表时出错！");
        }
        finally{
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return id;
    }
    /**
     *  根据当前对象的内容往ITG_ZONEINFO表中更新一条记录
     * @param con  数据库连接
     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public void update(Connection con) throws JadoException{
        PreparedStatement pstmt=null;
        try{
            String sql="update ITG_ZONEINFO set ui_name=? ,ui_registerid=? ,ui_time=? "+
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
            JLog.getLogger().error("更新地区信息表时出错:",ex);
            throw new JadoException("更新地区信息表时出错！");
        }
        finally{
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
    }
    /**
     * 根据ID号从ITG_ZONEINFO中读取数据
     * @param con 数据库连接
     * @param id 指定的ID号
     * @return 新的ITG_ZONEINFO对象
     * @throws JadoException error.jsp页面可以解析的错误对象
     */ 
    public static ITG_ZONEINFO get(Connection con,String id) throws JadoException {
        PreparedStatement pstmt=null;
        ResultSet rs=null;
        ITG_ZONEINFO itg_zoneinfo=null;
        try{
            String sql="select ui_id,ui_name,ui_registerid,ui_time            from ITG_ZONEINFO";
            sql+=" where ui_id='"+id+"' ";
            pstmt=con.prepareStatement(sql);
            rs=pstmt.executeQuery();
            if(rs.next()){
                itg_zoneinfo=new ITG_ZONEINFO();
                itg_zoneinfo.id=rs.getString("ui_id");
                itg_zoneinfo.name=rs.getString("ui_name");
                itg_zoneinfo.registerid=rs.getString("ui_registerid");
                itg_zoneinfo.time=rs.getDate("ui_time");
            }
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("读取地区信息表时出错:",ex);
            throw new JadoException("读取地区信息表时出错！");
        }
        finally{
            if(rs!=null) try{rs.close();}catch(Exception ex){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return itg_zoneinfo;
    }
    /**
     * 根据指定ID号删除ITG_ZONEINFO表中的数据
     * @param con 数据库连接
     * @param id 指定的ID号

     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public static void delete(Connection con,String id) throws JadoException {
        PreparedStatement pstmt=null;
        try{
            String sql="delete ITG_ZONEINFO where ui_id=? ";
            pstmt=con.prepareStatement(sql);
            int pos=1;
            pstmt.setString(pos++,id);
            pstmt.executeUpdate();
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("删除地区信息表时出错:",ex);
            throw new JadoException("删除地区信息表时出错！");
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
