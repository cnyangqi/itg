package com.nfwl.itg.user;

import java.sql.Date;

import com.jado.bean.Bean;



/**
 * 
 * @Project：ithinkgo   
 * @Type：   ITG_ORDERREC 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-7-24 上午09:25:30
 * @Comment
 * 
 */

public class ITG_ORDERREC extends Bean {

	private String or_id;
	
	private String or_userid;//用户ID号
	
	private Double or_money;//总金额
	
	private Integer or_status;//订单状态 1未付款 2 已付款 3 正在配送 4 完成 10取消
	
	private Date or_time;//下单时间
	
	private String or_no;//订单号
	
	private Double or_point;//积分
	
	private Integer or_carrymode;//送货方式
	
	private String or_invoicetitle; //发票抬头
	
	private String or_memo;//订单留言
	



	public String getOr_invoicetitle() {
		return or_invoicetitle;
	}

	public void setOr_invoicetitle(String or_invoicetitle) {
		this.or_invoicetitle = or_invoicetitle;
	}

	public String getOr_memo() {
		return or_memo;
	}

	public void setOr_memo(String or_memo) {
		this.or_memo = or_memo;
	}

	public Integer getOr_carrymode() {
		return or_carrymode;
	}

	public void setOr_carrymode(Integer or_carrymode) {
		this.or_carrymode = or_carrymode;
	}

	public Double getOr_point() {
		return or_point;
	}

	public void setOr_point(Double or_point) {
		this.or_point = or_point;
	}


	public String getOr_id() {
		return or_id;
	}

	public void setOr_id(String or_id) {
		this.or_id = or_id;
	}

	public String getOr_userid() {
		return or_userid;
	}

	public void setOr_userid(String or_userid) {
		this.or_userid = or_userid;
	}

	

	public Double getOr_money() {
		return or_money;
	}

	public void setOr_money(Double or_money) {
		this.or_money = or_money;
	}



	public Integer getOr_status() {
		return or_status;
	}

	public void setOr_status(Integer or_status) {
		this.or_status = or_status;
	}

	public Date getOr_time() {
		return or_time;
	}

	public void setOr_time(Date or_time) {
		this.or_time = or_time;
	}

	public String getOr_no() {
		return or_no;
	}

	public void setOr_no(String or_no) {
		this.or_no = or_no;
	}
	
	
	
}

