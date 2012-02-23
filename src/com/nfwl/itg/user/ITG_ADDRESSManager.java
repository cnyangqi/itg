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
 * 用户收货地址管理
 * 
 * @author yangq(qi.yang.cn@gmail.com) 2012-2-23
 */

public class ITG_ADDRESSManager {

	private String table = "ITG_ADDRESS";

	private String primary_key = "adr_id";

	private ITG_ADDRESS bean;

	private OracleDao od;

	public ITG_ADDRESS getBean() {
		return bean;
	}

	public void setBean(ITG_ADDRESS bean) {
		this.bean = bean;
	}

	public ITG_ADDRESS insert(Connection con, ITG_ADDRESS bean, int utype) throws JadoException {
		try {
			con.setAutoCommit(false);
			this.bean = bean;
			this.initBeanInfo();
			if (this.getBean().getAdr_id() == null || this.getBean().getAdr_id().equals(""))
				this.getBean().setAdr_id(JUtil.createUNID());
			od.insert(con);

			// 更新默认地址
			UserManager um = new UserManager();
			um.updateAddress(con, this.bean.getAdr_userid(), bean.getAdr_id(), utype);
			con.commit();
			con.setAutoCommit(true);
		}
		catch (Exception ex) {
			try {
				con.rollback();
			}
			catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			if (ex instanceof JadoException)
				throw (JadoException) ex;
			JLog.getLogger().error("增加地址时出错:", ex);
			throw new JadoException("增加地址时出错！");
		}

		return this.bean;
	}

	public List<Bean> getByUser(Connection con, String user_id) throws JadoException {
		return this.getByUser(con, user_id, 0, 0);

	}

	public List<Bean> getByUser(Connection con, String user_id, int start, int size)
			throws JadoException {
		this.bean = null;
		this.initBeanInfo();
		this.bean.addTerm(new TermBean("adr_userid", user_id, FieldTypeEnum.STRING, TermEnum.EQUAL));
		this.bean.addTerm(new TermBean("adr_status", 0, FieldTypeEnum.INTEGER, TermEnum.EQUAL));
		return this.od.search(con, start, size);

	}

	public int getByUserSize(Connection con, String user_id) throws JadoException {
		this.initBeanInfo();
		this.bean.addTerm(new TermBean("adr_userid", user_id, FieldTypeEnum.STRING, TermEnum.EQUAL));
		this.bean.addTerm(new TermBean("adr_status", 0, FieldTypeEnum.INTEGER, TermEnum.EQUAL));
		return this.od.getCount(con);

	}

	public ITG_ADDRESS get(Connection con, String id) throws JadoException {
		this.initBeanInfo();
		this.bean.setAdr_id(id);
		return (ITG_ADDRESS) this.od.get(con);
	}

	public void delete(Connection con, String id, String user_id, int utype) throws JadoException {
		try {
			con.setAutoCommit(false);
			ITG_ADDRESS ids = (ITG_ADDRESS) this.get(con, id);

			if (ids != null) {
				UserManager um = new UserManager();
				User user = (User) um.get(con, ids.getAdr_userid());
				// 如果用户中默认为些条地址,则设为空
				if (user != null && user.getId().equals(ids.getAdr_userid())) {
					if (user.getAdrid() != null && user.getAdrid().equals(ids.getAdr_id())) {
						um.updateAddress(con, ids.getAdr_userid(), "", utype);
					}
					this.bean = null;
					this.initBeanInfo();
					this.bean.setAdr_id(id);
					this.bean.setAdr_status(1);
					this.od.update(con);
				}

				con.commit();
				con.setAutoCommit(true);
			}

		}
		catch (Exception ex) {
			try {
				con.rollback();
			}
			catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			if (ex instanceof JadoException)
				throw (JadoException) ex;
			JLog.getLogger().error("删除地址时出错:", ex);
			throw new JadoException("删除地址时出错！");
		}
	}

	public boolean modfiy(Connection con, ITG_ADDRESS id) throws JadoException {
		this.bean = id;
		this.initBeanInfo();
		Integer i = this.od.update(con);
		if (i == 1) {
			return true;
		} else {
			return false;
		}
	}

	/** 设置用户默认地址 */
	public boolean setDefault(Connection con, String adr_id, String user_id, int utype)
			throws JadoException {
		UserManager um = new UserManager();
		return um.updateAddress(con, user_id, adr_id, utype);
	}

	private void initBeanInfo() throws JadoException {
		if (this.bean == null)
			bean = new ITG_ADDRESS();
		this.bean.setTable(table);
		this.bean.setPrimary_key(primary_key);
		this.od = new OracleDao(this.bean);
	}

	public ITG_ADDRESS formTObean(ITG_ADDRESSForm af) {
		ITG_ADDRESS a = new ITG_ADDRESS();
		a.setAdr_areacode(af.getAdr_areacode());
		a.setAdr_detail(af.getAdr_detail());
		a.setAdr_email(af.getAdr_email());
		a.setAdr_fpid(af.getAdr_fpid());
		if (af.getAdr_id() == null || af.getAdr_id().equals("")) {
			a.setAdr_id(JUtil.createUNID());
		} else {
			a.setAdr_id(af.getAdr_id());
		}
		a.setAdr_mobile(af.getAdr_mobile());
		a.setAdr_name(af.getAdr_name());
		a.setAdr_postcode(af.getAdr_postcode());
		a.setAdr_status(af.getAdr_status());
		a.setAdr_subnum(af.getAdr_subnum());
		a.setAdr_telephone(af.getAdr_telephone());
		a.setAdr_time(af.getAdr_time());
		a.setAdr_userid(af.getAdr_userid());
		a.setAdr_zone(af.getAdr_zone());

		return a;

	}
}
