package com.nfwl.itg.user;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.gemway.util.JUtil;
import com.jado.DbUtils_DAO;
import com.jado.JadoException;
import com.jado.Enum.FieldTypeEnum;
import com.jado.Enum.TermEnum;
import com.jado.bean.Bean;
import com.jado.bean.TermBean;
import com.jado.dao.OracleDao;
import com.nfwl.itg.common.Arith;

/**
 * 
 * @Project：ithinkgo
 * @Type： UserManager
 * @Author: yjw
 * @Email: y.jinwei@gmail.com
 * @Mobile: 13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date: 2011-7-24 下午10:23:56
 * 
 * @Comment
 * 
 */

public class UserManager {

	private String table = "USERS";

	private String primary_key = "id";

	private User bean;

	private OracleDao od;

	public User getBean() {
		return bean;
	}

	public void setBean(User bean) {
		this.bean = bean;
	}

	public User insert(Connection con, User bean) throws JadoException {
		this.bean = bean;
		this.initBeanInfo();
		if (this.getBean().getId() == null || this.getBean().getId().equals(""))
			this.getBean().setId(JUtil.createUNID());
		od.insert(con);
		return this.bean;
	}

	public void update(Connection con, User bean) throws JadoException {
		this.bean = bean;
		this.initBeanInfo();
		od.update(con);
	}

	public Bean get(Connection con, String id) throws JadoException {
		User u = new User();
		u.setId(id);
		this.bean = u;
		this.initBeanInfo();
		// this.bean.addTerm(new
		// TermBean("id",id,FieldTypeEnum.STRING,TermEnum.EQUAL));
		return this.od.get(con);

	}

	/** 通过定点单位主键查询用户 */
	public List<Bean> getUserByFixedpoint(Connection con, String id, Integer start, int size)
			throws JadoException {
		this.bean = null;
		this.initBeanInfo();
		this.bean.addTerm(new TermBean("itg_fixedpoint", id, FieldTypeEnum.STRING, TermEnum.EQUAL));
		this.bean.addTerm(new TermBean("utype", -1, FieldTypeEnum.INTEGER, TermEnum.NOT_IN));
		return this.od.search(con, start, size);

	}

	/** 通过定点单位主键查询用户count */
	public Integer getUserByFixedpointSize(Connection con, String id) throws JadoException {
		this.bean = null;
		this.initBeanInfo();
		this.bean.addTerm(new TermBean("itg_fixedpoint", id, FieldTypeEnum.STRING, TermEnum.EQUAL));
		this.bean.addTerm(new TermBean("utype", -1, FieldTypeEnum.INTEGER, TermEnum.NOT_IN));// 不显示软删除用户
		return this.od.getCount(con);
	}

	/** 通过用户主键删除定点单位用户 */
	public Integer deleteFixedpointUser(Connection con, String id) throws JadoException,
			SQLException {
		this.bean = null;
		this.initBeanInfo();
		this.bean.setId(id);
		this.bean.setUtype(-1);
		return od.update(con);
	}

	/** 通过用户主键查询用户 */
	public User getUserById(Connection con, String id) throws Exception {
		this.bean = null;
		this.initBeanInfo();
		this.bean.setId(id);
		return (User) od.search(con).get(0);
	}

	public boolean updateAddress(Connection con, String id, String adrid) throws JadoException {
		User u = new User();
		u.setId(id);
		u.setAdrid(adrid);
		this.bean = u;
		this.bean.addTerm(new TermBean("id", id, FieldTypeEnum.STRING, TermEnum.EQUAL));
		this.initBeanInfo();
		Integer i = od.update(con);
		if (i == 1) {
			return true;
		} else {
			return false;
		}
	}

	public boolean addPoint(Connection con, String id, Integer point) throws JadoException {
		try {
			String sql = "update USERS set point=point+? where id=? ";
			DbUtils_DAO dd = new DbUtils_DAO();
			Integer i = dd.Execute_Sql(con, sql, new Object[]{point, id});
			if (i == 1) {
				return true;
			} else {
				return false;
			}
		}
		catch (Exception e) {
			return false;
		}
	}

	public boolean addMoney(Connection con, String id, Double money) throws JadoException {

		String sql = "update USERS set money=money+? where id=? ";
		DbUtils_DAO dd = new DbUtils_DAO();
		Integer i = dd.Execute_Sql(con, sql, new Object[]{money, id});
		if (i == 1) {
			return true;
		} else {
			return false;
		}

	}

	public boolean minusMoney(Connection con, String id, Double money) throws JadoException {
		try {
			String sql = "update USERS set money=money-? where (money-?)>=0 and id=? ";
			DbUtils_DAO dd = new DbUtils_DAO();
			Integer i = dd.Execute_Sql(con, sql, new Object[]{money, money, id});
			if (i == 1) {
				return true;
			} else {
				return false;
			}
		}
		catch (Exception e) {
			return false;
		}
	}

	private void initBeanInfo() throws JadoException {
		if (this.bean == null)
			bean = new User();
		this.bean.setTable(table);
		this.bean.setPrimary_key(primary_key);
		this.od = new OracleDao(this.bean);
	}

	public UserForm beanTOform(User uf) {
		UserForm u = new UserForm();
		u.setAccount(uf.getAccount());
		u.setAdrid(uf.getAdrid());
		u.setAreacode(uf.getAreacode());
		u.setCx(uf.getCx());
		u.setDept(uf.getDept());
		u.setDetailadr(uf.getDetailadr());
		u.setEmail(uf.getEmail());
		u.setFace(uf.getFace());
		u.setFax(uf.getFax());
		u.setFaxareacode(uf.getFaxareacode());
		u.setFpid(uf.getFpid());
		u.setId(uf.getId());
		u.setMobile(uf.getMobile());
		u.setMoney(uf.getMoney());
		u.setName(uf.getName());
		u.setNickname(uf.getNickname());
		u.setPassword(uf.getPassword());
		u.setPoint(uf.getPoint());
		u.setPostcode(uf.getPostcode());
		u.setRegtime(uf.getRegtime());
		u.setSex(uf.getSex());
		u.setSubnum(uf.getSubnum());
		u.setTelephone(uf.getTelephone());
		u.setUtype(uf.getUtype());
		u.setZoneid(uf.getZoneid());

		return u;

	}

	public User formTObean(UserForm uf) {
		User u = new User();
		u.setAccount(uf.getAccount());
		u.setAdrid(uf.getAdrid());
		u.setAreacode(uf.getAreacode());
		u.setCx(uf.getCx());
		u.setDept(uf.getDept());
		u.setDetailadr(uf.getDetailadr());
		u.setEmail(uf.getEmail());
		u.setFace(uf.getFace());
		u.setFax(uf.getFax());
		u.setFaxareacode(uf.getFaxareacode());
		u.setFpid(uf.getFpid());
		u.setId(uf.getId());
		u.setMobile(uf.getMobile());
		u.setMoney(uf.getMoney());
		u.setName(uf.getName());
		u.setNickname(uf.getNickname());
		u.setPassword(uf.getPassword());
		u.setPoint(uf.getPoint());
		u.setPostcode(uf.getPostcode());
		u.setRegtime(uf.getRegtime());
		u.setSex(uf.getSex());
		u.setSubnum(uf.getSubnum());
		u.setTelephone(uf.getTelephone());
		u.setUtype(uf.getUtype());
		u.setZoneid(uf.getZoneid());

		return u;

	}

	public Map getAccountInfo(Connection con, String userid) throws JadoException {
		Map map = new HashMap<String, String>();

		User u = (User) this.get(con, userid);

		map.put("money", Arith.round(u.getMoney(), 2));
		map.put("point", u.getPoint());

		ITG_ORDERRECManager iom = new ITG_ORDERRECManager();
		Integer orderSize = iom.getByUserSize(con, userid, "");
		map.put("orderSize", orderSize);

		return map;
	}

}
