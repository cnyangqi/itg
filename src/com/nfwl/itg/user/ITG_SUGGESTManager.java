package com.nfwl.itg.user;

import java.sql.Connection;
import java.util.List;

import com.gemway.util.JUtil;
import com.jado.JadoException;
import com.jado.Enum.FieldTypeEnum;
import com.jado.Enum.TermEnum;
import com.jado.bean.Bean;
import com.jado.bean.TermBean;
import com.jado.dao.OracleDao;
import com.nfwl.itg.common.DateUtil;

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

public class ITG_SUGGESTManager {

	 private String table="ITG_SUGGEST";
	
	 private String primary_key="sg_id";
	 
	 private ITG_SUGGEST bean;

	 private OracleDao od;
	 
	
	public ITG_SUGGEST getBean() {
		return bean;
	}

	public void setBean(ITG_SUGGEST bean) {
		this.bean = bean;
	}

	public ITG_SUGGEST insert(Connection con,ITG_SUGGEST bean) throws JadoException{
		this.bean=bean;
		this.initBeanInfo();
		if(this.getBean().getSg_id()==null||this.getBean().getSg_id().equals("")) this.getBean().setSg_id(JUtil.createUNID());
		od.insert(con);
		return this.bean;
		
	}
	public List<Bean> getByUser(Connection con,String user_id)throws JadoException{
		return this.getByUser(con, user_id, 0, 0);
		
	}
	public List getByUser(Connection con,String user_id,int start,int size)throws JadoException{
		this.initBeanInfo();
		this.bean.addTerm(new TermBean("sg_userid",user_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
		return this.od.search(con,start,size);
		
	}
	public int getByUserSize(Connection con,String user_id)throws JadoException{
		this.initBeanInfo();
		this.bean.addTerm(new TermBean("sg_userid",user_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
		return this.od.getCount(con);
		
	}
	public void reply(Connection con,String sg_id,String user_id,String user_name,String content)throws JadoException{
		ITG_SUGGEST ts = new ITG_SUGGEST();
		ts.setSg_content(content);
		ts.setSg_id(sg_id);
		ts.setSg_replierid(user_id);
		ts.setSg_repliername(user_name);
		ts.setSg_replytime(new java.sql.Date(DateUtil.getCurrentDate().getTime()));
		this.bean = ts;
		this.initBeanInfo();
		this.od.update(con);
		
	}
	private void initBeanInfo() throws JadoException{
		if(this.bean==null) bean = new ITG_SUGGEST();
		this.bean.setTable(table);
		this.bean.setPrimary_key(primary_key);
		this.od = new OracleDao(this.bean);
	}
	
}

