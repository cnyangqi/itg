package com.nfwl.itg.user;

import java.sql.Date;

import com.jado.bean.Bean;



/**
 * 
 * @Project：ithinkgo   
 * @Type：   ITG_MESSAGEEVAL 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-7-24 上午11:12:44
 * @Comment
 * 
 */

public class ITG_MESSAGEEVAL extends Bean {

	private String me_id;//ID号
	
	private String me_userid;//用户ID号
	
	private Integer me_type;//类型 1 留言 2 评价
	
	private String me_odid;//订单明细号
	
	private String me_content;//内容
	
	private Integer me_desclevel;//商品与描述相符 1-5星
	
	private Integer me_attitudelevel;//卖家服态度 1-5星
	
	private Integer me_speedlevel;//卖家发货速度 1-5星
	
	private Integer me_deliverylevel;//物流公司服务 1-5星
	
	private Integer me_level;//综合评价 1-5星
	
	private Date me_time;//时间

	public String getMe_id() {
		return me_id;
	}

	public void setMe_id(String me_id) {
		this.me_id = me_id;
	}

	public String getMe_userid() {
		return me_userid;
	}

	public void setMe_userid(String me_userid) {
		this.me_userid = me_userid;
	}

	public Integer getMe_type() {
		return me_type;
	}

	public void setMe_type(Integer me_type) {
		this.me_type = me_type;
	}

	
	
	public String getMe_odid() {
		return me_odid;
	}

	public void setMe_odid(String me_odid) {
		this.me_odid = me_odid;
	}

	public String getMe_content() {
		return me_content;
	}

	public void setMe_content(String me_content) {
		this.me_content = me_content;
	}

	public Integer getMe_desclevel() {
		return me_desclevel;
	}

	public void setMe_desclevel(Integer me_desclevel) {
		this.me_desclevel = me_desclevel;
	}

	public Integer getMe_attitudelevel() {
		return me_attitudelevel;
	}

	public void setMe_attitudelevel(Integer me_attitudelevel) {
		this.me_attitudelevel = me_attitudelevel;
	}

	public Integer getMe_speedlevel() {
		return me_speedlevel;
	}

	public void setMe_speedlevel(Integer me_speedlevel) {
		this.me_speedlevel = me_speedlevel;
	}

	

	public Integer getMe_deliverylevel() {
		return me_deliverylevel;
	}

	public void setMe_deliverylevel(Integer me_deliverylevel) {
		this.me_deliverylevel = me_deliverylevel;
	}

	public Integer getMe_level() {
		return me_level;
	}

	public void setMe_level(Integer me_level) {
		this.me_level = me_level;
	}

	public Date getMe_time() {
		return me_time;
	}

	public void setMe_time(Date me_time) {
		this.me_time = me_time;
	}
	
	
}

