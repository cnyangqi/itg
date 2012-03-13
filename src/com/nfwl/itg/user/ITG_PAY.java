package com.nfwl.itg.user;

import java.sql.Date;

import com.jado.bean.Bean;

/**
 * 支付实体
 * 
 * @author yangq(qi.yang.cn@gmail.com) 2012-3-13
 */

public class ITG_PAY extends Bean {
	private String pay_id;// ID号

	private String pay_orderid;// 订单号

	private Double pay_money;// 支付多

	private String pay_type;// 支付方式

	private Date pay_time;// 支付时间

	private Integer pay_status;

	private Date pay_createtime;// 创建时间

	private String defaultbank;//

	public String getPay_id() {
		return pay_id;
	}

	public void setPay_id(String pay_id) {
		this.pay_id = pay_id;
	}

	public String getPay_orderid() {
		return pay_orderid;
	}

	public void setPay_orderid(String pay_orderid) {
		this.pay_orderid = pay_orderid;
	}

	public Double getPay_money() {
		return pay_money;
	}

	public void setPay_money(Double pay_money) {
		this.pay_money = pay_money;
	}

	public String getPay_type() {
		return pay_type;
	}

	public void setPay_type(String pay_type) {
		this.pay_type = pay_type;
	}

	public String getDefaultbank() {
		return defaultbank;
	}

	public void setDefaultbank(String defaultbank) {
		this.defaultbank = defaultbank;
	}

	public Integer getPay_status() {
		return pay_status;
	}

	public void setPay_status(Integer pay_status) {
		this.pay_status = pay_status;
	}

	public Date getPay_time() {
		return pay_time;
	}

	public void setPay_time(Date pay_time) {
		this.pay_time = pay_time;
	}

	public Date getPay_createtime() {
		return pay_createtime;
	}

	public void setPay_createtime(Date pay_createtime) {
		this.pay_createtime = pay_createtime;
	}

}
