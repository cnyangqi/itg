package com.nfwl.itg.dddw;
import java.sql.Date;
import com.gemway.partner.JUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import com.gemway.partner.JLog;
import com.jado.JadoException;

import java.sql.ResultSet;

import tools.Pub;

/**
 * 数据库表"定点单位(ITG_FIXEDPOINT)"的读写类
 * User: 谢智荣
 * Phone: 13858060816
 * Date: 2011-07-06
 */
public class ITG_FIXEDPOINT{
    /**
     * ID号
     */
    private String  id;
    /**
     * 单位名称
     */
    private String  name;
    /**
     * 地址
     */
    private String  address;
    /**
     * 联系人
     */
    private String  linker;
    /**
     * 联系电话
     */
    private String  phone;
    /**
     * EMAIL地址
     */
    private String  email;
    /**
     * 邮编
     */
    private String  postcode;
    /**
     * 单位代码
     */
    private String  code;
    /**
     * 有效标识 1是 0否
     */
    private Integer  valid;
    /**
     * 登记人
     */
    private String  registerid;
    /**
     * 登记时间
     */
    private Date  time;
    
    private String delday ;

    /**
     *  根据当前对象的内容往ITG_FIXEDPOINT表中写入一条新的数据
     * @param con  数据库连接
     * @return  新记录的ID号
     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public String insert(Connection con) throws JadoException{
        PreparedStatement pstmt=null;
        try{
            String sql="insert into ITG_FIXEDPOINT(fp_id,fp_name,fp_address,fp_delday,fp_linker,fp_phone,fp_email,fp_postcode,fp_code,fp_valid,fp_registerid,fp_time)" +
                        "values(?,?,?,?,?,?,?,?,?,?,?,?) ";
            if(Pub.isEmpty(id)) id= JUtil.createUNID();
            pstmt=con.prepareStatement(sql);
            int pos=1;
            pstmt.setString(pos++,this.id);
            pstmt.setString(pos++,this.name);
            pstmt.setString(pos++,this.address);
            pstmt.setString(pos++,this.delday);
            pstmt.setString(pos++,this.linker);
            pstmt.setString(pos++,this.phone);
            pstmt.setString(pos++,this.email);
            pstmt.setString(pos++,this.postcode);
            pstmt.setString(pos++,this.code);
            if(this.valid==null) pstmt.setNull(pos++,java.sql.Types.INTEGER);
            else pstmt.setInt(pos++,this.valid.intValue());
            pstmt.setString(pos++,this.registerid);
            if(this.time==null) pstmt.setNull(pos++,java.sql.Types.TIMESTAMP);
            else pstmt.setDate(pos++,this.time);
            pstmt.executeUpdate();
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("写入定点单位时出错:",ex);
            throw new JadoException("写入定点单位时出错！");
        }
        finally{
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return id;
    }
    /**
     *  根据当前对象的内容往ITG_FIXEDPOINT表中更新一条记录
     * @param con  数据库连接
     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public void update(Connection con) throws JadoException{
        PreparedStatement pstmt=null;
        try{
            String sql="update ITG_FIXEDPOINT set fp_name=? ,fp_address=? ,fp_delday=? ,fp_linker=? ,fp_phone=? ,fp_email=? ,fp_postcode=? ,fp_code=? ,fp_valid=? ,fp_registerid=? ,fp_time=? "+
               " where fp_id=? ";
            pstmt=con.prepareStatement(sql);
            int pos=1;
            pstmt.setString(pos++,this.name);
            pstmt.setString(pos++,this.address);
            pstmt.setString(pos++,this.delday);
            pstmt.setString(pos++,this.linker);
            pstmt.setString(pos++,this.phone);
            pstmt.setString(pos++,this.email);
            pstmt.setString(pos++,this.postcode);
            pstmt.setString(pos++,this.code);
            if(this.valid==null) pstmt.setNull(pos++,java.sql.Types.INTEGER);
            else pstmt.setInt(pos++,this.valid.intValue());
            pstmt.setString(pos++,this.registerid);
            if(this.time==null) pstmt.setNull(pos++,java.sql.Types.TIMESTAMP);
            else pstmt.setDate(pos++,this.time);
            pstmt.setString(pos++,this.id);
            pstmt.executeUpdate();
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("更新定点单位时出错:",ex);
            throw new JadoException("更新定点单位时出错！");
        }
        finally{
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
    }
    /**
     * 根据ID号从ITG_FIXEDPOINT中读取数据
     * @param con 数据库连接
     * @param id 指定的ID号
     * @return 新的ITG_FIXEDPOINT对象
     * @throws JadoException error.jsp页面可以解析的错误对象
     */ 
    public static ITG_FIXEDPOINT get(Connection con,String id) throws JadoException {
        PreparedStatement pstmt=null;
        ResultSet rs=null;
        ITG_FIXEDPOINT itg_fixedpoint=null;
        try{
            String sql="select fp_id,fp_name,fp_address,fp_delday,fp_linker,fp_phone,fp_email,fp_postcode,fp_code,fp_valid,fp_registerid,fp_time            from ITG_FIXEDPOINT";
            sql+=" where fp_id='"+id+"' ";
            pstmt=con.prepareStatement(sql);
            rs=pstmt.executeQuery();
            if(rs.next()){
                itg_fixedpoint=new ITG_FIXEDPOINT();
                itg_fixedpoint.id=rs.getString("fp_id");
                itg_fixedpoint.name=rs.getString("fp_name");
                itg_fixedpoint.address=rs.getString("fp_address");
                itg_fixedpoint.delday=rs.getString("fp_delday");
                itg_fixedpoint.linker=rs.getString("fp_linker");
                itg_fixedpoint.phone=rs.getString("fp_phone");
                itg_fixedpoint.email=rs.getString("fp_email");
                itg_fixedpoint.postcode=rs.getString("fp_postcode");
                itg_fixedpoint.code=rs.getString("fp_code");
                if(rs.getString("fp_valid")!=null)  itg_fixedpoint.valid=new Integer(rs.getInt("fp_valid"));
                itg_fixedpoint.registerid=rs.getString("fp_registerid");
                itg_fixedpoint.time=rs.getDate("fp_time");
            }
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("读取定点单位时出错:",ex);
            throw new JadoException("读取定点单位时出错！");
        }
        finally{
            if(rs!=null) try{rs.close();}catch(Exception ex){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return itg_fixedpoint;
    }
    /**
     * 根据指定ID号删除ITG_FIXEDPOINT表中的数据
     * @param con 数据库连接
     * @param id 指定的ID号

     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public static void delete(Connection con,String id) throws JadoException {
        PreparedStatement pstmt=null;
        try{
            String sql="delete ITG_FIXEDPOINT where fp_id=? ";
            pstmt=con.prepareStatement(sql);
            int pos=1;
            pstmt.setString(pos++,id);
            pstmt.executeUpdate();
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("删除定点单位时出错:",ex);
            throw new JadoException("删除定点单位时出错！");
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
    public String getAddress(){
        return this.address;
    }

    public void setAddress(String address){
        this.address=address;
    }
    public String getLinker(){
        return this.linker;
    }

    public void setLinker(String linker){
        this.linker=linker;
    }
    public String getPhone(){
        return this.phone;
    }

    public void setPhone(String phone){
        this.phone=phone;
    }
    public String getEmail(){
        return this.email;
    }

    public void setEmail(String email){
        this.email=email;
    }
    public String getPostcode(){
        return this.postcode;
    }

    public void setPostcode(String postcode){
        this.postcode=postcode;
    }
    public String getCode(){
        return this.code;
    }

    public void setCode(String code){
        this.code=code;
    }
    public Integer getValid(){
        return this.valid;
    }

    public void setValid(Integer valid){
        this.valid=valid;
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
  public String getDelday(){
      return this.delday;
  }
  
  public void setDelday(String delday){
      this.delday=delday;
  }
}
