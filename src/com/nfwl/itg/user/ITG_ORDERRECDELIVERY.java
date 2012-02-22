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

public class ITG_ORDERRECDELIVERY extends Bean {

	private String id;//ID号
	
	private String orid;//订单id号
	
	private String fpid;//定点单位ID号
	
	private String name;//收货人
	
	private Integer zone;//所在地区
	
	private String detail; //详细地址
	
	private String areacode;//电话区号
	
	private String telephone;//固定电话
	
	private String subnum;//分机号
	
	private String postcode;//邮编
	
	private String mobile;//手机号码
	
	private String adrid;//地址id;
	
	//private Integer newfalg;//是否新增0否1是
	
	private String email;
	
	
	
	
	




	public String getEmail() {
		return email;
	}





	public void setEmail(String email) {
		this.email = email;
	}




/*
	public Integer getNewfalg() {
		return newfalg;
	}





	public void setNewfalg(Integer newfalg) {
		this.newfalg = newfalg;
	}



*/

	public String getAdrid() {
		return adrid;
	}





	public void setAdrid(String adrid) {
		this.adrid = adrid;
	}





	public String getId() {
		return id;
	}





	public void setId(String id) {
		this.id = id;
	}





	public String getOrid() {
		return orid;
	}





	public void setOrid(String orid) {
		this.orid = orid;
	}





	public String getFpid() {
		return fpid;
	}





	public void setFpid(String fpid) {
		this.fpid = fpid;
	}





	public String getName() {
		return name;
	}





	public void setName(String name) {
		this.name = name;
	}





	public Integer getZone() {
		return zone;
	}





	public void setZone(Integer zone) {
		this.zone = zone;
	}





	public String getDetail() {
		return detail;
	}





	public void setDetail(String detail) {
		this.detail = detail;
	}





	public String getAreacode() {
		return areacode;
	}





	public void setAreacode(String areacode) {
		this.areacode = areacode;
	}





	public String getTelephone() {
		return telephone;
	}





	public void setTelephone(String telephone) {
		this.telephone = telephone;
	}





	public String getSubnum() {
		return subnum;
	}





	public void setSubnum(String subnum) {
		this.subnum = subnum;
	}





	public String getPostcode() {
		return postcode;
	}





	public void setPostcode(String postcode) {
		this.postcode = postcode;
	}





	public String getMobile() {
		return mobile;
	}





	public void setMobile(String mobile) {
		this.mobile = mobile;
	}





	@Override
	public String toString() {
		String s="收货人:"+this.name+"\n";
		s = s + "电话:"+this.areacode+"-"+this.telephone+"-"+this.subnum+ "\n";
		s = s + "手机号码:"+this.mobile+"\n";
		s = s + "所在地区:"+this.zone+"\n";
		s = s + "详细地址:"+this.detail+"\n";
		s = s + "邮编:"+this.postcode;
		return s;
	}
	
	
}

