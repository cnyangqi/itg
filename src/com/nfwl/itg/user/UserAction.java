package com.nfwl.itg.user;

import java.sql.Connection;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.jado.JLog;
import com.gemway.util.JUtil;
import com.jado.JadoException;
import com.nfwl.itg.common.ITG_HZ_ZONE;
import com.nfwl.itg.common.Message;
import com.nfwl.itg.common.TokenManager;
import com.nfwl.itg.common.dbUtil;

/**
 * 用户Action
 * 
 * @author yangq(qi.yang.cn@gmail.com)
 * 2012-2-23
 */
public class UserAction extends nfwlAction {

	/*
	 * 修改用户信息
	 */
	public ActionForward modfiy(ActionMapping mapping,
								ActionForm form,
								HttpServletRequest request,
								HttpServletResponse response) throws Exception {
		Connection con = null;
		try {
			if (TokenManager.isTokenValid(request, true)) {
				nps.core.User suser = (nps.core.User) request.getSession().getAttribute("user");
				UserForm userform = (UserForm) form;
				// 更新信息
				UserManager um = new UserManager();
				User user = um.formTObean(userform);
				if (suser.getId().equals(user.getId())) {
					
					/** 用户类型 */
					user.setUtype(suser.getType());

					con = dbUtil.getNfwlCon();
					um.update(con, user);

					TokenManager.saveToken(request);

					Message ms = new Message();
					ms.setFlag(true);
					ms.setMsg("修改用户信息成功!");
					request.setAttribute("message", ms);

					request.setAttribute("userForm", userform);
				} else {
					Message ms = new Message();
					ms.setFlag(true);
					ms.setMsg("修改用户信息出错!");
					request.setAttribute("message", ms);

				}

			} else {
				JLog.getLogger().info("非法的提交修改用户信息");
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("非法的提交修改用户信息!");
				request.setAttribute("message", ms);
				return mapping.findForward("userFailed");
			}

		}
		catch (Exception e) {
			JLog.getLogger().error("修改用户信息出错", e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("修改用户信息出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		}
		finally {
			if (con != null)
				con.close();
		}

		return mapping.findForward("modfiySuccess");
	}

	/*
	 * 修改密码
	 */
	public ActionForward changepassword(ActionMapping mapping,
										ActionForm form,
										HttpServletRequest request,
										HttpServletResponse response) throws Exception {
		Connection con = null;
		try {
			if (TokenManager.isTokenValid(request, true)) {
				con = nps.core.Database.GetDatabase("nfwl").GetConnection();
				nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");

				String oldpassword = JUtil.convertNull(request.getParameter("oldpassword"));
				String password = JUtil.convertNull(request.getParameter("password"));

				user.ChangePassword(oldpassword, password);

				Message ms = new Message();
				ms.setFlag(true);
				ms.setMsg("修改密码成功!");
				request.setAttribute("message", ms);
				TokenManager.saveToken(request);
			} else {
				JLog.getLogger().info("非法的提交修改密码");
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("非法的提交修改密码!");
				request.setAttribute("message", ms);

				return mapping.findForward("userFailed");
			}

		}
		catch (Exception e) {
			JLog.getLogger().error("修改密码出错", e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("修改密码出错!");
			request.setAttribute("message", ms);
			TokenManager.saveToken(request);
			return mapping.findForward("changepasswordError");
		}
		finally {
			if (con != null)
				con.close();
		}

		return mapping.findForward("changepasswordSuccess");
	}

}
