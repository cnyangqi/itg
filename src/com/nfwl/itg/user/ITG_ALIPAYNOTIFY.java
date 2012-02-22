package com.nfwl.itg.user;

import com.jado.bean.Bean;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   ITG_ALIPAYNOTIFY 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-11-24 下午09:01:10
 * @Comment
 * 
 */

public class ITG_ALIPAYNOTIFY extends Bean {

	private String id;
	 
	 private String trade_no;//支付宝交易号
	 
	 private String out_trade_no;//订单号
	 
	 private String total_fee;//总金额
	 
	 private String buyer_email;//买家支付宝账号
	 
	 private String trade_status;//交易状态
	 
	 private Integer type;//类型1支付宝付款2支付宝冲值
	 
	 private Integer status;//状态1成功2异常

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getTrade_no() {
		return trade_no;
	}

	public void setTrade_no(String trade_no) {
		this.trade_no = trade_no;
	}

	public String getOut_trade_no() {
		return out_trade_no;
	}

	public void setOut_trade_no(String out_trade_no) {
		this.out_trade_no = out_trade_no;
	}

	public String getTotal_fee() {
		return total_fee;
	}

	public void setTotal_fee(String total_fee) {
		this.total_fee = total_fee;
	}

	public String getBuyer_email() {
		return buyer_email;
	}

	public void setBuyer_email(String buyer_email) {
		this.buyer_email = buyer_email;
	}

	public String getTrade_status() {
		return trade_status;
	}

	public void setTrade_status(String trade_status) {
		this.trade_status = trade_status;
	}

	public Integer getType() {
		return type;
	}

	public void setType(Integer type) {
		this.type = type;
	}

	public Integer getStatus() {
		return status;
	}

	public void setStatus(Integer status) {
		this.status = status;
	}
	 
	 
}

