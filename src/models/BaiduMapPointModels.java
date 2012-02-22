package models;

import java.sql.Date;

public class BaiduMapPointModels {
//{title:"维修点2",content:"专修航母2",point:"122.190716|30.129447",isOpen:0,icon:{w:21,h:21,l:92,t:46,x:1,lb:10}}
  //{title:"维修点1",content:"专修航母1",point:"122.090717|30.029447",isOpen:0,icon:{w:21,h:21,l:92,t:46,x:1,lb:10}}
  //title:"一号救助点",content:"救   自理",point:"121.441889|28.675546",isOpen:0,icon:{w:21,h:21,l:46,t:46,x:1,lb:10}}
  // "   mobile, telephone, business, memo, csbm, creater, creatername, createtime)\n" + 
  
  public String id = null;
  public String title = null;
  public Integer type = null;//0 标准类型 1 自定义
  public String content = null;
  public Double longitude  = null;//经度
  public Double latitude = null;//纬度
  public Integer tagIcon = null;//标记图标
  public Integer tagWidth = null;//标记宽度
  public Integer tagHeight = null;//标记高度
  public Integer isOpen = 0;//默认打开  0 否 1 是
  public Integer parameterT = 46;//未知参数
  public Integer parameterX = 1;//未知参数
  public Integer parameterLB = 10;//未知参数
  public String memo = null;// 备注类型
  public String linkman = null;
  public String mobile = null;
  public String telephone = null;
  public String business  = null;
  public String csbm  = null;
  public String creater  = null;
  public String creatername  = null;
  public Date createtime  = null;
  public String address  = null;


  public String getId() {
    return id;
  }
  public void setId(String id) {
    this.id = id;
  }
  public String getCsbm() {
    return csbm;
  }
  public void setCsbm(String csbm) {
    this.csbm = csbm;
  }
  public String getCreater() {
    return creater;
  }
  public void setCreater(String creater) {
    this.creater = creater;
  }
  public String getCreatername() {
    return creatername;
  }
  public void setCreatername(String creatername) {
    this.creatername = creatername;
  }
  public Date getCreatetime() {
    return createtime;
  }
  public void setCreatetime(Date createtime) {
    this.createtime = createtime;
  }
  public String getMemo() {
    return memo;
  }

  public void setMemo(String memo) {
    this.memo = memo;
  }

  public String getLinkman() {
    return linkman;
  }

  public void setLinkman(String linkman) {
    this.linkman = linkman;
  }

  public String getMobile() {
    return mobile;
  }

  public void setMobile(String mobile) {
    this.mobile = mobile;
  }

  public String getTelephone() {
    return telephone;
  }

  public void setTelephone(String telephone) {
    this.telephone = telephone;
  }

  public String getBusiness() {
    return business;
  }

  public void setBusiness(String business) {
    this.business = business;
  }

  public Integer getType() {
    return type;
  }

  public void setType(Integer type) {
    this.type = type;
  }

  public String getTitle() {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public String getContent() {
    return content;
  }

  public void setContent(String content) {
    this.content = content;
  }

  public Double getLongitude() {
    return longitude;
  }

  public void setLongitude(Double longitude) {
    this.longitude = longitude;
  }

  public Double getLatitude() {
    return latitude;
  }

  public void setLatitude(Double latitude) {
    this.latitude = latitude;
  }

  public Integer getTagIcon() {
    return tagIcon;
  }

  public void setTagIcon(Integer tagIcon) {
    this.tagIcon = tagIcon;
  }

  public Integer getTagWidth() {
    return tagWidth;
  }

  public void setTagWidth(Integer tagWidth) {
    this.tagWidth = tagWidth;
  }

  public Integer getTagHeight() {
    return tagHeight;
  }

  public void setTagHeight(Integer tagHeight) {
    this.tagHeight = tagHeight;
  }

  public Integer getIsOpen() {
    return isOpen;
  }

  public void setIsOpen(Integer isOpen) {
    this.isOpen = isOpen;
  }

  public Integer getParameterT() {
    return parameterT;
  }

  public void setParameterT(Integer parameterT) {
    this.parameterT = parameterT;
  }

  public Integer getParameterX() {
    return parameterX;
  }

  public void setParameterX(Integer parameterX) {
    this.parameterX = parameterX;
  }

  public Integer getParameterLB() {
    return parameterLB;
  }

  public void setParameterLB(Integer parameterLB) {
    this.parameterLB = parameterLB;
  }
  
  public String getAddress() {
    return address;
  }
  public void setAddress(String address) {
    this.address = address;
  }
  public BaiduMapPointModels clone(){
		BaiduMapPointModels u = new BaiduMapPointModels();
		u.id = id;
		u.title = title;
    return u;
	}
}
