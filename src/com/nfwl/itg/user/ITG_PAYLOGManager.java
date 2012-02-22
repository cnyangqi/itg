package com.nfwl.itg.user;

import java.sql.Connection;

import com.gemway.util.JUtil;
import com.jado.JadoException;
import com.jado.dao.OracleDao;

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

public class ITG_PAYLOGManager {

	 private String table="ITG_PAYLOG";
		
	 private String primary_key="id";
	 
	 private ITG_PAYLOG bean;

	 private OracleDao od;
	 
	
	public ITG_PAYLOG getBean() {
		return bean;
	}

	public void setBean(ITG_PAYLOG bean) {
		this.bean = bean;
	}

	public ITG_PAYLOG insert(Connection con,ITG_PAYLOG bean) throws JadoException{
		this.bean=bean;
		this.initBeanInfo();
		if(this.getBean().getId()==null||this.getBean().getId().equals("")) this.getBean().setId(JUtil.createUNID());
		od.insert(con);
		return this.bean;
		
	}
	
	private void initBeanInfo() throws JadoException{
		if(this.bean==null) bean = new ITG_PAYLOG();
		this.bean.setTable(table);
		this.bean.setPrimary_key(primary_key);
		this.od = new OracleDao(this.bean);
	}
}

