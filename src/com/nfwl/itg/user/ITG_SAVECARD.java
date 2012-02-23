package com.nfwl.itg.user;

import java.sql.Date;

import com.jado.bean.Bean;

/**
 * 充值卡实体
 * 
 * @author yangq(qi.yang.cn@gmail.com) 2012-2-23
 */
public class ITG_SAVECARD extends Bean {

	private String sc_cardno;// 卡号

	private String sc_cardpwd;// 密码

	private Double sc_money;// 卡金额

	private Double sc_balance;// 余额

	private Date sc_time;// 创建日期

	private Date sc_publishtime;// 发行日期

	private Date sc_usetime;// 使用日期

	private String sc_creatorid;// 创建人ID号

	private Integer sc_status;// 0：新建（不可使用），1 已销售（可正常使用），-1 已注销 （不可使用）

	public String getSc_cardno() {
		return sc_cardno;
	}

	public void setSc_cardno(String sc_cardno) {
		this.sc_cardno = sc_cardno;
	}

	public String getSc_cardpwd() {
		return sc_cardpwd;
	}

	public void setSc_cardpwd(String sc_cardpwd) {
		this.sc_cardpwd = sc_cardpwd;
	}

	public Double getSc_money() {
		return sc_money;
	}

	public void setSc_money(Double sc_money) {
		this.sc_money = sc_money;
	}

	public Double getSc_balance() {
		return sc_balance;
	}

	public void setSc_balance(Double sc_balance) {
		this.sc_balance = sc_balance;
	}

	public Date getSc_time() {
		return sc_time;
	}

	public void setSc_time(Date sc_time) {
		this.sc_time = sc_time;
	}

	public Date getSc_publishtime() {
		return sc_publishtime;
	}

	public void setSc_publishtime(Date sc_publishtime) {
		this.sc_publishtime = sc_publishtime;
	}

	public Date getSc_usetime() {
		return sc_usetime;
	}

	public void setSc_usetime(Date sc_usetime) {
		this.sc_usetime = sc_usetime;
	}

	public String getSc_creatorid() {
		return sc_creatorid;
	}

	public void setSc_creatorid(String sc_creatorid) {
		this.sc_creatorid = sc_creatorid;
	}

	public Integer getSc_status() {
		return sc_status;
	}

	public void setSc_status(Integer sc_status) {
		this.sc_status = sc_status;
	}

}
