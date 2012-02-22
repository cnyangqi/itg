package com.nfwl.itg.order;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.gemway.util.JUtil;
import com.jado.JadoException;
import com.nfwl.itg.common.Arith;
import com.nfwl.itg.common.ArtileUtil;
import com.nfwl.itg.common.DateUtil;
import com.nfwl.itg.user.ITG_ADDRESS;
import com.nfwl.itg.user.ITG_ADDRESSManager;
import com.nfwl.itg.user.ITG_CARTRECManager;
import com.nfwl.itg.user.ITG_ORDERDETAIL;
import com.nfwl.itg.user.ITG_ORDERDETAILManager;
import com.nfwl.itg.user.ITG_ORDERREC;
import com.nfwl.itg.user.ITG_ORDERRECDELIVERY;
import com.nfwl.itg.user.ITG_ORDERRECDELIVERYManager;
import com.nfwl.itg.user.ITG_ORDERRECManager;
import com.nfwl.itg.em.OrderStatusEnum;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   addressManager 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-8-7 下午04:17:21
 * @Comment
 * 
 */

public class AddressManager {

	/*
	 * 确认收货地址
	 * 
	 * 1.adr_id为other生成一条收货地址
	 * 2.把购物车的数据生成订单
	 * 
	 */
	public String confirm(Connection con,String user_id,ITG_ADDRESS address,String session_order)throws JadoException{
		String rs="";
		try{
			con.setAutoCommit(false);
			
			//如果session中有订单号，说明已经创建过了
			if(session_order!=null&&!session_order.equals("")){
				ITG_ORDERRECManager ioem = new ITG_ORDERRECManager();
				ioem.updateMoneyAndPoint(con, session_order);
				
				ITG_ORDERRECDELIVERY iod = this.addressToOrderecDelivery(address);
				iod.setOrid(session_order);
				
				ITG_ORDERRECDELIVERYManager iodm = new ITG_ORDERRECDELIVERYManager();
				iodm.orderConfirm(con, iod);
				
				rs=session_order;
			}else{
				ITG_CARTRECManager icm = new ITG_CARTRECManager();
				List carts = icm.getCartByUser(con, user_id);
				if(carts!=null&&carts.size()>0){
					List<ITG_ORDERDETAIL> ioes = new ArrayList<ITG_ORDERDETAIL>();
					String orderid = JUtil.createUNID();//主订单id
					rs=orderid;
					BigDecimal price = new BigDecimal(0);
					BigDecimal point = new BigDecimal(0);
					for (int i = 0; i < carts.size(); i++) {
						ITG_ORDERDETAIL ioe = new ITG_ORDERDETAIL();
						Map m = (Map) carts.get(i);
						Double amount = Double.valueOf(m.get("amount").toString());
						ioe.setOd_id(JUtil.createUNID());
						ioe.setOd_num(amount);
						ioe.setOd_orid(orderid);
						ioe.setOd_prdid((String)m.get("prd_id"));
						ioe.setOd_prdname((String)m.get("prd_name"));
						Double _price = Double.valueOf(m.get("prd_price").toString());
						price =  price.add(new BigDecimal(Arith.mul(Arith.round(_price, 2),Arith.round(amount, 2)))); 
						ioe.setOd_price(_price);
						Double _point = Double.valueOf(m.get("prd_point").toString());
						point = price.add(new BigDecimal(Arith.mul(Arith.round(_point, 2),Arith.round(amount, 2))));
						ioes.add(ioe);
					}
					String no=DateUtil.getCurrentMonth()+""+DateUtil.getCurrentDay()+""+DateUtil.getCurrentHour()+""+DateUtil.getCurrentMillSecond()+""+DateUtil.getCurrentMinute();
					ITG_ORDERREC or = new ITG_ORDERREC();
					or.setOr_id(orderid);
					or.setOr_money(price.doubleValue());
					or.setOr_no(no);
					or.setOr_point(point.doubleValue());
					or.setOr_status(OrderStatusEnum.NEW.getCode());
					or.setOr_userid(user_id);
					ITG_ORDERRECManager iom = new ITG_ORDERRECManager();
					iom.insert(con, or);
					ITG_ORDERDETAILManager ioem = new ITG_ORDERDETAILManager();
					for(ITG_ORDERDETAIL ioe:ioes){
						ioem.insert(con, ioe);
					}
					
					ITG_ORDERRECDELIVERY iod = this.addressToOrderecDelivery(address);
					iod.setOrid(orderid);
					
					ITG_ORDERRECDELIVERYManager iodm = new ITG_ORDERRECDELIVERYManager();
					iodm.orderConfirm(con, iod);
					
				}
				icm.delByuser(con, user_id);
			}
			
			con.commit();
			con.setAutoCommit(true);
		}catch (Exception e) {
			try {
				con.rollback();
			} catch (SQLException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}finally{
			try {
				con.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return rs;
	}
	
	
	public String order_goconfirm(Connection con,String user_id,ITG_ADDRESS address,String prd_id,Double amount)throws JadoException{
		String rs="";
		try{
			con.setAutoCommit(false);
			
			Map map = ArtileUtil.getByCart(con, prd_id);
			if(map!=null){
				Double _price = Double.valueOf(map.get("prd_price").toString());
				Double _point = Double.valueOf(map.get("prd_point").toString());
				String orderid = JUtil.createUNID();//主订单id
				String no=DateUtil.getCurrentMonth()+""+DateUtil.getCurrentDay()+""+DateUtil.getCurrentHour()+""+DateUtil.getCurrentMillSecond()+""+DateUtil.getCurrentMinute();
				
				
				ITG_ORDERREC or = new ITG_ORDERREC();
				or.setOr_id(orderid);
				or.setOr_no(no);
				or.setOr_status(OrderStatusEnum.NEW.getCode());
				or.setOr_userid(user_id);
				or.setOr_money(Arith.mul(Arith.round(_price, 2),Arith.round(amount, 2)));
				or.setOr_point(Arith.mul(Arith.round(_point, 2),Arith.round(amount, 2)));
				ITG_ORDERRECManager iom = new ITG_ORDERRECManager();
				iom.insert(con, or);
				
				ITG_ORDERDETAIL ioe = new ITG_ORDERDETAIL();
				ioe.setOd_id(JUtil.createUNID());
				ioe.setOd_num(amount);
				ioe.setOd_orid(orderid);
				ioe.setOd_prdid((String)map.get("prd_id"));
				ioe.setOd_prdname((String)map.get("prd_name"));
				ioe.setOd_price(_price);
				ITG_ORDERDETAILManager ioem = new ITG_ORDERDETAILManager();
				ioem.insert(con, ioe);
				
				ITG_ORDERRECDELIVERY iod = this.addressToOrderecDelivery(address);
				iod.setOrid(orderid);
				
				ITG_ORDERRECDELIVERYManager iodm = new ITG_ORDERRECDELIVERYManager();
				iodm.orderConfirm(con, iod);
				
				rs=orderid;
				
			}
			con.commit();
			con.setAutoCommit(true);
		}catch (Exception e) {
			try {
				con.rollback();
			} catch (SQLException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}finally{
			try {
				con.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return rs;
	}
	
	public ITG_ORDERRECDELIVERY changeAddress(Connection con,String order_id,String adr_id,String itg_fixedpoint)throws JadoException{
		ITG_ADDRESSManager idm = new ITG_ADDRESSManager();
		ITG_ADDRESS address = null;
		if(adr_id.equals("itg_fixedpoint")){
			address = new ITG_ADDRESS();
 			address.setAdr_fpid(itg_fixedpoint);
 		}else{
 			address = idm.get(con, adr_id);
 		}
		ITG_ORDERRECDELIVERY iod = this.addressToOrderecDelivery(address);
		iod.setOrid(order_id);
		
		ITG_ORDERRECDELIVERYManager iodm = new ITG_ORDERRECDELIVERYManager();
		iodm.orderConfirm(con, iod);
		
		return iod;
	}
	private ITG_ORDERRECDELIVERY addressToOrderecDelivery(ITG_ADDRESS ia){
		ITG_ORDERRECDELIVERY iod = new ITG_ORDERRECDELIVERY();
		iod.setName(JUtil.convertNull(ia.getAdr_name()));
		if(ia.getAdr_zone()!=null)iod.setZone(ia.getAdr_zone());
		iod.setDetail(JUtil.convertNull(ia.getAdr_detail()));
		iod.setAreacode(JUtil.convertNull(ia.getAdr_areacode()));
		iod.setTelephone(JUtil.convertNull(ia.getAdr_telephone()));
		iod.setSubnum(JUtil.convertNull(ia.getAdr_subnum()));
		iod.setPostcode(JUtil.convertNull(ia.getAdr_postcode()));
		iod.setMobile(JUtil.convertNull(ia.getAdr_mobile()));
		iod.setEmail(JUtil.convertNull(ia.getAdr_email()));
		iod.setFpid(JUtil.convertNull(ia.getAdr_fpid()));
		iod.setAdrid(JUtil.convertNull(ia.getAdr_id()));
		
		return iod;
	}
}

