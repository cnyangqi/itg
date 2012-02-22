package com.nfwl.itg.user;

import java.sql.Connection;
import java.util.List;

import com.gemway.util.JUtil;
import com.jado.DbUtils_DAO;
import com.jado.JadoException;
import com.jado.Enum.FieldTypeEnum;
import com.jado.Enum.SortEnum;
import com.jado.Enum.TermEnum;
import com.jado.bean.Bean;
import com.jado.bean.SortBean;
import com.jado.bean.TermBean;
import com.jado.dao.OracleDao;
import com.nfwl.itg.common.DateUtil;
import com.nfwl.itg.em.OrderStatusEnum;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   ITG_ORDERRECManager 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-7-24 上午09:30:46
 * @Comment
 * 
 */

public class ITG_ORDERRECManager {
	 private String table="ITG_ORDERREC";
		
	 private String primary_key="or_id";
	 
	 private ITG_ORDERREC bean;

	 private OracleDao od;
	 
	
	public ITG_ORDERREC getBean() {
		return bean;
	}

	public void setBean(ITG_ORDERREC bean) {
		this.bean = bean;
	}

	public ITG_ORDERREC insert(Connection con,ITG_ORDERREC bean) throws JadoException{
		this.bean=bean;
		this.initBeanInfo();
		if(this.getBean().getOr_id()==null||this.getBean().getOr_id().equals("")) this.getBean().setOr_id(JUtil.createUNID());
		od.insert(con);
		return this.bean;
		
	}
	public Integer getByUserSize(Connection con,String user_id,String state) throws JadoException{
		this.initBeanInfo();
		if(!user_id.equals("")) this.bean.addTerm(new TermBean("or_userid",user_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
		if(state!=null&&!state.equals("")) this.bean.addTerm(new TermBean("or_status",state,FieldTypeEnum.STRING,TermEnum.EQUAL));
		return this.od.getCount(con);
	}
	public List<Bean> getByUser(Connection con,String user_id,String state)throws JadoException{
		return this.getByUser(con, user_id,state, 0, 0);
		
	}
	public List<Bean> getByUser(Connection con,String user_id,String state,int start,int size)throws JadoException{
		this.initBeanInfo();
		if(!user_id.equals("")) this.bean.addTerm(new TermBean("or_userid",user_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
		if(state!=null&&!state.equals("")) this.bean.addTerm(new TermBean("or_status",state,FieldTypeEnum.STRING,TermEnum.EQUAL));
		//this.bean.setOr_userid(user_id);
		this.bean.addSort(new SortBean("or_id",SortEnum.JX));
		this.bean.addSort(new SortBean("or_time",SortEnum.JX));
		this.bean.addSort(new SortBean("or_status",SortEnum.SX));
		return this.od.search(con,start,size);
	
	}
	public ITG_ORDERREC get(Connection con,String or_id)throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		this.bean.setOr_id(or_id);
		return (ITG_ORDERREC) this.od.get(con);
	}
	public List<Bean> search(Connection con ,int start,int size,Object[] obj)throws JadoException{
		String sql = " select io.*,ia.adr_detail,u.name from ITG_ORDERREC io,users u,ITG_ADDRESS ia where io.or_adrid=ia.adr_id and io.or_userid=u.id order by io.or_id desc";
		DbUtils_DAO dd = new DbUtils_DAO();
		return dd.MapListHandler_Search(con, sql,obj, start, size);
	}
	public void setCarrymode(Connection con,String or_id,Integer mode)throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		this.bean.setOr_id(or_id);
		this.bean.setOr_carrymode(mode);
		this.od.update(con);
	}
	/*
	public void setAddress(Connection con,String or_id,String adr_id)throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		this.bean.setOr_id(or_id);
		this.bean.setOr_adrid(adr_id);
		this.od.update(con);
	}*/
	/*
	public ITG_ADDRESS getAddress(Connection con,String or_id)throws JadoException{
		ITG_ORDERREC io = (ITG_ORDERREC) this.get(con, or_id);
		if(io!=null){
			ITG_ADDRESSManager idm = new ITG_ADDRESSManager();
			return (ITG_ADDRESS) idm.get(con, io.getOr_adrid());
		}
		return null;
		
	}*/
	public void confirmOrder(Connection con,ITG_ORDERREC io,String or_memo,String or_invoicetitle)throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		this.bean.setOr_time(new java.sql.Date(DateUtil.getCurrentDate().getTime()));
		this.bean.setOr_id(io.getOr_id());
		this.bean.setOr_memo(or_memo);
		this.bean.setOr_invoicetitle(or_invoicetitle);
		this.bean.setOr_status(OrderStatusEnum.CONFIRM.getCode());
		this.od.update(con);
	}
	public void paid(Connection con,String or_id)throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		this.bean.setOr_id(or_id);
		this.bean.setOr_status(OrderStatusEnum.PAID.getCode());
		this.od.update(con);
	}
	public void updateMoneyAndPoint(Connection con,String or_id)throws JadoException{
		String sql="update itg_orderrec io set (io.or_money,io.or_point)=("+
					 " select sum(ord.od_num * ats.prd_localprice),sum(ord.od_num*ats.prd_point)"+
					   " from itg_orderdetail ord, article ats"+
					  " where ats.id = od_prdid"+
					    " and ord.od_orid = io.or_id) where io.or_id=?";
		
		Object[] obj=new Object[]{or_id};
		DbUtils_DAO dd = new DbUtils_DAO();
		dd.Execute_Sql(con, sql, obj);
		
		
	}
	public void canche(Connection con,String or_id) throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		this.bean.setOr_id(or_id);
		this.bean.setOr_status(OrderStatusEnum.CANCEL.getCode());
		this.od.update(con);
	}
	public void receiving(Connection con,String or_id) throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		this.bean.setOr_id(or_id);
		this.bean.setOr_status(OrderStatusEnum.FINISH.getCode());
		this.od.update(con);
	}
	
	private void initBeanInfo() throws JadoException{
		if(this.bean==null) bean = new ITG_ORDERREC();
		this.bean.setTable(table);
		this.bean.setPrimary_key(primary_key);
		this.od = new OracleDao(this.bean);
	}
}

