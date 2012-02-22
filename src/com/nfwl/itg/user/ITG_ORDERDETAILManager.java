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

public class ITG_ORDERDETAILManager {

	 private String table="ITG_ORDERDETAIL";
		
	 private String primary_key="od_id";
	 
	 private ITG_ORDERDETAIL bean;

	 private OracleDao od;
	 
	
	public ITG_ORDERDETAIL getBean() {
		return bean;
	}

	public void setBean(ITG_ORDERDETAIL bean) {
		this.bean = bean;
	}

	public ITG_ORDERDETAIL insert(Connection con,ITG_ORDERDETAIL bean) throws JadoException{
		this.bean=bean;
		this.initBeanInfo();
		if(this.getBean().getOd_id()==null||this.getBean().getOd_id().equals("")) this.getBean().setOd_id(JUtil.createUNID());
		od.insert(con);
		return this.bean;
		
	}
	public List getByOrder(Connection con,String order_id)throws JadoException{
		return this.getByOrder(con, order_id, 0, 0);
		
	}
	public List getByOrder(Connection con,String order_id,int start,int size)throws JadoException{
		//this.initBeanInfo();
		//this.bean.addTerm(new TermBean("od_orid",order_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
		//return this.od.search(con,start,size);
		String sql = " select ig.*,art.pic_url,art.url_gen,art.title,art.score,art.prd_name,art.prd_newlevel,art.prd_marketprice,art.prd_localprice,art.prd_point,art.PRD_BRANDNAME,art.PRD_ORIGINCOUNTRYNAME,art.PRD_ORIGINPROVINCENAME,art.PRD_CODE from ITG_ORDERDETAIL ig,article art where ig.od_prdid=art.id and ig.od_orid=?";
		DbUtils_DAO dd = new DbUtils_DAO();
		Object[] obj = new Object[]{order_id};
		return dd.MapListHandler_Search(con, sql, obj, start, size);
		
	}
	public ITG_ORDERDETAIL get(Connection con,String od_id)throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		this.bean.setOd_id(od_id);
		return (ITG_ORDERDETAIL) this.od.get(con);
	}
	public void del(Connection con,String[] ods)throws JadoException{
		if(!(ods!=null&&ods.length>0)) return;
		this.bean=null;
		this.initBeanInfo();
		String _ods="";
		for(int i=0;i<ods.length;i++){
			if(_ods.equals("")){
				_ods=ods[i];
			}else{
				_ods=_ods+","+ods[i];
			}
		}
		this.bean.addTerm(new TermBean("od_id",_ods,FieldTypeEnum.STRING,TermEnum.IN));
		this.od.delete(con);
	}
	public void updAmount(Connection con,String od_id, Double amount)throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		this.bean.setOd_id(od_id);
		this.bean.setOd_num(amount);
		this.bean.addTerm(new TermBean("od_id",od_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
		this.od.update(con);
	}
	private void initBeanInfo() throws JadoException{
		if(this.bean==null) bean = new ITG_ORDERDETAIL();
		this.bean.setTable(table);
		this.bean.setPrimary_key(primary_key);
		this.od = new OracleDao(this.bean);
	}
}

