package com.nfwl.itg.user;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import com.gemway.util.JUtil;
import com.jado.JLog;
import com.jado.JadoException;
import com.jado.bean.Bean;
import com.jado.dao.OracleDao;
import com.nfwl.itg.common.DateUtil;
import com.nfwl.itg.em.RechargeTypeEnum;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   ITG_SUGGESTManager 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-7-23 下午10:09:54
 * @Comment
 * 
 */

public class ITG_SAVECARDManager {

	 private String table="ITG_SAVECARD";
	
	 private String primary_key="sc_cardno";
	 
	 private ITG_SAVECARD bean;

	 private OracleDao od;
	 
	public String recharge(Connection con,String user_id,String cardno,String cardpwd)throws JadoException{
		String s="";
		ITG_SAVECARD _bean = (ITG_SAVECARD)this.getbyCardno(con, cardno);
		if(_bean==null){
			return "你输入的卡号有误！";
		}else{
			if(_bean.getSc_balance()==0.0){
				return "你输入的卡号金额为0";
			}else{
				if(_bean.getSc_cardpwd().equals(cardpwd)){
					Statement stmt=null;
					ResultSet rs = null;
					
					try{
						con.setAutoCommit(false);
						String sql="select * from ITG_SAVECARD where sc_cardno='"+cardno+"' for update";

						 stmt=con.createStatement();
				         rs = stmt.executeQuery(sql); 
				         if (rs.next())
				         { 
				        	 UserManager um = new UserManager();
				        	 boolean b = um.addMoney(con, user_id, _bean.getSc_balance());
				        	 if(b){
				        		 this.userCard(con, cardno);
				        		 ITG_RECHARGERECManager irm = new ITG_RECHARGERECManager();
				        		 ITG_RECHARGEREC ir = new ITG_RECHARGEREC();
				        		 ir.setRcr_id(JUtil.createUNID());
				        		 ir.setRcr_userid(user_id);
				        		 ir.setRcr_cardno(cardno);
				        		 ir.setRcr_cardpwd(cardpwd);
				        		 ir.setRcr_money(_bean.getSc_balance());
				        		 ir.setRcr_type(RechargeTypeEnum.CARDRECHARGE.getCode());
				        		 irm.insert(con, ir);
				        		 s="冲值成功！";
				        	 }else{
				        		 s="冲值出错";
				        	 }
				        	 
				         }
						con.setAutoCommit(true);
						con.commit();
					}
					catch (Exception ex){
						try {
							con.rollback();
						} catch (SQLException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
						if(ex instanceof JadoException) throw (JadoException)ex;
				          JLog.getLogger().error("冲值出错:",ex);
				          throw new JadoException("冲值出错！");
					}finally{
						try {
							if(stmt!=null) stmt.close();
							if(rs!=null) rs.close();
						} catch (SQLException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
					}
				}else{
					return "密码有误！";
				}
			}
		}
		
		return s;
	}
	public ITG_SAVECARD getBean() {
		return bean;
	}

	public void setBean(ITG_SAVECARD bean) {
		this.bean = bean;
	}

	public ITG_SAVECARD insert(Connection con,ITG_SAVECARD bean) throws JadoException{
		this.bean=bean;
		this.initBeanInfo();
		od.insert(con);
		return this.bean;
		
	}
	public Bean getbyCardno(Connection con,String cardno)throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		this.bean.setSc_cardno(cardno);
		return this.od.get(con);
		
	}
	public boolean check(Connection con,String cardno,String cardpwd)throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		this.bean.setSc_cardno(cardno);
		this.bean.setSc_cardpwd(cardpwd);
		Bean b= this.od.get(con);
		if(b==null){
			return false;
		}else{
			return true;
		}
	}
	//设置使用时间和余额为0，表示已经使用过
	public void userCard(Connection con,String cardno) throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		this.bean.setSc_cardno(cardno);
		this.bean.setSc_balance(0.0);
		this.bean.setSc_usetime(new java.sql.Date(DateUtil.getCurrentDate().getTime()));
		this.od.update(con);
	}
	
	private void initBeanInfo() throws JadoException{
		if(this.bean==null) bean = new ITG_SAVECARD();
		this.bean.setTable(table);
		this.bean.setPrimary_key(primary_key);
		this.od = new OracleDao(this.bean);
	}
	
}

