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
import com.jado.bean.Bean;
import com.nfwl.itg.common.Message;
import com.nfwl.itg.common.TokenManager;
import com.nfwl.itg.common.dbUtil;
import com.nfwl.itg.em.OrderStatusEnum;
import com.nfwl.itg.em.PayTypeEnum;
import com.nfwl.itg.order.AddressManager;
import com.nfwl.itg.order.OrderUtil;
import com.nfwl.itg.order.PayManager;

/**
 * 订单修改Action
 * 
 * @author yangq(qi.yang.cn@gmail.com) 2012-3-12
 */

public class OrderModifyAction extends nfwlAction {

	public ActionForward view(	ActionMapping mapping,
								ActionForm form,
								HttpServletRequest request,
								HttpServletResponse response) throws Exception {
		Connection con = null;
		try {
			nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
			if (user != null) {
				String order_id = JUtil.convertNull(request.getParameter("or_id"));

				con = dbUtil.getNfwlCon();
				ITG_ORDERRECManager igom = new ITG_ORDERRECManager();
				ITG_ORDERREC igo = (ITG_ORDERREC) igom.get(con, order_id);
				if (igo != null) {
					if (user.getId().equals(igo.getOr_userid())) {
						request.setAttribute("orderrec", igo);
						// 列表信息
						ITG_ORDERDETAILManager ioem = new ITG_ORDERDETAILManager();
						List detail = ioem.getByOrder(con, order_id);
						request.setAttribute("list", detail);

						// 地址信息
						ITG_ORDERRECDELIVERYManager iodm = new ITG_ORDERRECDELIVERYManager();
						ITG_ORDERRECDELIVERY iod = iodm.getByOrder(con, order_id);
						request.setAttribute("address", iod);

						// 支付信息
						ITG_PAYManager ipm = new ITG_PAYManager();
						Bean b = ipm.getByOrder(con, order_id);
						if (b != null) {
							request.setAttribute("pay", b);
						}

						TokenManager.saveToken(request);
					} else {
						Message ms = new Message();
						ms.setFlag(false);
						ms.setError("找不到相应的订单信息!");
						request.setAttribute("message", ms);
						return mapping.findForward("userFailed");
					}
				}
			} else {
				return mapping.findForward("nologing");
			}

		}
		catch (Exception e) {
			JLog.getLogger().error("查看订单详细信息时出错!", e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("查看订单详细信息时出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		}
		finally {
			if (con != null)
				con.close();
		}
		return mapping.findForward("viewSuccess");
	}

	public ActionForward changeAddress(	ActionMapping mapping,
										ActionForm form,
										HttpServletRequest request,
										HttpServletResponse response) throws Exception {
		Connection con = null;
		try {
			nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
			if (TokenManager.isTokenValid(request, true)) {
				String order_id = JUtil.convertNull(request.getParameter("or_id"));

				con = dbUtil.getNfwlCon();
				ITG_ORDERRECManager igom = new ITG_ORDERRECManager();
				ITG_ORDERREC igo = (ITG_ORDERREC) igom.get(con, order_id);
				if (igo != null) {
					if (user.getId().equals(igo.getOr_userid())) {
						if (igo.getOr_status() == OrderStatusEnum.NEW.getCode()) {
							String adr_id = JUtil.convertNull(request.getParameter("adr_id"));
							if (adr_id.equals("")) {
								Message ms = new Message();
								ms.setFlag(false);
								ms.setError("你没有选择地址!");
								request.setAttribute("message", ms);
								return mapping.findForward("changeAddressFailed");
							} else {
								AddressManager am = new AddressManager();
								ITG_ORDERRECDELIVERY ia = am.changeAddress(	con,
																			order_id,
																			adr_id,
																			user.getItg_fixedpoint());
								if (ia != null) {
									Message ms = new Message();
									ms.setFlag(true);
									ms.setMsg("设置订单收货地址成功!");
									request.setAttribute("message", ms);
									request.setAttribute("address", ia);
									return mapping.findForward("changeAddressSuccess");
								} else {
									Message ms = new Message();
									ms.setFlag(false);
									ms.setError("设置订单收货地址出错!");
									request.setAttribute("message", ms);
									return mapping.findForward("changeAddressFailed");
								}
							}
						} else {
							Message ms = new Message();
							ms.setFlag(false);
							ms.setError("只有新订单可以设置收货地址!");
							request.setAttribute("message", ms);

							return mapping.findForward("changeAddressFailed");
						}
					} else {
						Message ms = new Message();
						ms.setFlag(false);
						ms.setError("找不到相应的订单信息!");
						request.setAttribute("message", ms);
						return mapping.findForward("userFailed");
					}

				} else {
					Message ms = new Message();
					ms.setFlag(false);
					ms.setError("没有订单可以设置收货地址!");
					request.setAttribute("message", ms);

					return mapping.findForward("changeAddressFailed");
				}
			} else {
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("非法的设置收货地址!");
				request.setAttribute("message", ms);

				return mapping.findForward("userFailed");
			}

		}
		catch (Exception e) {
			JLog.getLogger().error("设置收货地址!", e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("设置收货地址!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		}
		finally {
			if (con != null)
				con.close();
		}
	}

	public ActionForward changePay(	ActionMapping mapping,
									ActionForm form,
									HttpServletRequest request,
									HttpServletResponse response) throws Exception {
		Connection con = null;
		try {
			nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");

			if (TokenManager.isTokenValid(request, true)) {
				String order_id = JUtil.convertNull(request.getParameter("or_id"));
				con = dbUtil.getNfwlCon();
				ITG_ORDERRECManager igom = new ITG_ORDERRECManager();
				ITG_ORDERREC igo = (ITG_ORDERREC) igom.get(con, order_id);

				if (igo != null) {
					if (user.getId().equals(igo.getOr_userid())) {
						if (igo.getOr_status() == OrderStatusEnum.NEW.getCode()
							|| igo.getOr_status() == OrderStatusEnum.CONFIRM.getCode()) {
							con = dbUtil.getNfwlCon();
							// 扩展功能参数——默认支付方式

							String pay_mode = JUtil.convertNull(request.getParameter("pay_bank"));
							String paymethod = ""; // 默认支付方式，四个值可选：bankPay(网银);
													// cartoon(卡通);
													// directPay(余额); CASH(网点支付)
							String defaultbank = ""; // 默认网银代号，代号列表见http://club.alipay.com/read.php?tid=8681379
							if (pay_mode.equals("directPay")) {
								paymethod = "directPay";
							} else if (pay_mode.equals("default")) {
								paymethod = "default";
							} else {
								paymethod = "bankPay";
								defaultbank = pay_mode;
							}
							ITG_PAY ip = new ITG_PAY();
							ip.setPay_id(JUtil.createUNID());
							ip.setPay_orderid(order_id);
							ip.setPay_type(paymethod);
							ip.setDefaultbank(defaultbank);
							ip.setPay_status(0);

							PayManager pm = new PayManager();
							pm.changePay(con, ip);

							if (ip != null) {
								Message ms = new Message();
								ms.setFlag(true);
								ms.setMsg("设置订单支付方式成功!");
								request.setAttribute("message", ms);
								request.setAttribute("pay", ip);
								return mapping.findForward("changePaySuccess");
							} else {
								Message ms = new Message();
								ms.setFlag(false);
								ms.setError("设置订单支付方式出错!");
								request.setAttribute("message", ms);
								return mapping.findForward("changePayFailed");
							}
						} else {
							Message ms = new Message();
							ms.setFlag(false);
							ms.setError("只有新订单可以设置支付方式!");
							request.setAttribute("message", ms);

							return mapping.findForward("changePayFailed");
						}
					} else {
						Message ms = new Message();
						ms.setFlag(false);
						ms.setError("找不到相应的订单信息!");
						request.setAttribute("message", ms);
						return mapping.findForward("userFailed");
					}
				} else {
					Message ms = new Message();
					ms.setFlag(false);
					ms.setError("没有订单可以设置支付方式!");
					request.setAttribute("message", ms);

					return mapping.findForward("changePayFailed");
				}
			} else {
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("非法的设置支付方式!");
				request.setAttribute("message", ms);

				return mapping.findForward("userFailed");
			}

		}
		catch (Exception e) {
			JLog.getLogger().error("设置支付方式出错!", e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("设置支付方式出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		}
		finally {
			if (con != null)
				con.close();
		}
	}

	public ActionForward canche(ActionMapping mapping,
								ActionForm form,
								HttpServletRequest request,
								HttpServletResponse response) throws Exception {
		Connection con = null;
		String order_id = JUtil.convertNull(request.getParameter("or_id"));
		try {
			nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
			if (TokenManager.isTokenValid(request, true)) {

				con = dbUtil.getNfwlCon();
				ITG_ORDERRECManager igom = new ITG_ORDERRECManager();
				ITG_ORDERREC igo = (ITG_ORDERREC) igom.get(con, order_id);

				if (igo != null) {
					if (user.getId().equals(igo.getOr_userid())) {
						if (igo.getOr_status() == OrderStatusEnum.NEW.getCode()
							|| igo.getOr_status() == OrderStatusEnum.CONFIRM.getCode()) {
							con = dbUtil.getNfwlCon();

							ITG_ORDERRECManager iom = new ITG_ORDERRECManager();
							iom.canche(con, order_id);

							Message ms = new Message();
							ms.setFlag(true);
							ms.setMsg("取消订单成功!");
							ms.setUrl("/user/ordermodify.do?cmd=view&or_id=" + order_id);
							request.setAttribute("message", ms);
							return mapping.findForward("cancheSuccess");

						} else {
							Message ms = new Message();
							ms.setFlag(false);
							ms.setError("只有新订单或未付款可以取消!");
							request.setAttribute("message", ms);
							ms.setUrl("/user/ordermodify.do?cmd=view&or_id=" + order_id);
							return mapping.findForward("cancheFailed");
						}
					} else {
						Message ms = new Message();
						ms.setFlag(false);
						ms.setError("找不到相应的订单信息!");
						request.setAttribute("message", ms);
						return mapping.findForward("userFailed");
					}
				} else {
					Message ms = new Message();
					ms.setFlag(false);
					ms.setError("没有订单可以取消!");
					request.setAttribute("message", ms);
					ms.setUrl("/user/ordermodify.do?cmd=view&or_id=" + order_id);
					return mapping.findForward("cancheFailed");
				}
			} else {
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("非法的取消订单!");
				request.setAttribute("message", ms);

				return mapping.findForward("userFailed");
			}

		}
		catch (Exception e) {
			JLog.getLogger().error("取消订单出错!", e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("取消订单出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		}
		finally {
			if (con != null)
				con.close();
		}
	}

	public ActionForward receiving(	ActionMapping mapping,
									ActionForm form,
									HttpServletRequest request,
									HttpServletResponse response) throws Exception {
		Connection con = null;
		try {
			nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
			if (TokenManager.isTokenValid(request, true)) {
				String order_id = JUtil.convertNull(request.getParameter("or_id"));

				con = dbUtil.getNfwlCon();
				ITG_ORDERRECManager igom = new ITG_ORDERRECManager();
				ITG_ORDERREC igo = (ITG_ORDERREC) igom.get(con, order_id);

				if (igo != null) {
					if (user.getId().equals(igo.getOr_userid())) {
						if (igo.getOr_status() == OrderStatusEnum.SHIPPING.getCode()) {
							con = dbUtil.getNfwlCon();

							ITG_ORDERRECManager iom = new ITG_ORDERRECManager();
							iom.receiving(con, order_id);

							Message ms = new Message();
							ms.setFlag(true);
							ms.setMsg("订单确认收货成功!");
							request.setAttribute("message", ms);
							ms.setUrl("/user/ordermodify.do?cmd=view&or_id=" + order_id);
							return mapping.findForward("receivingSuccess");

						} else {
							Message ms = new Message();
							ms.setFlag(false);
							ms.setError("只有已发货的订单可以确认收货!");
							request.setAttribute("message", ms);
							ms.setUrl("/user/ordermodify.do?cmd=view&or_id=" + order_id);
							return mapping.findForward("receivingFailed");
						}
					} else {
						Message ms = new Message();
						ms.setFlag(false);
						ms.setError("找不到相应的订单信息!");
						request.setAttribute("message", ms);
						return mapping.findForward("userFailed");
					}

				} else {
					Message ms = new Message();
					ms.setFlag(false);
					ms.setError("没有订单可以确认收货!");
					request.setAttribute("message", ms);
					ms.setUrl("/user/ordermodify.do?cmd=view&or_id=" + order_id);
					return mapping.findForward("receivingFailed");
				}
			} else {
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("非法的订单可以确认收货!");
				request.setAttribute("message", ms);
				return mapping.findForward("userFailed");
			}

		}
		catch (Exception e) {
			JLog.getLogger().error("订单可以确认收货出错!", e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("订单可以确认收货出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("userError");
		}
		finally {
			if (con != null)
				con.close();
		}
	}

	public ActionForward confirm(	ActionMapping mapping,
									ActionForm form,
									HttpServletRequest request,
									HttpServletResponse response) throws Exception {
		String url = "";
		Connection con = null;
		try {
			if (TokenManager.isTokenValid(request, true)) {
				nps.core.User user = (nps.core.User) request.getSession().getAttribute("user");
				if (user != null) {
					String session_order = JUtil.convertNull(request.getParameter("or_id"));
					if (session_order.equals("")) {
						JLog.getLogger().info("没有订单可以确认");
						Message ms = new Message();
						ms.setFlag(false);
						ms.setError("没有订单可以确认!");
						request.setAttribute("message", ms);
						return mapping.findForward("orderFailed");
					} else {
						con = dbUtil.getNfwlCon();
						boolean falg = OrderUtil.isNewAndSelfOrder(con, session_order, user.getId());
						if (falg) {
							ITG_PAYManager ipm = new ITG_PAYManager();
							ITG_PAY pay = (ITG_PAY) ipm.getByOrder(con, session_order);
							if (pay != null) {
								ITG_ORDERRECManager igom = new ITG_ORDERRECManager();
								ITG_ORDERREC igo = igom.get(con, session_order);

								String or_memo = JUtil.convertNull(request.getParameter("or_memo"));
								String or_invoicetitle = JUtil.convertNull(request.getParameter("or_invoicetitle"));
								igom.confirmOrder(con, igo, or_memo, or_invoicetitle);
								if (pay.getPay_type().equals(PayTypeEnum.DEFAULT.getCode())) {
									url = "/order/pay.do?cmd=pay&or_id=" + session_order;
								} else {
									request.setAttribute("or_id", session_order);
									url = "/order/alipayto.jsp";
								}
								request.getSession().removeAttribute("order");
							} else {
								JLog.getLogger().info("没有支付信息");
								Message ms = new Message();
								ms.setFlag(false);
								ms.setError("没有支付信息!");
								request.setAttribute("message", ms);
								return mapping.findForward("orderFailed");
							}
						} else {
							request.getSession().removeAttribute("order");
							return mapping.findForward("myorder");
						}
					}

				} else {
					return mapping.findForward("nologing");
				}
			} else {
				JLog.getLogger().info("非法的确认订单");
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("非法的确认订单!");
				request.setAttribute("message", ms);
				return mapping.findForward("orderFailed");
			}

		}
		catch (Exception e) {
			JLog.getLogger().error("确认订单信息出错!", e);
			Message ms = new Message();
			ms.setFlag(false);
			ms.setError("显示订单信息出错!");
			request.setAttribute("message", ms);
			return mapping.findForward("orderError");
		}
		finally {
			if (con != null)
				con.close();
		}
		return new ActionForward(url);
	}

}
