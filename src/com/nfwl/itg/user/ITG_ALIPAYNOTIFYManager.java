package com.nfwl.itg.user;



import java.sql.Connection;

import com.gemway.util.JUtil;
import com.jado.JadoException;
import com.jado.dao.OracleDao;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   ITG_ALIPAYNOTIFYManager 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-11-24 下午09:02:11
 * @Comment
 * 
 */

public class ITG_ALIPAYNOTIFYManager {
	
	 private String table="ITG_ALIPAYNOTIFY";
		
	 private String primary_key="id";
	 
	 private String prefix=""; 
	 
	 private ITG_ALIPAYNOTIFY bean;

	 private OracleDao od;
	 

	 public ITG_ALIPAYNOTIFY getBean() {
			return bean;
		}

	public void setBean(ITG_ALIPAYNOTIFY bean) {
		this.bean = bean;
	}
	private void initBeanInfo() throws JadoException{
		if(this.bean==null) bean = new ITG_ALIPAYNOTIFY();
		this.bean.setTable(table);
		this.bean.setPrimary_key(primary_key);
		bean.setColumPrefix(prefix);
		this.od = new OracleDao(this.bean);
	}

   

     public ITG_ALIPAYNOTIFY newNotify(Connection con,ITG_ALIPAYNOTIFY jdy) throws JadoException{
		 this.bean=jdy;
		 this.initBeanInfo();
		 if(this.getBean().getId()==null||this.getBean().getId().equals(""))
					this.getBean().setId(JUtil.createUNID());
		 this.od.insert(con);
		 return jdy;
	 }
}

