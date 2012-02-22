package models;

import java.util.ArrayList;
import java.util.Date;

public class CarOut {
  
  private String id = null;
  private String fpid = null;//单位ID
  private String fpname = null;//单位单位名称
  private String carnum = null;//联系人
  private String driver = null;//驾驶员
  private Date delday = null;//配送日期
  private String operaterid = null;//操作员ID
  private String operatername = null;//操作员
  private String operatertime = null;//操作员
  private Integer status = null;//
  private String cnstatus = null;//
  

  public String getCnstatus() {
    return cnstatus;
  }
  public void setCnstatus(String cnstatus) {
    this.cnstatus = cnstatus;
  }
  public String getFpid() {
    return fpid;
  }
  public void setFpid(String fpid) {
    this.fpid = fpid;
  }
  public Integer getStatus() {
    return status;
  }
  public void setStatus(Integer status) {
    this.status = status;
  }
  public String getId() {
    return id;
  }
  public void setId(String id) {
    this.id = id;
  }

  public String getFpname() {
    return fpname;
  }
  public void setFpname(String fpmane) {
    this.fpname = fpmane;
  }
  public String getCarnum() {
    return carnum;
  }
  public void setCarnum(String carnum) {
    this.carnum = carnum;
  }
  public String getDriver() {
    return driver;
  }
  public void setDriver(String driver) {
    this.driver = driver;
  }
  public Date getDelday() {
    return delday;
  }
  public void setDelday(Date delday) {
    this.delday = delday;
  }
  public String getOperaterid() {
    return operaterid;
  }
  public void setOperaterid(String operaterid) {
    this.operaterid = operaterid;
  }
  public String getOperatername() {
    return operatername;
  }
  public void setOperatername(String operatername) {
    this.operatername = operatername;
  }
  public String getOperatertime() {
    return operatertime;
  }
  public void setOperatertime(String operatertime) {
    this.operatertime = operatertime;
  }
  public CarOut clone(){
    return null;
  }

}
