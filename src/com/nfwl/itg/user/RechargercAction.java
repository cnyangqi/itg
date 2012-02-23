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
import com.nfwl.itg.common.TokenManager;
import com.nfwl.itg.common.dbUtil;
import com.nfwl.itg.common.pageList;

/**
 * 充值卡管理Action
 * 
 * @author yangq(qi.yang.cn@gmail.com) 2012-2-23
 */
public class RechargercAction extends nfwlAction {

	public ActionForward recharge(	ActionMapping mapping,
									ActionForm form,
									HttpServletRequest request,
									HttpServletResponse response) throws Exception {
		Connection con = null;
		try {
			if (TokenManager.isTokenValid(request, false)) {
				con = dbUtil.getNfwlCon();
				nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");

				String rechargetype = JUtil.convertNull(request.getParameter("rechargetype"));
				String total_fee = JUtil.convertNull(request.getParameter("total_fee"));
				if (rechargetype.equals("zfb")) {
					ITG_RECHARGERECManager rm = new ITG_RECHARGERECManager();
					ITG_RECHARGEREC ir = rm.alipayRecharge(con, user.getId());
					ir.setRcr_money(Double.valueOf(total_fee));
					request.setAttribute("recharge", ir);
					return mapping.findForward("alipayRechargeSuccess");
				} else {
					Message ms = new Message();
					ms.setFlag(false);
					ms.setError("暂时只支持支付宝充值!");
					request.setAttribute("message", ms);
					return mapping.findForward("onlyalipay");
				}

			} else {
				JLog.getLogger().info("非法的充值!");
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("非法的充值!");
				request.setAttribute("message", ms);
				return mapping.findForward("userFailed");
			}
		}
		catch (Exception e) {
			JLog.getLogger().error("充值出错", e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("充值出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		}
		finally {
			if (con != null)
				con.close();
		}

	}

	/** 充值卡充值 */
	public ActionForward czkRecharge(	ActionMapping mapping,
										ActionForm form,
										HttpServletRequest request,
										HttpServletResponse response) throws Exception {
		Connection con = null;

		try {
			if (TokenManager.isTokenValid(request, true)) {
				nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
				ITG_SAVECARDManager ism = new ITG_SAVECARDManager();
				con = dbUtil.getNfwlCon();
				String cardno = JUtil.convertNull(request.getParameter("cardno"));
				String cardpwd = JUtil.convertNull(request.getParameter("cardpwd"));
				String msg = ism.recharge(con, user.getId(), cardno, cardpwd);

				Message ms = new Message();
				ms.setFlag(true);
				ms.setMsg(msg);
				request.setAttribute("message", ms);
			} else {
				JLog.getLogger().info("非法的冲值");
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("非法的充值!");
				request.setAttribute("message", ms);
				return mapping.findForward("userFailed");
			}

			TokenManager.saveToken(request);
		}
		catch (Exception e) {
			JLog.getLogger().error("充值出错", e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("充值出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		}
		finally {
			if (con != null)
				con.close();
		}

		return mapping.findForward("czkRechargeSuccess");

	}

	public ActionForward search(ActionMapping mapping,
								ActionForm form,
								HttpServletRequest request,
								HttpServletResponse response) throws Exception {
		Connection con = null;
		pageList pl = this.getPageList(request);
		String to = JUtil.convertNull(request.getParameter("to"));
		try {

			nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");

			ITG_RECHARGERECManager irm = new ITG_RECHARGERECManager();
			con = dbUtil.getNfwlCon();

			List<Bean> list = irm.getByUser(con, user.getId(), pl.getStart(), pl.getPageSize());
			pl.setList(list);
			pl.setSize(irm.getByUserSize(con, user.getId()));
			request.setAttribute("PAGELIST", pl);

		}
		catch (Exception e) {
			JLog.getLogger().error("查看冲值记录信息时出错", e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("查看冲值记录信息时出错!");
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

}
