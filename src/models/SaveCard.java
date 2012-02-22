package models;

import java.util.Date;

public class SaveCard {
  
  String cardno      = null;//varchar2(10) NOT NULL,
  String cardpwd     = null;//varchar2(10),
  Double money       = null;//number,
  Double balance     = null;//number,
  Date time        = null;//date,
  Date publishtime = null;//date,
  Date usetime     = null;//date,
  String creatorid   = null;//varchar2(36),
  Integer status      = null;//number
  String cnstatus      = null;//number
  
  
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
