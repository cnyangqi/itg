package tools;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import nps.core.Database;

import com.gemway.partner.JUtil;

public class AjaxUtils {
  
  //检测该标题文号是否可用
  public String checkNo(String no){      
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sql = "select id from users where upper(account) = upper(?)";
    String sreturn = "";
    try {
      con = con = Database.GetDatabase("nps").GetConnection();
      pstmt = con.prepareStatement(sql);
      
      pstmt.setString(1,no);
      rs = pstmt.executeQuery();
      if(rs.next()){
        sreturn = rs.getString(1);
      }
      
    } catch (Exception e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    }finally{
      if(rs!=null)try{rs.close();}catch(Exception e){}
      if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
      if(con!=null)try{con.close();}catch(Exception e){}
    }
    
    
    return sreturn;     
}   
 

  /**
   * @param args
   */
  public static void main(String[] args) {
    // TODO Auto-generated method stub

  }

}

