package models;

public class UserModels {
  //id,name,account,password,telephone,itg_fixedpoint,fax,email,mobile,face,cx,dept,utype
	public String id;
	public String name;
	public String account;
	public String password;
  public String telephone;
  public String worknum;
  public String itg_fixedpoint;
  public String itg_fixedpointname;
  public String fax;
  public String email;
  public String mobile;
  public String face;
  public String cx;
  public String dept;
  public String utype;
  public String nickname;
  public String logincode;
  public String urlTo = "http://new.ithinkgo.com:8822";
	
	public UserModels clone(){
		UserModels u = new UserModels();
		u.id = id;
		u.name = name;
		u.account = account;
    u.password = password;
    u.itg_fixedpoint = itg_fixedpoint;
		u.telephone = telephone;
		return u;
	}

  public String getUrlTo() {
    return urlTo;
  }

  public String getWorknum() {
    return worknum;
  }

  public void setWorknum(String worknum) {
    this.worknum = worknum;
  }

  public void setUrlTo(String urlTo) {
    this.urlTo = urlTo;
  }

  public String getLogincode() {
    return logincode;
  }

  public void setLogincode(String logincode) {
    this.logincode = logincode;
  }

  public String getNickname() {
    return nickname;
  }

  public void setNickname(String nickname) {
    this.nickname = nickname;
  }

  public String getId() {
    return id;
  }

  public void setId(String id) {
    this.id = id;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String getAccount() {
    return account;
  }

  public void setAccount(String account) {
    this.account = account;
  }

  public String getPassword() {
    return password;
  }

  public void setPassword(String password) {
    this.password = password;
  }

  public String getTelephone() {
    return telephone;
  }

  public void setTelephone(String telephone) {
    this.telephone = telephone;
  }

  public String getItg_fixedpoint() {
    return itg_fixedpoint;
  }

  public void setItg_fixedpoint(String itg_fixedpoint) {
    this.itg_fixedpoint = itg_fixedpoint;
  }

  public String getFax() {
    return fax;
  }

  public void setFax(String fax) {
    this.fax = fax;
  }

  public String getEmail() {
    return email;
  }

  public void setEmail(String email) {
    this.email = email;
  }

  public String getMobile() {
    return mobile;
  }

  public void setMobile(String mobile) {
    this.mobile = mobile;
  }

  public String getFace() {
    return face;
  }

  public void setFace(String face) {
    this.face = face;
  }

  public String getCx() {
    return cx;
  }

  public void setCx(String cx) {
    this.cx = cx;
  }

  public String getDept() {
    return dept;
  }

  public void setDept(String dept) {
    this.dept = dept;
  }

  public String getUtype() {
    return utype;
  }

  public void setUtype(String utype) {
    this.utype = utype;
  }

  public String getItg_fixedpointname() {
    return itg_fixedpointname;
  }

  public void setItg_fixedpointname(String itg_fixedpointname) {
    this.itg_fixedpointname = itg_fixedpointname;
  }
	
	
}
