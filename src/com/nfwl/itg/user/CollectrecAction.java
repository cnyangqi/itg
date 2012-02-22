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

import com.nfwl.itg.common.Message;
import com.nfwl.itg.common.dbUtil;
import com.nfwl.itg.common.pageList;






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

public class CollectrecAction extends nfwlAction {

	
	
	public ActionForward add(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection con = null;
		String to_url = JUtil.convertNull(request.getParameter("to_url"));
		try
		{
     		nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
     		
     		con = dbUtil.getNfwlCon();

     		ITG_COLLECTREC ic = new ITG_COLLECTREC();
     		String prd_id = JUtil.convertNull(request.getParameter("prd_id"));
     		ic.setCol_artid(prd_id);
     		ic.setCol_userid(user.getId());
     		
     		ITG_COLLECTRECManager icm = new ITG_COLLECTRECManager();
     		icm.insert(con, ic);
    			
		}catch(Exception e){
			JLog.getLogger().error("增加收藏时出错!",e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("增加收藏时出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		}
		finally
		{
			if (con!=null) con.close();	
		}
		return new ActionForward(to_url);
	}


	public ActionForward search(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection con = null;
		pageList pl = this.getPageList(request);
		String to = JUtil.convertNull(request.getParameter("to"));
		try
		{
     		nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
     		
     		ITG_COLLECTRECManager icm = new ITG_COLLECTRECManager();
     		con = dbUtil.getNfwlCon();
     		
     		List list = icm.getByUser(con, user.getId(), pl.getStart(), pl.getPageSize());
     		pl.setList(list);
     		pl.setSize(icm.getByUserSize(con, user.getId()));
     		request.setAttribute("PAGELIST", pl);
    			
		}catch(Exception e){
			JLog.getLogger().error("查询收藏信息时出错!",e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("查询收藏信息时出错!");
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
	public ActionForward delete(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection con = null;
		try
		{
			nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
     		if(user!=null){
     			ITG_COLLECTRECManager icm = new ITG_COLLECTRECManager();
         		con = dbUtil.getNfwlCon();

         		String id = JUtil.convertNull(request.getParameter("id"));
         		user.getId();
         		if(!id.equals("")) icm.delete(con, id,user.getId());
     		}else{
     			
     		}
     			
		}catch(Exception e){
			JLog.getLogger().error("查询收藏信息时出错!",e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("删除收藏时出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		}
		finally
		{
			if (con!=null) con.close();	
		}
		String cur_page = JUtil.convertNull(request.getParameter("cur_page"));
		if(cur_page.equals("")) cur_page="1";
		return new ActionForward("/user/collectrec.do?cmd=search&cur_page="+cur_page);
	}
	
	private pageList getPageList(HttpServletRequest request){
		pageList  pl= new pageList();
		pl.setPageCur(1);
		pl.setPageSize(5);
		
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

