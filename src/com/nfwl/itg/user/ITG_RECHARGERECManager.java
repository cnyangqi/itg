package com.nfwl.itg.user;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import com.gemway.util.JUtil;
import com.jado.DbUtils_DAO;
import com.jado.JadoException;
import com.jado.Enum.FieldTypeEnum;
import com.jado.Enum.TermEnum;
import com.jado.bean.Bean;
import com.jado.bean.TermBean;
import com.jado.dao.OracleDao;
import com.nfwl.itg.common.Arith;
import com.nfwl.itg.em.AlipayNotifyStatusEnum;
import com.nfwl.itg.em.AlipayNotifyTypeEnum;
import com.nfwl.itg.em.RechargeTypeEnum;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   ITG_RECHARGERECManager 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-7-23 下午07:59:46
 * @Comment
 * 
 */

public class ITG_RECHARGERECManager {

	
	 private String table="ITG_RECHARGEREC";
		
	 private String primary_key="rcr_id";
	 
	 private ITG_RECHARGEREC bean;

	 private OracleDao od;
	 
	
	public ITG_RECHARGEREC getBean() {
		return bean;
	}

	public void setBean(ITG_RECHARGEREC bean) {
		this.bean = bean;
	}

	public ITG_RECHARGEREC insert(Connection con,ITG_RECHARGEREC bean) throws JadoException{
		this.bean=bean;
		this.initBeanInfo();
		if(this.getBean().getRcr_id()==null||this.getBean().getRcr_id().equals("")) this.getBean().setRcr_id(JUtil.createUNID());
		od.insert(con);
		return this.bean;
		
	}
	public ITG_RECHARGEREC get(Connection con,String id)throws JadoException{
		this.initBeanInfo();
		this.bean.setRcr_id(id);
		return (ITG_RECHARGEREC) this.od.get(con);
	}
	public List<Bean> getByUser(Connection con,String user_id)throws JadoException{
		return this.getByUser(con, user_id, 0, 0);
		
	}
	public List getByUser(Connection con,String user_id,int start,int size)throws JadoException{
		this.initBeanInfo();
		this.bean.addTerm(new TermBean("rcr_userid",user_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
		return this.od.search(con,start,size);
		
	}
	public int getByUserSize(Connection con,String user_id)throws JadoException{
		this.initBeanInfo();
		if(!user_id.equals("")) this.bean.addTerm(new TermBean("rcr_userid",user_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
		return this.od.getCount(con);
	}
	
	
	
	
	public ITG_RECHARGEREC alipayRecharge(Connection con,String user_id)throws JadoException{
		ITG_RECHARGEREC irg = new ITG_RECHARGEREC();
		irg.setRcr_id(JUtil.createUNID());
		irg.setRcr_userid(user_id);
		irg.setRcr_type(RechargeTypeEnum.ALIPAYRECHARGE.getCode());
		irg.setRcr_money(0.0D);
		return this.insert(con, irg);
		
	}
	public void alipayRechargeSuccess(Connection con,String no,String trade_no,String buyer_email ,Double total_fee,String trade_status)throws JadoException{
		try{
			con.setAutoCommit(false);
			ITG_RECHARGEREC ir = this.get(con, no);
			total_fee = Arith.round(total_fee,2);
			boolean falg = this.rechargeReturn(con, no, total_fee,trade_no,buyer_email);
			if(falg){
				ITG_ALIPAYNOTIFY ja = new ITG_ALIPAYNOTIFY();
				ja.setBuyer_email(buyer_email);
				ja.setOut_trade_no(no);
				ja.setStatus(AlipayNotifyStatusEnum.SUCCESS.getCode());
				ja.setTotal_fee(total_fee.toString());
				ja.setTrade_no(trade_no);
				ja.setTrade_status(trade_status);
				ja.setType(AlipayNotifyTypeEnum.RECHARGE.getCode());
				
				ITG_ALIPAYNOTIFYManager jam = new ITG_ALIPAYNOTIFYManager();
				jam.newNotify(con,ja);
				
				UserManager um = new UserManager();
			
				boolean rfalg = um.addMoney(con, ir.getRcr_userid(), total_fee);
				
				if(rfalg){
					con.commit();
				}else{
					con.rollback();
					ITG_ALIPAYNOTIFY _ja = new ITG_ALIPAYNOTIFY();
					_ja.setBuyer_email(buyer_email);
					_ja.setOut_trade_no(no);
					_ja.setStatus(AlipayNotifyStatusEnum.ADDMONYERROR.getCode());
					_ja.setTotal_fee(total_fee.toString());
					_ja.setTrade_no(trade_no);
					_ja.setTrade_status(trade_status);
					_ja.setType(AlipayNotifyTypeEnum.RECHARGE.getCode());
					
					ITG_ALIPAYNOTIFYManager _jam = new ITG_ALIPAYNOTIFYManager();
					_jam.newNotify(con,_ja);
				}
			}else{
				ITG_ALIPAYNOTIFY _ja = new ITG_ALIPAYNOTIFY();
				_ja.setBuyer_email(buyer_email);
				_ja.setOut_trade_no(no);
				_ja.setStatus(AlipayNotifyStatusEnum.REPEAY.getCode());
				_ja.setTotal_fee(total_fee.toString());
				_ja.setTrade_no(trade_no);
				_ja.setTrade_status(trade_status);
				_ja.setType(AlipayNotifyTypeEnum.RECHARGE.getCode());
				
				ITG_ALIPAYNOTIFYManager _jam = new ITG_ALIPAYNOTIFYManager();
				_jam.newNotify(con,_ja);
			}
			con.setAutoCommit(true);
		}catch (Exception e) {
			try {
				con.rollback();
			} catch (SQLException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
			ITG_ALIPAYNOTIFY ja = new ITG_ALIPAYNOTIFY();
			ja.setBuyer_email(buyer_email);
			ja.setOut_trade_no(no);
			ja.setStatus(AlipayNotifyStatusEnum.EXCEPTION.getCode());
			ja.setTotal_fee(total_fee.toString());
			ja.setTrade_no(trade_no);
			ja.setTrade_status(trade_status);
			ja.setType( AlipayNotifyTypeEnum.RECHARGE.getCode());
			
			ITG_ALIPAYNOTIFYManager jam = new ITG_ALIPAYNOTIFYManager();
			jam.newNotify(con,ja);
		}
	}
	
	public boolean rechargeReturn(Connection con,String cr_id,Double money,String rcr_tradeno,String rcr_buyeremail)throws JadoException{
		
		String sql="update ITG_RECHARGEREC set RCR_MONEY=?,rcr_tradeno=?,rcr_buyeremail=? where rcr_id=? and RCR_MONEY=0";
		DbUtils_DAO dd = new DbUtils_DAO();
		Integer i= dd.Execute_Sql(con, sql,new Object[]{money,rcr_tradeno,rcr_buyeremail,cr_id});
		if(i==1){
			return true;
		}else{
			return false;
		}
	
	}
	
	private void initBeanInfo() throws JadoException{
		if(this.bean==null) bean = new ITG_RECHARGEREC();
		this.bean.setTable(table);
		this.bean.setPrimary_key(primary_key);
		this.od = new OracleDao(this.bean);
	}
	
	
}

