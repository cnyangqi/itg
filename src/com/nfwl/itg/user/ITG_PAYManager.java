package com.nfwl.itg.user;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import com.gemway.util.JUtil;
import com.jado.JLog;
import com.jado.JadoException;
import com.jado.Enum.FieldTypeEnum;
import com.jado.Enum.TermEnum;
import com.jado.bean.Bean;
import com.jado.bean.TermBean;
import com.jado.dao.OracleDao;
import com.nfwl.itg.common.DateUtil;
import com.nfwl.itg.em.AlipayNotifyStatusEnum;
import com.nfwl.itg.em.AlipayNotifyTypeEnum;
import com.nfwl.itg.em.OrderStatusEnum;
import com.nfwl.itg.em.PayLogEnum;
import com.nfwl.itg.em.PointrecTypeEnum;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   ITH_COLLECTRECManager 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-7-23 下午08:55:20
 * @Comment
 * 
 */

public class ITG_PAYManager {

	 private String table="ITG_PAY";
		
	 private String primary_key="pay_id";
	 
	 private ITG_PAY bean;

	 private OracleDao od;
	 
	
	public ITG_PAY getBean() {
		return bean;
	}

	public void setBean(ITG_PAY bean) {
		this.bean = bean;
	}

	public void alipaySucceed(Connection con,String trade_no,String order_id,Double money,String buyer_email,String trade_status)throws JadoException{
		try{
			
			con.setAutoCommit(false);
			
			ITG_ORDERRECManager igom =new ITG_ORDERRECManager();
			ITG_ORDERREC igo = (ITG_ORDERREC)igom.get(con, order_id);
			if(igo!=null){
				//如果订单为新建或者为确认
				if(igo.getOr_status()==OrderStatusEnum.NEW.getCode()||igo.getOr_status()==OrderStatusEnum.CONFIRM.getCode()){
					this.initBeanInfo();
					this.bean.setPay_money(money);
					this.bean.setPay_status(1);
					this.bean.setPay_time(new java.sql.Date(DateUtil.getCurrentDate().getTime()));
					this.bean.addTerm(new TermBean("pay_orderid",order_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
					this.od.update(con);
					
					//积分记录
					ITG_POINTREC ip = new ITG_POINTREC();
					ip.setPr_id(JUtil.createUNID());
					ip.setPr_point(igo.getOr_point().intValue());
					ip.setPr_resourceid(order_id);
					ip.setPr_type(PointrecTypeEnum.BUY.getCode());
					ip.setPr_userid(igo.getOr_userid());
					ITG_POINTRECManager ipm = new ITG_POINTRECManager();
					ipm.insert(con, ip);
					
					//更新积份
					UserManager um = new UserManager();
					um.addPoint(con,  igo.getOr_userid(), igo.getOr_point().intValue());
					
					//更新订单
					igom =new ITG_ORDERRECManager();
					igom.paid(con, order_id);
					
					//记录支付日志
					ITG_ALIPAYNOTIFY ja = new ITG_ALIPAYNOTIFY();
					ja.setBuyer_email(buyer_email);
					ja.setOut_trade_no(order_id);
					ja.setStatus(AlipayNotifyStatusEnum.SUCCESS.getCode());
					ja.setTotal_fee(money.toString());
					ja.setTrade_no(trade_no);
					ja.setTrade_status(trade_status);
					ja.setType( AlipayNotifyTypeEnum.PAYMENT.getCode());
					
					ITG_ALIPAYNOTIFYManager jam = new ITG_ALIPAYNOTIFYManager();
					jam.newNotify(con,ja);
					
					
				}else{
					ITG_ALIPAYNOTIFY _ja = new ITG_ALIPAYNOTIFY();
					_ja.setBuyer_email(buyer_email);
					_ja.setOut_trade_no(trade_no);
					_ja.setStatus(AlipayNotifyStatusEnum.REPEAY.getCode());
					_ja.setTotal_fee(money.toString());
					_ja.setTrade_no(trade_no);
					_ja.setTrade_status(trade_status);
					_ja.setType(AlipayNotifyTypeEnum.PAYMENT.getCode() );
					
					ITG_ALIPAYNOTIFYManager _jam = new ITG_ALIPAYNOTIFYManager();
					_jam.newNotify(con,_ja);
				}
			}else{
				ITG_ALIPAYNOTIFY _ja = new ITG_ALIPAYNOTIFY();
				_ja.setBuyer_email(buyer_email);
				_ja.setOut_trade_no(trade_no);
				_ja.setStatus(AlipayNotifyStatusEnum.NOTFINDORDER.getCode());
				_ja.setTotal_fee(money.toString());
				_ja.setTrade_no(trade_no);
				_ja.setTrade_status(trade_status);
				_ja.setType( AlipayNotifyTypeEnum.PAYMENT.getCode());
				
				ITG_ALIPAYNOTIFYManager _jam = new ITG_ALIPAYNOTIFYManager();
				_jam.newNotify(con,_ja);
			}
			con.setAutoCommit(true);
			con.commit();
		}catch (Exception ex){
			try {
				con.rollback();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			ITG_ALIPAYNOTIFY ja = new ITG_ALIPAYNOTIFY();
			ja.setBuyer_email(buyer_email);
			ja.setOut_trade_no(order_id);
			ja.setStatus(AlipayNotifyStatusEnum.EXCEPTION.getCode());
			ja.setTotal_fee(money.toString());
			ja.setTrade_no(trade_no);
			ja.setTrade_status(trade_status);
			ja.setType(AlipayNotifyTypeEnum.PAYMENT.getCode());
			
			ITG_ALIPAYNOTIFYManager jam = new ITG_ALIPAYNOTIFYManager();
			jam.newNotify(con,ja);
			
		}
	
	}
	
	public String defaultpay(Connection con,String user_id,String order_id)throws JadoException{
		String s="";
		UserManager um = new UserManager();
		User user = (User) um.get(con, user_id);
		if(user==null){
			s = "你不是合法用户，不能付款!";
		}else{
			ITG_ORDERRECManager igom =new ITG_ORDERRECManager();
			ITG_ORDERREC igo = (ITG_ORDERREC) igom.get(con, order_id);
			if(igo==null){
				s = "没有可以付款的订单!";
			}else{
				try{
					con.setAutoCommit(false);
					Boolean b = um.minusMoney(con, user.getId(), igo.getOr_money());
					if(b){
						//更新支付信息
						this.bean=null;
						this.initBeanInfo();
						this.bean.setPay_money(igo.getOr_money());
						this.bean.setPay_status(1);
						this.bean.setPay_time(new java.sql.Date(DateUtil.getCurrentDate().getTime()));
						this.bean.addTerm(new TermBean("pay_orderid",order_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
						this.od.update(con);
						
						ITG_POINTREC ip = new ITG_POINTREC();
						ip.setPr_id(JUtil.createUNID());
						ip.setPr_point(igo.getOr_point().intValue());
						ip.setPr_resourceid(order_id);
						ip.setPr_type(1);
						ip.setPr_userid(user.getId());
						ITG_POINTRECManager ipm = new ITG_POINTRECManager();
						ipm.insert(con, ip);
						
						//更新订单信息
						igom.paid(con, igo.getOr_id());
						
						//更新积分信息
						um.addPoint(con,  user.getId(), igo.getOr_point().intValue());

						con.setAutoCommit(true);
						con.commit();

						s="支付成功";
					}else{
						s="你没有足够的余额支付，请冲值或选择其它支付方式!";
					}
				}catch (Exception ex){
					try {
						con.rollback();
					} catch (SQLException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
					if(ex instanceof JadoException) throw (JadoException)ex;
			          JLog.getLogger().error("支付出错:",ex);
			          throw new JadoException("支付出错！");
				}
			}
		}
		return s;
		
	}
	public Bean getByOrder(Connection con,String order_id) throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		this.bean.addTerm(new TermBean("pay_orderid",order_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
		List<Bean> ls = this.od.search(con);
		for(Bean b:ls){
			return b;
		}
		return null;
		
		
	}
	public void createPay(Connection con,ITG_PAY bean) throws JadoException{
		try{
			con.setAutoCommit(false);
			this.initBeanInfo();
			this.bean.addTerm(new TermBean("pay_orderid",bean.getPay_orderid(),FieldTypeEnum.STRING,TermEnum.EQUAL));
			this.od.delete(con);
			
			this.bean=bean;
			this.initBeanInfo();
			if(this.getBean().getPay_id()==null||this.getBean().getPay_id().equals("")) this.getBean().setPay_id(JUtil.createUNID());
			this.od.insert(con);
			
			
			con.commit();
			con.setAutoCommit(true);
		}
		catch (Exception ex){
			try {
				con.rollback();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			if(ex instanceof JadoException) throw (JadoException)ex;
	          JLog.getLogger().error("创建订单支付信息出错:",ex);
	          throw new JadoException("创建订单支付信息出错！");
		}
	}
	/*
	public void setPaytype(Connection con,String pay_id,Integer type)throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		this.bean.setPay_id(pay_id);
		this.bean.setPay_type(type);
		this.od.update(con);
	}*/
	
	private void initBeanInfo() throws JadoException{
		if(this.bean==null) bean = new ITG_PAY();
		this.bean.setTable(table);
		this.bean.setPrimary_key(primary_key);
		this.od = new OracleDao(this.bean);
	}
}

