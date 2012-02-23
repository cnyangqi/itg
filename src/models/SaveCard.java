package models;

import java.util.Date;

/**
 * 储值卡实体
 * 
 * @author yangq(qi.yang.cn@gmail.com) 2012-2-23
 */
public class SaveCard {

	String cardno = null;// 卡号,
	String cardpwd = null;// 卡密码,
	Double money = null;// 金额,
	Double balance = null;// 余额,
	Date time = null;// ,发卡日期
	Date publishtime = null;// 销售日期,
	Date usetime = null;// 使用日期,
	String creatorid = null;// 发卡人主键,
	Integer status = null;// 重置卡状态 -1已注销（不可使用）/0新发卡（不可使用）/1已销售（正常使用）/2已使用
	String cnstatus = null;// 中文状态

	public String getCardno() {
		return cardno;
	}

	public void setCardno(String cardno) {
		this.cardno = cardno;
	}

	public String getId() {
		return cardno;
	}

	public void setId(String cardno) {
		this.cardno = cardno;
	}

	public String getCardpwd() {
		return cardpwd;
	}

	public void setCardpwd(String cardpwd) {
		this.cardpwd = cardpwd;
	}

	public Double getMoney() {
		return money;
	}

	public void setMoney(Double money) {
		this.money = money;
	}

	public Double getBalance() {
		return balance;
	}

	public void setBalance(Double balance) {
		this.balance = balance;
	}

	public Date getTime() {
		return time;
	}

	public void setTime(Date time) {
		this.time = time;
	}

	public Date getPublishtime() {
		return publishtime;
	}

	public void setPublishtime(Date publishtime) {
		this.publishtime = publishtime;
	}

	public Date getUsetime() {
		return usetime;
	}

	public void setUsetime(Date usetime) {
		this.usetime = usetime;
	}

	public String getCreatorid() {
		return creatorid;
	}

	public void setCreatorid(String creatorid) {
		this.creatorid = creatorid;
	}

	public Integer getStatus() {
		return status;
	}

	public void setStatus(Integer status) {
		this.status = status;
	}

	public String getCnstatus() {
		return cnstatus;
	}

	public void setCnstatus(String cnstatus) {
		this.cnstatus = cnstatus;
	}

}
