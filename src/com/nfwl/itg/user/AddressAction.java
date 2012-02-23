package com.nfwl.itg.user;

import java.sql.Connection;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.gemway.util.JUtil;
import com.jado.JLog;
import com.jado.Enum.FieldTypeEnum;
import com.jado.Enum.TermEnum;
import com.jado.bean.TermBean;
import com.nfwl.itg.common.Message;
import com.nfwl.itg.common.TokenManager;
import com.nfwl.itg.common.dbUtil;

/**
 * 用户收货地址Action
 * 
 * @author yangq(qi.yang.cn@gmail.com) 2012-2-23
 */

public class AddressAction extends nfwlAction {

	public ActionForward insert(ActionMapping mapping,
								ActionForm form,
								HttpServletRequest request,
								HttpServletResponse response) throws Exception {
		Connection con = null;
		try {
			if (TokenManager.isTokenValid(request, true)) {
				nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
				ITG_ADDRESSManager iam = new ITG_ADDRESSManager();
				con = dbUtil.getNfwlCon();
				if (iam.getByUserSize(con, user.getId()) >= 5) {
					request.setAttribute("msg", "最多只能有5个地址，请先删除一条数据");
					TokenManager.saveToken(request);
					return mapping.findForward("insertFailed");
				}
				ITG_ADDRESSForm idform = (ITG_ADDRESSForm) form;
				ITG_ADDRESS id = iam.formTObean(idform);
				id.setAdr_id(JUtil.createUNID());
				id.setAdr_userid(user.getId());
				id.setAdr_fpid("");// 定点单位ID号
				iam.insert(con, id, user.getType());

				Message ms = new Message();
				ms.setFlag(true);
				ms.setMsg("增加地址成功!");
				request.setAttribute("message", ms);

				request.setAttribute("addressForm", null);
				TokenManager.saveToken(request);
			} else {
				JLog.getLogger().info("非法的增加地址");
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("非法的增加地址!");
				request.setAttribute("message", ms);
				return mapping.findForward("userFailed");
			}

		}
		catch (Exception e) {
			JLog.getLogger().error("新增地址出错!", e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("新增地址出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		}
		finally {
			if (con != null)
				con.close();
		}

		return mapping.findForward("insertSuccess");

	}

	public ActionForward modify(ActionMapping mapping,
								ActionForm form,
								HttpServletRequest request,
								HttpServletResponse response) throws Exception {
		Connection con = null;
		try {
			if (TokenManager.isTokenValid(request, true)) {
				nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
				ITG_ADDRESSManager iam = new ITG_ADDRESSManager();
				con = dbUtil.getNfwlCon();

				ITG_ADDRESSForm idform = (ITG_ADDRESSForm) form;
				ITG_ADDRESS id = iam.formTObean(idform);
				id.addTerm(new TermBean("adr_userid",
										user.getId(),
										FieldTypeEnum.STRING,
										TermEnum.EQUAL));
				boolean flag = iam.modfiy(con, id);
				if (flag) {
					Message ms = new Message();
					ms.setFlag(true);
					ms.setMsg("修改地址成功!");
					request.setAttribute("message", ms);

				} else {
					Message ms = new Message();
					ms.setFlag(true);
					ms.setMsg("修改地址出错!");
					request.setAttribute("message", ms);

				}

				request.setAttribute("addressForm", null);
				TokenManager.saveToken(request);
			} else {
				JLog.getLogger().info("非法的修改地址");
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("非法的修改地址!");
				request.setAttribute("message", ms);
				return mapping.findForward("userFailed");
			}

		}
		catch (Exception e) {
			JLog.getLogger().error("修改地址时出错!", e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("修改地址时出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		}
		finally {
			if (con != null)
				con.close();
		}
		return mapping.findForward("modifySuccess");
	}
}
