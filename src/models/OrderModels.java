package models;

import java.sql.Date;

public class OrderModels {
  public String   or_id            = null;// VARCHAR2(36) not null,
  public String   or_userid        = null;// VARCHAR2(36),
  public Double   or_money         = null;// NUMBER,
  public String   or_status        = null;// INTEGER,
  public Date   or_time          = null;// DATE default sysdate,
  public String   or_adrid         = null;// VARCHAR2(36),
  public String   or_no            = null;// VARCHAR2(15),
  public Integer   or_point         = null;// NUMBER,
  public Integer   or_carrymode     = null;// INTEGER,
  public String   or_invoicetitle  = null;// VARCHAR2(60),
  public String   or_memo          = null;// VARCHAR2(200)
  public String   or_telephone          = null;// VARCHAR2(200)
  public String   or_mobile          = null;// VARCHAR2(200)
  
  
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


  public String getOr_status() {
    return or_status;
  }


  public void setOr_status(String or_status) {
    this.or_status = or_status;
  }


  public Date getOr_time() {
    return or_time;
  }


  public void setOr_time(Date or_time) {
    this.or_time = or_time;
  }


  public String getOr_adrid() {
    return or_adrid;
  }


  public void setOr_adrid(String or_adrid) {
    this.or_adrid = or_adrid;
  }


  public String getOr_no() {
    return or_no;
  }


  public void setOr_no(String or_no) {
    this.or_no = or_no;
  }


  public Integer getOr_point() {
    return or_point;
  }


  public void setOr_point(Integer or_point) {
    this.or_point = or_point;
  }


  public Integer getOr_carrymode() {
    return or_carrymode;
  }


  public void setOr_carrymode(Integer or_carrymode) {
    this.or_carrymode = or_carrymode;
  }


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


  public String getOr_telephone() {
    return or_telephone;
  }


  public void setOr_telephone(String or_telephone) {
    this.or_telephone = or_telephone;
  }


  public String getOr_mobile() {
    return or_mobile;
  }


  public void setOr_mobile(String or_mobile) {
    this.or_mobile = or_mobile;
  }


  public OrderModels clone(){
    OrderModels o = new OrderModels();
		o.or_id = or_id;
		o.or_userid = or_userid;
    return o;
	}
}
