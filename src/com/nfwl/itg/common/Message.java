package com.nfwl.itg.common;

/**
 * 
 * @Project：cnbaibao   
 * @Type：   Message 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-10-23 下午06:36:21
 * @Comment
 * 
 */

public class Message {

	private Boolean flag;
	
	private String msg;
	
	private String error;
	
	private String url;

	public Boolean getFlag() {
		return flag;
	}

	public String getMsg() {
		return msg;
	}

	public void setMsg(String msg) {
		this.msg = msg;
	}

	public String getError() {
		return error;
	}

	public void setError(String error) {
		this.error = error;
	}

	public void setFlag(Boolean flag) {
		this.flag = flag;
	}

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	
	
	
}

