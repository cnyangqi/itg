package com.nfwl.itg.order;

import java.sql.Connection;

import com.jado.JadoException;
import com.nfwl.itg.em.OrderStatusEnum;
import com.nfwl.itg.user.ITG_ORDERREC;
import com.nfwl.itg.user.ITG_ORDERRECManager;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   OrderUtil 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-11-28 下午10:15:55
 * @Comment
 * 
 */

public class OrderUtil {

	public static boolean isNewAndSelfOrder(Connection con,String order_id,String user_id) throws JadoException{
		if(order_id==null||order_id.equals("")) return false;
		ITG_ORDERRECManager iom = new ITG_ORDERRECManager();
		ITG_ORDERREC io =  iom.get(con, order_id);
		if(io!=null){
			if(io.getOr_userid().equals(user_id)){
				if(io.getOr_status()==OrderStatusEnum.NEW.getCode()){
					return true;
				}else{
					return false;
				}
			}else{
				return false;
			}
		}else{
			return false;
		}
		
	}
}

