package tools;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Vector;

import com.et.mvc.JsonView;

import controllers.SaveCardController;

import models.SaveCard;
import nps.exception.NpsException;


/**
 * User: 谢智荣
 * Date: 11-10-19
 * Time: 下午12:24
 */
public class Random {

    //返回随即整数字符串
    //len 整数长度
    public static String getIntegerStr(Connection con,int len) throws NpsException {
        long num=9;
        if(len>1){
            long base=10;
            for(int i=0;i<len;i++) base=base*10;
            num=base-1;
        }
        String sql="select lpad(trunc(dbms_random.value(0,"+String.valueOf(num)+")),"+len+",'0') from dual ";
        ResultSet rs=null;
        PreparedStatement pstmt=null;
        String val=null;
        try{
            pstmt=con.prepareStatement(sql);
            rs=pstmt.executeQuery();
            rs.next();
            val=rs.getString(1);
        }catch(Exception ex){
          nps.util.DefaultLog.info("获取随机数的时候出错，[len:]"+len+",[sql:]"+sql);
          nps.util.DefaultLog.error(ex);
            throw new NpsException("获取随机数的时候出错!",0);
        }
        return val;
    }

    //返回随即整数字符串列表
    //len 整数长度  size 列表个数
    public static List getIntegerStrList(Connection con,int len,int size) throws NpsException {
        long num=9;
        if(len>1){
            long base=10;
            for(int i=0;i<len;i++) base=base*10;
            num=base-1;
        }
        String sql="select lpad(trunc(dbms_random.value(0,"+String.valueOf(num)+")),"+len+",'0') from dual ";
        ResultSet rs=null;
        PreparedStatement pstmt=null;
        Vector vals=null;
        String val=null;
        try{
            pstmt=con.prepareStatement(sql);
            for(int i=0;i<size;i++){
                rs=pstmt.executeQuery();
                rs.next();
                val=rs.getString(1);
                if(vals==null) vals=new Vector();
                vals.add(val);
                try{rs.close();}catch(Exception ex){}
            }
        }catch(Exception ex){
          nps.util.DefaultLog.error(ex);
          nps.util.DefaultLog.info("获取随机数的时候出错，[len:]"+len+",[sql:]"+sql);
            throw new NpsException("获取随机数的时候出错!",0);
        }
        return vals;
    }
    public static Integer getRandom(Integer len){
    	int[] array = {0,1,2,3,4,5,6,7,8,9};
    	java.util.Random rand = new java.util.Random();
        for (int i = 10; i > 1; i--) {
            int index = rand.nextInt(i);
            int tmp = array[index];
            array[index] = array[i - 1];
            array[i - 1] = tmp;
        }
        int result = 0;
        for(int i = 0; i < len; i++)
            result = result * 10 + array[i];
    	return result;
    }
    public static String getNo(Integer n){
		 SimpleDateFormat df = new SimpleDateFormat("yyMMddHH");
		 String sdf = df.format(new Date()); 
		 Integer random = getRandom(n);
		 String no=sdf+random.toString();
		 return no;
	}
    
    public static void main(String [] args){
      try{
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        
     }catch(SQLException e1) {
         System.out.println("注册数据库驱动程序失败！" );
         return;
     }
     try {
       Connection con = DriverManager.getConnection("jdbc:oracle:thin:@www.zjhy.net.cn:1521:hyyb2","nps","nps");
       int size = 10;
       SaveCard card = null;
       List nums= Random.getIntegerStrList(con, 10,size*2);
       List pwds= Random.getIntegerStrList(con, 10,size);
       int num=0;
       card=new SaveCard();
       SaveCardController scc = new SaveCardController();
       for(int i=0;i<size;i++){
           if(controllers.SaveCardController.exist(con,(String)nums.get(i))) continue;
           card.setCardno((String)nums.get(i));
           card.setCardpwd((String)pwds.get(num));
           card.setCreatorid("10");
           card.setMoney(10.0);
           card.setBalance(10.0);
           scc.insert(con, card);
           num++;
           if(num>=size) break;
       }
       
     
       
       System.out.println("数据库联接成功！" );
     }
     catch(Exception ex){
       ex.printStackTrace();
        //System.out.println("数据库联接失败");
        //return;
     }
    }
}
