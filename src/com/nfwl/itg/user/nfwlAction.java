package com.nfwl.itg.user;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   nfwlAction 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-7-25 下午09:52:14
 * @Comment
 * 
 */

public class nfwlAction extends DispatchAction {

	@Override
	public ActionForward execute(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
		if(user == null)
		  {
			   //throw new nps.exception.NpsException(nps.exception.ErrorHelper.ACCESS_NOTLOGIN);
			   return mapping.findForward("nologing");
		  }
		return super.execute(mapping, form, request, response);
	}
}

