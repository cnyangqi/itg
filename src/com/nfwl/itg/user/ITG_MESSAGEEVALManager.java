package com.nfwl.itg.user;

import java.sql.Connection;
import java.util.List;

import com.gemway.util.JUtil;
import com.jado.DbUtils_DAO;
import com.jado.JadoException;
import com.jado.Enum.FieldTypeEnum;
import com.jado.Enum.TermEnum;
import com.jado.bean.Bean;
import com.jado.bean.TermBean;
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

public class ITG_MESSAGEEVALManager {

	 private String table="ITG_MESSAGEEVAL";
		
	 private String primary_key="me_id";
	 
	 private ITG_MESSAGEEVAL bean;

	 private OracleDao od;
	 
	
	public ITG_MESSAGEEVAL getBean() {
		return bean;
	}

	public void setBean(ITG_MESSAGEEVAL bean) {
		this.bean = bean;
	}

	public ITG_MESSAGEEVAL insert(Connection con,ITG_MESSAGEEVAL bean) throws JadoException{
		this.bean=bean;
		this.initBeanInfo();
		if(this.getBean().getMe_id()==null||this.getBean().getMe_id().equals("")) this.getBean().setMe_id(JUtil.createUNID());
		od.insert(con);
		return this.bean;
		
	}
	public List getByUser(Connection con,String user_id,String mi_type)throws JadoException{
		return this.getByUser(con, user_id,mi_type, 0, 0);
		
	}
	public List getByUser(Connection con,String user_id,String mi_type,int start,int size)throws JadoException{
		//this.initBeanInfo();
		//this.bean.addTerm(new TermBean("me_userid",user_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
		//return this.od.search(con,start,size);
		String sql = " select * " +
				"  from ITG_MESSAGEEVAL t1,ITG_ORDERDETAIL t2 where t1.me_odid=t2.od_id and t1.me_userid=? and t1.me_type=? ";
		DbUtils_DAO dd = new DbUtils_DAO();
		Object[] obj = new Object[]{user_id,mi_type};
		return dd.MapListHandler_Search(con, sql, obj, start, size);
	}
	public int getByUserSize(Connection con,String user_id,String mi_type)throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		this.bean.addTerm(new TermBean("me_userid",user_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
		if(!mi_type.equals("")) this.bean.addTerm(new TermBean("me_type",mi_type,FieldTypeEnum.STRING,TermEnum.EQUAL));
		return this.od.getCount(con);
		
	}
	public List<Bean> getByOrderDetail(Connection con,String detail_id)throws JadoException{
		return this.getByOrderDetail(con, detail_id, 0, 0);
		
	}
	public List<Bean> getByOrderDetail(Connection con,String detail_id,int start,int size)throws JadoException{
		this.initBeanInfo();
		this.bean.addTerm(new TermBean("me_odid",detail_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
		return this.od.search(con,start,size);
		
	}
	public boolean isEvel(Connection con,String od_id)throws JadoException{
		this.initBeanInfo();
		this.bean.addTerm(new TermBean("me_odid",od_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
		this.bean.addTerm(new TermBean("me_type",2,FieldTypeEnum.INTEGER,TermEnum.EQUAL));
		int count = this.od.getCount(con);
		if(count>0){
			return true;
		}else{
			return false;
		}
	}
	private void initBeanInfo() throws JadoException{
		if(this.bean==null) bean = new ITG_MESSAGEEVAL();
		this.bean.setTable(table);
		this.bean.setPrimary_key(primary_key);
		this.od = new OracleDao(this.bean);
	}
	
}

