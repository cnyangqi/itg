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
 * @Type：   ITG_POINTRECManager 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-7-28 下午11:05:55
 * @Comment
 * 
 */

public class ITG_POINTRECManager {

	private String table="ITG_POINTREC";
	
	 private String primary_key="pr_id";
	 
	 private ITG_POINTREC bean;

	 private OracleDao od;
	 
	
	public ITG_POINTREC getBean() {
		return bean;
	}

	public void setBean(ITG_POINTREC bean) {
		this.bean = bean;
	}

	public ITG_POINTREC insert(Connection con,ITG_POINTREC bean) throws JadoException{
		this.bean=bean;
		this.initBeanInfo();
		if(this.getBean().getPr_id()==null||this.getBean().getPr_id().equals("")) this.getBean().setPr_id(JUtil.createUNID());
		od.insert(con);
		return this.bean;
		
	}
	public List<Bean> getByUser(Connection con,String user_id)throws JadoException{
		return this.getByUser(con, user_id, 0, 0);
		
	}
	public List getByUser(Connection con,String user_id,int start,int size)throws JadoException{
		/*String sql = " select ip.*,art.title,art.score,art.prd_name,art.prd_newlevel,art.prd_marketprice,art.prd_localprice,art.prd_point,art.PRD_BRANDNAME,art.PRD_ORIGINCOUNTRYNAME,art.PRD_ORIGINPROVINCENAME,art.PRD_CODE from ITG_POINTREC ip,article art where ip.pr_resourceid=art.id and ip.pr_userid=?";
		DbUtils_DAO dd = new DbUtils_DAO();
		Object[] obj = new Object[]{user_id};
		return dd.MapListHandler_Search(con, sql, obj, start, size);*/
		this.bean=null;
		this.initBeanInfo();
		this.bean.addTerm(new TermBean("pr_userid",user_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
		return this.od.search(con, start, size);
		
	}
	public int getByUserSize(Connection con,String user_id)throws JadoException{
		this.initBeanInfo();
		this.bean.addTerm(new TermBean("pr_userid",user_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
		return this.od.getCount(con);
		
	}
	
	private void initBeanInfo() throws JadoException{
		if(this.bean==null) bean = new ITG_POINTREC();
		this.bean.setTable(table);
		this.bean.setPrimary_key(primary_key);
		this.od = new OracleDao(this.bean);
	}
}

