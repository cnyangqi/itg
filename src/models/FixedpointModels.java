package models;

import java.sql.Date;

public class FixedpointModels {
  private String   fp_id            = null;// VARCHAR2(36) not null,
  private String   fp_name        = null;// VARCHAR2(36),
  private String   fp_address         = null;// NUMBER,
  private String   fp_linker        = null;// INTEGER,
  private String   fp_phone          = null;// DATE default sysdate,
  private String   fp_email         = null;// VARCHAR2(36),
  private String   fp_postcode            = null;// VARCHAR2(15),
  private String   fp_code         = null;// NUMBER,
  private Integer  fp_valid     = null;// INTEGER,
  private String   fp_registerid  = null;// VARCHAR2(60),
  private Date     fp_time          = null;// VARCHAR2(200)
  private String   fp_delday         = null;// VARCHAR2(200)
  private boolean  selected          = false;// VARCHAR2(200)
  
 

  public String getFp_delday() {
    return fp_delday;
  }



  public void setFp_delday(String fp_delday) {
    this.fp_delday = fp_delday;
  }



  public String getFp_id() {
    return fp_id;
  }



  public void setFp_id(String fp_id) {
    this.fp_id = fp_id;
  }



  public String getFp_name() {
    return fp_name;
  }



  public void setFp_name(String fp_name) {
    this.fp_name = fp_name;
  }



  public String getFp_address() {
    return fp_address;
  }



  public void setFp_address(String fp_address) {
    this.fp_address = fp_address;
  }



  public String getFp_linker() {
    return fp_linker;
  }



  public void setFp_linker(String fp_linker) {
    this.fp_linker = fp_linker;
  }



  public String getFp_phone() {
    return fp_phone;
  }



  public void setFp_phone(String fp_phone) {
    this.fp_phone = fp_phone;
  }



  public String getFp_email() {
    return fp_email;
  }



  public void setFp_email(String fp_email) {
    this.fp_email = fp_email;
  }



  public String getFp_postcode() {
    return fp_postcode;
  }



  public void setFp_postcode(String fp_postcode) {
    this.fp_postcode = fp_postcode;
  }



  public String getFp_code() {
    return fp_code;
  }



  public void setFp_code(String fp_code) {
    this.fp_code = fp_code;
  }



  public Integer getFp_valid() {
    return fp_valid;
  }



  public void setFp_valid(Integer fp_valid) {
    this.fp_valid = fp_valid;
  }



  public String getFp_registerid() {
    return fp_registerid;
  }



  public void setFp_registerid(String fp_registerid) {
    this.fp_registerid = fp_registerid;
  }



  public Date getFp_time() {
    return fp_time;
  }



  public void setFp_time(Date fp_time) {
    this.fp_time = fp_time;
  }



  public boolean getSelected() {
    return selected;
  }



  public void setSelected(boolean selected) {
    this.selected = selected;
  }



  public FixedpointModels clone(){
    FixedpointModels o = new FixedpointModels();
    return o;
	}
}
