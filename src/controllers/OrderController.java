package controllers;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import nps.exception.NpsException;

import tools.Pub;

import models.OrderModels;
import models.UserModels;

import com.et.mvc.JsonView;
import com.et.mvc.View;
import com.gemway.partner.JLog;
import com.gemway.util.JError;

public class OrderController extends ApplicationController{
  
  
  
  ////fpids 格式 'aa','vv','cc','dd'
  /**
   * 出车 更改订单状态
   * @param con
   * @param fpids
   * @param fromstatus
   * @param tostatus
   * @throws NpsException 
   */
  public static void carOut(Connection con,String fpids,int fromstatus ,int tostatus) throws NpsException{

    PreparedStatement pstmt=null;
    String sql =  "update itg_orderrec \n" +
            "   set or_status = "+tostatus +" \n" + 
            " where or_id in (select o.or_id \n" + 
            "                   from itg_orderrec o, users u, itg_fixedpoint fp \n" + 
            "                  where o.or_userid = u.id \n" + 
            "                    and fp.fp_id = u.itg_fixedpoint \n" + 
            "                    and o.or_status = "+fromstatus+"  \n" + 
            "                    and fp.fp_id in ("+fpids+")) ";

    
    try{
      pstmt = con.prepareStatement(sql);
      pstmt.executeUpdate();
    }catch(Exception ex){
      nps.util.DefaultLog.error(ex);
    }finally{
        if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
    }
  
  }
  ////fpid 格式 'aa','vv','cc','dd'
  /**
   * 填写出车订单子表
   * @param con
   * @param caroutid
   * @param fpid
   * @throws NpsException 
   */
  public static void carOutOrder(Connection con,String caroutid,String fpid) throws NpsException{

    PreparedStatement pstmt=null;
    PreparedStatement pstmtupdate=null;
    ResultSet rs = null;
    String sql =   "select o.or_id \n" +
            "                   from itg_orderrec o, users u, itg_fixedpoint fp\n" + 
            "                  where o.or_userid = u.id\n" + 
            "                    and fp.fp_id = u.itg_fixedpoint\n" + 
            "                    and o.or_status = 2\n" + 
            "                   and fp.fp_id = ?";

    String sqlupdate = " insert into itg_carout_order (id, caroutid, orderid) values  (?, ?, ?) ";
    
    try{
      pstmt = con.prepareStatement(sql);
      pstmt.setString(1, fpid);
      rs = pstmt.executeQuery();
      pstmtupdate = con.prepareStatement(sqlupdate);
      
      while(rs.next()){
        pstmtupdate.setString(1, Pub.createUNID());
        pstmtupdate.setString(2, caroutid);
        pstmtupdate.setString(3, rs.getString("or_id"));
        pstmtupdate.executeUpdate();
      }
     
    }catch(Exception ex){
      nps.util.DefaultLog.error(ex);  
    }finally{
        if(rs!=null) try{rs.close();}catch(Exception ex){}
        if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        if(pstmtupdate!=null) try{pstmtupdate.close();}catch(Exception ex){}
    }
  
  }
  
  /**
   * 改变订单状态
   * @param ids
   * @param todo
   * @return
   * @throws NpsException 
   */
  public View changeOrder(String ids,String todo ) throws NpsException{
    Map<String,Object> result = new HashMap<String,Object>();
    ArrayList<UserModels>   users = new ArrayList<UserModels>();     
    Connection con = null;
    PreparedStatement pstmt=null;
    ResultSet rs = null;
    String sql = "update  itg_orderrec set or_status = "+todo+" where or_id in ("+ids+")";
    try {
        con = nps.core.Database.GetDatabase("nps").GetConnection();
        pstmt = con.prepareStatement(sql);
        pstmt.executeUpdate();
        result.put("success", true);
        result.put("msg", "修改订单状态陈功");
      }catch(Exception ex){
        result.put("success", false);
        result.put("msg","修改订单状态失败");
        nps.util.DefaultLog.error(ex);
      } finally{
          if(rs!=null) try{rs.close();}catch(Exception ex){}
          if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
          if(con!=null) try{con.close();}catch(Exception e){}
      }
    
    
    //return new JsonView(result);
    View view = new JsonView(result);
    view.setContentType("text/html;charset=utf-8");
    return view;
    
  } 
  
  /**
   * 
   * @return
   * @throws Exception
   */
  public View getAllOrders() throws Exception{
    Map<String,Object> result = new HashMap<String,Object>();
    ArrayList<OrderModels>   orders = new ArrayList<OrderModels>();     
      Connection con = null;
      try {
        con = nps.core.Database.GetDatabase("nps").GetConnection();
        orders = getOrders(con,null);
        
      }catch(Exception e){
        nps.util.DefaultLog.error(e);
      }finally{
        if(con!=null) try{con.close();}catch(Exception e){}
      }
    
    result.put("total", orders.size());
    result.put("rows", orders);
    
    return new JsonView(result);
  }
  
  /**
   * 
   * @param status
   * @return
   * @throws Exception
   */
  public View getOrders(Integer status,Integer pageSize, Integer pageNumber) throws Exception{


    Map<String, Object> result = new HashMap<String, Object>();
    ArrayList<OrderModels> orders = new ArrayList<OrderModels>();
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    OrderModels order = null;
    int totle = 0;
    String  sql= " select or_id,name  or_userid,telephone or_telephone,mobile or_mobile, or_money, decode(or_status,0,'新建',1,'已确认',2,'已付款',3,'正在配送',4,'已完成',99,'已删除',100,'取消','未知') or_status, or_time " +
        ", or_no, or_point, or_carrymode, or_invoicetitle, or_memo from itg_orderrec ,users where id = or_userid  ";
    
    
    String sqlCount = " select count(or_id) from itg_orderrec ,users where id = or_userid  ";

    try {
      con = nps.core.Database.GetDatabase("nps").GetConnection();

       
        if (status != null && status > -1) {
          sqlCount += " and or_status = ? ";
        }

        pstmt = con.prepareStatement(sqlCount);
        int pos = 1;
        
        if (status != null && status > -1) {
          pstmt.setInt(pos++, status);
        }
        rs = pstmt.executeQuery();
        if(rs.next()){
          totle = rs.getInt(1);
        }
        result.put("total", totle);
        
        if(totle ==0){          
          result.put("rows", orders);
          return new JsonView(result);
        }
       
        if (status != null && status > -1) {
          sql += " and or_status = ? ";
        }

        pstmt = con.prepareStatement(sql);
        pos = 1;
        
        if (status != null && status > -1) {
          pstmt.setInt(pos++, status);
        }
        rs = pstmt.executeQuery();
        int index = 0;
        while (rs.next()) {
          if (++index <= pageSize * (pageNumber - 1))
            continue;
          if (index > pageSize * (pageNumber))
            break;
          if (orders == null)
            orders = new ArrayList<OrderModels>();
          order = new OrderModels();
          order.setOr_id(rs.getString("or_id"));
          order.setOr_userid(rs.getString("or_userid"));
          order.setOr_money(rs.getDouble("or_money"));
          order.setOr_status(rs.getString("or_status"));
          order.setOr_mobile(rs.getString("or_mobile"));
          order.setOr_telephone(rs.getString("or_telephone"));
          order.setOr_time(rs.getDate("or_time"));
          //order.setOr_adrid(rs.getString("or_adrid"));
          order.setOr_no(rs.getString("or_no"));
          order.setOr_point(rs.getInt("or_point"));
          order.setOr_carrymode(rs.getInt("or_carrymode"));
          order.setOr_invoicetitle(rs.getString("or_invoicetitle"));
          order.setOr_memo(rs.getString("or_memo"));
          orders.add(order);
        }
        
        result.put("rows", orders);
        return new JsonView(result);
      } catch (Exception ex) {
        nps.util.DefaultLog.error(ex);
      } finally {
        if (rs != null)try { rs.close(); } catch (Exception ex) { }
        if (pstmt != null) try { pstmt.close(); } catch (Exception ex) {}
        if (con != null) try { con.close(); } catch (Exception ex) {}
      }
    return null;
    } 
  
  /**
   * 
   * @param con
   * @param status
   * @return
   * @throws JError
   * @throws NpsException 
   */
  private  ArrayList<OrderModels> getOrders(Connection con,Integer status) throws JError, NpsException{
    ArrayList<OrderModels> alods = null;

    PreparedStatement pstmt=null;
    ResultSet rs = null;
    OrderModels order = null;
    try{
        String sql= " select or_id,name  or_userid,telephone or_telephone,mobile or_mobile, or_money, decode(or_status,1,'未付款',2,'已付款',3,'已发车',4,'已送达',5,'已完成',10,'取消','未知') or_status, or_time  " +
        		", or_no, or_point, or_carrymode, or_invoicetitle, or_memo from itg_orderrec ,users where id = or_userid  ";
       
        if(status!=null&& status!=0){
          sql += " and or_status = ? " ;
        }
        
        pstmt=con.prepareStatement(sql);
        if(status!=null&& status!=0){
          pstmt.setInt(1, status);
        }
        rs  = pstmt.executeQuery();
        while(rs.next()){
          if(alods ==null ) alods = new ArrayList<OrderModels>();
          order = new OrderModels();
          order.setOr_id(rs.getString("or_id"));
          order.setOr_userid(rs.getString("or_userid"));
          order.setOr_money(rs.getDouble("or_money"));
          order.setOr_status(rs.getString("or_status"));
          order.setOr_mobile(rs.getString("or_mobile"));
          order.setOr_telephone(rs.getString("or_telephone"));
          order.setOr_time(rs.getDate("or_time"));
          //order.setOr_adrid(rs.getString("or_adrid"));
          order.setOr_no(rs.getString("or_no"));
          order.setOr_point(rs.getInt("or_point"));
          order.setOr_carrymode(rs.getInt("or_carrymode"));
          order.setOr_invoicetitle(rs.getString("or_invoicetitle"));
          order.setOr_memo(rs.getString("or_memo"));
          
          alods.add(order);
        }
    }
    catch(Exception ex){
      nps.util.DefaultLog.error(ex);
    }
    finally{
        if(rs!=null) try{rs.close();}catch(Exception ex){}
        if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
    }

    
    return alods;
  }
  
  /**
   * 
   * @param id
   * @return
   * @throws JError
   * @throws NpsException 
   */
  public static View getOrderById(String id) throws JError, NpsException{
    PreparedStatement pstmt=null;
    ResultSet rs = null; 
    Connection con = null;
    OrderModels order = null;
    try {
        con = nps.core.Database.GetDatabase("nps").GetConnection();
        
        String sql= " select or_id, name or_userid,telephone or_telephone,mobile or_mobile, or_money, decode(or_status,1,'未付款',2,'已付款',3,'正在配送',4,'已完成',5,'',10,'取消','未知') or_status, or_time " +
            ", or_no, or_point, or_carrymode, or_invoicetitle, or_memo from itg_orderrec ,users where id = or_userid and or_id = ?";
       
        
        pstmt=con.prepareStatement(sql);
        pstmt.setString(1,id);
        rs  = pstmt.executeQuery();
        if(rs.next()){
          order = new OrderModels();
          order.setOr_id(rs.getString("or_id"));
          order.setOr_userid(rs.getString("or_userid"));
          order.setOr_money(rs.getDouble("or_money"));
          order.setOr_status(rs.getString("or_status"));
          order.setOr_mobile(rs.getString("or_mobile"));
          order.setOr_telephone(rs.getString("or_telephone"));
          order.setOr_time(rs.getDate("or_time"));
          //order.setOr_adrid(rs.getString("or_adrid"));
          order.setOr_no(rs.getString("or_no"));
          order.setOr_point(rs.getInt("or_point"));
          order.setOr_carrymode(rs.getInt("or_carrymode"));
          order.setOr_invoicetitle(rs.getString("or_invoicetitle"));
          order.setOr_memo(rs.getString("or_memo"));
        }
    }
    catch(Exception ex){
      nps.util.DefaultLog.error(ex);
    }
    finally{
        if(rs!=null) try{rs.close();}catch(Exception ex){}
        if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        if(con!=null) try{con.close();}catch(Exception ex){}
    }
    return new JsonView(order);
  }

}
