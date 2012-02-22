package com.nfwl.itg.order;

import java.sql.Connection;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;


import com.gemway.util.JUtil;
import com.jado.JLog;
import com.jado.JadoException;

import com.nfwl.itg.user.ITG_ORDERREC;
import com.nfwl.itg.user.ITG_ORDERRECManager;
import com.nfwl.itg.user.ITG_PAY;
import com.nfwl.itg.user.ITG_PAYManager;
import com.nfwl.itg.common.Message;
import com.nfwl.itg.common.dbUtil;
import com.nfwl.itg.em.OrderStatusEnum;
import com.nfwl.itg.em.PayLogEnum;
import com.nfwl.itg.em.PayTypeEnum;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   PayAction 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-9-6 下午09:58:42
 * @Comment
 * 
 */

public class PayAction extends DispatchAction{

	public ActionForward pay(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		
		Connection con= null;
		try{
				nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
				if(user!=null){
					String or_id=JUtil.convertNull(request.getParameter("or_id"));
					if(or_id.equals("")){
						JLog.getLogger().info("没有订单可以支付");
						Message ms = new Message();
						ms.setFlag(false);
						ms.setError("没有订单可以支付!");
						request.setAttribute("message", ms);
						return mapping.findForward("orderFailed");
					}else{
						con = dbUtil.getNfwlCon();
						ITG_ORDERRECManager igom =new ITG_ORDERRECManager();
						ITG_ORDERREC igo = (ITG_ORDERREC) igom.get(con, or_id);
						if(igo!=null){
							if(igo.getOr_status()==OrderStatusEnum.CONFIRM.getCode()){
								ITG_PAYManager ipm = new ITG_PAYManager();
								ITG_PAY pay  = (ITG_PAY) ipm.getByOrder(con, or_id);
								if(pay!=null){
									if(pay.getPay_type().equals(PayTypeEnum.DEFAULT.getCode())){
										String s = ipm.defaultpay(con, user.getId(), or_id);
										request.setAttribute("msg", s+"[<a href='/user/order.do?cmd=search'>进入</a>]订单管理");
									}else{
										request.setAttribute("or_id", or_id);
										String url="/order/alipayto.jsp";
										return new ActionForward(url);
									}
								}else{
									JLog.getLogger().info("没有支付信息");
									Message ms = new Message();
									ms.setFlag(false);
									ms.setError("没有支付信息!");
									request.setAttribute("message", ms);
									return mapping.findForward("orderFailed");
								}
							}else{
								Message ms = new Message();
								ms.setFlag(false);
								ms.setError("只有已确认的订单可以支付!");
								request.setAttribute("message", ms);
								return mapping.findForward("orderFailed");
							}
							
						}else{
							JLog.getLogger().info("没有订单可以支付");
							Message ms = new Message();
							ms.setFlag(false);
							ms.setError("没有订单可以支付!");
							request.setAttribute("message", ms);
							return mapping.findForward("orderFailed");
						}
						
					}
				}else{
					 return mapping.findForward("nologing");
				}
		}catch(Exception e){
			JLog.getLogger().error("支付出错!",e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("支付出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("orderError");
		}
		finally
		{
			if (con!=null) con.close();	
		}
		return new ActionForward("/order/message.jsp");
	}
}

