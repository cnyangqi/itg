package com.nfwl.itg.product;

import java.sql.Date;
import com.gemway.partner.JUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import com.gemway.partner.JLog;
import com.jado.JadoException;

import java.sql.ResultSet;
import java.util.Hashtable;
import java.util.Vector;

import tools.Pub;
/**
 * 数据库表"产品分类(ITG_PRODUCTSORT)"的读写类
 * User: 谢智荣
 * Phone: 13858060816
 * Date: 2011-07-08
 */
public class ITG_PRODUCTSORT{
    /**
     * ID号
     */
    private String  id;
    /**
     * 父类ID号
     */
    private String  pid;
    /**
     * 名称
     */
    private String  name;
    /**
     * 排序位置
     */
    private Integer  pos;
    /**
     * 子产品数量 在更新产品信息的时候自动更新本字段数据。
     */
    private Integer  subnum;
    /**
     * 子产品最近更新时间  在更新产品信息的时候自动更新本字段数据。
     */
    private Date  updatetime;
    /**
     * 备注
     */
    private String  memo;
    /**
     * 登记人
     */
    private String  regisgerid;
    /**
     * 登记时间
     */
    private Date  time;

    /**
     *  根据当前对象的内容往ITG_PRODUCTSORT表中写入一条新的数据
     * @param con  数据库连接
     * @return  新记录的ID号
     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public String insert(Connection con) throws JadoException{
        PreparedStatement pstmt=null;
        try{
            String sql="insert into ITG_PRODUCTSORT(ps_id,ps_pid,ps_name,ps_pos,ps_subnum,ps_updatetime,ps_memo,ps_regisgerid,ps_time)" +
                        "values(?,?,?,?,?,?,?,?,?) ";
            if(Pub.isEmpty(id)) id= JUtil.createUNID();
            pstmt=con.prepareStatement(sql);
            int pos=1;
            pstmt.setString(pos++,this.id);
            pstmt.setString(pos++,this.pid);
            pstmt.setString(pos++,this.name);
            if(this.pos==null) pstmt.setNull(pos++,java.sql.Types.INTEGER);
            else pstmt.setInt(pos++,this.pos.intValue());
            if(this.subnum==null) pstmt.setNull(pos++,java.sql.Types.INTEGER);
            else pstmt.setInt(pos++,this.subnum.intValue());
            if(this.updatetime==null) pstmt.setNull(pos++,java.sql.Types.TIMESTAMP);
            else pstmt.setDate(pos++,this.updatetime);
            pstmt.setString(pos++,this.memo);
            pstmt.setString(pos++,this.regisgerid);
            if(this.time==null) pstmt.setNull(pos++,java.sql.Types.TIMESTAMP);
            else pstmt.setDate(pos++,this.time);
            pstmt.executeUpdate();
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("写入产品分类时出错:",ex);
            throw new JadoException("写入产品分类时出错！");
        }
        finally{
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return id;
    }
    /**
     *  根据当前对象的内容往ITG_PRODUCTSORT表中更新一条记录
     * @param con  数据库连接
     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public void update(Connection con) throws JadoException{
        PreparedStatement pstmt=null;
        try{
            String sql="update ITG_PRODUCTSORT set ps_pid=? ,ps_name=? ,ps_pos=? ,ps_subnum=? ,ps_updatetime=? ,ps_memo=? ,ps_regisgerid=? ,ps_time=? "+
               " where ps_id=? ";
            pstmt=con.prepareStatement(sql);
            int pos=1;
            pstmt.setString(pos++,this.pid);
            pstmt.setString(pos++,this.name);
            if(this.pos==null) pstmt.setNull(pos++,java.sql.Types.INTEGER);
            else pstmt.setInt(pos++,this.pos.intValue());
            if(this.subnum==null) pstmt.setNull(pos++,java.sql.Types.INTEGER);
            else pstmt.setInt(pos++,this.subnum.intValue());
            if(this.updatetime==null) pstmt.setNull(pos++,java.sql.Types.TIMESTAMP);
            else pstmt.setDate(pos++,this.updatetime);
            pstmt.setString(pos++,this.memo);
            pstmt.setString(pos++,this.regisgerid);
            if(this.time==null) pstmt.setNull(pos++,java.sql.Types.TIMESTAMP);
            else pstmt.setDate(pos++,this.time);
            pstmt.setString(pos++,this.id);
            pstmt.executeUpdate();
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("更新产品分类时出错:",ex);
            throw new JadoException("更新产品分类时出错！");
        }
        finally{
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
    }
    /**
     * 根据ID号从ITG_PRODUCTSORT中读取数据
     * @param con 数据库连接
     * @param id 指定的ID号
     * @return 新的ITG_PRODUCTSORT对象
     * @throws JadoException error.jsp页面可以解析的错误对象
     */ 
    public static ITG_PRODUCTSORT get(Connection con,String id) throws JadoException {
        PreparedStatement pstmt=null;
        ResultSet rs=null;
        ITG_PRODUCTSORT itg_productsort=null;
        try{
            String sql="select ps_id,ps_pid,ps_name,ps_pos,ps_subnum,ps_updatetime,ps_memo,ps_regisgerid,ps_time            from ITG_PRODUCTSORT";
            sql+=" where ps_id='"+id+"' ";
            pstmt=con.prepareStatement(sql);
            rs=pstmt.executeQuery();
            if(rs.next()){
                itg_productsort=new ITG_PRODUCTSORT();
                itg_productsort.id=rs.getString("ps_id");
                itg_productsort.pid=rs.getString("ps_pid");
                itg_productsort.name=rs.getString("ps_name");
                if(rs.getString("ps_pos")!=null)  itg_productsort.pos=new Integer(rs.getInt("ps_pos"));
                if(rs.getString("ps_subnum")!=null)  itg_productsort.subnum=new Integer(rs.getInt("ps_subnum"));
                itg_productsort.updatetime=rs.getDate("ps_updatetime");
                itg_productsort.memo=rs.getString("ps_memo");
                itg_productsort.regisgerid=rs.getString("ps_regisgerid");
                itg_productsort.time=rs.getDate("ps_time");
            }
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("读取产品分类时出错:",ex);
            throw new JadoException("读取产品分类时出错！");
        }
        finally{
            if(rs!=null) try{rs.close();}catch(Exception ex){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return itg_productsort;
    }
    /**
     * 根据指定ID号删除ITG_PRODUCTSORT表中的数据
     * @param con 数据库连接
     * @param id 指定的ID号

     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public static void delete(Connection con,String id) throws JadoException {
        PreparedStatement pstmt=null;
        try{
            String sql="delete ITG_PRODUCTSORT where ps_id=? ";
            pstmt=con.prepareStatement(sql);
            int pos=1;
            pstmt.setString(pos++,id);
            pstmt.executeUpdate();
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("删除产品分类时出错:",ex);
            throw new JadoException("删除产品分类时出错！");
        }
        finally{
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
    }    
    
    /**
     * 根据ID??从ITG_PRODUCTSORT中读取数据
     * @param con 数据库连接
     * @return 新的ITG_PRODUCTSORT对象
     * @throws JadoException error.jsp页面可以解析的错误对象
     */
    public static Vector<ITG_PRODUCTSORT> gets(Connection con) throws JadoException {
        PreparedStatement pstmt=null;
        ResultSet rs=null;
        ITG_PRODUCTSORT ITG_PRODUCTSORT=null;
        Vector<ITG_PRODUCTSORT> npcs=null;
        try{
            String sql="select ps_id,ps_pid,ps_name            from ITG_PRODUCTSORT";
            sql+=" order by ps_id ";
            pstmt=con.prepareStatement(sql);
            rs=pstmt.executeQuery();
            while(rs.next()){
                ITG_PRODUCTSORT=new ITG_PRODUCTSORT();
                ITG_PRODUCTSORT.id=rs.getString("ps_id");
                ITG_PRODUCTSORT.pid=rs.getString("ps_pid");
                ITG_PRODUCTSORT.name=rs.getString("ps_name");
                if(npcs==null) npcs=new Vector<ITG_PRODUCTSORT>();
                npcs.add(ITG_PRODUCTSORT);
            }
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("读取产品类别信息表时出错:",ex);
            throw new JadoException("读取产品类别信息表时出错！");
        }
        finally{
            if(rs!=null) try{rs.close();}catch(Exception ex){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return npcs;
    }

    private static Hashtable<String,Vector<ITG_PRODUCTSORT>> subs=null;
    public static Vector<ITG_PRODUCTSORT> getSubs(Connection con,String parentid) throws JadoException {
        if(subs!=null&&subs.get(parentid==null?"":parentid)!=null) return subs.get(parentid==null?"":parentid);
        PreparedStatement pstmt=null;
        ResultSet rs=null;
        ITG_PRODUCTSORT ITG_PRODUCTSORT=null;
        Vector<ITG_PRODUCTSORT> npcs=null;
        try{
            String sql="select ps_id,ps_pid,ps_name from ITG_PRODUCTSORT";
            if(Pub.isEmpty(parentid)) sql+=" where ps_pid is null  order by ps_id ";
            else sql+=" where ps_pid=? order by ps_id ";
            pstmt=con.prepareStatement(sql);
            if(Pub.notEmpty(parentid)) pstmt.setString(1,parentid);
            rs=pstmt.executeQuery();
            while(rs.next()){
                ITG_PRODUCTSORT=new ITG_PRODUCTSORT();
                ITG_PRODUCTSORT.id=rs.getString("ps_id");
                ITG_PRODUCTSORT.pid=rs.getString("ps_pid");
                ITG_PRODUCTSORT.name=rs.getString("ps_name");
                if(npcs==null) npcs=new Vector<ITG_PRODUCTSORT>();
                npcs.add(ITG_PRODUCTSORT);
            }
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("读取产品类别信息表时出错:",ex);
            throw new JadoException("读取产品类别信息表时出错！");
        }
        finally{
            if(rs!=null) try{rs.close();}catch(Exception ex){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        if(subs==null) subs=new Hashtable<String,Vector<ITG_PRODUCTSORT>>();
        subs.put(parentid==null?"":parentid,npcs);
        return npcs;
    }

    public static Hashtable<String,ITG_PRODUCTSORT> getsHashtable(Connection con) throws JadoException {
        PreparedStatement pstmt=null;
        ResultSet rs=null;
        ITG_PRODUCTSORT ITG_PRODUCTSORT=null;
        Hashtable<String,ITG_PRODUCTSORT> npcs=null;
        try{
            String sql="select ps_id,ps_pid,ps_name            from ITG_PRODUCTSORT";
            sql+=" order by ps_id ";
            pstmt=con.prepareStatement(sql);
            rs=pstmt.executeQuery();
            while(rs.next()){
                ITG_PRODUCTSORT=new ITG_PRODUCTSORT();
                ITG_PRODUCTSORT.id=rs.getString("ps_id");
                ITG_PRODUCTSORT.pid=rs.getString("ps_pid");
                ITG_PRODUCTSORT.name=rs.getString("ps_name");
                if(npcs==null) npcs=new Hashtable<String,ITG_PRODUCTSORT>();
                npcs.put(ITG_PRODUCTSORT.id,ITG_PRODUCTSORT);
            }
        }
        catch(Exception ex){
            if(ex instanceof JadoException) throw (JadoException)ex;
            JLog.getLogger().error("读取产品类别信息表时出错:",ex);
            throw new JadoException("读取产品类别信息表时出错！");
        }
        finally{
            if(rs!=null) try{rs.close();}catch(Exception ex){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return npcs;
    }
    
    
    
    public String getId(){
        return this.id;
    }

    public void setId(String id){
        this.id=id;
    }
    public String getPid(){
        return this.pid;
    }

    public void setPid(String pid){
        this.pid=pid;
    }
    public String getName(){
        return this.name;
    }

    public void setName(String name){
        this.name=name;
    }
    public Integer getPos(){
        return this.pos;
    }

    public void setPos(Integer pos){
        this.pos=pos;
    }
    public Integer getSubnum(){
        return this.subnum;
    }

    public void setSubnum(Integer subnum){
        this.subnum=subnum;
    }
    public Date getUpdatetime(){
        return this.updatetime;
    }

    public void setUpdatetime(Date updatetime){
        this.updatetime=updatetime;
    }
    public String getMemo(){
        return this.memo;
    }

    public void setMemo(String memo){
        this.memo=memo;
    }
    public String getRegisgerid(){
        return this.regisgerid;
    }

    public void setRegisgerid(String regisgerid){
        this.regisgerid=regisgerid;
    }
    public Date getTime(){
        return this.time;
    }

    public void setTime(Date time){
        this.time=time;
    }
}
