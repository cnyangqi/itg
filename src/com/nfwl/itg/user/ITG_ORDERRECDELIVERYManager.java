package com.nfwl.itg.user;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;


import com.gemway.partner.JLog;

import com.gemway.util.JUtil;
import com.jado.JadoException;
import com.jado.Enum.FieldTypeEnum;
import com.jado.Enum.TermEnum;
import com.jado.bean.Bean;
import com.jado.bean.TermBean;
import com.jado.dao.OracleDao;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   ITG_ADDRESSManager 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-7-24 上午11:49:26
 * @Comment
 * 
 */

public class ITG_ORDERRECDELIVERYManager {

	 private String table="ITG_ORDERRECDELIVERY";
		
	 private String primary_key="id";
	 
	 private String prefix="od_"; 
	 
	 private ITG_ORDERRECDELIVERY bean;

	 private OracleDao od;
	 
	
	public ITG_ORDERRECDELIVERY getBean() {
		return bean;
	}

	public void setBean(ITG_ORDERRECDELIVERY bean) {
		this.bean = bean;
	}
	private void initBeanInfo() throws JadoException{
		if(this.bean==null) bean = new ITG_ORDERRECDELIVERY();
		this.bean.setTable(table);
		this.bean.setPrimary_key(primary_key);
		bean.setColumPrefix(prefix);
		this.od = new OracleDao(this.bean);
	}
	public ITG_ORDERRECDELIVERY insert(Connection con,ITG_ORDERRECDELIVERY bean) throws JadoException{
		try{
			
			this.bean=bean;
			this.initBeanInfo();
			if(this.getBean().getId()==null||this.getBean().getId().equals("")) this.getBean().setId(JUtil.createUNID());
			od.insert(con);
			
		}catch (Exception ex){
			if(ex instanceof JadoException) throw (JadoException)ex;
	          JLog.getLogger().error("增加收货地址时出错:",ex);
	          throw new JadoException("增加收货地址时出错！");
		}
		
		return this.bean;
	}
	public ITG_ORDERRECDELIVERY getByOrder(Connection con,String or_id)throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		this.bean.addTerm(new TermBean("orid",or_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
		List<Bean>  ls = this.od.search(con);
		for(Bean b:ls){
			return (ITG_ORDERRECDELIVERY) b;
		}
		return null;
		
	}
	public Bean get(Connection con,String id)throws JadoException{
		this.initBeanInfo();
		this.bean.setId(id);
		return this.od.get(con);
	}
	
	public boolean modfiy(Connection con,ITG_ORDERRECDELIVERY id)throws JadoException{
		this.bean=id;
		this.initBeanInfo();
		Integer i = this.od.update(con);
		if(i==1){
			return true;
		}else{
			return false;
		}
	}
	/**
	 * 确认地址
	 * @param con
	 * @param io
	 * @return  是否第一次确认地址
	 * @throws JadoException 
	 */
	public boolean orderConfirm(Connection con,ITG_ORDERRECDELIVERY iod) throws JadoException{
		ITG_ORDERRECDELIVERY oldiod = this.getByOrder(con, iod.getOrid());
		if(oldiod==null){
			this.insert(con, iod);
			return true;
		}else{
			iod.setId(oldiod.getId());
			this.modfiy(con, iod);
			return false;
		}
	}

}

