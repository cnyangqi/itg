package nps.core;

import java.io.Serializable;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;
import java.util.Locale;

import nps.exception.ErrorHelper;
import nps.exception.NpsException;
import nps.util.tree.TreeNode;

/**
 * 2010-01-25 jialin 1. 新增查看全局具有公开栏目的站点
 * 
 * 用户类 NPS - a new publishing system Copyright (c) 2007
 * 
 * @author jialin, lanxi justa network co.,ltd.
 * @version 1.0
 */
public class User implements TreeNode, Serializable, Constants {
	private String id;
	private String name;
	private String account;
	private String telephone;
	private String fax;
	private String email;
	private String mobile;
	private String face;
	private int index; // 次序
	private int type;// 用户类型 -1软删除 /0工作人员 /1会员 /2定点单位用户 /6定点单位管理员 /9系统管理员
	private String itg_fixedpointname;
	private String itg_fixedpoint;
	private String adrid;
	private Integer point;// 当前积分
	private Double money;// 账户余额

	private String password = null; // 在新建时有效

	private Locale locale = Config.LOCALE;

	private String unit_id = null; // 单位信息
	private String dept_id = null; // 部门
	private Hashtable roles_by_domain_name = null; // 角色按域、名称检索
	private Hashtable roles_by_id = null; // 角色按ID检索
	private Hashtable roles_grantable_by_id = null; // 可管理的角色列表，按ID检索
	private Hashtable roles_grantable_by_domain_name = null; // 可管理的角色按域、名称检索

	private Hashtable sites_owners = null; // 我管理的站点，site按id检索,仅存放name
	private Hashtable sites_myunit = null; // 本单位
	private Hashtable sites_public = null; // 有公开栏目的站点
	private Hashtable sites = null; // 存放实力化过的SITE信息
	private String default_site = null;// 缺省site id

	public User() {}

	public User(String id, String name, String account, int type) {
		this.id = id;
		this.name = name;
		this.account = account;
		this.type = type;
	}

	// 根据帐号密码登陆系统
	public static User Login(String account, String password) throws NpsException {
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		User u = null;

		// 数据库中总是以大写保存帐号,忽略大小写
		String u_account = account.trim().toUpperCase();
		try {
			conn = Database.GetDatabase("nps").GetConnection();

			// 1.校验用户
			sql = "select a.id,a.name,a.password,a.telephone,a.fax,a.email,a.mobile,a.utype,a.cx,a.face,b.id deptid,b.name deptname,b.code deptcode,b.cx deptcx,b.parentid parentdept,b.unit unitid,"
					+ "(select ifp.fp_name||'('|| ifp.fp_linker||ifp.fp_phone||')'||ifp.fp_address  from itg_fixedpoint ifp where ifp.fp_id=a.itg_fixedpoint) itg_fixedpointname,a.itg_fixedpoint,a.adrid,a.point,a.money "
					+ "  from users a,dept b "
					+ " where a.dept=b.id(+) and a.account=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, u_account);
			rs = pstmt.executeQuery();

			// 没有找到用户
			if (!rs.next())
				return null;

			// 校验密码
			if (password == null && rs.getString("password") != null)
				return null;
			if (password != null && !password.equals(rs.getString("password")))
				return null;

			// 密码正确,开始加载信息
			u = new User(rs.getString("id"), rs.getString("name"), u_account, rs.getInt("utype"));
			u.email = rs.getString("email");
			u.fax = rs.getString("fax");
			u.mobile = rs.getString("mobile");
			u.telephone = rs.getString("telephone");
			u.face = rs.getString("face");
			u.index = rs.getInt("cx");

			u.unit_id = rs.getString("unitid");
			u.dept_id = rs.getString("deptid");
			u.setItg_fixedpoint(rs.getString("itg_fixedpoint"));
			u.setItg_fixedpointname(rs.getString("itg_fixedpointname"));
			u.setAdrid(rs.getString("adrid"));

			u.setPoint(rs.getInt("point"));
			u.setMoney(rs.getDouble("money"));

			/*
			 * u.unit = Unit.GetUnit(conn,rs.getString("unitid")); u.dept =
			 * u.unit.GetDeptTree(conn).GetDept(rs.getString("deptid"));
			 */

			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e) {}

			// 2.加载ROLE信息
			sql = "select b.* from UserRole a,Role b where a.roleid = b.id and a.userid=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, u.id);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				if (u.roles_by_domain_name == null)
					u.roles_by_domain_name = new Hashtable();
				if (u.roles_by_id == null)
					u.roles_by_id = new Hashtable();

				if (u.roles_by_domain_name.containsKey(rs.getString("domain"))) {
					Hashtable roles_by_name = (Hashtable) u.roles_by_domain_name.get(rs.getString("domain"));
					if (!roles_by_name.containsKey(rs.getString("name")))
						roles_by_name.put(rs.getString("name"), rs.getString("id"));
				} else {
					Hashtable roles_by_name = new Hashtable();
					roles_by_name.put(rs.getString("name"), rs.getString("id"));
					u.roles_by_domain_name.put(rs.getString("domain"), roles_by_name);
				}

				u.roles_by_id.put(rs.getString("id"), rs.getString("name"));
			}

			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e) {}

			// 2.1 加载可管理的Role信息
			sql = "select b.* from UserRole_grantable a,Role b where a.roleid = b.id and a.userid=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, u.id);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				if (u.roles_grantable_by_id == null)
					u.roles_grantable_by_id = new Hashtable();
				if (u.roles_grantable_by_domain_name == null)
					u.roles_grantable_by_domain_name = new Hashtable();

				if (u.roles_grantable_by_domain_name.containsKey(rs.getString("domain"))) {
					Hashtable roles_by_name = (Hashtable) u.roles_grantable_by_domain_name.get(rs.getString("domain"));
					if (!roles_by_name.containsKey(rs.getString("name")))
						roles_by_name.put(rs.getString("name"), rs.getString("id"));
				} else {
					Hashtable roles_by_name = new Hashtable();
					roles_by_name.put(rs.getString("name"), rs.getString("id"));
					u.roles_grantable_by_domain_name.put(rs.getString("domain"), roles_by_name);
				}

				u.roles_grantable_by_id.put(rs.getString("id"), rs.getString("name"));
			}

			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e) {}

			// 3.加载能够管理的所有站点信息
			// 仅仅加载id和name,放入site_owner
			if (u.type == USER_SYSADMIN) {
				sql = "select id,name from site";
				pstmt = conn.prepareStatement(sql);
			} else {
				// 仅加载没有被禁用的站点
				sql = "select b.id,b.name from site b,site_owner a where a.siteid=b.id and a.userid=? and b.state=?";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, u.id);
				pstmt.setInt(2, SITE_NORMAL);
			}
			rs = pstmt.executeQuery();
			while (rs.next()) {
				// 如果当前用户名下只有一个站点，将该站点设置为默认站点
				// 否则，要求用户从这些站点中选择或设置一个为默认站点
				if (u.default_site == null)
					u.default_site = rs.getString("id");
				else
					u.default_site = null;

				if (u.sites_owners == null)
					u.sites_owners = new Hashtable();
				u.sites_owners.put(rs.getString("id"), rs.getString("name"));

				if (u.type == USER_SYSADMIN) {
					if (u.sites_myunit == null)
						u.sites_myunit = new Hashtable();
					u.sites_myunit.put(rs.getString("id"), rs.getString("name"));
				}
			}

			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e) {}

			// 4.如果是一般用户，另外加载本单位内站点信息
			if (u.type != USER_SYSADMIN) {
				sql = "select id,name from site where unit=? and state=?";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, u.GetUnitId());
				pstmt.setInt(2, SITE_NORMAL);
				rs = pstmt.executeQuery();
				while (rs.next()) {
					if (u.sites_myunit == null)
						u.sites_myunit = new Hashtable();

					if (!u.sites_myunit.containsKey(rs.getString("id")))
						u.sites_myunit.put(rs.getString("id"), rs.getString("name"));
				}

				if (rs != null)
					try {
						rs.close();
					}
					catch (Exception e) {}
				if (pstmt != null)
					try {
						pstmt.close();
					}
					catch (Exception e) {}

				// 加载有公开栏目的站点，且不在本用户部门内清单中
				sql = "select id,name from site where id in (\n"
						+ "select distinct siteid from topic Where visible=2\n"
						+ "minus \n"
						+ "select id from site where unit=? and state=?"
						+ ")";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, u.GetUnitId());
				pstmt.setInt(2, SITE_NORMAL);
				rs = pstmt.executeQuery();
				while (rs.next()) {
					if (u.sites_public == null)
						u.sites_public = new Hashtable();

					if (!u.sites_public.containsKey(rs.getString("id")))
						u.sites_public.put(rs.getString("id"), rs.getString("name"));
				}
			}
		}
		catch (Exception e) {
			nps.util.DefaultLog.error(e);
		}
		finally {
			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e) {}
			if (conn != null)
				try {
					conn.close();
				}
				catch (Exception e) {}
		}

		return u;
	}

	// 系统加载加载
	public static User LoadInternal(Connection conn, String id) throws NpsException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		User u = null;

		try {
			// 1.校验用户
			sql = "select a.name,a.account,a.telephone,a.fax,a.email,a.mobile,a.utype,a.face,b.id deptid,b.name deptname,b.code deptcode,b.cx deptcx,b.unit unitid "
					+ "  from users a,dept b "
					+ " where a.dept=b.id and a.id=?";

			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, id);
			rs = pstmt.executeQuery();

			// 没有找到用户
			if (!rs.next())
				return null;

			// 1.加载用户基本信息
			u = new User(id, rs.getString("name"), rs.getString("account"), rs.getInt("utype"));
			u.email = rs.getString("email");
			u.fax = rs.getString("fax");
			u.mobile = rs.getString("mobile");
			u.telephone = rs.getString("telephone");
			u.face = rs.getString("face");

			u.unit_id = rs.getString("unitid");
			u.dept_id = rs.getString("deptid");
			/*
			 * u.unit = Unit.GetUnit(conn,rs.getString("unitid")); u.dept =
			 * u.unit.GetDeptTree(conn).GetDept(rs.getString("deptid"));
			 */

			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e) {}

			// 2.加载ROLE信息
			sql = "select b.* from UserRole a,Role b where a.roleid = b.id and a.userid=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, id);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				if (u.roles_by_domain_name == null)
					u.roles_by_domain_name = new Hashtable();
				if (u.roles_by_id == null)
					u.roles_by_id = new Hashtable();

				if (u.roles_by_domain_name.containsKey(rs.getString("domain"))) {
					Hashtable roles_by_name = (Hashtable) u.roles_by_domain_name.get(rs.getString("domain"));
					if (!roles_by_name.containsKey(rs.getString("name")))
						roles_by_name.put(rs.getString("name"), rs.getString("id"));
				} else {
					Hashtable roles_by_name = new Hashtable();
					roles_by_name.put(rs.getString("name"), rs.getString("id"));
					u.roles_by_domain_name.put(rs.getString("domain"), roles_by_name);

				}

				u.roles_by_id.put(rs.getString("id"), rs.getString("name"));
			}

			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e) {}

			// 2.1 加载可管理的Role信息
			sql = "select b.* from UserRole_Grantable a,Role b where a.roleid = b.id and a.userid=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, u.id);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				if (u.roles_grantable_by_domain_name == null)
					u.roles_grantable_by_domain_name = new Hashtable();
				if (u.roles_grantable_by_id == null)
					u.roles_grantable_by_id = new Hashtable();

				if (u.roles_grantable_by_domain_name.containsKey(rs.getString("domain"))) {
					Hashtable roles_by_name = (Hashtable) u.roles_grantable_by_domain_name.get(rs.getString("domain"));
					if (!roles_by_name.containsKey(rs.getString("name")))
						roles_by_name.put(rs.getString("name"), rs.getString("id"));
				} else {
					Hashtable roles_by_name = new Hashtable();
					roles_by_name.put(rs.getString("name"), rs.getString("id"));
					u.roles_grantable_by_domain_name.put(rs.getString("domain"), roles_by_name);

				}

				u.roles_grantable_by_id.put(rs.getString("id"), rs.getString("name"));
			}

			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e) {}

			// 3.加载能够管理的所有站点信息
			// 仅仅加载id和name,放入sites_owners
			if (u.type == USER_SYSADMIN) {
				sql = "select id,name from site";
				pstmt = conn.prepareStatement(sql);
			} else {
				// 仅加载没有被禁用的站点
				sql = "select b.id,b.name from site b,site_owner a where a.siteid=b.id and a.userid=? and b.state=?";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, u.id);
				pstmt.setInt(2, SITE_NORMAL);
			}
			rs = pstmt.executeQuery();
			while (rs.next()) {
				// 如果当前用户名下只有一个站点，将该站点设置为默认站点
				// 否则，要求用户从这些站点中选择或设置一个为默认站点
				if (u.default_site == null)
					u.default_site = rs.getString("id");
				else
					u.default_site = null;

				if (u.sites_owners == null)
					u.sites_owners = new Hashtable();
				u.sites_owners.put(rs.getString("id"), rs.getString("name"));

				// 系统管理员用户，同时加载本单位所有站点信息
				if (u.type == USER_SYSADMIN) {
					if (u.sites_myunit == null)
						u.sites_myunit = new Hashtable();
					u.sites_myunit.put(rs.getString("id"), rs.getString("name"));
				}
			}

			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e) {}

			// 4.如果是一般用户，另外加载本单位内站点信息
			if (u.type != USER_SYSADMIN) {
				sql = "select id,name from site where unit=? and state=?";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, u.GetUnitId());
				pstmt.setInt(2, SITE_NORMAL);
				rs = pstmt.executeQuery();
				while (rs.next()) {
					if (u.sites_myunit == null)
						u.sites_myunit = new Hashtable();
					if (!u.sites_myunit.containsKey(rs.getString("id")))
						u.sites_myunit.put(rs.getString("id"), rs.getString("name"));
				}

				if (rs != null)
					try {
						rs.close();
					}
					catch (Exception e) {}
				if (pstmt != null)
					try {
						pstmt.close();
					}
					catch (Exception e) {}

				// 加载有公开栏目的站点，且不在本用户部门内清单中
				sql = "select id,name from site where id in (\n"
						+ "select distinct siteid from topic Where visible=2\n"
						+ "minus \n"
						+ "select id from site where unit=? and state=?"
						+ ")";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, u.GetUnitId());
				pstmt.setInt(2, SITE_NORMAL);
				rs = pstmt.executeQuery();
				while (rs.next()) {
					if (u.sites_public == null)
						u.sites_public = new Hashtable();

					if (!u.sites_public.containsKey(rs.getString("id")))
						u.sites_public.put(rs.getString("id"), rs.getString("name"));
				}
			}
		}
		catch (Exception e) {
			nps.util.DefaultLog.error(e);
		}
		finally {
			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e) {}
		}

		return u;
	}

	// 根据用户uid加载用户基本信息
	// 站点管理员可以加载本部门数据，系统管理员可以获得所有用户信息
	public User GetUser(String id) throws NpsException {
		if (id == null)
			return null;
		if (id.equalsIgnoreCase(this.id))
			return this;

		Connection conn = null;
		try {
			conn = Database.GetDatabase("nps").GetConnection();
			return GetUser(conn, id);
		}
		catch (Exception e) {
			nps.util.DefaultLog.error(e);
		}
		finally {
			if (conn != null)
				try {
					conn.close();
				}
				catch (Exception e) {}
		}

		return null;
	}

	// 站点管理员可以加载本部门数据，系统管理员可以获得所有用户信息
	public User GetUser(Connection conn, String id) throws NpsException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		User u = null;

		try {
			// 1.校验用户
			sql = "select a.name,a.account,a.telephone,a.fax,a.email,a.mobile,a.utype,a.face,b.id deptid,b.name deptname,b.code deptcode,b.cx deptcx,b.unit unitid "
					+ "  from users a,dept b "
					+ " where a.dept=b.id and a.id=?";
			if (!IsSysAdmin())
				sql += " and b.unit=?";

			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, id);
			if (!IsSysAdmin())
				pstmt.setString(2, GetUnitId());
			rs = pstmt.executeQuery();

			// 没有找到用户
			if (!rs.next())
				return null;

			// 1.加载用户基本信息
			u = new User(id, rs.getString("name"), rs.getString("account"), rs.getInt("utype"));
			u.email = rs.getString("email");
			u.fax = rs.getString("fax");
			u.mobile = rs.getString("mobile");
			u.telephone = rs.getString("telephone");
			u.face = rs.getString("face");

			u.unit_id = rs.getString("unitid");
			u.dept_id = rs.getString("deptid");
			/*
			 * u.unit = Unit.GetUnit(conn,rs.getString("unitid")); u.dept =
			 * u.unit.GetDeptTree(conn).GetDept(rs.getString("deptid"));
			 */

			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e) {}

			// 2.加载ROLE信息
			sql = "select b.* from UserRole a,Role b where a.roleid = b.id and a.userid=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, id);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				if (u.roles_by_domain_name == null)
					u.roles_by_domain_name = new Hashtable();
				if (u.roles_by_id == null)
					u.roles_by_id = new Hashtable();

				if (u.roles_by_domain_name.containsKey(rs.getString("domain"))) {
					Hashtable roles_by_name = (Hashtable) u.roles_by_domain_name.get(rs.getString("domain"));
					if (!roles_by_name.containsKey(rs.getString("name")))
						roles_by_name.put(rs.getString("name"), rs.getString("id"));
				} else {
					Hashtable roles_by_name = new Hashtable();
					roles_by_name.put(rs.getString("name"), rs.getString("id"));
					u.roles_by_domain_name.put(rs.getString("domain"), roles_by_name);

				}

				u.roles_by_id.put(rs.getString("id"), rs.getString("name"));
			}

			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e) {}

			// 2.1 加载可管理的Role信息
			sql = "select b.* from UserRole_Grantable a,Role b where a.roleid = b.id and a.userid=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, u.id);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				if (u.roles_grantable_by_domain_name == null)
					u.roles_grantable_by_domain_name = new Hashtable();
				if (u.roles_grantable_by_id == null)
					u.roles_grantable_by_id = new Hashtable();

				if (u.roles_grantable_by_domain_name.containsKey(rs.getString("domain"))) {
					Hashtable roles_by_name = (Hashtable) u.roles_grantable_by_domain_name.get(rs.getString("domain"));
					if (!roles_by_name.containsKey(rs.getString("name")))
						roles_by_name.put(rs.getString("name"), rs.getString("id"));
				} else {
					Hashtable roles_by_name = new Hashtable();
					roles_by_name.put(rs.getString("name"), rs.getString("id"));
					u.roles_grantable_by_domain_name.put(rs.getString("domain"), roles_by_name);

				}

				u.roles_grantable_by_id.put(rs.getString("id"), rs.getString("name"));
			}

			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e) {}

			// 3.加载能够管理的所有站点信息
			// 仅仅加载id和name,放入sites_owners
			if (u.type == USER_SYSADMIN) {
				sql = "select id,name from site";
				pstmt = conn.prepareStatement(sql);
			} else {
				// 仅加载没有被禁用的站点
				sql = "select b.id,b.name from site b,site_owner a where a.siteid=b.id and a.userid=? and b.state=?";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, u.id);
				pstmt.setInt(2, SITE_NORMAL);
			}
			rs = pstmt.executeQuery();
			while (rs.next()) {
				// 如果当前用户名下只有一个站点，将该站点设置为默认站点
				// 否则，要求用户从这些站点中选择或设置一个为默认站点
				if (u.default_site == null)
					u.default_site = rs.getString("id");
				else
					u.default_site = null;

				if (u.sites_owners == null)
					u.sites_owners = new Hashtable();
				u.sites_owners.put(rs.getString("id"), rs.getString("name"));

				// 系统管理员用户，同时加载本单位所有站点信息
				if (u.type == USER_SYSADMIN) {
					if (u.sites_myunit == null)
						u.sites_myunit = new Hashtable();
					u.sites_myunit.put(rs.getString("id"), rs.getString("name"));
				}
			}

			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e) {}

			// 4.如果是一般用户，另外加载本单位内站点信息
			if (u.type != USER_SYSADMIN) {
				sql = "select id,name from site where unit=? and state=?";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, u.GetUnitId());
				pstmt.setInt(2, SITE_NORMAL);
				rs = pstmt.executeQuery();
				while (rs.next()) {
					if (u.sites_myunit == null)
						u.sites_myunit = new Hashtable();
					if (!u.sites_myunit.containsKey(rs.getString("id")))
						u.sites_myunit.put(rs.getString("id"), rs.getString("name"));
				}

				if (rs != null)
					try {
						rs.close();
					}
					catch (Exception e) {}
				if (pstmt != null)
					try {
						pstmt.close();
					}
					catch (Exception e) {}

				// 加载有公开栏目的站点，且不在本用户部门内清单中
				sql = "select id,name from site where id in (\n"
						+ "select distinct siteid from topic Where visible=2\n"
						+ "minus \n"
						+ "select id from site where unit=? and state=?"
						+ ")";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, u.GetUnitId());
				pstmt.setInt(2, SITE_NORMAL);
				rs = pstmt.executeQuery();
				while (rs.next()) {
					if (u.sites_public == null)
						u.sites_public = new Hashtable();

					if (!u.sites_public.containsKey(rs.getString("id")))
						u.sites_public.put(rs.getString("id"), rs.getString("name"));
				}
			}
		}
		catch (Exception e) {
			nps.util.DefaultLog.error(e);
		}
		finally {
			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e) {}
		}

		return u;
	}

	// 获得用户全名，按UserName(DeptName/UnitName)返回
	public String GetFullname() {

		return name + "(" + GetDeptName() + "/" + GetUnitName() + ")";
	}

	/*
	 * //根据ID获得用户全名 public static String GetFullname(String id) { if(id==null)
	 * return null;
	 * 
	 * Connection conn = null; PreparedStatement pstmt = null; ResultSet rs =
	 * null; try { conn = Database.GetDatabase("nps").GetConnection(); pstmt =
	 * conn.prepareStatement(
	 * "Select a.Name uname,b.Name deptname,c.Name unitname From users a,dept b,unit  c Where a.dept = b.Id  And b.unit = c.Id and a.id=?"
	 * ); pstmt.setString(1,id); rs = pstmt.executeQuery(); if(rs.next()) {
	 * return
	 * rs.getString("uname")+"("+rs.getString("deptname")+"/"+rs.getString
	 * ("unitname")+")"; } } catch(Exception e) { } finally {
	 * if(rs!=null)try{rs.close();}catch(Exception e){}
	 * if(pstmt!=null)try{pstmt.close();}catch(Exception e){}
	 * if(conn!=null)try{conn.close();}catch(Exception e){} }
	 * 
	 * return null; }
	 */

	// 新建用户
	public User NewUser(Connection conn,
						String name,
						String account,
						String password,
						String unitid,
						String deptid,
						int utype) throws NpsException {
		// 1.校验数据
		if (name == null || account == null || unitid == null || deptid == null) {
			throw new NpsException("User name can not be null", ErrorHelper.INPUT_ERROR);
		}

		if (account == null) {
			throw new NpsException("User account can not be null", ErrorHelper.INPUT_ERROR);
		}

		if (unitid == null) {
			throw new NpsException("Company can not be null", ErrorHelper.INPUT_ERROR);
		}

		if (deptid == null) {
			throw new NpsException("Department can not be null", ErrorHelper.INPUT_ERROR);
		}

		// 2.校验用户是否有权限
		if (this.type != USER_SYSADMIN) {
			// 2.1.只有管理员能创建超级帐号
			if (utype == USER_SYSADMIN) {
				throw new NpsException("NOT super administrator", ErrorHelper.ACCESS_NOPRIVILEGE);
			}
			Unit unit = this.GetUnit();

			// 2.2.自己单位的才能管理
			if (!unit.GetId().equalsIgnoreCase(unitid)) {
				throw new NpsException("NOT this company", ErrorHelper.ACCESS_NOPRIVILEGE);
			}

			// 2.3.本人是单位的管理员
			if (!IsLocalAdmin()) {
				throw new NpsException("NOT local administrator", ErrorHelper.ACCESS_NOPRIVILEGE);
			}
		}

		try {
			String id = GenerateUserID(conn);
			User user = new User(id, name, account.toUpperCase(), utype);
			user.password = password;
			user.unit_id = unitid;
			user.dept_id = deptid;
			// user.unit = Unit.GetUnit(conn,unitid);
			// user.dept = user.unit.GetDeptTree(conn).GetDept(deptid);
			return user;
		}
		catch (Exception e) {
			nps.util.DefaultLog.error(e);
		}

		return null;
	}

	private String GenerateUserID(Connection conn) throws NpsException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			pstmt = conn.prepareStatement("select seq_user.nextval userid from dual");
			rs = pstmt.executeQuery();
			if (rs.next()) {
				return rs.getString("userid");
			}
			return null;
		}
		catch (Exception e) {
			nps.util.DefaultLog.error(e);
		}
		finally {
			try {
				rs.close();
			}
			catch (Exception e1) {}
			try {
				pstmt.close();
			}
			catch (Exception e1) {}
		}

		return null;
	}

	// 保存
	public void Save(Connection conn, boolean bNew) throws NpsException {
		try {
			if (bNew)
				Save(conn);
			else
				Update(conn);
		}
		catch (NpsException e) {
			try {
				conn.rollback();
			}
			catch (Exception e1) {}
			throw e;
		}
	}

	private void Save(Connection conn) throws NpsException {
		PreparedStatement pstmt = null;
		String sql = null;

		try {
			sql = "insert into users(id,name,account,password,telephone,fax,email,mobile,face,cx,dept,utype) "
					+ " values(?,?,?,?,?,?,?,?,?,?,?,?)";
			pstmt = conn.prepareStatement(sql);
			int colIndex = 1;
			pstmt.setString(colIndex++, id);
			pstmt.setString(colIndex++, name);
			pstmt.setString(colIndex++, account);
			pstmt.setString(colIndex++, password);
			pstmt.setString(colIndex++, telephone);
			pstmt.setString(colIndex++, fax);
			pstmt.setString(colIndex++, email);
			pstmt.setString(colIndex++, mobile);
			pstmt.setString(colIndex++, face);
			pstmt.setInt(colIndex++, index);
			pstmt.setString(colIndex++, this.dept_id);
			pstmt.setInt(colIndex++, type);
			pstmt.executeUpdate();
		}
		catch (Exception e) {
			nps.util.DefaultLog.error(e);
		}
		finally {
			try {
				pstmt.close();
			}
			catch (Exception e1) {}
		}
	}

	private void Update(Connection conn) throws NpsException {
		PreparedStatement pstmt = null;
		String sql = "update users set name=?,account=?,telephone=?,fax=?,email=?,mobile=?,face=?,cx=?,dept=?,utype=? where id=?";
		try {
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, name);
			pstmt.setString(2, account);
			pstmt.setString(3, telephone);
			pstmt.setString(4, fax);
			pstmt.setString(5, email);
			pstmt.setString(6, mobile);
			pstmt.setString(7, face);
			pstmt.setInt(8, index);
			pstmt.setString(9, this.dept_id);
			pstmt.setInt(10, type);
			pstmt.setString(11, id);
			pstmt.executeUpdate();
		}
		catch (Exception e) {
			nps.util.DefaultLog.error(e);
		}
		finally {
			try {
				pstmt.close();
			}
			catch (Exception e1) {}
		}
	}

	// 管理员重置密码
	public void ResetPassword(String uid) throws NpsException {
		ResetPassword(uid, DEFAULT_PASSWORD);
	}

	// 管理员重置密码
	public void ResetPassword(String uid, String pass) throws NpsException {
		// 1.校验权限
		if (!IsSysAdmin() && !IsLocalAdmin())
			throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

		// 2.更改密码
		Connection conn = null;
		try {
			conn = Database.GetDatabase("nps").GetConnection();
			ResetPassword(conn, uid, pass);
		}
		catch (NpsException nps_e) {
			// nothing we do
		}
		catch (Exception e) {
			nps.util.DefaultLog.error(e);
		}
		finally {
			if (conn != null)
				try {
					conn.close();
				}
				catch (Exception e1) {}
		}
	}

	public void ResetPassword(Connection conn, String uid, String pass) throws NpsException {
		// 1.校验权限
		if (!IsSysAdmin() && !IsLocalAdmin())
			throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

		// 2.更改密码
		try {
			if (!IsSysAdmin()) {
				// 不是本单位的，也没有重置权限
				User aUser = GetUser(conn, uid);
				if (aUser == null)
					throw new NpsException(ErrorHelper.SYS_NOUSER);
			}

			// 重置密码
			_ChangePassword(conn, uid, pass);
		}
		catch (Exception e) {
			try {
				conn.rollback();
			}
			catch (Exception e1) {}
			nps.util.DefaultLog.error(e);
		}
	}

	// 个人重置密码
	public void ChangePassword(String oldpass, String newpass) throws NpsException {
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {
			conn = Database.GetDatabase("nps").GetConnection();
			conn.setAutoCommit(false);

			// 1.校验老密码
			String sql = "select password from users where id=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, id);
			rs = pstmt.executeQuery();
			if (!rs.next())
				throw new NpsException("No " + name, ErrorHelper.SYS_NOUSER);
			String dbpass = rs.getString("password");
			if (oldpass != null && dbpass != null) {
				if (!oldpass.equals(dbpass))
					throw new NpsException("Wrong old password", ErrorHelper.SYS_PASSWORD_ERROR);
			} else if ((oldpass != null && dbpass == null) || (oldpass == null && dbpass != null)) {
				throw new NpsException("Wrong old password", ErrorHelper.SYS_PASSWORD_ERROR);
			}

			try {
				rs.close();
			}
			catch (Exception e1) {}
			try {
				pstmt.close();
			}
			catch (Exception e2) {}

			// 2.更改密码
			_ChangePassword(conn, id, newpass);
		}
		catch (Exception e) {
			nps.util.DefaultLog.error(e);
		}
		finally {
			if (conn != null)
				try {
					conn.close();
				}
				catch (Exception e1) {}
		}
	}

	public void ChangePassword(Connection conn, String oldpass, String newpass) throws NpsException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {
			// 1.校验老密码
			String sql = "select password from users where id=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, id);
			rs = pstmt.executeQuery();
			if (!rs.next())
				throw new NpsException("No " + name, ErrorHelper.SYS_NOUSER);
			String dbpass = rs.getString("password");
			if (oldpass != null && dbpass != null) {
				if (!oldpass.equals(dbpass))
					throw new NpsException("Wrong old password", ErrorHelper.SYS_PASSWORD_ERROR);
			} else if ((oldpass != null && dbpass == null) || (oldpass == null && dbpass != null)) {
				throw new NpsException("Wrong old password", ErrorHelper.SYS_PASSWORD_ERROR);
			}

			try {
				rs.close();
			}
			catch (Exception e1) {}
			try {
				pstmt.close();
			}
			catch (Exception e2) {}

			// 2.更改密码
			_ChangePassword(conn, id, newpass);
		}
		catch (Exception e) {
			try {
				conn.rollback();
			}
			catch (Exception e1) {}
			nps.util.DefaultLog.error(e);
		}
	}

	private void _ChangePassword(Connection conn, String uid, String pass) throws NpsException {
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement("update users set password=? where id=?");
			pstmt.setString(1, pass);
			pstmt.setString(2, uid);
			pstmt.executeUpdate();
		}
		catch (Exception e) {
			nps.util.DefaultLog.error(e);
		}
		finally {
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e1) {}
		}
	}

	// 删除指定的用户，返回成功删除的清单
	public List Delete(String[] uids) throws NpsException {
		if (uids == null || uids.length == 0)
			return null;
		if (!IsSysAdmin() && !IsLocalAdmin())
			throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

		Connection conn = null;
		try {
			conn = Database.GetDatabase("nps").GetConnection();
			conn.setAutoCommit(false);
			return Delete(conn, uids);
		}
		catch (NpsException nps_e) {
			try {
				conn.rollback();
			}
			catch (Exception e1) {}
		}
		catch (Exception e) {
			try {
				conn.rollback();
			}
			catch (Exception e1) {}
			nps.util.DefaultLog.error(e);
		}
		finally {
			if (conn != null)
				try {
					conn.close();
				}
				catch (Exception e1) {}
		}

		return null;
	}

	public List Delete(Connection conn, String[] uids) throws NpsException {
		if (uids == null || uids.length == 0)
			return null;
		if (!IsSysAdmin() && !IsLocalAdmin())
			throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

		ArrayList list = new ArrayList(uids.length);
		try {
			for (Object obj : uids) {
				String uid = (String) obj;
				if (uid == null || uid.length() == 0)
					continue;

				User aUser = null;
				String owner = null;

				// 不能删除的用户就跳过
				try {
					aUser = GetUser(conn, uid);
					if (aUser == null)
						continue;

					owner = GetDefaultOwner(conn, aUser.GetUnit(), uids);
				}
				catch (Exception e) {
					nps.util.DefaultLog.error_noexception(e);
					continue;
				}

				// 删除用户
				Delete(conn, aUser, owner);
				list.add(uid);
			}
		}
		catch (Exception e) {
			try {
				conn.rollback();
			}
			catch (Exception e1) {}
			list.clear();
			nps.util.DefaultLog.error(e);
		}

		return list;
	}

	// 删除自己
	public void Delete() throws NpsException {
		Delete(new String[]{id});
	}

	// 获得Unit指定站点的管理员，不包括excepts清单
	private String GetDefaultOwner(Connection conn, Unit aunit, String[] excepts)
			throws NpsException {
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		String owner = null;
		try {
			// 1.查找该站点的管理员。用于将所有以前人员发布的文章全部挂在该站点的管理员名下
			// 如果该站点没有管理员，设置为管理员，待管理员处理
			String sql = "Select a.userid From site_owner a,users b,dept c Where a.userid=b.Id and b.dept=c.id and c.unit=?";
			String clause_where = "";
			if (excepts != null && excepts.length > 0) {
				for (Object obj : excepts) {
					String except = (String) obj;
					clause_where = " and b.id<>'" + except + "'";
				}
			}

			pstmt = conn.prepareStatement(sql + clause_where);
			pstmt.setString(1, aunit.GetId());
			rs = pstmt.executeQuery();
			if (rs.next()) {
				owner = rs.getString("userid");
			} else {
				// 如果该站点没有管理员，设置为管理员，待管理员处理
				try {
					rs.close();
				}
				catch (Exception e1) {}
				try {
					pstmt.close();
				}
				catch (Exception e1) {}
				sql = "select id from users b where utype=9 " + clause_where;
				pstmt = conn.prepareStatement(sql + clause_where);
				rs = pstmt.executeQuery();
				if (rs.next()) {
					owner = rs.getString("id");
				}
			}
		}
		catch (Exception e) {
			nps.util.DefaultLog.error(e);
		}
		finally {
			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e1) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e1) {}
		}

		return owner;
	}

	// 删除指定用户USER，并将该用户的文章挂在owner下
	private void Delete(Connection conn, User user, String owner) throws NpsException {
		PreparedStatement pstmt = null;
		String sql = null;
		try {
			// 1.将文章挂在owner下
			sql = "update article set creator=? where creator=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, owner);
			pstmt.setString(2, user.GetId());
			pstmt.executeUpdate();
			try {
				pstmt.close();
			}
			catch (Exception e1) {}

			// 2.将template挂在owner下
			sql = "update template set creator=? where creator=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, owner);
			pstmt.setString(2, user.GetId());
			pstmt.executeUpdate();
			try {
				pstmt.close();
			}
			catch (Exception e1) {}

			// 3.将resource挂在owner下
			sql = "update resources set creator=? where creator=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, owner);
			pstmt.setString(2, user.GetId());
			pstmt.executeUpdate();
			try {
				pstmt.close();
			}
			catch (Exception e1) {}

			// 3.删除用户角色
			sql = "delete from userrole where userid=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user.GetId());
			pstmt.executeUpdate();
			try {
				pstmt.close();
			}
			catch (Exception e1) {}

			// 3.1删除该用户可以管理的所有角色
			sql = "delete from userrole_grantable where userid=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user.GetId());
			pstmt.executeUpdate();
			try {
				pstmt.close();
			}
			catch (Exception e1) {}

			// 4.删除版主
			sql = "delete from topic_owner where userid=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user.GetId());
			pstmt.executeUpdate();
			try {
				pstmt.close();
			}
			catch (Exception e1) {}

			// 5.删除站点属主
			sql = "delete from site_owner where userid=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user.GetId());
			pstmt.executeUpdate();
			try {
				pstmt.close();
			}
			catch (Exception e1) {}

			// 6.删除用户
			sql = "delete from users where id=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user.GetId());
			pstmt.executeUpdate();
		}
		catch (Exception e) {
			nps.util.DefaultLog.error(e);
		}
		finally {
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e1) {}
		}
	}

	// 为用户添加指定角色
	public void AddRole(Connection conn, User user, String role_id) throws NpsException {
		if (!IsSysAdmin() && !IsLocalAdmin())
			throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

		// 当前用户不能授权的，返回没有权限
		if (!HasRoleGrantable(role_id))
			throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

		if (role_id == null || role_id.length() == 0)
			return;

		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		try {
			sql = "select * from Role b where id=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, role_id);
			rs = pstmt.executeQuery();

			if (rs.next()) {
				String role_domain = rs.getString("domain");
				String role_name = rs.getString("name");

				try {
					rs.close();
				}
				catch (Exception e1) {}
				try {
					pstmt.close();
				}
				catch (Exception e1) {}

				sql = "insert into userrole(userid,roleid) values(?,?)";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, user.GetId());
				pstmt.setString(2, role_id);
				pstmt.executeUpdate();

				try {
					pstmt.close();
				}
				catch (Exception e1) {}

				// 该用户的权限立即生效
				if (user.roles_by_domain_name == null)
					user.roles_by_domain_name = new Hashtable();
				if (user.roles_by_id == null)
					user.roles_by_id = new Hashtable();

				if (user.roles_by_domain_name.containsKey(role_domain)) {
					Hashtable roles_by_name = (Hashtable) user.roles_by_domain_name.get(role_domain);
					if (!roles_by_name.containsKey(role_name))
						roles_by_name.put(role_name, role_id);
				} else {
					Hashtable roles_by_name = new Hashtable();
					roles_by_name.put(role_name, role_id);
					user.roles_by_domain_name.put(role_domain, roles_by_name);
				}
				user.roles_by_id.put(role_id, role_name);
			}
		}
		catch (Exception e) {
			try {
				conn.rollback();
			}
			catch (Exception e1) {}
			nps.util.DefaultLog.error(e);
		}
		finally {
			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e1) {}
		}
	}

	// 为用户添加指定角色
	public void AddRole(Connection conn, User user, String domain, String rolename)
			throws NpsException {
		if (!IsSysAdmin() && !IsLocalAdmin())
			throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

		// 当前用户不能授权的，返回没有权限
		if (!HasRoleGrantable(domain, rolename))
			throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

		if (domain == null)
			domain = "default";
		if (rolename == null || rolename.length() == 0)
			return;

		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		try {
			sql = "select * from Role b where domain=? and name=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, domain);
			pstmt.setString(2, rolename);
			rs = pstmt.executeQuery();

			if (rs.next()) {
				String role_id = rs.getString("id");

				try {
					rs.close();
				}
				catch (Exception e1) {}
				try {
					pstmt.close();
				}
				catch (Exception e1) {}

				sql = "insert into userrole(userid,roleid) values(?,?)";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, user.GetId());
				pstmt.setString(2, role_id);
				pstmt.executeUpdate();

				try {
					pstmt.close();
				}
				catch (Exception e1) {}

				// 该用户的权限立即生效
				if (user.roles_by_domain_name == null)
					user.roles_by_domain_name = new Hashtable();
				if (user.roles_by_id == null)
					user.roles_by_id = new Hashtable();

				if (user.roles_by_domain_name.containsKey(domain)) {
					Hashtable roles_by_name = (Hashtable) user.roles_by_domain_name.get(domain);
					if (!roles_by_name.containsKey(rolename))
						roles_by_name.put(rolename, role_id);
				} else {
					Hashtable roles_by_name = new Hashtable();
					roles_by_name.put(rolename, role_id);
					user.roles_by_domain_name.put(domain, roles_by_name);
				}
				user.roles_by_id.put(role_id, rolename);
			}
		}
		catch (Exception e) {
			try {
				conn.rollback();
			}
			catch (Exception e1) {}
			nps.util.DefaultLog.error(e);
		}
		finally {
			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e1) {}
		}
	}

	// 为用户user设置权限列表
	public void SetRoles(Connection conn, User user, String[] roles) throws NpsException {
		if (!IsSysAdmin() && !IsLocalAdmin())
			throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			String sql = "delete from userrole where userid=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user.id);
			pstmt.executeUpdate();

			if (roles != null && roles.length > 0) {
				try {
					pstmt.close();
				}
				catch (Exception e1) {}
				sql = "insert into userrole(userid,roleid) values(?,?)";
				pstmt = conn.prepareStatement(sql);
				for (int i = 0; i < roles.length; i++) {
					if (roles[i] != null && roles[i].length() > 0) {
						pstmt.setString(1, user.GetId());
						pstmt.setString(2, roles[i]);
						pstmt.executeUpdate();

					}
				}
			}

			// 该用户的权限立即生效
			// 从数据库中加载ROLE信息
			try {
				pstmt.close();
			}
			catch (Exception e1) {}
			if (user.roles_by_domain_name != null)
				user.roles_by_domain_name.clear();
			if (user.roles_by_id != null)
				user.roles_by_id.clear();

			if (roles != null && roles.length > 0) {
				sql = "select b.* from UserRole a,Role b where a.roleid = b.id and a.userid=?";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, user.id);
				rs = pstmt.executeQuery();

				while (rs.next()) {
					if (user.roles_by_domain_name == null)
						user.roles_by_domain_name = new Hashtable();
					if (user.roles_by_id == null)
						user.roles_by_id = new Hashtable();

					if (user.roles_by_domain_name.containsKey(rs.getString("domain"))) {
						Hashtable roles_by_name = (Hashtable) user.roles_by_domain_name.get(rs.getString("domain"));
						if (!roles_by_name.containsKey(rs.getString("name")))
							roles_by_name.put(rs.getString("name"), rs.getString("id"));
					} else {
						Hashtable roles_by_name = new Hashtable();
						roles_by_name.put(rs.getString("name"), rs.getString("id"));
						user.roles_by_domain_name.put(rs.getString("domain"), roles_by_name);
					}
					user.roles_by_id.put(rs.getString("id"), rs.getString("name"));
				}
			}
		}
		catch (Exception e) {
			try {
				conn.rollback();
			}
			catch (Exception e1) {}
			nps.util.DefaultLog.error(e);
		}
		finally {
			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e1) {}
		}
	}

	// 为指定用户添加可授权的角色
	public void AddGrantableRole(Connection conn, User user, String role_id) throws NpsException {
		if (!IsSysAdmin() && !IsLocalAdmin())
			throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

		// 当前用户不能授权的，返回没有权限
		if (!HasRoleGrantable(role_id))
			throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

		if (role_id == null || role_id.length() == 0)
			return;

		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		try {
			sql = "select * from Role b where id=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, role_id);
			rs = pstmt.executeQuery();

			if (rs.next()) {
				String role_domain = rs.getString("domain");
				String role_name = rs.getString("name");

				try {
					rs.close();
				}
				catch (Exception e1) {}
				try {
					pstmt.close();
				}
				catch (Exception e1) {}

				sql = "insert into userrole_grantable(userid,roleid) values(?,?)";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, user.GetId());
				pstmt.setString(2, role_id);
				pstmt.executeUpdate();

				// 该用户的权限立即生效
				// 从数据库中加载ROLE信息
				if (user.roles_grantable_by_domain_name == null)
					user.roles_grantable_by_domain_name = new Hashtable();
				if (user.roles_grantable_by_id == null)
					user.roles_grantable_by_id = new Hashtable();

				if (user.roles_grantable_by_domain_name.containsKey(role_domain)) {
					Hashtable roles_by_name = (Hashtable) user.roles_grantable_by_domain_name.get(role_domain);
					if (!roles_by_name.containsKey(role_name))
						roles_by_name.put(role_name, role_id);
				} else {
					Hashtable roles_by_name = new Hashtable();
					roles_by_name.put(role_name, role_id);
					user.roles_grantable_by_domain_name.put(role_domain, roles_by_name);
				}

				user.roles_grantable_by_id.put(role_id, role_name);
			}
		}
		catch (Exception e) {
			try {
				conn.rollback();
			}
			catch (Exception e1) {}
			nps.util.DefaultLog.error(e);
		}
		finally {
			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e1) {}
		}
	}

	// 为指定用户添加可授权的角色
	public void AddGrantableRole(Connection conn, User user, String domain, String rolename)
			throws NpsException {
		if (!IsSysAdmin() && !IsLocalAdmin())
			throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

		// 当前用户不能授权的，返回没有权限
		if (!HasRoleGrantable(domain, rolename))
			throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

		if (domain == null)
			domain = "default";
		if (rolename == null || rolename.length() == 0)
			return;

		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		try {
			sql = "select * from Role b where domain=? and name=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, domain);
			pstmt.setString(2, rolename);
			rs = pstmt.executeQuery();

			if (rs.next()) {
				String role_id = rs.getString("id");

				try {
					rs.close();
				}
				catch (Exception e1) {}
				try {
					pstmt.close();
				}
				catch (Exception e1) {}

				sql = "insert into userrole_grantable(userid,roleid) values(?,?)";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, user.GetId());
				pstmt.setString(2, role_id);
				pstmt.executeUpdate();

				// 该用户的权限立即生效
				// 从数据库中加载ROLE信息
				if (user.roles_grantable_by_domain_name == null)
					user.roles_grantable_by_domain_name = new Hashtable();
				if (user.roles_grantable_by_id == null)
					user.roles_grantable_by_id = new Hashtable();

				if (user.roles_grantable_by_domain_name.containsKey(domain)) {
					Hashtable roles_by_name = (Hashtable) user.roles_grantable_by_domain_name.get(domain);
					if (!roles_by_name.containsKey(rolename))
						roles_by_name.put(rolename, role_id);
				} else {
					Hashtable roles_by_name = new Hashtable();
					roles_by_name.put(rolename, role_id);
					user.roles_grantable_by_domain_name.put(domain, roles_by_name);
				}

				user.roles_grantable_by_id.put(role_id, rolename);
			}
		}
		catch (Exception e) {
			try {
				conn.rollback();
			}
			catch (Exception e1) {}
			nps.util.DefaultLog.error(e);
		}
		finally {
			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e1) {}
		}
	}

	// 为用户user设置可管理的权限列表
	public void SetGrantableRoles(Connection conn, User user, String[] roles) throws NpsException {
		if (!IsSysAdmin() && !IsLocalAdmin())
			throw new NpsException(ErrorHelper.ACCESS_NOPRIVILEGE);

		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			String sql = "delete from userrole_grantable where userid=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user.id);
			pstmt.executeUpdate();

			if (roles != null && roles.length > 0) {
				try {
					pstmt.close();
				}
				catch (Exception e1) {}
				sql = "insert into userrole_grantable(userid,roleid) values(?,?)";
				pstmt = conn.prepareStatement(sql);
				for (int i = 0; i < roles.length; i++) {
					if (roles[i] != null && roles[i].length() > 0) {
						pstmt.setString(1, user.GetId());
						pstmt.setString(2, roles[i]);
						pstmt.executeUpdate();
					}
				}
			}

			// 该用户的权限立即生效
			// 从数据库中加载ROLE信息
			try {
				pstmt.close();
			}
			catch (Exception e1) {}
			if (user.roles_grantable_by_id != null)
				user.roles_grantable_by_id.clear();

			if (roles != null && roles.length > 0) {
				sql = "select b.* from UserRole_grantable a,Role b where a.roleid = b.id and a.userid=?";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, user.id);
				rs = pstmt.executeQuery();

				while (rs.next()) {
					if (user.roles_grantable_by_domain_name == null)
						user.roles_grantable_by_domain_name = new Hashtable();
					if (user.roles_grantable_by_id == null)
						user.roles_grantable_by_id = new Hashtable();

					if (user.roles_grantable_by_domain_name.containsKey(rs.getString("domain"))) {
						Hashtable roles_by_name = (Hashtable) user.roles_grantable_by_domain_name.get(rs.getString("domain"));
						if (!roles_by_name.containsKey(rs.getString("name")))
							roles_by_name.put(rs.getString("name"), rs.getString("id"));
					} else {
						Hashtable roles_by_name = new Hashtable();
						roles_by_name.put(rs.getString("name"), rs.getString("id"));
						user.roles_grantable_by_domain_name.put(rs.getString("domain"),
																roles_by_name);
					}

					user.roles_grantable_by_id.put(rs.getString("id"), rs.getString("name"));
				}
			}
		}
		catch (Exception e) {
			try {
				conn.rollback();
			}
			catch (Exception e1) {}
			nps.util.DefaultLog.error(e);
		}
		finally {
			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e1) {}
		}
	}

	public boolean HasRole(String roleid) {
		if (roles_by_id != null && roles_by_id.containsKey(roleid))
			return true;
		return false;
	}

	public boolean HasRole(String domain, String rolename) {
		return HasRoleName(domain, rolename);
	}

	public boolean HasRoleName(String domain, String rolename) {
		if (domain == null || domain.length() == 0)
			domain = "default";

		if (roles_by_domain_name == null || !roles_by_domain_name.containsKey(domain))
			return false;

		Hashtable roles_name = (Hashtable) roles_by_domain_name.get(domain);
		if (roles_name != null && roles_name.containsKey(rolename))
			return true;

		return false;
	}

	public boolean HasRoleGrantable(String roleid) {
		// 系统管理员永远可以分配权限
		if (IsSysAdmin())
			return true;

		if (roles_grantable_by_id != null && roles_grantable_by_id.containsKey(roleid))
			return true;
		return false;
	}

	public boolean HasRoleGrantable(String domain, String rolename) {
		// 系统管理员永远可以分配权限
		if (IsSysAdmin())
			return true;

		if (domain == null || domain.length() == 0)
			domain = "default";

		if (roles_grantable_by_domain_name == null
			|| !roles_grantable_by_domain_name.containsKey(domain))
			return false;

		Hashtable roles_name = (Hashtable) roles_grantable_by_domain_name.get(domain);
		if (roles_name != null && roles_name.containsKey(rolename))
			return true;

		return false;
	}

	// 系统管理员
	public boolean IsSysAdmin() {
		return type == USER_SYSADMIN;
	}

	// 本单位管理员
	public boolean IsSiteAdmin(String site_id) {
		if (site_id == null || site_id.length() == 0)
			return false;
		if (sites_owners == null || sites_owners.isEmpty())
			return false;

		return sites_owners.containsKey(site_id);
	}

	// 判断是否可以访问某个站点
	public boolean IsAccessibleSite(String site_id) {
		if (site_id == null || site_id.length() == 0)
			return false;
		if (sites_owners != null && sites_owners.containsKey(site_id))
			return true;
		if (sites_myunit != null && sites_myunit.containsKey(site_id))
			return true;

		return false;
	}

	// 本单位管理员，只要有站点归他管理，就是本单位管理员
	// 只能管理自己单位的站点，所以只要判断是否是有站点归他管理就可以了
	// 可以开设帐号、部门
	public boolean IsLocalAdmin() {
		// 2008.04.15,jialin fixed
		// sysadmin is local admin too
		if (type == USER_SYSADMIN)
			return true;
		if (sites_owners == null || sites_owners.isEmpty())
			return false;
		return true;
	}

	// 是否普通用户
	public boolean IsNormalUser() {
		return type == USER_NORMAL;
	}

	public void RemoveSite(Site site) {
		if (sites_owners != null)
			sites_owners.remove(site.GetId());
		if (sites_myunit != null)
			sites_myunit.remove(site.GetId());
	}

	public void Add2OwnSite(Site site) {
		if (sites_owners == null)
			sites_owners = new Hashtable();
		if (sites_owners.containsKey(site.GetId()))
			sites_owners.remove(site.GetId());

		sites_owners.put(site.GetId(), site.GetName());
	}

	public void Add2UnitSite(Site site) {
		if (sites_myunit == null)
			sites_myunit = new Hashtable();
		if (sites_myunit.containsKey(site.GetId()))
			sites_myunit.remove(site.GetId());

		sites_myunit.put(site.GetId(), site.GetName());
	}

	public void SetName(String s) {
		this.name = s;
	}

	public void SetAccount(String s) {
		this.account = s.toUpperCase();
	}

	public void SetDept(Dept dept) {
		this.dept_id = dept.GetId();
		this.unit_id = dept.GetUnit().GetId();
	}

	// 只有系统管理员才能修改用户类型
	public void SetType(User user, int utype) {
		if (IsSysAdmin())
			user.type = utype;
	}

	public void SetIndex(int i) {
		index = i;
	}

	public void SetTelephone(String tele) {
		this.telephone = tele;
	}

	public void SetFax(String fax) {
		this.fax = fax;
	}

	public void SetEmail(String email) {
		this.email = email;
	}

	public void SetMobile(String mobile) {
		this.mobile = mobile;
	}

	// 2010.03.23 jialin
	// 调整位首先从缓冲池中读取，如果没有，才从数据库中加载
	public Dept GetDept() {
		DeptTree tree = DeptPool.GetPool().get(unit_id);
		if (tree != null)
			return tree.GetDept(dept_id);

		Connection conn = null;
		try {
			conn = Database.GetDatabase("nps").GetConnection();
			return GetDept(conn);
		}
		catch (NpsException nps_e) {

		}
		catch (Exception e) {
			nps.util.DefaultLog.error_noexception(e);
		}
		finally {
			try {
				conn.close();
			}
			catch (Exception e1) {}
		}

		return null;
	}

	public Dept GetDept(Connection conn) throws NpsException {
		DeptTree tree = DeptPool.GetPool().get(unit_id);
		if (tree != null)
			return tree.GetDept(dept_id);

		try {
			Unit unit = Unit.GetUnit(conn, unit_id);
			tree = unit.GetDeptTree(conn);
			DeptPool.GetPool().put(tree);
			if (tree != null)
				return tree.GetDept(dept_id);
		}
		catch (Exception e) {
			nps.util.DefaultLog.error(e);
		}

		return null;
	}

	// 获取单位列表
	// 系统管理员返回所有单位列表，一般用户返回本单位列表
	public List<Unit> GetUnits() throws NpsException {
		ArrayList<Unit> units = new ArrayList<Unit>();

		// 一般用户，只能看到自己所在单位信息
		if (type != USER_SYSADMIN) {
			Unit unit = this.GetUnit();
			if (unit == null)
				return units;
			units.add(unit);
			return units;
		}

		// 系统管理员，可以看到所有单位信息
		Connection conn = null;
		try {
			conn = Database.GetDatabase("nps").GetConnection();
			return GetUnits(conn);
		}
		catch (NpsException nps_e) {
			// nothing we do
		}
		catch (Exception e) {
			nps.util.DefaultLog.error(e);
		}
		finally {
			if (conn != null)
				try {
					conn.close();
				}
				catch (Exception e) {}
		}

		return units;
	}

	public List<Unit> GetUnits(Connection conn) throws NpsException {
		ArrayList<Unit> units = new ArrayList<Unit>();

		// 一般用户，只能看到自己所在单位信息
		if (type != USER_SYSADMIN) {
			Unit unit = this.GetUnit();
			if (unit == null)
				return units;
			units.add(unit);
			return units;
		}

		// 系统管理员，可以看到所有单位信息
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			// Load unit information
			String sql = "select * from unit";
			pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				DeptTree tree = DeptPool.GetPool().get(rs.getString("id"));
				if (tree != null) {
					units.add(tree.GetUnit());
					continue;
				}

				Unit aUnit = new Unit(	rs.getString("id"),
										rs.getString("name"),
										rs.getString("code"));

				aUnit.SetAddress(rs.getString("address"));
				aUnit.SetAttachman(rs.getString("attachman"));
				aUnit.SetMobile(rs.getString("mobile"));
				aUnit.SetPhonenum(rs.getString("phonenum"));
				aUnit.SetZipcode(rs.getString("zipcode"));
				aUnit.SetEmail(rs.getString("email"));

				// 写入缓存
				tree = aUnit.GetDeptTree(conn);
				DeptPool.GetPool().put(tree);

				units.add(aUnit);
			}
		}
		catch (Exception e) {
			nps.util.DefaultLog.error(e);
		}
		finally {
			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception e) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception e) {}
		}

		return units;
	}

	// 获得当前用户所属单位
	// 2010.03.23 jialin
	// 调整位首先从缓冲池中读取，如果没有，才从数据库中加载
	public Unit GetUnit() {
		DeptTree tree = DeptPool.GetPool().get(unit_id);
		if (tree != null)
			return tree.GetUnit();

		Connection conn = null;
		try {
			conn = Database.GetDatabase("nps").GetConnection();

			return GetUnit(conn);
		}
		catch (NpsException nps_e) {
			// nothing we do
		}
		catch (Exception e) {
			nps.util.DefaultLog.error_noexception(e);
		}
		finally {
			if (conn != null)
				try {
					conn.close();
				}
				catch (Exception e) {}
		}

		return null;
	}

	public Unit GetUnit(Connection conn) throws NpsException {
		DeptTree tree = DeptPool.GetPool().get(unit_id);
		if (tree != null)
			return tree.GetUnit();

		try {
			// 加载单位信息并写入缓存
			Unit unit = Unit.GetUnit(conn, unit_id);
			tree = DeptTree.LoadTree(conn, unit, unit.GetName());
			DeptPool.GetPool().put(tree);

			return unit;
		}
		catch (Exception e) {
			nps.util.DefaultLog.error(e);
		}

		return null;
	}

	// 根据ID获得所属单位
	// 2010.03.23 jialin
	// 调整位首先从缓冲池中读取，如果没有，才从数据库中加载
	public Unit GetUnit(String unitid) throws NpsException {
		if (unitid == null)
			return null;
		if (unitid.equals(unit_id))
			return GetUnit();

		// 不是系统管理员不能获得其他单位信息
		if (type != USER_SYSADMIN)
			return null;

		DeptTree tree = DeptPool.GetPool().get(unitid);
		if (tree != null)
			return tree.GetUnit();

		Connection conn = null;
		try {
			conn = Database.GetDatabase("nps").GetConnection();

			return GetUnit(conn, unitid);
		}
		catch (NpsException nps_e) {
			// nothing we do
		}
		catch (Exception e) {
			nps.util.DefaultLog.error(e);
		}
		finally {
			if (conn != null)
				try {
					conn.close();
				}
				catch (Exception e) {}
		}

		return null;
	}

	public Unit GetUnit(Connection conn, String unitid) throws NpsException {
		if (unitid == null)
			return null;
		if (unitid.equals(unit_id))
			return GetUnit(conn);

		// 不是系统管理员不能获得其他单位信息
		if (type != USER_SYSADMIN)
			return null;

		DeptTree tree = DeptPool.GetPool().get(unitid);
		if (tree != null)
			return tree.GetUnit();

		try {
			// 加载单位信息并写入缓存
			Unit unit = Unit.GetUnit(conn, unitid);
			tree = DeptTree.LoadTree(conn, unit, unit.GetName());
			DeptPool.GetPool().put(tree);

			return unit;
		}
		catch (NpsException nps_e) {
			// nothing we do
		}
		catch (Exception e) {
			nps.util.DefaultLog.error(e);
		}

		return null;
	}

	public String GetUnitId() {
		return unit_id;
	}

	public String GetUnitName() {
		Unit unit = GetUnit();
		if (unit == null)
			return null;
		return unit.GetName();
	}

	public String GetUnitCode() {
		Unit unit = GetUnit();
		if (unit == null)
			return null;
		return unit.GetCode();
	}

	public String GetDeptId() {
		return dept_id;
	}

	public String GetDeptCode() {
		Dept dept = GetDept();
		if (dept == null)
			return null;
		return dept.GetCode();
	}

	public String GetDeptName() {
		Dept dept = GetDept();
		if (dept == null)
			return null;
		return dept.GetName();
	}

	public String GetTelephone() {
		return telephone;
	}

	public String GetFax() {
		return fax;
	}

	public String GetEmail() {
		return email;
	}

	public String GetMobile() {
		return mobile;
	}

	public String GetUID() {
		return id;
	}

	public String GetName() {
		return name;
	}

	public String GetAccount() {
		return account;
	}

	// TreeNode系列方法
	public String GetId() {
		return id;
	}

	// parentid为dept id
	public String GetParentId() {
		return dept_id;
	}

	public void SetLocale(Locale local) {
		this.locale = local;
	}

	public Locale GetLocale() {
		return locale;
	}

	public String GetFace() {
		return face;
	}

	public void SetFace(String s) {
		face = s;
	}

	public int GetIndex() {
		return index;
	}

	public String GetDefaultSiteId() {
		return default_site;
	}

	public void SetDefaultSite(String id) {
		if (sites_owners.containsKey(id))
			default_site = id;
	}

	public Site GetDefaultSite() {
		if (default_site == null)
			return null;
		return GetSite(default_site);
	}

	public Hashtable GetOwnSites() {
		return sites_owners;
	}

	// 获得本单位建的所有站点，系统管理员返回所有站点
	// Hashtable id为site id，value为site name
	public Hashtable GetUnitSites() {
		return sites_myunit;
	}

	// 返回所有有公开栏目的站点，但不包括本单位站点
	// Hashtable id为site id，value为site name
	public Hashtable GetPublicSites() {
		return sites_public;
	}

	public Site GetSite(String siteid) {
		if (sites != null && sites.containsKey(siteid))
			return (Site) sites.get(siteid);

		// 校验是否有权限
		if ((sites_owners == null || !sites_owners.containsKey(siteid))
			&& (sites_myunit == null || !sites_myunit.containsKey(siteid)))
			return null;

		// 从Site Pool缓存中读取
		Site site = SitePool.GetPool().get(siteid);
		if (site != null)
			return site;

		// 加载Site信息
		Connection conn = null;
		NpsContext ctxt = null;

		try {
			conn = Database.GetDatabase("nps").GetConnection();
			ctxt = new NpsContext(conn, this);
			return GetSite(ctxt, siteid);
		}
		catch (Exception e) {
			nps.util.DefaultLog.error_noexception(e);
		}
		finally {
			if (ctxt != null)
				ctxt.Clear();
		}

		return null;
	}

	public Site GetSite(NpsContext ctxt, String siteid) {
		if (sites != null && sites.containsKey(siteid))
			return (Site) sites.get(siteid);

		// 校验是否有权限
		if ((sites_owners == null || !sites_owners.containsKey(siteid))
			&& (sites_myunit == null || !sites_myunit.containsKey(siteid)))
			return null;

		// 加载Site信息
		try {
			Site site = ctxt.GetSite(siteid);
			if (site != null) {
				if (sites == null)
					sites = new Hashtable();
				sites.put(siteid, site);
			}
			return site;
		}
		catch (Exception e) {
			nps.util.DefaultLog.error_noexception(e);
		}

		return null;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getItg_fixedpointname() {
		return itg_fixedpointname;
	}

	public void setItg_fixedpointname(String itg_fixedpointname) {
		this.itg_fixedpointname = itg_fixedpointname;
	}

	public String getItg_fixedpoint() {
		return itg_fixedpoint;
	}

	public void setItg_fixedpoint(String itg_fixedpoint) {
		this.itg_fixedpoint = itg_fixedpoint;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getAccount() {
		return account;
	}

	public void setAccount(String account) {
		this.account = account;
	}

	public String getMobile() {
		return mobile;
	}

	public void setMobile(String mobile) {
		this.mobile = mobile;
	}

	public String getAdrid() {
		return adrid;
	}

	public void setAdrid(String adrid) {
		this.adrid = adrid;
	}

	public Integer getPoint() {
		return point;
	}

	public void setPoint(Integer point) {
		this.point = point;
	}

	public Double getMoney() {
		return money;
	}

	public void setMoney(Double money) {
		this.money = money;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

}