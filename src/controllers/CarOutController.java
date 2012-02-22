package controllers;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import models.CarOut;
import nps.core.User;
import nps.exception.NpsException;
import tools.Pub;

import com.et.mvc.JsonView;
import com.et.mvc.View;
import com.gemway.util.JUtil;
import com.nfwl.itg.em.OrderStatusEnum;

public class CarOutController extends ApplicationController{
  
  /**
   * 
   * @param ids ids 格式 'aa','vv','cc','dd'
   * @param driver
   * @param carnum
   * @return
   * @throws NpsException
   */
  public View carOut(String ids,String driver,String carnum) throws  NpsException {
    Map<String, Object> result = new HashMap<String, Object>();
    Connection con = null;
    PreparedStatement pstmt = null;
    try {
      con = nps.core.Database.GetDatabase("nps").GetConnection();
      String [] aid = ids.replaceAll("'", "").split(",");
      
      String sql =  "insert into itg_carout \n" +
              "  (id, fp_id, carnum, driver, deltime, operater, operatetime,status) \n" + 
              "values \n" + 
              "  (?,?,?,?,sysdate,?,sysdate,'1') ";
      pstmt = con.prepareStatement(sql);
      String caroutid  = null;
      for (int i = 0; i < aid.length; i++) {
        caroutid = Pub.createUNID();
        pstmt.setString(1, caroutid);
        pstmt.setString(2, aid[i]);
        pstmt.setString(3, carnum);
        pstmt.setString(4, driver);
        pstmt.setString(5, ((User) session.getAttribute("user")).GetAccount());
        pstmt.executeUpdate();
        OrderController.carOutOrder(con, caroutid, aid[i]);
        
      }
      
      OrderController.carOut(con, ids, 2, 3);
      result.put("success", true);
      result.put("msg", "出车成功");
    } catch (Exception ex) {
      result.put("success", false);
      result.put("msg", "出车失败");
      nps.util.DefaultLog.error(ex);
    } finally {
      if (pstmt != null) try { pstmt.close(); } catch (Exception ex) {}
      if (con != null)try { con.close();} catch (Exception e) { }
  }

    // return new JsonView(result);
    View view = new JsonView(result);
    view.setContentType("text/html;charset=utf-8");
    return view;

  }

  /**
   * 改变订单状态
   * @param con
   * @param caroutid
   * @param todo
   * @throws NpsException
   */
  public void changeOrderStatues(Connection con,String caroutid,Integer todo ) throws NpsException {
    PreparedStatement pstmt=null;
    try {
      
      String sql = "update  itg_orderrec set or_status = "+todo+" where or_id in ( select ORDERID from itG_carout_order WHERE CAROUTID in ("+caroutid+") )";
        pstmt = con.prepareStatement(sql);
        pstmt.executeUpdate();
    }catch(Exception ex){
        
      nps.util.DefaultLog.error(ex);
      }
      finally{
          if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
      }
   
    
   
  } 
  
  
  /**
   * 改变出车记录状态
   * @param ids
   * @param fpids
   * @param todo
   * @return
   * @throws NpsException 
   */
  public View changeStatues(String ids,String fpids,Integer todo ) throws NpsException{
    Map<String,Object> result = new HashMap<String,Object>();
    Connection con = null;
    PreparedStatement pstmt=null;
    ResultSet rs = null;
    String sql = "update  itg_carout set status = "+todo+" where id in ("+ids+")";
    try {
      con = nps.core.Database.GetDatabase("nps").GetConnection();
      
      switch (todo) {
      case 3://完成  出车完成 相应的订单改成完成状态
        changeOrderStatues(con, ids, OrderStatusEnum.FINISH.getCode()); 
        break;
      case 9://取消  出车取消 相应的订单改成已付款状态
        changeOrderStatues(con, ids, OrderStatusEnum.PAID.getCode()); 
        break;
      case 10://删除出车删除 相应的订单改成已付款状态
        changeOrderStatues(con, ids,OrderStatusEnum.PAID.getCode()); 
        break;

      default:
        break;
      }
      
        pstmt = con.prepareStatement(sql);
       
        pstmt.executeUpdate();
        result.put("success", true);
        result.put("msg", "修改出车状态成功");
      }
      catch(Exception ex){
        result.put("success", false);
        result.put("msg","修改出车状态失败");
        nps.util.DefaultLog.error(ex);
      }
      finally{
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
   * 获取出车列表
   * @param fpname
   * @param deldayfrom
   * @param deldayto
   * @param status
   * @param pageSize
   * @param pageNumber
   * @return
   * @throws NpsException
   */
  public View getCarOuts(String fpname,String deldayfrom,String deldayto,String status, Integer pageSize, Integer pageNumber) throws NpsException {
    
    Map<String, Object> result = new HashMap<String, Object>();
    ArrayList<CarOut> carouts =  new ArrayList<CarOut>();
    CarOut carout = null;
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    int totle = 0;
    String sql= " select id, c.fp_id,fp.fp_name, carnum, driver, deltime, operater, operatetime,       decode(status,1,'已发车',2,'已送达',3,'已完成',9,'取消',10,'删除','未知') cnstatus,status  from itg_carout c,itg_fixedpoint fp where fp.fp_id = c.fp_id ";
    String sqlCount = "select count(id) from itg_carout c,itg_fixedpoint fp where fp.fp_id = c.fp_id ";
   
    String whereclause = " ";//需今天送货的单位
    try {
      con = nps.core.Database.GetDatabase("nps").GetConnection();
      
      if(fpname!=null&&fpname.length()>0){
        whereclause +=" and fp.fp_name like ? ";
      }
      if(status!=null&&status.length()>0&&Integer.valueOf(status)<10&&Integer.valueOf(status)>0){
        whereclause +=" and  c.status = ? ";
      }
      if(deldayfrom!=null&&deldayfrom.length()>0){
        whereclause += " and trunc(deltime) >= to_date(?, 'YYYY-MM-DD') ";
      }
      
      if(deldayto!=null&&deldayto.length()>0){
        whereclause += " and trunc(deltime) <= to_date(?, 'YYYY-MM-DD') ";
      }
        
        pstmt = con.prepareStatement(sqlCount + whereclause);
       
        
        int pos = 1;
        if(fpname!=null&&fpname.length()>0){
          pstmt.setString(pos++, fpname);
        }
        if(status!=null&&status.length()>0&&Integer.valueOf(status)<10&&Integer.valueOf(status)>0){
          pstmt.setString(pos++, status);
        }
        if(deldayfrom!=null&&deldayfrom.length()>0){
          pstmt.setString(pos++, deldayfrom);
        }
        
        if(deldayto!=null&&deldayto.length()>0){
          pstmt.setString(pos++, deldayto);
        }
        rs = pstmt.executeQuery();
        if(rs.next()){
          totle = rs.getInt(1);
        }
        result.put("total", totle);
        
        if(totle ==0){          
          result.put("rows", carouts);
          //“{"total":0,"rows":[]}”
          return new JsonView(result);
        }
       
        pstmt = con.prepareStatement(sql + whereclause);
        pos = 1;
        if(fpname!=null&&fpname.length()>0){
          pstmt.setString(pos++, fpname);
        }
        if(status!=null&&status.length()>0&&Integer.valueOf(status)<10&&Integer.valueOf(status)>0){
          pstmt.setString(pos++, status);
        }
        if(deldayfrom!=null&&deldayfrom.length()>0){
          pstmt.setString(pos++, deldayfrom);
        }
        
        if(deldayto!=null&&deldayto.length()>0){
          pstmt.setString(pos++, deldayto);
        }
       
        rs = pstmt.executeQuery();
        int index = 0;
        while (rs.next()) {
          if (++index <= pageSize * (pageNumber - 1))
            continue;
          if (index > pageSize * (pageNumber))
            break;
          if (carouts == null)
            carouts = new ArrayList<CarOut>();
          carout = new CarOut();
          carout.setId(rs.getString("id"));
          carout.setFpid(rs.getString("fp_id"));
          carout.setFpname(rs.getString("fp_name"));
          carout.setCarnum(JUtil.convertNull(rs.getString("carnum"),"&nbsp; "));
          carout.setDriver(JUtil.convertNull(rs.getString("driver"),"&nbsp; "));
          carout.setDelday(rs.getDate("deltime"));
          carout.setOperatername(rs.getString("operater"));
          carout.setOperatertime(rs.getString("operatetime"));
          carout.setStatus(rs.getInt("status"));
          carout.setCnstatus(rs.getString("cnstatus"));
          carouts.add(carout);
        }
        
        result.put("rows", carouts);
        return new JsonView(result);
      } catch (Exception ex) {
        ex.printStackTrace();
        nps.util.DefaultLog.error(ex);
      } finally {
        if (rs != null)try { rs.close(); } catch (Exception ex) { }
        if (pstmt != null) try { pstmt.close(); } catch (Exception ex) {}
        if (con != null)try { con.close();} catch (Exception e) { }
    }
    return null;
   }
    
  public static View getcaroutById(String id) throws NpsException{

    PreparedStatement pstmt=null;
    ResultSet rs = null; 
    Connection con = null;
    CarOut carout = null;
    try {
        con = nps.core.Database.GetDatabase("nps").GetConnection();
        
        String sql= " select or_id, name or_userid,telephone or_telephone,mobile or_mobile, or_money, decode(or_status,1,'未付款',2,'已付款',3,'正在配送',4,'已完成',5,'',10,'取消','未知') or_status, or_time, or_adrid " +
            ", or_no, or_point, or_carrymode, or_invoicetitle, or_memo from itg_caroutrec ,users where id = or_userid and or_id = ?";
       
        
        pstmt=con.prepareStatement(sql);
        pstmt.setString(1,id);
        rs  = pstmt.executeQuery();
        if(rs.next()){
          carout = new CarOut();
         
        }
    } catch(Exception ex){
      nps.util.DefaultLog.error(ex);
    } finally{
        if(rs!=null) try{rs.close();}catch(Exception ex){}
        if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        if(con!=null) try{con.close();}catch(Exception ex){}
    }

     
    return new JsonView(carout);
  }

}
