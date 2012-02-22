package com.nfwl.itg.user;

import java.sql.Connection;

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

public class OrderEvalAction extends nfwlAction {

	public ActionForward orderEvalInit(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection con = null;
		try
		{
			String od_id = JUtil.convertNull(request.getParameter("od_id"));
			
			con = dbUtil.getNfwlCon();
			ITG_ORDERDETAILManager ioe = new ITG_ORDERDETAILManager();
			ITG_ORDERDETAIL b = ioe.get(con, od_id);
			
			ITG_MESSAGEEVALManager ime  = new ITG_MESSAGEEVALManager();
			boolean flag = ime.isEvel(con, od_id);
			if(flag){
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("不能对已经评价过的商品评价!");
				request.setAttribute("message", ms);
				return mapping.findForward("orderEvalInitFailed");
			}
			request.setAttribute("bean", b);
			
		}catch(Exception e){
			JLog.getLogger().error("初始化订单评论时出错!",e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("初始化订单评论时出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		}
		finally
		{
			if (con!=null) con.close();	
		}
		
		return mapping.findForward("orderEvalInitSuccess");
	}
	public ActionForward orderEval(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection con = null;
		try
		{
			
			String me_desclevel = JUtil.convertNull(request.getParameter("me_desclevel"));
			String me_attitudelevel = JUtil.convertNull(request.getParameter("me_attitudelevel"));
			String me_speedlevel = JUtil.convertNull(request.getParameter("me_speedlevel"));
			String me_deliverylevel = JUtil.convertNull(request.getParameter("me_deliverylevel"));
			String me_level = JUtil.convertNull(request.getParameter("me_level"));
			String me_content = JUtil.convertNull(request.getParameter("me_content"));
			String me_odid = JUtil.convertNull(request.getParameter("me_odid"));
			String me_orid = JUtil.convertNull(request.getParameter("me_orid"));
			con = dbUtil.getNfwlCon();
			
			ITG_ORDERRECManager ioe = new ITG_ORDERRECManager();
			ITG_ORDERREC io = (ITG_ORDERREC) ioe.get(con, me_orid);
			if(OrderStatusEnum.FINISH.getCode()==io.getOr_status()){
				nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
				if(user.getId().equals(io.getOr_userid())){
					
					ITG_MESSAGEEVALManager ime  = new ITG_MESSAGEEVALManager();
					
					boolean flag = ime.isEvel(con, me_odid);
					if(flag){
						Message ms = new Message();
						ms.setFlag(false);
						ms.setError("不能对已经评价过的商品评价!");
						request.setAttribute("message", ms);
						return mapping.findForward("orderEvalFailed");
					}else{
						ITG_MESSAGEEVAL im  = new ITG_MESSAGEEVAL();
						im.setMe_id(JUtil.createUNID());
						im.setMe_userid(user.getId());
						im.setMe_odid(me_odid);
						im.setMe_type(2);
						im.setMe_desclevel(Integer.parseInt(me_desclevel));
						im.setMe_attitudelevel(Integer.parseInt(me_attitudelevel));
						im.setMe_speedlevel(Integer.parseInt(me_speedlevel));
						im.setMe_deliverylevel(Integer.parseInt(me_deliverylevel));
						im.setMe_level(Integer.parseInt(me_level));
						im.setMe_content(me_content);
						
						
						ime.insert(con, im);
					}
					Message ms = new Message();
					ms.setFlag(true);
					ms.setMsg("感谢你的评价!");
					request.setAttribute("message", ms);
				}else{
					Message ms = new Message();
					ms.setFlag(false);
					ms.setError("你不能评价相应的订单信息!");
					request.setAttribute("message", ms);
					return mapping.findForward("orderEvalFailed");
				}
				
			}else{
				Message ms = new Message();
				ms.setFlag(true);
				ms.setMsg("只能对已完成配送的商品评价!");
				request.setAttribute("message", ms);
			}
			
		}catch(Exception e){
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("订单评论时出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		}
		finally
		{
			if (con!=null) con.close();	
		}
		return mapping.findForward("orderEvalSuccess");
	}
	
}

