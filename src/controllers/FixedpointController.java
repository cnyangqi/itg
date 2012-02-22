package controllers;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import nps.exception.NpsException;

import models.FixedpointModels;

import com.et.mvc.JsonView;
import com.et.mvc.View;

public class FixedpointController extends ApplicationController{
  
  
  /**
   * 取得今天需要送货的定点单位
   * @param name
   * @param linker
   * @param addr
   * @param pageSize
   * @param pageNumber
   * @return
   * @throws NpsException
   */
  public View getDailyDelivery(String name,String linker,String addr, Integer pageSize, Integer pageNumber) throws NpsException{
  
   Map<String, Object> result = new HashMap<String, Object>();
   ArrayList<FixedpointModels> fixedpoints =  new ArrayList<FixedpointModels>();
   FixedpointModels fixedpoint = null;
   Connection con = null;
   PreparedStatement pstmt = null;
   ResultSet rs = null;
   int totle = 0;
   String sql= "select fp_id, fp_name, fp_address, fp_linker, fp_phone, fp_email, fp_postcode, fp_code, fp_valid, fp_registerid, fp_time,fp_delday from itg_fixedpoint ";
    String sqlCount = "select count(fp_id) from itg_fixedpoint";
  //需今天送货的单位
    String whereclause = " where instr(fp_delday,to_char(sysdate -1,'D'))>0 and  fp_valid = 1 ";
  //有尚未送货的订单
    whereclause += " and exists (select o.or_id from itg_orderrec o,users u where o.or_userid = u.id and o.or_status = 2 and u.itg_fixedpoint = fp_id) ";
   try {
     con = nps.core.Database.GetDatabase("nps").GetConnection();

       if (name != null && name.length() > 0) {
         whereclause += " and fp_name like ? ";
       }
       if (linker != null && linker.length() > 0) {
         whereclause += " and fp_linker like ? ";
       }
       if (addr != null && addr.length() > 0) {
         whereclause += " and fp_address  like ? ";
       }
       pstmt = con.prepareStatement(sqlCount + whereclause);
       int pos = 1;
       if (name != null && name.length() > 0) {
         pstmt.setString(pos++, "%" +name+"%" );
       }
       if (linker != null && linker.length() > 0) {
         pstmt.setString(pos++, "%" +linker+"%" );
       }
       if (addr != null && addr.length() > 0) {
         pstmt.setString(pos++, "%" + addr + "%");
       }
      
       rs = pstmt.executeQuery();
       if(rs.next()){
         totle = rs.getInt(1);
       }
       result.put("total", totle);
       
       if(totle ==0){          
         result.put("rows", fixedpoints);
         //“{"total":0,"rows":[]}”
         return new JsonView(result);
       }
      
       pstmt = con.prepareStatement(sql + whereclause);
       pos = 1;
       if (name != null && name.length() > 0) {
         pstmt.setString(pos++, "%" +name+"%" );
       }
       if (linker != null && linker.length() > 0) {
         pstmt.setString(pos++, "%" +linker+"%" );
       }
       if (addr != null && addr.length() > 0) {
         pstmt.setString(pos++, "%" + addr + "%");
       }
      
       rs = pstmt.executeQuery();
       int index = 0;
       while (rs.next()) {
         if (++index <= pageSize * (pageNumber - 1))
           continue;
         if (index > pageSize * (pageNumber))
           break;
         if (fixedpoints == null)
           fixedpoints = new ArrayList<FixedpointModels>();
         fixedpoint = new FixedpointModels();
         // id,name,account,password,telephone,itg_fixedpoint,fax,email,mobile,face,cx,dept,utype
         fixedpoint.setFp_id(rs.getString("fp_id"));
         fixedpoint.setFp_name(rs.getString("fp_name"));
         fixedpoint.setFp_address(rs.getString("fp_address"));
         fixedpoint.setFp_linker(rs.getString("fp_linker"));
         fixedpoint.setFp_delday(rs.getString("fp_delday"));
         fixedpoints.add(fixedpoint);
       }
       
       result.put("rows", fixedpoints);
       
     } catch (Exception ex) {
       nps.util.DefaultLog.error(ex);
     } finally {
       if (rs != null)try { rs.close(); } catch (Exception ex) { }
       if (pstmt != null) try { pstmt.close(); } catch (Exception ex) {}
       if (con != null)try { con.close();} catch (Exception e) { }
   }
   return new JsonView(result);
  }
  
  /**
   * 
   * @param code
   * @return
   * @throws Exception
   */
  public String checkCode(String code) throws Exception{
    Map<String,Object> result = new HashMap<String,Object>();
    result.put("success", "code".equals(code));
    System.out.println("code = ["+ code+"]");
    View view = new JsonView(result);
    view.setContentType("text/html;charset=UTF-8");
    return "code".equals(code)?"true":"false";
  }
  public View getAll(String id) throws NpsException{
    Map<String,Object> result = new HashMap<String,Object>();
    ArrayList<FixedpointModels>   fixedpoints = new ArrayList<FixedpointModels>();
      Connection con = null;
      PreparedStatement pstmt=null;
      ResultSet rs = null;
      FixedpointModels fixedpoint = null;
      String sql= "select fp_id, fp_name, fp_address, fp_linker, fp_phone, fp_email, fp_postcode, fp_code, fp_valid, fp_registerid, fp_time from itg_fixedpoint where fp_valid = 1";
         
      int totle = 0;
      try {
        con = nps.core.Database.GetDatabase("nps").GetConnection();
        if(id!=null&&id.length()>0){
              sql += " and fp_id = ? ";
            }
            pstmt=con.prepareStatement(sql);
            if(id!=null&&id.length()>0){
              pstmt.setString(1, id);
            }
            rs  = pstmt.executeQuery();
            while(rs.next()){
              totle++;
              if(fixedpoints ==null ) fixedpoints = new ArrayList<FixedpointModels>();
              fixedpoint = new FixedpointModels();
              fixedpoint.setFp_id(rs.getString("fp_id"));
              fixedpoint.setFp_name(rs.getString("fp_name"));
              fixedpoint.setFp_address(rs.getString("fp_address"));
              fixedpoint.setFp_linker(rs.getString("fp_linker"));
              fixedpoints.add(fixedpoint);
            }
        }catch(Exception ex){
          nps.util.DefaultLog.error(ex);
        }
        finally{
            if(rs!=null) try{rs.close();}catch(Exception ex){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
            if(con!=null) try{con.close();}catch(Exception e){}
        }
      result.put("total",totle);
      result.put("rows", fixedpoints);
    
    return new JsonView(fixedpoints);
  }
  
}
