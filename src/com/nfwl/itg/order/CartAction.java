package com.nfwl.itg.order;

import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;

import com.gemway.partner.JUtil;
import com.jado.JLog;
import com.nfwl.itg.common.ArtileUtil;
import com.nfwl.itg.common.Message;
import com.nfwl.itg.common.TokenManager;
import com.nfwl.itg.common.dbUtil;
import com.nfwl.itg.em.OrderStatusEnum;
import com.nfwl.itg.user.ITG_ORDERREC;
import com.nfwl.itg.user.ITG_ORDERRECManager;


/**
 * 
 * @Project：ithinkgo   
 * @Type：   CartAction 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-8-2 下午08:16:50
 * @Comment
 * 
 */

public class CartAction extends DispatchAction {

	/*
	 * 显示购物车
	 * 当session有order的时候去订单明细表里查(如果session中有order的时候说明用户一定是登陆的，因为用户在确认地址时会生成订单，并把相应订单号存在session中)
	 * 当用户登陆的时候去数据库查找
	 * 当用户没有登陆的时候在cookie中查找
	 * 转向/order/cartlist.jsp
	 * 
	 */
	public ActionForward view(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		
		Connection con = null;
		try
		{
			nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
			if(user!=null){
				String session_order=JUtil.convertNull((String)request.getSession().getAttribute("order"));
				
				if(session_order.equals("")){
					con = dbUtil.getNfwlCon();
					CartManager cm = new CartManager();
					List<Cart> ls = cm.getUserCarts(con, user.getId(), session_order);
					if(ls!=null) request.setAttribute("beans", ls);
				}else{
					con = dbUtil.getNfwlCon();
					boolean falg = OrderUtil.isNewAndSelfOrder(con, session_order, user.getId());
					if(falg){
						CartManager cm = new CartManager();
						List<Cart> ls = cm.getUserCarts(con, user.getId(), session_order);
						if(ls!=null) request.setAttribute("beans", ls);
					}else{
						request.getSession().removeAttribute("order");
						return mapping.findForward("myorder");
					}
				}
			}else{
				List<Cart> ls =CartUtil.getCartByCookie(request);
				if(ls!=null) request.setAttribute("beans", ls);
			}
			TokenManager.saveToken(request);
			
		}catch(Exception e){
			JLog.getLogger().error("读取购物车里数据出错!",e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("读取购物车里数据出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("orderError");
		}
		finally
		{
			if (con!=null) con.close();	
		}

		return mapping.findForward("viewSuccess"); 
	}
	
	/*
	 *添加产品到购物车
	 *当用户登陆的时候存到数据库
	 *没有登陆的时候添加到cooke中
	 *
	 * 
	 */
	public ActionForward add(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		
		Connection con = null;
		try
		{
				//TokenManager.isTokenValid(request, true);
			//if (TokenManager.isTokenValid(request, true)) {
				nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
				String prd_id = JUtil.convertNull(request.getParameter("prd_id"));
				String num = JUtil.convertNull(request.getParameter("num"));
				if(num.equals("")) num="1";
				if(user!=null){
					String session_order=JUtil.convertNull((String)request.getSession().getAttribute("order"));
					con = dbUtil.getNfwlCon();
					
					if(session_order.equals("")){
						CartManager cm = new CartManager();
						List<Cart> ls = cm.add(con, user.getId(), session_order, prd_id,num);
						if(ls!=null) request.setAttribute("beans", ls);
					}else{
						boolean falg = OrderUtil.isNewAndSelfOrder(con, session_order, user.getId());
						if(!session_order.equals("")||falg){
							CartManager cm = new CartManager();
							List<Cart> ls = cm.add(con, user.getId(), session_order, prd_id,num);
							if(ls!=null) request.setAttribute("beans", ls);
						}else{
							request.getSession().removeAttribute("order");
							return mapping.findForward("myorder");
						}
						
					}
				}else{
					
					List<Cart> ls =CartUtil.getCartByCookie(request);
					if(ls==null) ls = new ArrayList<Cart>();
					if(!prd_id.equals("")){
						con = nps.core.Database.GetDatabase("nfwl").GetConnection();
						Map map = ArtileUtil.getByCart(con, prd_id);
						if(map!=null){
							Cart c = CartUtil.ArtmapToCart(map);
							c.setId(JUtil.createUNID());
							if(!num.equals("")){
								try{
									c.setAmount(Double.valueOf(num));
								}catch (Exception e) {
									c.setAmount(1D);
								}
							}
							
							if(c!=null)ls.add(c);
							CartUtil.setCookieCart(response, ls);
							
						}
						
					}
					request.setAttribute("beans", ls);
					
				}
				TokenManager.saveToken(request);
		}catch(Exception e){
			JLog.getLogger().error("添加产品到购物车时出错!",e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("添加产品到购物车时出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("orderError");
		}
		finally
		{
			if (con!=null) con.close();	
		}

		return mapping.findForward("addSuccess"); 
	}
	/*
	 * 删除购物车的产品
	 * 当用户登陆的时候从数据库中删除
	 * 当用户没有登陆的时候添加数据库cooke中
	 */
	public ActionForward del(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		
		Connection con = null;
		//String id = JUtil.convertNull(request.getParameter("cart_id"));
		String[] cart_ids = request.getParameterValues("cart_id");
		try
		{
			if (TokenManager.isTokenValid(request, true)) {
				nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
				if(user!=null){
					String session_order=JUtil.convertNull((String)request.getSession().getAttribute("order"));
					con = dbUtil.getNfwlCon();
					
					if(session_order.equals("")){
						CartManager cm = new CartManager();
						List<Cart> ls = cm.del(con, user.getId(), session_order, cart_ids);
						if(ls!=null) request.setAttribute("beans", ls);
					}else{
						boolean falg = OrderUtil.isNewAndSelfOrder(con, session_order, user.getId());
						if(!session_order.equals("")||falg){
							CartManager cm = new CartManager();
							List<Cart> ls = cm.del(con, user.getId(), session_order, cart_ids);
							if(ls!=null) request.setAttribute("beans", ls);
						}else{
							request.getSession().removeAttribute("order");
							return mapping.findForward("myorder");
						}
						
					}
					
				}else{
					List<Cart> ls =CartUtil.getCartByCookie(request);
					if(ls==null) ls = new ArrayList<Cart>();
					if(cart_ids!=null&&cart_ids.length>0){
							List<Cart> _ls = CartUtil.delCartByid(ls,cart_ids);
							CartUtil.setCookieCart(response, _ls);
							if(_ls!=null) request.setAttribute("beans", _ls);
					}else{
						request.setAttribute("beans", ls);
					}
				}
				TokenManager.saveToken(request);
			}else{
				JLog.getLogger().error("非法的在购物车删除产品!");
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("非法的在购物车删除产品!");
				request.setAttribute("message", ms);
				return mapping.findForward("orderFailed");
			}
		}catch(Exception e){
			JLog.getLogger().error("删除购物车里的数据出错!",e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("删除购物车里的数据出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("orderError");
		}
		finally
		{
			if (con!=null) con.close();	
		}

		return mapping.findForward("delSuccess"); 
	}
	public ActionForward balance(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		Connection con = null;	
		String[] amount = request.getParameterValues("amount");
		String[] cartids = request.getParameterValues("cartid");
		String islogin = JUtil.convertNull(request.getParameter("islogin"));
		try
		{
			if (TokenManager.isTokenValid(request, true)) {
				nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
				if(user!=null){
					String session_order=JUtil.convertNull((String)request.getSession().getAttribute("order"));
					con = dbUtil.getNfwlCon();
					if(session_order.equals("")){
						CartManager cm = new CartManager();
						if(islogin.equals("true")){
							if(session_order.equals("")){
								cm.updateCarterc(con, cartids, amount);
							}else{
								cm.updateOrder(con, cartids, amount,session_order);
								
							}
						}else{
							List<Cart> ls =CartUtil.getCartByCookie(request);
							cm.addCartec(con, user.getId(), ls, cartids, amount);
						}
						CartUtil.clearCookieCart(response);
					}else{
						boolean falg = OrderUtil.isNewAndSelfOrder(con, session_order, user.getId());
						if(falg){
							CartManager cm = new CartManager();
							if(islogin.equals("true")){
								if(session_order.equals("")){
									cm.updateCarterc(con, cartids, amount);
								}else{
									cm.updateOrder(con, cartids, amount,session_order);
									
								}
							}else{
								List<Cart> ls =CartUtil.getCartByCookie(request);
								cm.addCartec(con, user.getId(), ls, cartids, amount);
							}
							CartUtil.clearCookieCart(response);
						}else{
							request.getSession().removeAttribute("order");
							return mapping.findForward("myorder");
						}
					}
					
				}else{
					 return mapping.findForward("nologing");
				}
			}else{
				JLog.getLogger().error("非法的在购物车结算!");
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("非法的在购物车结算!");
				request.setAttribute("message", ms);
				return mapping.findForward("orderFailed");
			}
		}catch(Exception e){
			JLog.getLogger().error("结算购物车出错!",e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("结算购物车出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("orderError");
		}
		finally
		{
			if (con!=null) con.close();	
		}
		return new ActionForward("/user/loadaddress.do?cmd=orderAddress");
	}
	
	
	
}

