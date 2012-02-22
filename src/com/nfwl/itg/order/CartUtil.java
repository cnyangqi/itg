package com.nfwl.itg.order;

import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;



import com.nfwl.itg.user.ITG_CARTREC;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   CarUtil 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-8-2 下午10:07:59
 * @Comment
 * 
 */

public class CartUtil {

	
	public static List<Cart> getCartByCookie(HttpServletRequest request){
		Cookie cookies[]=request.getCookies();
		Cookie sCookie=null;
		if (cookies!=null)
		{
			
			for(int i=0;i<cookies.length;i++){
				sCookie=cookies[i];
				if(sCookie.getName().equals("ithinkgo_cart")){
					String scart = sCookie.getValue();
					return cartToList(URLDecoder.decode(scart));
				}
			}
		}
		return null;
	}
	public static List<Cart> cartToList(String scart){
		 JSONArray jsonArray1 = JSONArray.fromObject(scart);
		 System.out.println("cartToList:"+jsonArray1);
		 List<Cart> ls =  JSONArray.toList(jsonArray1, Cart.class);
		return ls;
	}
	public static void clearCookieCart(HttpServletResponse response){
		 Cookie cart=new Cookie("ithinkgo_cart",null);
		 cart.setMaxAge(0);
		 cart.setPath("/");
		 response.addCookie(cart);
	}
	public static void setCookieCart(HttpServletResponse response,List<Cart> ls){
		
			JSONArray jsonArray = JSONArray.fromObject(ls);
			String _s = jsonArray.toString();
			System.out.println("setCookeiCart:"+_s);
			Cookie cart =new Cookie("ithinkgo_cart",URLEncoder.encode(_s));
			cart.setPath("/");
			//cart.setDomain("ithinkgo.com");
			cart.setMaxAge(60*60*24*1);
		  	response.addCookie(cart);
		
		
	}
	public static List<Cart> listMapToCart(List ls){
		List<Cart> _ls=new ArrayList<Cart>();
		
		for (int i = 0; i < ls.size(); i++) {
			Cart c= new Cart();
			Map m = (Map) ls.get(i); 
			//System.out.println(m.get("amount"));
			//System.out.println(m.get("prd_id"));
			//System.out.println(m.get("prd_name"));
			//System.out.println(m.get("prd_picurl"));
			//System.out.println(m.get("prd_point"));
			//System.out.println(m.get("prd_price"));
			//System.out.println(m.get("prd_url"));
			
			c.setId((String)m.get("cr_id"));
			if(m.get("amount")==null||m.get("amount").equals("")){
				c.setAmount(0D);
			}else{
				c.setAmount(Double.valueOf(m.get("amount").toString()));
			}
			c.setPrd_id((String)m.get("prd_id"));
			c.setPrd_name((String)m.get("prd_name"));
			c.setPrd_picurl((String)m.get("prd_picurl"));
			c.setPrd_point(Double.valueOf(m.get("prd_point").toString()));
			c.setPrd_price(Double.valueOf(m.get("prd_price").toString()));
			c.setPrd_url((String)m.get("prd_url"));
			_ls.add(c);
			
		}
		return _ls;
	}
	public static Cart ArtmapToCart(Map m){
		if(m==null) return null;
		Cart c = new Cart();
		c.setAmount(1.0);
		c.setPrd_id((String)m.get("prd_id"));
		c.setPrd_name((String)m.get("prd_name"));
		c.setPrd_picurl((String)m.get("prd_picurl"));
		c.setPrd_point(Double.valueOf(m.get("prd_point").toString()));
		c.setPrd_price(Double.valueOf(m.get("prd_price").toString()));
		c.setPrd_url((String)m.get("prd_url"));
		return c;
	}
	public static List<Cart> delCartByid(List<Cart> ls,String[] cart_ids){
		if(ls==null) return null;
		List<Cart> _ls = new ArrayList<Cart>();
		for(Cart c:ls){
			boolean flag=false;
			for(int i=0;i<cart_ids.length;i++){
				//如果找到相等的
				if(c.getId().equals(cart_ids[i])){
					flag=true;
					break;
				}
			}
			if(!flag)_ls.add(c);
			
		}
		return _ls;
	}
	public static List<Cart> orderdetailToCart(List ls){
		List<Cart> _ls=new ArrayList<Cart>();
		
		for (int i = 0; i < ls.size(); i++) {
			Cart c= new Cart();
			Map m = (Map) ls.get(i); 
			
			c.setId((String)m.get("od_id"));
			c.setAmount(Double.valueOf(m.get("od_num").toString()));
			c.setPrd_id((String)m.get("od_prdid"));
			c.setPrd_name((String)m.get("od_prdname"));
			c.setPrd_picurl((String)m.get("pic_url"));
			c.setPrd_point(Double.valueOf(m.get("prd_point").toString()));
			c.setPrd_price(Double.valueOf(m.get("prd_localprice").toString()));
			c.setPrd_url((String)m.get("url_gen"));
			
			_ls.add(c);
		}
		return _ls;
	}
}

