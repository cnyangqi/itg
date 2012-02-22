package com.nfwl.itg.user;

import java.sql.Connection;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import nps.core.Database;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.gemway.util.JUtil;
import com.jado.JLog;
import com.jado.bean.Bean;
import com.nfwl.itg.common.Message;
import com.nfwl.itg.common.TokenManager;
import com.nfwl.itg.common.dbUtil;
import com.nfwl.itg.common.pageList;

/**
 * 定点单位用户Action
 * 
 * @author yangq(qi.yang.cn@gmail.com)
 */
public class FixedpointAction extends nfwlAction {

	/** 定点单位用户查询 */
	public ActionForward search(ActionMapping mapping,
								ActionForm form,
								HttpServletRequest request,
								HttpServletResponse response) throws Exception {
		Connection con = null;
		pageList pl = this.getPageList(request);
		String to = JUtil.convertNull(request.getParameter("to"));
		try {
			nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");

			con = Database.GetDatabase("nps").GetConnection();
			UserManager um = new UserManager();
			List<Bean> list = um.getUserByFixedpoint(	con,
														user.getItg_fixedpoint(),
														pl.getStart(),
														pl.getPageSize());

			pl.setList(list);
			pl.setSize(um.getUserByFixedpointSize(con, user.getItg_fixedpoint()));
			request.setAttribute("PAGELIST", pl);

		}
		catch (Exception e) {
			JLog.getLogger().error("查询定点用户时出错!", e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("查询定点用户时出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		}
		finally {
			if (con != null)
				con.close();
		}
		if (to.equals("")) {
			return mapping.findForward("searchSuccess");
		} else {
			return new ActionForward(to);
		}
	}

	/** 定点单位用户新增 */
	public ActionForward insert(ActionMapping mapping,
								ActionForm form,
								HttpServletRequest request,
								HttpServletResponse response) throws Exception {

		if (isFixedpointManage(request)) {
			UserForm userform = (UserForm) form;
			UserManager um = new UserManager();
			User user = um.formTObean(userform);

			nps.core.User temp = (nps.core.User) request.getSession().getAttribute("user");
			user.setItg_fixedpoint(temp.getItg_fixedpoint());
			user.setUtype(2);

			Connection conn = Database.GetDatabase("nps").GetConnection();
			um.insert(conn, user);
			conn.close();
		}

		return new ActionForward("/user/fixedpoint.do?cmd=search");
	}

	/** 定点单位用户删除 */
	public ActionForward delete(ActionMapping mapping,
								ActionForm form,
								HttpServletRequest request,
								HttpServletResponse response) throws Exception {

		if (isFixedpointManage(request)) {
			String id = request.getParameter("id");
			UserManager um = new UserManager();
			Connection conn = Database.GetDatabase("nps").GetConnection();
			um.deleteFixedpointUser(conn, id);
			conn.close();
		}

		return new ActionForward("/user/fixedpoint.do?cmd=search");
	}

	/** 定点单位用户编辑 */
	public ActionForward edit(	ActionMapping mapping,
								ActionForm form,
								HttpServletRequest request,
								HttpServletResponse response) throws Exception {
		String id = request.getParameter("id");

		Connection con = null;
		try {
			con = dbUtil.getNfwlCon();
			UserManager um = new UserManager();
			User u = (User) um.get(con, id);
			TokenManager.saveToken(request);
			UserForm uf = um.beanTOform(u);
			request.setAttribute("userForm", uf);
		}
		catch (Exception e) {
			return mapping.findForward("userError");
		}
		finally {
			if (con != null)
				con.close();
		}

		return mapping.findForward("editSuccess");
	}

	/** 定点单位用户保存修改 */
	public ActionForward save(	ActionMapping mapping,
								ActionForm form,
								HttpServletRequest request,
								HttpServletResponse response) throws Exception {

		Connection con = null;
		UserForm userform = (UserForm) form;
		// 更新信息
		UserManager um = new UserManager();
		User user = um.formTObean(userform);
		con = dbUtil.getNfwlCon();
		um.update(con, user);

		Message ms = new Message();
		ms.setFlag(true);
		ms.setMsg("修改用户信息成功!");
		request.setAttribute("message", ms);
		request.setAttribute("userForm", userform);

		return new ActionForward("/user/fixedpoint.do?cmd=search");
	}

	/** 分页对象 */
	private pageList getPageList(HttpServletRequest request) {
		pageList pl = new pageList();
		pl.setPageCur(1);
		pl.setPageSize(10);

		String pageCur = JUtil.convertNull(request.getParameter("pageCur"));
		String pageSize = JUtil.convertNull(request.getParameter("pageSize"));

		if (!pageCur.equals("")) {
			pl.setPageCur(Integer.parseInt(pageCur));
		}
		if (!pageSize.equals("")) {
			pl.setPageSize(Integer.parseInt(pageSize));
		}

		return pl;
	}

	/** 验证操作用户是否为定点单位管理员 */
	private boolean isFixedpointManage(HttpServletRequest request) {
		nps.core.User temp = (nps.core.User) request.getSession().getAttribute("user");
		return (temp.getType() == 6);
	}

}
