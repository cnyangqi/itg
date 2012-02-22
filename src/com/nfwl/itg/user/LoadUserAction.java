package com.nfwl.itg.user;

import java.sql.Connection;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.jado.JLog;
import com.nfwl.itg.common.Message;
import com.nfwl.itg.common.TokenManager;
import com.nfwl.itg.common.dbUtil;

/**
 * 
 * @Project：ithinkgo
 * @Type： UserAction
 * @Author: yjw
 * @Email: y.jinwei@gmail.com
 * @Mobile: 13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date: 2011-7-24 下午05:19:24
 * @Comment
 * 
 */

public class LoadUserAction extends nfwlAction {

	public ActionForward modfiy(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection con = null;
		try {
			con = dbUtil.getNfwlCon();
			nps.core.User user = (nps.core.User) request.getSession()
					.getAttribute("user");
			String userid = user.GetId();
			UserManager um = new UserManager();
			User u = (User) um.get(con, userid);
			TokenManager.saveToken(request);
			UserForm uf = um.beanTOform(u);
			request.setAttribute("userForm", uf);
		} catch (Exception e) {
			JLog.getLogger().error("显示用户信息出错", e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("显示用户信息出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");

		} finally {
			if (con != null)
				con.close();
		}

		return mapping.findForward("modfiySuccess");
	}

	/** 账户信息 */
	@SuppressWarnings("rawtypes")
	public ActionForward acctountInfo(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection con = null;
		try {
			con = dbUtil.getNfwlCon();
			nps.core.User user = (nps.core.User) request.getSession()
					.getAttribute("user");
			String userid = user.GetId();
			UserManager um = new UserManager();
			Map map = um.getAccountInfo(con, userid);
			request.setAttribute("accountInfo", map);
		} catch (Exception e) {
			JLog.getLogger().error("载入账号信息出错", e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("载入账号信息出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		} finally {
			if (con != null)
				con.close();
		}
		return mapping.findForward("acctountInfoSuccess");
	}

}
