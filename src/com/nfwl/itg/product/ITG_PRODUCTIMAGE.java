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
 * 数据库表"产品图片信息表(ITG_PRODUCTIMAGE)"的读写类
 * User: 谢智荣
 * Phone: 13858060816
 * Date: 2011-07-08
 */
public class ITG_PRODUCTIMAGE{
    /**
     * ID号
     */
    private String  id;
    /**
     * 产品ID号
     */
    private String  prdid;
    /**
     * 文件名 文件的实际名字，服务器上不以改名字存储，而是 ID号.扩展名
     */
    private String  filename;
    
    /**
     * 文件存储路径
     */
    private String  filepath;
    /**
     * 扩展名
     */
    
    private String  ext;
    /**
     * 次序
     */
    private Integer  pos;
    /**
     * 登记人
     */
    private String  registerid;
    /**
     * 登记时间
     */
    private Date  time;
    
    
    
    
    public static Vector getByPrdid(Connection con,String prdid) throws JadoException{
      Vector vipm = null;
      PreparedStatement pstmt=null;
      ResultSet rs=null;
      
      try{
          String sql="select pi_id,pi_prdid,pi_filename,pi_filepath,pi_ext,pi_pos,pi_registerid,pi_time      from ITG_PRODUCTIMAGE where pi_prdid=? order by pi_pos ";
          pstmt=con.prepareStatement(sql);
          pstmt.setString(1, prdid);
          rs=pstmt.executeQuery();
          while(rs.next()){
            if(vipm == null)vipm = new Vector();
            ITG_PRODUCTIMAGE itg_productimage=null;
              itg_productimage=new ITG_PRODUCTIMAGE();
              itg_productimage.id=rs.getString("pi_id");
              itg_productimage.prdid=rs.getString("pi_prdid");
              itg_productimage.filename=rs.getString("pi_filename");
              itg_productimage.filepath=rs.getString("pi_filepath");
              itg_productimage.ext=rs.getString("pi_ext");
              if(rs.getString("pi_pos")!=null)  itg_productimage.pos=new Integer(rs.getInt("pi_pos"));
              itg_productimage.registerid=rs.getString("pi_registerid");
              itg_productimage.time=rs.getDate("pi_time");
              vipm.add(itg_productimage);
          }
      }
      catch(Exception ex){
          if(ex instanceof JadoException) throw (JadoException)ex;
          JLog.getLogger().error("读取产品图片信息表时出错:",ex);
          throw new JadoException("读取产品图片信息表时出错！");
      }
      finally{
          if(rs!=null) try{rs.close();}catch(Exception ex){}
          if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
      }
  
      return vipm;
      
    }
    

    /**
     *  根据当前对象的内容往ITG_PRODUCTIMAGE表中写入一条新的数据
     * @param con  数据库连接
     * @return  新记录的ID号
     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public String insert(Connection con) throws JadoException{
        PreparedStatement pstmt=null;
        try{
            String sql="insert into ITG_PRODUCTIMAGE(pi_id,pi_prdid,pi_filename,pi_filepath,pi_ext,pi_pos,pi_registerid,pi_time)" +
                        "values(?,?,?,?,?,?,?,?) ";
            if(Pub.isEmpty(id)) id= JUtil.createUNID();
            pstmt=con.prepareStatement(sql);
            int pos=1;
            pstmt.setString(pos++,this.id);
            pstmt.setString(pos++,this.prdid);
            pstmt.setString(pos++,this.filename);
            pstmt.setString(pos++,this.filepath);
            pstmt.setString(pos++,this.ext);
            if(this.pos==null) pstmt.setNull(pos++,java.sql.Types.INTEGER);
            else pstmt.setInt(pos++,this.pos.intValue());
            pstmt.setString(pos++,this.registerid);
            if(this.time==null) pstmt.setNull(pos++,java.sql.Types.TIMESTAMP);
            else pstmt.setDate(pos++,this.time);
            pstmt.executeUpdate();
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("写入产品图片信息表时出错:",ex);
            throw new JadoException("写入产品图片信息表时出错！");
        }
        finally{
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return id;
    }
    /**
     *  根据当前对象的内容往ITG_PRODUCTIMAGE表中更新一条记录
     * @param con  数据库连接
     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public void update(Connection con) throws JadoException{
        PreparedStatement pstmt=null;
        try{
            String sql="update ITG_PRODUCTIMAGE set pi_prdid=? ,pi_filename=? ,pi_filepath=? ,pi_ext=? ,pi_pos=? ,pi_registerid=? ,pi_time=? "+
               " where pi_id=? ";
            pstmt=con.prepareStatement(sql);
            int pos=1;
            pstmt.setString(pos++,this.prdid);
            pstmt.setString(pos++,this.filename);
            pstmt.setString(pos++,this.filepath);
            pstmt.setString(pos++,this.ext);
            if(this.pos==null) pstmt.setNull(pos++,java.sql.Types.INTEGER);
            else pstmt.setInt(pos++,this.pos.intValue());
            pstmt.setString(pos++,this.registerid);
            if(this.time==null) pstmt.setNull(pos++,java.sql.Types.TIMESTAMP);
            else pstmt.setDate(pos++,this.time);
            pstmt.setString(pos++,this.id);
            pstmt.executeUpdate();
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("更新产品图片信息表时出错:",ex);
            throw new JadoException("更新产品图片信息表时出错！");
        }
        finally{
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
    }
    /**
     * 根据ID号从ITG_PRODUCTIMAGE中读取数据
     * @param con 数据库连接
     * @param id 指定的ID号
     * @return 新的ITG_PRODUCTIMAGE对象
     * @throws JadoException error.jsp页面可以解析的错误对象
     */ 
    public static ITG_PRODUCTIMAGE get(Connection con,String id) throws JadoException {
        PreparedStatement pstmt=null;
        ResultSet rs=null;
        ITG_PRODUCTIMAGE itg_productimage=null;
        try{
            String sql="select pi_id,pi_prdid,pi_filename,pi_filepath,pi_ext,pi_pos,pi_registerid,pi_time            from ITG_PRODUCTIMAGE";
            sql+=" where pi_id='"+id+"' ";
            pstmt=con.prepareStatement(sql);
            rs=pstmt.executeQuery();
            if(rs.next()){
                itg_productimage=new ITG_PRODUCTIMAGE();
                itg_productimage.id=rs.getString("pi_id");
                itg_productimage.prdid=rs.getString("pi_prdid");
                itg_productimage.filename=rs.getString("pi_filename");
                itg_productimage.filepath=rs.getString("pi_filepath");
                itg_productimage.ext=rs.getString("pi_ext");
                if(rs.getString("pi_pos")!=null)  itg_productimage.pos=new Integer(rs.getInt("pi_pos"));
                itg_productimage.registerid=rs.getString("pi_registerid");
                itg_productimage.time=rs.getDate("pi_time");
            }
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("读取产品图片信息表时出错:",ex);
            throw new JadoException("读取产品图片信息表时出错！");
        }
        finally{
            if(rs!=null) try{rs.close();}catch(Exception ex){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return itg_productimage;
    }
    /**
     * 根据指定ID号删除ITG_PRODUCTIMAGE表中的数据
     * @param con 数据库连接
     * @param id 指定的ID号

     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public static void delete(Connection con,String id) throws JadoException {
        PreparedStatement pstmt=null;
        try{
            String sql="delete ITG_PRODUCTIMAGE where pi_id=? ";
            pstmt=con.prepareStatement(sql);
            int pos=1;
            pstmt.setString(pos++,id);
            pstmt.executeUpdate();
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("删除产品图片信息表时出错:",ex);
            throw new JadoException("删除产品图片信息表时出错！");
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
    public String getPrdid(){
        return this.prdid;
    }

    public void setPrdid(String prdid){
        this.prdid=prdid;
    }
    public String getFilename(){
      return this.filename;
  }

  public void setFilename(String filename){
      this.filename=filename;
  }
  public String getFilepath(){
    return this.filepath;
}

public void setFilepath(String filepath){
    this.filepath=filepath;
}
    public String getExt(){
        return this.ext;
    }

    public void setExt(String ext){
        this.ext=ext;
    }
    public Integer getPos(){
        return this.pos;
    }

    public void setPos(Integer pos){
        this.pos=pos;
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
