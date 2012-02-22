package com.nfwl.itg.order;

import java.sql.Connection;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;



import com.jado.JLog;
import com.gemway.util.JUtil;
import com.jado.JadoException;
import com.jado.bean.Bean;
import com.nfwl.itg.common.Message;
import com.nfwl.itg.common.TokenManager;
import com.nfwl.itg.common.dbUtil;
import com.nfwl.itg.user.ITG_PAY;
import com.nfwl.itg.user.ITG_PAYManager;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   CarrymodeAction 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-8-7 下午10:33:47
 * @Comment
 * 
 */

public class PaymodeAction extends DispatchAction {

	public ActionForward init(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		
		Connection con= null;
		try{
			nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
			if(user!=null){
				String session_order=JUtil.convertNull((String)request.getSession().getAttribute("order"));
				con = dbUtil.getNfwlCon();
				boolean falg = OrderUtil.isNewAndSelfOrder(con, session_order, user.getId());
				if(falg){
					
					ITG_PAYManager ipm = new ITG_PAYManager();
					Bean b = ipm.getByOrder(con, session_order);
					if(b!=null){
						request.setAttribute("pay", b);
					}
					TokenManager.saveToken(request);
				}else{
					request.getSession().removeAttribute("order");
					return mapping.findForward("myorder");
				}
					
				
			}else{
				 return mapping.findForward("nologing");
			}
		}catch(Exception e){
			JLog.getLogger().error("初始化支付方式出错!",e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("初始化支付方式出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("orderError");
		}
		finally
		{
			if (con!=null) con.close();	
		}
		return mapping.findForward("initSuccess");
		
		
	}
	
	public ActionForward setPaymode(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		
		Connection con= null;
		try{
			if (TokenManager.isTokenValid(request, true)) {
				nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
				if(user!=null){
					
					String session_order=JUtil.convertNull((String)request.getSession().getAttribute("order"));
					con = dbUtil.getNfwlCon();
					boolean falg = OrderUtil.isNewAndSelfOrder(con, session_order, user.getId());
					if(falg){
						//扩展功能参数——默认支付方式
				        String pay_mode = JUtil.convertNull(request.getParameter("pay_bank"));
				        String paymethod = "";		//默认支付方式，四个值可选：bankPay(网银); cartoon(卡通); directPay(余额); CASH(网点支付)
				        String defaultbank = "";	//默认网银代号，代号列表见http://club.alipay.com/read.php?tid=8681379
				        if(pay_mode.equals("directPay")){
				        	paymethod = "directPay";
				        }else if(pay_mode.equals("default")){
				        	paymethod = "default";
				        }else{
				        	paymethod = "bankPay";
				        	defaultbank = pay_mode;
				        }
				        ITG_PAY ip = new ITG_PAY();
				        ip.setPay_id(JUtil.createUNID());
				        ip.setPay_orderid(session_order);
				        ip.setPay_type(paymethod);
				        ip.setDefaultbank(defaultbank);
				        ip.setPay_status(0);
				        
				        PayManager pm = new PayManager();
				        pm.changePay(con, ip);
					}else{
						request.getSession().removeAttribute("order");
						return mapping.findForward("myorder");
					}
					
				}else{
					request.getSession().removeAttribute("order");
					 return mapping.findForward("nologing");
				}
			}else{
				JLog.getLogger().info("非法的设置支付方式");
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("非法的设置支付方式!");
				request.setAttribute("message", ms);
				return mapping.findForward("orderFailed");
			}
			
		}catch(Exception e){
			JLog.getLogger().error("设置支付方式出错!",e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("设置支付方式出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("orderError");
		}
		finally
		{
			if (con!=null) con.close();	
		}
		
		return new ActionForward("/order/loadconfirmorder.do?cmd=view");
	}
	
}

