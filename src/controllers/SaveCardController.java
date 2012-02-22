package controllers;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import models.SaveCard;
import nps.exception.NpsException;
import tools.Random;

import com.et.mvc.JsonView;
import com.et.mvc.View;

public class SaveCardController extends ApplicationController {
  
  public View changeStatues(String ids,String fpids,Integer todo ) throws NpsException{
    Map<String,Object> result = new HashMap<String,Object>();
    Connection con = null;
    PreparedStatement pstmt=null;
    ResultSet rs = null;
    String sql = "update  itg_savecard set sc_status = "+todo+" where sc_cardno in ("+ids+")";
    try {
      con = nps.core.Database.GetDatabase("nps").GetConnection();
      
        pstmt = con.prepareStatement(sql);
       
        pstmt.executeUpdate();
        result.put("success", true);
        result.put("msg", "储值卡状态修改成功");
      }
      catch(Exception ex){
        result.put("success", false);
        result.put("msg","储值卡状态修改失败");
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
  public View getSaveCard(Integer status,String carno,String createfrom,String createto, Integer pageSize, Integer pageNumber) throws NpsException{
    Map<String, Object> result = new HashMap<String, Object>();
    ArrayList<SaveCard> cards = new ArrayList<SaveCard>();
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    SaveCard card = null;
    
//    if(s_startdate != null && s_startdate.trim().length() > 0)
//    {
//        clause += " and trunc(b.YWSW_DJSJ) >= to_date('" + s_startdate + "', 'YYYY-MM-DD') ";
//    }
   
    int totle = 0;
    String sql = "select sc_cardno, sc_cardpwd, sc_money, sc_balance, sc_time, sc_publishtime, sc_usetime, sc_creatorid, sc_status,decode(sc_status,0,'新建',1,'已销售',2,'已使用',-1,'删除','未知') cnstatus from itg_savecard ";
    String sqlCount = "select count(*) from itg_savecard";
    String sqlwhere = " where 1=1 ";

    try {
      con = nps.core.Database.GetDatabase("nps").GetConnection();

      if(status!=null&&status.intValue()!=100){
        sqlwhere +=" and sc_status = ? ";
      }
      if(createfrom != null && createfrom.trim().length() > 0){
        sqlwhere += " and trunc(sc_time) >= to_date(?, 'YYYY-MM-DD') ";
      }
      if(createto != null && createto.trim().length() > 0){
        sqlwhere += " and trunc(sc_time) <= to_date(?, 'YYYY-MM-DD') ";
      }
      if(carno != null && carno.trim().length() > 0){
        sqlwhere += " and sc_cardno like ? ";
      }
       

        pstmt = con.prepareStatement(sqlCount + sqlwhere);
        int pos = 1;
        
        if(status!=null&&status.intValue()!=100){
          pstmt.setInt(pos++, status);
        }
        if(createfrom != null && createfrom.trim().length() > 0){
          pstmt.setString(pos++, createfrom);
        }
        if(createto != null && createto.trim().length() > 0){
          pstmt.setString(pos++, createto);
        }
        if(carno != null && carno.trim().length() > 0){
          pstmt.setString(pos++, "%"+carno+"%");
        }
        
        rs = pstmt.executeQuery();
        if(rs.next()){
          totle = rs.getInt(1);
        }
        result.put("total", totle);
        
        if(totle ==0){          
          result.put("rows", cards);
          return new JsonView(result);
        }
        
        pstmt = con.prepareStatement(sql+sqlwhere);
        pos = 1;
        if(status!=null&&status.intValue()!=100){
          pstmt.setInt(pos++, status);
        }
        if(createfrom != null && createfrom.trim().length() > 0){
          pstmt.setString(pos++, createfrom);
        }
        if(createto != null && createto.trim().length() > 0){
          pstmt.setString(pos++, createto);
        }
        if(carno != null && carno.trim().length() > 0){
          pstmt.setString(pos++, "%"+carno+"%");
        }
        rs = pstmt.executeQuery();
        int index = 0;
        while (rs.next()) {
          if (++index <= pageSize * (pageNumber - 1))
            continue;
          if (index > pageSize * (pageNumber))
            break;
          if (cards == null)
            cards = new ArrayList<SaveCard>();
          card = new SaveCard();
          // sc_cardno, sc_cardpwd, sc_money, sc_balance, sc_time, sc_publishtime, sc_usetime, sc_creatorid, sc_status
          card.setCardno(rs.getString("sc_cardno"));
          card.setCardpwd(rs.getString("sc_cardpwd"));
          card.setMoney(rs.getDouble("sc_money"));
          card.setBalance(rs.getDouble("sc_balance"));
          card.setTime(rs.getDate("sc_time"));
          card.setPublishtime(rs.getDate("sc_publishtime"));
          card.setUsetime(rs.getDate("sc_usetime"));
          card.setCreatorid(rs.getString("sc_creatorid"));
          card.setStatus(rs.getInt("sc_status"));
          card.setCnstatus(rs.getString("cnstatus"));
          
          cards.add(card);
        }
        
        result.put("rows", cards);
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
  
  

  public View create(Integer size,Double money) throws NpsException {
    Map<String, Object> result = new HashMap<String, Object>();
    ArrayList<SaveCard> cards = new ArrayList<SaveCard>();
    SaveCard card = null;
    Connection con = null;
    nps.core.User user = (nps.core.User) session.getAttribute("user");
    String createid = user.getId();
    
    try {
      con = nps.core.Database.GetDatabase("nps").GetConnection();
      List nums= Random.getIntegerStrList(con, 10,size*2);
      List pwds= Random.getIntegerStrList(con, 10,size);
      int num=0;
      card=new SaveCard();
      for(int i=0;i<size;i++){
          if(exist(con,(String)nums.get(i))) continue;
          card.setCardno((String)nums.get(i));
          card.setCardpwd((String)pwds.get(num));
          card.setCreatorid(createid);
          card.setMoney(money);
          card.setBalance(money);
          insert(con, card);
          cards.add(card);
          num++;
          if(num>=size) break;
      }
      result.put("success", true);
      result.put("msg", "成功保存");
      result.put("rows", cards);
      return new JsonView(result);
    } catch (Exception ex) {
      ex.printStackTrace();
      nps.util.DefaultLog.error(ex);
    } finally {
      if (con != null)try { con.close();} catch (Exception ex) {}
    }

    // return new JsonView(result);
    View view = new JsonView(result);
    view.setContentType("text/html;charset=utf-8");
    return view;

  }
  
  public String insert(Connection con,SaveCard card) throws NpsException{
    PreparedStatement pstmt=null;
    ResultSet rs = null;
    String sql = "insert into itg_savecard \n" +
            "  (sc_cardno, sc_cardpwd, sc_money, sc_balance, sc_time,   sc_creatorid, sc_status) \n" + 
            "values \n" + 
            "  (?, ?, ?, ?, sysdate,  ?, 0) ";
    try {
        pstmt = con.prepareStatement(sql);
        int colIndex =1;
        pstmt.setString(colIndex ++,card.getCardno());
        pstmt.setString(colIndex ++,card.getCardpwd());
        pstmt.setDouble(colIndex ++,card.getMoney());
        pstmt.setDouble(colIndex ++,card.getBalance());
        pstmt.setString(colIndex ++,card.getCreatorid());
        pstmt.executeUpdate();
        return card.getCardno();
      }catch(Exception ex){
        nps.util.DefaultLog.error(ex);
      }finally{
          if(rs!=null) try{rs.close();}catch(Exception ex){}
          if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
      }
    return null;
    
  }
  public static boolean exist(Connection con,String no) throws NpsException{
    boolean bexist = false;
    String sql = " select * from itg_savecard where sc_cardno = ?";
    
    PreparedStatement pstmt=null;
    ResultSet rs = null;
    try{
        pstmt=con.prepareStatement(sql);
        pstmt.setString(1,no);
        rs = pstmt.executeQuery();
        if(rs.next()){
          bexist = true;
        }
        
    }catch(Exception ex){
      nps.util.DefaultLog.error(ex);
    }finally{
      if (rs != null)try {rs.close();} catch (Exception ex) {}
      if (pstmt != null) try {pstmt.close(); } catch (Exception ex) {}
    }
    return bexist;
  } 
  public static SaveCard parse(String scsv,nps.core.User user){
    SaveCard sc = null;
    if(scsv==null||scsv.isEmpty()) return null;
    String [] as = scsv.split(",");
    if(as==null||as.length!=3){
      return null;
    }
    
    String carno = as[0].trim();
    String carpwd = as[1].trim();
    String money = as[2].trim();
    
    String regExNum10 = "\\d{10}"; 
    String regExDouble = "[0-9]+(.[0-9]+)?";   
    Pattern pregExNum10 = Pattern.compile(regExNum10);  
    Pattern pregExDouble = Pattern.compile(regExDouble); 

    Matcher mcarno = pregExNum10.matcher(carno); 
    Matcher mcarpwd = pregExNum10.matcher(carpwd); 
    Matcher mmoney = pregExDouble.matcher(money); 
    
    //System.out.println(m1.matches());
    
      if(mcarno.matches()&&mcarpwd.matches()&&mmoney.matches()){    
      
      try{
        sc = new SaveCard();
        sc.setCardno(carno);
        sc.setCardpwd(carpwd);
        sc.setMoney(Double.parseDouble(money));
        sc.setCreatorid(user.getId());
        sc.setBalance(sc.getMoney());
        sc.setTime(new java.sql.Date(new java.util.Date().getTime()));
        sc.setStatus(0);
      }catch(Exception e){
        return null;
      }
    }
      
      return sc;
  }
}
