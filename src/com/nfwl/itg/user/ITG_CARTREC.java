package com.nfwl.itg.user;

import java.sql.Date;

import com.jado.bean.Bean;



/**
 * 
 * @Project：ithinkgo   
 * @Type：   ITG_CARTREC 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-7-23 下午09:54:33
 * @Comment 购物车记录
 * 
 */

public class ITG_CARTREC extends Bean {

	private String cr_id;//ID号
	
	private String cr_userid;//用户ID号
	
	private String cr_prdid;//商品ID号
	
	private Double cr_num;//购买数量
	
	private Date cr_time;//日期

	public String getCr_id() {
		return cr_id;
	}

	public void setCr_id(String cr_id) {
		this.cr_id = cr_id;
	}

	public String getCr_userid() {
		return cr_userid;
	}

	public void setCr_userid(String cr_userid) {
		this.cr_userid = cr_userid;
	}

	public String getCr_prdid() {
		return cr_prdid;
	}

	public void setCr_prdid(String cr_prdid) {
		this.cr_prdid = cr_prdid;
	}

	

	public Double getCr_num() {
		return cr_num;
	}

	public void setCr_num(Double cr_num) {
		this.cr_num = cr_num;
	}

	public Date getCr_time() {
		return cr_time;
	}

	public void setCr_time(Date cr_time) {
		this.cr_time = cr_time;
	}
	
	
}

