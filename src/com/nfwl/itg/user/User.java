package com.nfwl.itg.user;

import com.jado.bean.Bean;

/**
 * 
 * @Project：ithinkgo
 * @Type： UserForm
 * @Author: yjw
 * @Email: y.jinwei@gmail.com
 * @Mobile: 13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date: 2011-7-24 下午05:16:54
 * @Comment
 * 
 *          2011.11.30 增加定点单位字段 yangq
 */

public class User extends Bean {

	private String id;

	private String account;// 账号

	private String password;// 密码

	private String areacode;// 电话区号

	private String telephone;// 电话

	private String subnum;// 电话分机号

	private String faxareacode;// 传真区号

	private String fax;// 传真

	private String email;// 邮箱

	private String mobile;// 手机

	private String face; // 脸谱绝对路径

	private Integer cx;

	private String dept;// 部门

	private int utype;// 用户类型 0 普通工作人员 9 系统管理员 1 想购网会员

	private String regtime;// 注册时间

	private Integer sex;// 性别 0 男 1 女

	private String fpid;// 定点单位ID号

	private Integer zoneid;// 所在地区

	private String detailadr;// 详细地址

	private String postcode;// 邮编

	private String adrid;// 最近收货地址

	private Integer point;// 当前积分

	private Double money;// 账户余额

	private String nickname;// 昵称

	private String name;// 真实姓名

	private String itg_fixedpoint;// 定点单位

	public String getAccount() {
		return account;
	}

	public void setAccount(String account) {
		this.account = account;
	}

	public String getPostcode() {
		return postcode;
	}

	public void setPostcode(String postcode) {
		this.postcode = postcode;
	}

	public String getAdrid() {
		return adrid;
	}

	public void setAdrid(String adrid) {
		this.adrid = adrid;
	}

	public Integer getPoint() {
		return point;
	}

	public void setPoint(Integer point) {
		this.point = point;
	}

	public Double getMoney() {
		return money;
	}

	public void setMoney(Double money) {
		this.money = money;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getNickname() {
		return nickname;
	}

	public void setNickname(String nickname) {
		this.nickname = nickname;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public Integer getSex() {
		return sex;
	}

	public void setSex(Integer sex) {
		this.sex = sex;
	}

	public Integer getZoneid() {
		return zoneid;
	}

	public void setZoneid(Integer zoneid) {
		this.zoneid = zoneid;
	}

	public String getDetailadr() {
		return detailadr;
	}

	public void setDetailadr(String detailadr) {
		this.detailadr = detailadr;
	}

	public String getMobile() {
		return mobile;
	}

	public void setMobile(String mobile) {
		this.mobile = mobile;
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

	public String getFaxareacode() {
		return faxareacode;
	}

	public void setFaxareacode(String faxareacode) {
		this.faxareacode = faxareacode;
	}

	public String getFax() {
		return fax;
	}

	public void setFax(String fax) {
		this.fax = fax;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getFace() {
		return face;
	}

	public void setFace(String face) {
		this.face = face;
	}

	public Integer getCx() {
		return cx;
	}

	public void setCx(Integer cx) {
		this.cx = cx;
	}

	public String getDept() {
		return dept;
	}

	public void setDept(String dept) {
		this.dept = dept;
	}

	public int getUtype() {
		return utype;
	}

	public void setUtype(int utype) {
		this.utype = utype;
	}

	public String getRegtime() {
		return regtime;
	}

	public void setRegtime(String regtime) {
		this.regtime = regtime;
	}

	public String getFpid() {
		return fpid;
	}

	public void setFpid(String fpid) {
		this.fpid = fpid;
	}

	public String getItg_fixedpoint() {
		return itg_fixedpoint;
	}

	public void setItg_fixedpoint(String itg_fixedpoint) {
		this.itg_fixedpoint = itg_fixedpoint;
	}

}
