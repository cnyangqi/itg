package com.nfwl.itg.user;

import com.jado.bean.Bean;



/**
 * 
 * @Project：ithinkgo   
 * @Type：   ITG_ADDRESS 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-7-24 上午11:38:56
 * @Comment
 * 
 */

public class ITG_ADDRESS extends Bean {

	private String adr_id;//ID号
	
	private String adr_userid;//用户ID号
	
	private String adr_fpid;//定点单位ID号
	
	private String adr_name;//收货人
	
	private Integer adr_zone;//所在地区
	
	private String adr_detail; //详细地址
	
	private String adr_areacode;//电话区号
	
	private String adr_telephone;//固定电话
	
	private String adr_subnum;//分机号
	
	private String adr_postcode;//邮编
	
	private String adr_mobile;//手机号码
	
	private String adr_time;//时间
	
	private String adr_email;//邮箱
	
	private Integer adr_status;//是否删除0未删除1已删除
	
	

	public Integer getAdr_status() {
		return adr_status;
	}

	public void setAdr_status(Integer adr_status) {
		this.adr_status = adr_status;
	}

	public String getAdr_email() {
		return adr_email;
	}

	public void setAdr_email(String adr_email) {
		this.adr_email = adr_email;
	}

	public String getAdr_id() {
		return adr_id;
	}

	public void setAdr_id(String adr_id) {
		this.adr_id = adr_id;
	}

	public String getAdr_userid() {
		return adr_userid;
	}

	public void setAdr_userid(String adr_userid) {
		this.adr_userid = adr_userid;
	}

	public String getAdr_fpid() {
		return adr_fpid;
	}

	public void setAdr_fpid(String adr_fpid) {
		this.adr_fpid = adr_fpid;
	}

	public String getAdr_name() {
		return adr_name;
	}

	public void setAdr_name(String adr_name) {
		this.adr_name = adr_name;
	}

	public Integer getAdr_zone() {
		return adr_zone;
	}

	public void setAdr_zone(Integer adr_zone) {
		this.adr_zone = adr_zone;
	}

	public String getAdr_detail() {
		return adr_detail;
	}

	public void setAdr_detail(String adr_detail) {
		this.adr_detail = adr_detail;
	}

	public String getAdr_telephone() {
		return adr_telephone;
	}

	public void setAdr_telephone(String adr_telephone) {
		this.adr_telephone = adr_telephone;
	}

	public String getAdr_subnum() {
		return adr_subnum;
	}

	public void setAdr_subnum(String adr_subnum) {
		this.adr_subnum = adr_subnum;
	}

	public String getAdr_postcode() {
		return adr_postcode;
	}

	public void setAdr_postcode(String adr_postcode) {
		this.adr_postcode = adr_postcode;
	}

	public String getAdr_mobile() {
		return adr_mobile;
	}

	public void setAdr_mobile(String adr_mobile) {
		this.adr_mobile = adr_mobile;
	}

	public String getAdr_time() {
		return adr_time;
	}

	public void setAdr_time(String adr_time) {
		this.adr_time = adr_time;
	}

	public String getAdr_areacode() {
		return adr_areacode;
	}

	public void setAdr_areacode(String adr_areacode) {
		this.adr_areacode = adr_areacode;
	}

	@Override
	public String toString() {
		String s="收货人:"+this.adr_name+"\n";
		s = s + "电话:"+this.adr_areacode+"-"+this.adr_telephone+"-"+this.adr_subnum+ "\n";
		s = s + "手机号码:"+this.adr_mobile+"\n";
		s = s + "所在地区:"+this.adr_zone+"\n";
		s = s + "详细地址:"+this.adr_detail+"\n";
		s = s + "邮编:"+this.adr_postcode;
		return s;
	}
	
	
}

