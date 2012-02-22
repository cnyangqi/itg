package com.nfwl.itg.user;

import java.sql.Date;

import com.jado.bean.Bean;



/**
 * 
 * @Project：ithinkgo   
 * @Type：   Itg_RecharGerec 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-7-23 下午05:47:08
 * @Comment 充值记录
 * 
 */

public class ITG_RECHARGEREC extends Bean {

	private String rcr_id;//ID号
	
	private String rcr_userid;//用户ID号
	
	private String rcr_cardno;//卡号
	
	private String rcr_cardpwd;//密码
	
	private Double rcr_money;//卡金额
	
	private Date rcr_time;//日期
	
	private Integer rcr_type;//类型 1 储值卡 2 支付宝
	
	private String rcr_tradeno;//支付宝交易号
	
	private String rcr_buyeremail;//支付宝账号
	
	
	
	
	public String getRcr_tradeno() {
		return rcr_tradeno;
	}

	public void setRcr_tradeno(String rcr_tradeno) {
		this.rcr_tradeno = rcr_tradeno;
	}

	

	public String getRcr_buyeremail() {
		return rcr_buyeremail;
	}

	public void setRcr_buyeremail(String rcr_buyeremail) {
		this.rcr_buyeremail = rcr_buyeremail;
	}

	public Integer getRcr_type() {
		return rcr_type;
	}

	public void setRcr_type(Integer rcr_type) {
		this.rcr_type = rcr_type;
	}

	public String getRcr_id() {
		return rcr_id;
	}

	public void setRcr_id(String rcr_id) {
		this.rcr_id = rcr_id;
	}

	public String getRcr_userid() {
		return rcr_userid;
	}

	public void setRcr_userid(String rcr_userid) {
		this.rcr_userid = rcr_userid;
	}

	public String getRcr_cardno() {
		return rcr_cardno;
	}

	public void setRcr_cardno(String rcr_cardno) {
		this.rcr_cardno = rcr_cardno;
	}

	public String getRcr_cardpwd() {
		return rcr_cardpwd;
	}

	public void setRcr_cardpwd(String rcr_cardpwd) {
		this.rcr_cardpwd = rcr_cardpwd;
	}

	

	
	

	public Double getRcr_money() {
		return rcr_money;
	}

	public void setRcr_money(Double rcr_money) {
		this.rcr_money = rcr_money;
	}

	public Date getRcr_time() {
		return rcr_time;
	}

	public void setRcr_time(Date rcr_time) {
		this.rcr_time = rcr_time;
	}
	

	
}

