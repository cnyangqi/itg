package com.nfwl.itg.user;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;

import com.nfwl.itg.common.TokenManager;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   LoadAction 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-11-19 下午04:08:07
 * @Comment
 * 
 */

public class LoadAction extends DispatchAction {

	
	public ActionForward czkrecharge(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		
		TokenManager.saveToken(request); 
		
		return mapping.findForward("czkrechargeSuccess");
		
	}
	
	public ActionForward recharge(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		
		TokenManager.saveToken(request); 
		
		return mapping.findForward("rechargeSuccess");
		
	}
	public ActionForward changepassword(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception { 
		TokenManager.saveToken(request);
		return mapping.findForward("changepasswordSuccess");
	}
}

