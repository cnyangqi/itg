package com.nfwl.itg.user;

import java.sql.Connection;
import java.util.List;

import com.gemway.util.JUtil;
import com.jado.DbUtils_DAO;
import com.jado.JadoException;
import com.jado.Enum.FieldTypeEnum;
import com.jado.Enum.TermEnum;
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

public class ITG_COLLECTRECManager {

	 private String table="ITG_COLLECTREC";
		
	 private String primary_key="col_id";
	 
	 private ITG_COLLECTREC bean;

	 private OracleDao od;
	 
	
	public ITG_COLLECTREC getBean() {
		return bean;
	}

	public void setBean(ITG_COLLECTREC bean) {
		this.bean = bean;
	}

	public ITG_COLLECTREC insert(Connection con,ITG_COLLECTREC bean) throws JadoException{
		this.bean=bean;
		this.initBeanInfo();
		if(this.getBean().getCol_id()==null||this.getBean().getCol_id().equals("")) this.getBean().setCol_id(JUtil.createUNID());
		od.insert(con);
		return this.bean;
		
	}
	public List getByUser(Connection con,String user_id)throws JadoException{
		return this.getByUser(con, user_id, 0, 0);
		
	}
	public List getByUser(Connection con,String user_id,int start,int size)throws JadoException{
		String sql = " select col_id,col_artid,ic.col_time,art.pic_url,art.url_gen,art.title,art.score,art.prd_name,art.prd_newlevel,art.prd_marketprice,art.prd_localprice,art.prd_point,art.PRD_BRANDNAME,art.PRD_ORIGINCOUNTRYNAME,art.PRD_ORIGINPROVINCENAME,art.PRD_CODE from ITG_COLLECTREC ic,article art where ic.col_artid=art.id and ic.col_userid=?";
		DbUtils_DAO dd = new DbUtils_DAO();
		Object[] obj = new Object[]{user_id};
		return dd.MapListHandler_Search(con, sql, obj, start, size);
		
	}
	public int getByUserSize(Connection con,String user_id)throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		if(!user_id.equals("")) this.bean.addTerm(new TermBean("col_userid",user_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
		return this.od.getCount(con);
		
	}
	public void delete(Connection con,String id,String user_id)throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		this.bean.addTerm(new TermBean("col_userid",user_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
		this.bean.setCol_id(id);
		this.od.delete(con);
	}
	private void initBeanInfo() throws JadoException{
		if(this.bean==null) bean = new ITG_COLLECTREC();
		this.bean.setTable(table);
		this.bean.setPrimary_key(primary_key);
		this.od = new OracleDao(this.bean);
	}
}

