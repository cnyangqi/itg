package com.nfwl.itg.common;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;



import com.nfwl.itg.user.ITG_ADDRESSManager;
import com.nfwl.itg.dddw.ITG_FIXEDPOINT;
import com.nfwl.itg.em.OrderStatusEnum;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   MyFunction 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-8-13 下午05:44:28
 * @Comment
 * 
 */

public class MyFunction {

	
	public static List getZone(){
		List ls = new ArrayList();
		Connection con = null;
		try
		{
			con = dbUtil.getNfwlCon();
			ls = ITG_HZ_ZONE.gets(con);
		}catch(Exception e){
			e.printStackTrace();	
		}
		finally
		{
			if (con!=null)
				try {
					con.close();
				} catch (SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}	
		}
		

		return ls;
	}
	
	public static List getUserAddress(String user_id){
		List ls = new ArrayList();
		Connection con = null;
		try
		{
			con = dbUtil.getNfwlCon();
			ITG_ADDRESSManager iam = new ITG_ADDRESSManager();
			ls = iam.getByUser(con, user_id);
		}catch(Exception e){
			e.printStackTrace();	
		}
		finally
		{
			if (con!=null)
				try {
					con.close();
				} catch (SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}	
		}
		return ls;
	}
	public static String getOrderStatusInfo1(Integer code){
		String rs="";
		OrderStatusEnum ose = OrderStatusEnum.getByCode(code);
		if(ose!=null){
			rs = ose.getInfo();
		}
		return rs;
	}
	public static ITG_FIXEDPOINT getUserFixedPoint(String id){
		Connection con = null;
		try
		{
			con = dbUtil.getNfwlCon();
			ITG_FIXEDPOINT ifp = ITG_FIXEDPOINT.get(con, id);
			if(ifp!=null) return ifp;
			
		}catch(Exception e){
			e.printStackTrace();	
		}
		finally
		{
			if (con!=null)
				try {
					con.close();
				} catch (SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}	
		}
		return null;
	}
	
}

