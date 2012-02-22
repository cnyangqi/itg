package com.nfwl.itg.user;

import com.jado.bean.Bean;



/**
 * 
 * @Project：ithinkgo   
 * @Type：   ITG_ORDERDETAIL 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-7-24 上午10:41:36
 * @Comment
 * 
 */

public class ITG_ORDERDETAIL extends Bean {

	private String od_id;//ID号
	
	private String od_orid;//订单ID号
	
	private String od_prdid;//商品ID号
	
	private String od_prdname;//商品名称
	
	private Double od_price;//商品价格
	
	private Double od_num;//数量

	public String getOd_id() {
		return od_id;
	}

	public void setOd_id(String od_id) {
		this.od_id = od_id;
	}

	public String getOd_orid() {
		return od_orid;
	}

	public void setOd_orid(String od_orid) {
		this.od_orid = od_orid;
	}

	public String getOd_prdid() {
		return od_prdid;
	}

	public void setOd_prdid(String od_prdid) {
		this.od_prdid = od_prdid;
	}

	public String getOd_prdname() {
		return od_prdname;
	}

	public void setOd_prdname(String od_prdname) {
		this.od_prdname = od_prdname;
	}

	public Double getOd_price() {
		return od_price;
	}

	public void setOd_price(Double od_price) {
		this.od_price = od_price;
	}

	public Double getOd_num() {
		return od_num;
	}

	public void setOd_num(Double od_num) {
		this.od_num = od_num;
	}

	
	
	
}

