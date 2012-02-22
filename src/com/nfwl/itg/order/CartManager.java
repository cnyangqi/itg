package com.nfwl.itg.order;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import com.gemway.partner.JUtil;
import com.jado.JadoException;
import com.nfwl.itg.common.ArtileUtil;
import com.nfwl.itg.user.ITG_CARTREC;
import com.nfwl.itg.user.ITG_CARTRECManager;
import com.nfwl.itg.user.ITG_ORDERDETAIL;
import com.nfwl.itg.user.ITG_ORDERDETAILManager;
import com.nfwl.itg.user.ITG_ORDERRECManager;

/**
 * 
 * @Project：ithinkgo
 * @Type： CartManager
 * @Author: yjw
 * @Email: y.jinwei@gmail.com
 * @Mobile: 13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date: 2011-8-9 下午08:28:25
 * @Comment
 * 
 */

public class CartManager {

	public List<Cart> getUserCarts(Connection con, String user_id,
			String orderid) throws JadoException {
		List<Cart> ls = null;
		try {
			ITG_CARTRECManager icm = new ITG_CARTRECManager();
			if (orderid.equals("")) {
				List _ls = icm.getCartByUser(con, user_id);
				if (_ls != null) {
					ls = CartUtil.listMapToCart(_ls);
				}
			} else {
				ITG_ORDERDETAILManager ioem = new ITG_ORDERDETAILManager();
				List _ls = ioem.getByOrder(con, orderid);
				if (_ls != null) {
					ls = CartUtil.orderdetailToCart(_ls);
				}
			}

		} catch (Exception e) {
			throw new JadoException("读取购物车时出错!");
		}
		return ls;
	}

	public List<Cart> add(Connection con, String user_id, String orderid,
			String prd_id,String num) throws JadoException {
		List<Cart> ls = null;
		try {
			Map map = ArtileUtil.getByCart(con, prd_id);

			if (orderid.equals("")) {
				ITG_CARTRECManager icm = new ITG_CARTRECManager();
				if (map != null) {
					ITG_CARTREC ig = new ITG_CARTREC();
					ig.setCr_id(JUtil.createUNID());
					if(!num.equals("")){
						try{
							ig.setCr_num(Double.valueOf(num));
						}catch (Exception e) {
							ig.setCr_num(1D);
						}
					}
					
					ig.setCr_prdid((String) map.get("prd_id"));
					ig.setCr_userid(user_id);
					icm.insert(con, ig);
				}
				List _ls = icm.getCartByUser(con, user_id);
				if (_ls != null) {
					ls = CartUtil.listMapToCart(_ls);
				}
			} else {
				ITG_ORDERDETAILManager ioem = new ITG_ORDERDETAILManager();
				if (map != null) {
					ITG_ORDERDETAIL io = new ITG_ORDERDETAIL();
					io.setOd_id(JUtil.createUNID());
					io.setOd_orid(orderid);
					io.setOd_prdid((String) map.get("prd_id"));
					io.setOd_prdname((String) map.get("prd_name"));
					io.setOd_price(Double.valueOf(map.get("prd_price")
							.toString()));
					if(!num.equals("")){
						try{
							io.setOd_num(Double.valueOf(num));
						}catch (Exception e) {
							io.setOd_num(1.0);
						}
					}
					
					ioem.insert(con, io);
				}
				List _ls = ioem.getByOrder(con, orderid);
				if (_ls != null) {
					ls = CartUtil.orderdetailToCart(_ls);
				}
			}

		} catch (Exception e) {
			throw new JadoException("添加商品到购物车时出错!");
		}
		return ls;
	}

	public List<Cart> del(Connection con, String user_id, String orderid,
			String[] ids) throws JadoException {
		List<Cart> ls = null;
		try {
			if (orderid.equals("")) {
				ITG_CARTRECManager icm = new ITG_CARTRECManager();
				icm.del(con, ids);
				List _ls = icm.getCartByUser(con, user_id);
				if (_ls != null) {
					ls = CartUtil.listMapToCart(_ls);
				}
			} else {
				ITG_ORDERDETAILManager ioem = new ITG_ORDERDETAILManager();
				ioem.del(con, ids);

				List _ls = ioem.getByOrder(con, orderid);
				if (_ls != null) {
					ls = CartUtil.orderdetailToCart(_ls);
				}
			}

		} catch (Exception e) {
			throw new JadoException("删除购物车商品时出错!");
		}
		return ls;
	}

	public void updateOrder(Connection con,String[] ids, String[] amount,String session_order) throws JadoException {
		try {	
				con.setAutoCommit(false);
				
				if (ids != null && ids.length > 0) {
					ITG_ORDERDETAILManager ioem = new ITG_ORDERDETAILManager();
					Double price = 0.0;
					Double point = 0.0;
					for (int i = 0; i < ids.length; i++) {
						// icm.updAmount(con, cartids[i],
						// Double.valueOf(amount[i]));
						ioem.updAmount(con, ids[i], Double
								.valueOf(amount[i]));

					}
					ITG_ORDERRECManager iom = new ITG_ORDERRECManager();
					
					iom.updateMoneyAndPoint(con, session_order);
				}
				con.commit();
				con.setAutoCommit(true);

		} catch (Exception e) {
			try {
				con.rollback();
			} catch (SQLException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
			throw new JadoException("把购物车商品更新到订单信息时出错!");
		}
	}
	public void updateCarterc(Connection con,String[] ids, String[] amount) throws JadoException {
		try {	
			if (ids != null && ids.length > 0) {
				ITG_CARTRECManager icm = new ITG_CARTRECManager();
				for (int i = 0; i < ids.length; i++) {
					icm.updAmount(con, ids[i], Double
							.valueOf(amount[i]));
				}
			}
		} catch (Exception e) {
			throw new JadoException("删除购物车商品更新到购物车时出错!");
		}
	}
	public void addCartec(Connection con,String user_id,List<Cart> ls,String[] ids, String[] amount)throws JadoException{
		if(ls!=null){
			ITG_CARTRECManager icm = new ITG_CARTRECManager();
			for(Cart c:ls){
				ITG_CARTREC ig = new ITG_CARTREC();
				ig.setCr_id(c.getId());
				ig.setCr_num(c.getAmount());
				ig.setCr_prdid(c.getPrd_id());
				ig.setCr_userid(user_id);
				if(ids!=null&&ids.length>0){
					for(int i=0;i<ids.length;i++){
						if(ids[i].equals(c.getId())){
							ig.setCr_num(Double.valueOf(amount[i]));
							break;
						}
					}
					
				}
				icm.insert(con, ig);
			}
			
		}
	}
	
	

}
