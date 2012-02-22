package com.nfwl.itg.user;

import java.sql.Connection;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.gemway.util.JUtil;
import com.jado.JLog;
import com.jado.bean.Bean;
import com.nfwl.itg.common.Message;
import com.nfwl.itg.common.dbUtil;
import com.nfwl.itg.common.pageList;
import com.nfwl.itg.em.OrderStatusEnum;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   UserAction 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-7-24 下午05:19:24
 * @Comment
 * 
 */

public class OrderAction extends nfwlAction {

	public ActionForward search(ActionMapping mapping, ActionForm form, HttpServletRequest request,
			HttpServletResponse response) throws Exception {
		Connection con = null;
		pageList pl = this.getPageList(request);
		String to = JUtil.convertNull(request.getParameter("to"));
		try {
			nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");

			ITG_ORDERRECManager iom = new ITG_ORDERRECManager();
			con = dbUtil.getNfwlCon();
			String state = "";
			if (pl.getParameter().get("state") != null) {
				state = pl.getParameter().get("state").toString();
			}
			List<Bean> list = iom.getByUser(con, user.getId(), state, pl.getStart(), pl.getPageSize());
			pl.setList(list);
			pl.setSize(iom.getByUserSize(con, user.getId(), state));

			request.setAttribute("PAGELIST", pl);

		} catch (Exception e) {
			JLog.getLogger().error("查询订单信息时出错!", e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("查询订单信息时出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		} finally {
			if (con != null)
				con.close();
		}
		if (to.equals("")) {
			return mapping.findForward("searchSuccess");
		} else {
			return new ActionForward(to);
		}
	}

	public ActionForward view(ActionMapping mapping, ActionForm form, HttpServletRequest request,
			HttpServletResponse response) throws Exception {
		Connection con = null;
		try {
			String order_id = JUtil.convertNull(request.getParameter("or_id"));

			con = dbUtil.getNfwlCon();
			ITG_ORDERDETAILManager ioe = new ITG_ORDERDETAILManager();
			List<Bean> ls = ioe.getByOrder(con, order_id);
			request.setAttribute("list", ls);

			ITG_ORDERRECManager iom = new ITG_ORDERRECManager();
			ITG_ORDERREC order = (ITG_ORDERREC) iom.get(con, order_id);

			if (order != null) {
				request.setAttribute("order", order);

				//地址信息
				ITG_ORDERRECDELIVERYManager iodm = new ITG_ORDERRECDELIVERYManager();
				ITG_ORDERRECDELIVERY iod = iodm.getByOrder(con, order_id);
				request.setAttribute("address", iod);

				UserManager um = new UserManager();
				User u = (User) um.get(con, order.getOr_userid());
				request.setAttribute("user", u);

			}

		} catch (Exception e) {
			JLog.getLogger().error("查看信息详细信息时出错!", e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("查看信息详细信息时出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		} finally {
			if (con != null)
				con.close();
		}
		return mapping.findForward("viewSuccess");
	}

	public ActionForward detail(ActionMapping mapping, ActionForm form, HttpServletRequest request,
			HttpServletResponse response) throws Exception {
		Connection con = null;
		try {
			String order_id = JUtil.convertNull(request.getParameter("or_id"));

			con = nps.core.Database.GetDatabase("nfwl").GetConnection();
			ITG_ORDERDETAILManager ioe = new ITG_ORDERDETAILManager();
			List<Bean> ls = ioe.getByOrder(con, order_id);

			request.setAttribute("list", ls);

		} catch (Exception e) {
			JLog.getLogger().error("查看订单明细时出错!", e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("查看订单明细时出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		} finally {
			if (con != null)
				con.close();
		}

		return mapping.findForward("detailSuccess");
	}

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

		String state = JUtil.convertNull(request.getParameter("state"));
		if (!state.equals("")) {
			pl.addParameter("state", Integer.valueOf(state));
		}
		pl.addParameter("status", OrderStatusEnum.gets());

		return pl;
	}

}
