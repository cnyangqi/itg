package controllers;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import models.UserModels;
import nps.exception.NpsException;
import tools.Pub;

import com.et.mvc.JsonView;
import com.et.mvc.View;

public class UserController extends ApplicationController {

	// 检测用户名是否可用
	/**
	 * 
	 * @param account
	 * @return
	 * @throws NpsException
	 */
	public View checkAccount(String account, Integer random) throws NpsException {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		boolean canContinue = true;
		String sql = "select id,name,account,password,telephone,itg_fixedpoint,fp_name,fax,email,mobile,face,cx,dept,utype from users ,itg_fixedpoint  where fp_id(+) = itg_fixedpoint and upper(account) = upper(?) ";

		String msg = "该用户名可以正常使用";
		try {
			con = nps.core.Database.GetDatabase("nps").GetConnection();
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, account);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				canContinue = false;
				msg = "该用户名已被使用，请更换！";
			}
		}
		catch (Exception ex) {
			nps.util.DefaultLog.error(ex);
		}
		finally {
			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception ex) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception ex) {}
			if (con != null)
				try {
					con.close();
				}
				catch (Exception ex) {}
		}

		Map<String, Object> result = new HashMap<String, Object>();
		result.put("success", canContinue);
		result.put("msg", msg);

		return new JsonView(result);
	}

	/**
	 * 
	 * @param id
	 * @return
	 * @throws Exception
	 */
	public static UserModels getUserById(String id) throws Exception {
		Connection con = null;
		UserModels user = null;
		try {
			con = nps.core.Database.GetDatabase("nps").GetConnection();
			PreparedStatement pstmt = null;
			ResultSet rs = null;

			try {
				String sql = "select id,name,account,password,telephone,itg_fixedpoint,fp_name,fax,email,mobile,face,cx,dept,utype,nickname,worknum from users ,itg_fixedpoint  where fp_id(+) = itg_fixedpoint and id = ? ";

				pstmt = con.prepareStatement(sql);
				// int pos = 1;
				pstmt.setString(1, id);

				rs = pstmt.executeQuery();
				if (rs.next()) {
					user = new UserModels();
					user.setId(rs.getString("id"));
					user.setName(rs.getString("name"));
					user.setAccount(rs.getString("account"));
					user.setTelephone(rs.getString("telephone"));
					user.setItg_fixedpoint(rs.getString("itg_fixedpoint"));
					user.setItg_fixedpointname(rs.getString("fp_name"));
					user.setEmail(rs.getString("email"));
					user.setFace(rs.getString("face"));
					user.setFax(rs.getString("fax"));
					user.setMobile(rs.getString("mobile"));
					user.setUtype(rs.getString("utype"));
					user.setDept(rs.getString("dept"));
					user.setNickname(rs.getString("nickname"));
					user.setWorknum(rs.getString("worknum"));
				}
			}
			catch (Exception ex) {
				nps.util.DefaultLog.error(ex);
			}
			finally {
				if (rs != null)
					try {
						rs.close();
					}
					catch (Exception ex) {}
				if (pstmt != null)
					try {
						pstmt.close();
					}
					catch (Exception ex) {}
			}
		}
		catch (Exception e) {

		}
		finally {
			if (con != null)
				try {
					con.close();
				}
				catch (Exception e) {}
		}
		return user;
	}

	/**
	 * 
	 * @param id
	 * @param fpid
	 * @param name
	 * @param utype
	 * @param fixedpoint
	 * @param mobile
	 * @param pageSize
	 * @param pageNumber
	 * @return
	 * @throws Exception
	 */
	public View getUser(String id,
						String fpid,
						String name,
						Integer utype,
						String fixedpoint,
						String mobile,
						Integer pageSize,
						Integer pageNumber) throws Exception {
		Map<String, Object> result = new HashMap<String, Object>();
		ArrayList<UserModels> users = new ArrayList<UserModels>();
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		UserModels user = null;
		int totle = 0;
		String sql = "select id,name,account,worknum,password,telephone,itg_fixedpoint,fp_name,fax,email,mobile,face,cx,dept,utype from users ,itg_fixedpoint  where fp_id(+) = itg_fixedpoint and utype >= 0 and utype<9 ";
		String sqlCount = "select count(id) from users ,itg_fixedpoint  where fp_id(+) = itg_fixedpoint and utype >= 0   and utype<9 ";

		try {
			con = nps.core.Database.GetDatabase("nps").GetConnection();

			if (id != null && id.length() > 0) {
				sqlCount += " and id = ? ";
			}
			if (fpid != null && fpid.length() > 0) {
				sqlCount += " and itg_fixedpoint = ? ";
			}
			if (name != null && name.length() > 0) {
				sqlCount += " and name  like ? ";
			}
			if (mobile != null && mobile.length() > 0) {
				sqlCount += " and mobile like ? ";
			}
			if (fixedpoint != null && fixedpoint.length() > 0) {
				sqlCount += " and  fp_name like  ? ";
			}
			if (utype != null && utype >= 0) {
				sqlCount += " and utype = ? ";
			}

			pstmt = con.prepareStatement(sqlCount);
			int pos = 1;
			if (id != null && id.length() > 0) {
				pstmt.setString(pos++, id);
			}
			if (fpid != null && fpid.length() > 0) {
				pstmt.setString(pos++, fpid);
			}
			if (name != null && name.length() > 0) {
				pstmt.setString(pos++, "%" + name + "%");
			}
			if (mobile != null && mobile.length() > 0) {
				pstmt.setString(pos++, "%" + mobile + "%");
			}
			if (fixedpoint != null && fixedpoint.length() > 0) {
				pstmt.setString(pos++, "%" + fixedpoint + "%");
			}
			if (utype != null && utype >= 0) {
				pstmt.setInt(pos++, utype);
			}
			rs = pstmt.executeQuery();
			if (rs.next()) {
				totle = rs.getInt(1);
			}
			result.put("total", totle);

			if (totle == 0) {
				result.put("rows", users);
				return new JsonView(result);
			}

			if (id != null && id.length() > 0) {
				sql += " and id = ? ";
			}
			if (fpid != null && fpid.length() > 0) {
				sql += " and itg_fixedpoint = ? ";
			}
			if (name != null && name.length() > 0) {
				sql += " and name  like ? ";
			}
			if (mobile != null && mobile.length() > 0) {
				sql += " and mobile like ? ";
			}
			if (fixedpoint != null && fixedpoint.length() > 0) {
				sql += " and  fp_name like  ? ";
			}
			if (utype != null && utype >= 0) {
				sql += " and utype = ? ";
			}

			pstmt = con.prepareStatement(sql);
			pos = 1;
			if (id != null && id.length() > 0) {
				pstmt.setString(pos++, id);
			}
			if (fpid != null && fpid.length() > 0) {
				pstmt.setString(pos++, fpid);
			}
			if (name != null && name.length() > 0) {
				pstmt.setString(pos++, "%" + name + "%");
			}
			if (mobile != null && mobile.length() > 0) {
				pstmt.setString(pos++, "%" + mobile + "%");
			}
			if (fixedpoint != null && fixedpoint.length() > 0) {
				pstmt.setString(pos++, "%" + fixedpoint + "%");
			}
			if (utype != null && utype >= 0) {
				pstmt.setInt(pos++, utype);
			}
			rs = pstmt.executeQuery();
			int index = 0;
			while (rs.next()) {
				if (++index <= pageSize * (pageNumber - 1))
					continue;
				if (index > pageSize * (pageNumber))
					break;
				if (users == null)
					users = new ArrayList<UserModels>();
				user = new UserModels();
				// id,name,account,password,telephone,itg_fixedpoint,fax,email,mobile,face,cx,dept,utype
				// from users
				user.setId(rs.getString("id"));
				user.setName(rs.getString("name"));
				user.setAccount(rs.getString("account"));
				user.setWorknum(rs.getString("worknum"));
				user.setTelephone(rs.getString("telephone"));
				user.setItg_fixedpoint(rs.getString("itg_fixedpoint"));
				user.setItg_fixedpointname(rs.getString("fp_name"));
				user.setFace(rs.getString("face"));
				user.setEmail(rs.getString("email"));
				user.setFax(rs.getString("fax"));
				user.setMobile(rs.getString("mobile"));
				user.setUtype(rs.getString("utype"));
				user.setDept(rs.getString("dept"));
				users.add(user);
			}

			result.put("rows", users);
			return new JsonView(result);
		}
		catch (Exception ex) {
			nps.util.DefaultLog.error(ex);
		}
		finally {
			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception ex) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception ex) {}
			if (con != null)
				try {
					con.close();
				}
				catch (Exception ex) {}
		}
		return null;
	}

	/**
	 * 
	 * @param user
	 * @return
	 * @throws Exception
	 */
	public View save(UserModels user) throws Exception {
		Map<String, Object> result = new HashMap<String, Object>();
		ArrayList<UserModels> users = new ArrayList<UserModels>();
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = "";
		boolean isNew = false;

		try {
			con = nps.core.Database.GetDatabase("nps").GetConnection();
			if (user.getId() == null || user.getId().length() < 1) {
				isNew = true;
				user.setId(Pub.createUNID());
			}
			if (isNew) {
				sql = "insert into users(id,name,account,worknum,password,telephone,itg_fixedpoint,fax,email,mobile,face,cx,dept,utype,nickname) "
						+ " values(?,?,UPPER(?),?,?,?,?,?,?,?,?,?,2,?,?)";
			} else {
				sql = " update users set id = ?,name = ?,worknum = ?,password = ?,telephone = ?,itg_fixedpoint = ?,fax = ?,email = ?,mobile = ?,face = ?,cx = ?,utype = ? ,nickname = ? where id = ?";
			}

			pstmt = con.prepareStatement(sql);

			int colIndex = 1;
			pstmt.setString(colIndex++, user.getId());
			pstmt.setString(colIndex++, user.getName());
			if (isNew) {
				// 新建用户才插入account 插入后account不可更改
				pstmt.setString(colIndex++, user.getAccount());
			}
			pstmt.setString(colIndex++, user.getWorknum());
			pstmt.setString(colIndex++, "1");
			pstmt.setString(colIndex++, user.getTelephone());
			pstmt.setString(colIndex++, user.getItg_fixedpoint());
			pstmt.setString(colIndex++, user.getFax());
			pstmt.setString(colIndex++, user.getEmail());
			pstmt.setString(colIndex++, user.getMobile());
			pstmt.setString(colIndex++, "");
			pstmt.setString(colIndex++, user.getCx());
			pstmt.setString(colIndex++, Pub.getString(user.getUtype(), "1"));
			pstmt.setString(colIndex++, user.getNickname());
			if (!isNew) {
				pstmt.setString(colIndex++, user.getId());
			}
			pstmt.executeUpdate();
			result.put("success", true);
			if (!isNew) {
				result.put("msg", "成功更新");
			} else {
				result.put("msg", "成功保存");
			}
		}
		catch (Exception ex) {
			nps.util.DefaultLog.error(ex);
		}
		finally {
			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception ex) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception ex) {}
			if (con != null)
				try {
					con.close();
				}
				catch (Exception ex) {}
		}

		// return new JsonView(result);
		View view = new JsonView(result);
		view.setContentType("text/html;charset=utf-8");
		return view;

	}

	/**
	 * 
	 * @param id
	 * @return
	 * @throws Exception
	 */
	public View delete(String id) throws Exception {
		Map<String, Object> result = new HashMap<String, Object>();
		ArrayList<UserModels> users = new ArrayList<UserModels>();
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = "update   users set utype = -1 where id in (" + id + ")";
		boolean isNew = false;
		try {
			con = nps.core.Database.GetDatabase("nps").GetConnection();
			// System.out.println("delete sql = "+sql);
			pstmt = con.prepareStatement(sql);

			pstmt.executeUpdate();
			result.put("success", true);
			result.put("msg", "删除成功");
		}
		catch (Exception ex) {
			result.put("success", false);
			result.put("msg", "用户删除失败");
			nps.util.DefaultLog.error(ex);
		}
		finally {
			if (rs != null)
				try {
					rs.close();
				}
				catch (Exception ex) {}
			if (pstmt != null)
				try {
					pstmt.close();
				}
				catch (Exception ex) {}
			if (con != null)
				try {
					con.close();
				}
				catch (Exception e) {}
		}

		// return new JsonView(result);
		View view = new JsonView(result);
		view.setContentType("text/html;charset=utf-8");
		return view;

	}

}
