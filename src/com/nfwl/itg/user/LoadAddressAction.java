package com.nfwl.itg.user;

import java.sql.Connection;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.jado.JLog;
import com.gemway.util.JUtil;
import com.jado.bean.Bean;
import com.nfwl.itg.common.Message;
import com.nfwl.itg.common.TokenManager;
import com.nfwl.itg.common.dbUtil;


/**
 * 
 * @Project：ithinkgo   
 * @Type：   LoadAddressAction 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-8-14 下午01:24:33
 * @Comment
 * 
 */

public class LoadAddressAction extends nfwlAction {

	public ActionForward orderAddress(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection con = null;
		try
		{
			String session_order=JUtil.convertNull((String)request.getSession().getAttribute("order"));
			if(!session_order.equals("")){
				con = dbUtil.getNfwlCon();
				//地址信息
				ITG_ORDERRECDELIVERYManager iodm = new ITG_ORDERRECDELIVERYManager();
				ITG_ORDERRECDELIVERY iod = iodm.getByOrder(con, session_order);
				request.setAttribute("address", iod);
			}
     		TokenManager.saveToken(request);	
		}catch(Exception e){
			JLog.getLogger().error("订单地址初始化时出错!",e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("订单地址初始化时出错!!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		}
		finally
		{
			if (con!=null) con.close();	
		}
		return mapping.findForward("orderAddressSuccess");
	}
	
	public ActionForward view(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection con = null;
		try
		{
     		ITG_ADDRESSManager iam = new ITG_ADDRESSManager();
     		con = dbUtil.getNfwlCon();
     		String id = JUtil.convertNull(request.getParameter("id"));
     		if(!id.equals("")){
     			Bean b = iam.get(con, id);
	     		request.setAttribute("addressForm", b);
	     		
     		}
     		TokenManager.saveToken(request);	
		}catch(Exception e){
			JLog.getLogger().error("显示地址时出错!",e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("删除地址时出错!!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		}
		finally
		{
			if (con!=null) con.close();	
		}
		return mapping.findForward("viewSuccess");
	}
	public ActionForward delete(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection con = null;
		try
		{
			nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
			if (TokenManager.isTokenValid(request, true)) { 
				ITG_ADDRESSManager iam = new ITG_ADDRESSManager();
	     		con = dbUtil.getNfwlCon();
	
	     		String id = JUtil.convertNull(request.getParameter("id"));
	     		if(!id.equals("")) iam.delete(con, id,user.getId());
	     		
	     		Message ms = new Message();
				ms.setFlag(true);
				ms.setMsg("删除地址成功!");
				request.setAttribute("message", ms);
				
	     		TokenManager.saveToken(request);
			}else{
				JLog.getLogger().info("非法的删除地址");
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("非法的删除地址!");
				request.setAttribute("message", ms);
				return mapping.findForward("userFailed");
			}
		}catch(Exception e){
			JLog.getLogger().error("删除地址时出错!",e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("删除地址时出错!!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		}
		finally
		{
			if (con!=null) con.close();	
		}
		return mapping.findForward("deleteSuccess");
	}
	public ActionForward setdefault(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection con = null;
		
		try
		{
			if (TokenManager.isTokenValid(request, true)) { 
				nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
	     		
	     		ITG_ADDRESSManager iam = new ITG_ADDRESSManager();
	     		con =  dbUtil.getNfwlCon();

	     		String id = JUtil.convertNull(request.getParameter("id"));
	     		if(!id.equals("")){
	     			boolean flag = iam.setDefault(con, id, user.getId());
	     			if(flag){
	     				Message ms = new Message();
	    				ms.setFlag(true);
	    				ms.setMsg("设置默认地址成功!");
	    				request.setAttribute("message", ms);
	    				
	    				user.setAdrid(id);
	    				request.getSession().setAttribute("user",user);
	     			}else{
	     				Message ms = new Message();
	    				ms.setFlag(false);
	    				ms.setError("设置默认地址出错!");
	    				request.setAttribute("message", ms);

	     			}
	     		}else{
	     			Message ms = new Message();
    				ms.setFlag(false);
    				ms.setMsg("找不到相应的地址可以设置默认地址!");
    				request.setAttribute("message", ms);
	     		}
	     	
	     						
	     		TokenManager.saveToken(request);
			}else{
				JLog.getLogger().info("非法的设置默认地址");
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("非法的设置默认地址!");
				request.setAttribute("message", ms);
				return mapping.findForward("userFailed");
			}
	     		
		}catch(Exception e){
			JLog.getLogger().error("设置默认地址时出错!",e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("设置默认地址时出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		}
		finally
		{
			if (con!=null) con.close();	
		}
		return mapping.findForward("setdefaultSuccess");
	}
}

