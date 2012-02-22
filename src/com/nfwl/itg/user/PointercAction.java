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
import com.jado.JadoException;
import com.nfwl.itg.common.ITG_HZ_ZONE;
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

public class PointercAction extends nfwlAction {

	


	public ActionForward search(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection con = null;
		pageList pl = this.getPageList(request);
		String to = JUtil.convertNull(request.getParameter("to"));
		try
		{
     		nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
     	
     		ITG_POINTRECManager isg = new ITG_POINTRECManager();
     		con = dbUtil.getNfwlCon();
     		
     		List list = isg.getByUser(con, user.getId(),pl.getStart(), pl.getPageSize());
     		pl.setList(list);
     		pl.setSize(isg.getByUserSize(con, user.getId()));
     		request.setAttribute("PAGELIST", pl);
     		
		}catch(Exception e){
			JLog.getLogger().error("查询积分信息时出错!",e);	
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("查询积分信息时出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		}
		finally
		{
			if (con!=null) con.close();	
		}
		if (to.equals("")){
			return mapping.findForward("searchSuccess");
		}else{
			return new ActionForward(to);
		}
	}
	
	private pageList getPageList(HttpServletRequest request){
		pageList  pl= new pageList();
		pl.setPageCur(1);
		pl.setPageSize(10);
		
		String pageCur =  JUtil.convertNull(request.getParameter("pageCur"));
		String pageSize = JUtil.convertNull(request.getParameter("pageSize"));
		
		if (!pageCur.equals("")){
			pl.setPageCur(Integer.parseInt(pageCur));
 		}
		if (!pageSize.equals("")){
			pl.setPageSize(Integer.parseInt(pageSize));
 		}
	
		return pl;
	}
	
	
}

