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
 * @Type：   ITG_CARTRECManager 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-7-23 下午09:57:53
 * @Comment
 * 
 */

public class ITG_CARTRECManager {

	 private String table="ITG_CARTREC";
		
	 private String primary_key="cr_id";
	 
	 private ITG_CARTREC bean;

	 private OracleDao od;
	 
	
	public ITG_CARTREC getBean() {
		return bean;
	}

	public void setBean(ITG_CARTREC bean) {
		this.bean = bean;
	}

	public ITG_CARTREC insert(Connection con,ITG_CARTREC bean) throws JadoException{
		this.bean=bean;
		this.initBeanInfo();
		if(this.getBean().getCr_id()==null||this.getBean().getCr_id().equals("")) this.getBean().setCr_id(JUtil.createUNID());
		od.insert(con);
		return this.bean;
		
	}
	public List getByUser(Connection con,String user_id)throws JadoException{
		return this.getByUser(con, user_id, 0, 0);
		
	}
	public List getByUser(Connection con,String user_id,int start,int size)throws JadoException{
		String sql = " select ic.CR_NUM,ic.cr_prdid,ic.cr_time,art.pic_url,art.url_gen,art.title,art.score,art.prd_name,art.prd_newlevel,art.prd_marketprice,art.prd_localprice,art.prd_point,art.PRD_BRANDNAME,art.PRD_ORIGINCOUNTRYNAME,art.PRD_ORIGINPROVINCENAME,art.PRD_CODE from ITG_CARTREC ic,article art where ic.cr_prdid=art.id and ic.cr_userid=?";
		DbUtils_DAO dd = new DbUtils_DAO();
		Object[] obj = new Object[]{user_id};
		return dd.MapListHandler_Search(con, sql, obj, start, size);
		
	}
	public List getCartByUser(Connection con,String user_id)throws JadoException{
		String sql = " select ic.cr_id,art.url_gen prd_url,art.pic_url prd_picurl,ic.cr_prdid prd_id,art.prd_name prd_name,art.prd_point prd_point,art.prd_localprice prd_price,ic.cr_num amount from ITG_CARTREC ic,article art where ic.cr_prdid=art.id and ic.cr_userid=?";
		DbUtils_DAO dd = new DbUtils_DAO();
		Object[] obj = new Object[]{user_id};
		return dd.MapListHandler_Search(con, sql, obj);
	}
	public Bean get(Connection con ,String id)throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		this.bean.setCr_id(id);
		return this.od.get(con);
	}
	public void del(Connection con,String id)throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		this.bean.setCr_id(id);
		this.od.delete(con);
	}
	public void del(Connection con,String[] ids)throws JadoException{
		if(!(ids!=null&&ids.length>0)) return;
		this.bean=null;
		this.initBeanInfo();
		String _ids="";
		for(int i=0;i<ids.length;i++){
			if(_ids.equals("")){
				_ids=ids[i];
			}else{
				_ids=_ids+","+ids[i];
			}
		}
		System.out.println(_ids);
		this.bean.addTerm(new TermBean("cr_id",_ids,FieldTypeEnum.STRING,TermEnum.IN));
		this.od.delete(con);
	}
	public void delByuser(Connection con,String user_id)throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		this.bean.addTerm(new TermBean("cr_userid",user_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
		this.od.delete(con);
	}
	public void updAmount(Connection con,String cr_id, Double amount)throws JadoException{
		this.bean=null;
		this.initBeanInfo();
		this.bean.setCr_id(cr_id);
		this.bean.setCr_num(amount);
		this.bean.addTerm(new TermBean("cr_id",cr_id,FieldTypeEnum.STRING,TermEnum.EQUAL));
		this.od.update(con);
	}
	private void initBeanInfo() throws JadoException{
		if(this.bean==null) bean = new ITG_CARTREC();
		this.bean.setTable(table);
		this.bean.setPrimary_key(primary_key);
		this.od = new OracleDao(this.bean);
	}
}

