package com.nfwl.itg.order;

import java.sql.Connection;

import com.jado.JadoException;
import com.nfwl.itg.user.ITG_PAY;
import com.nfwl.itg.user.ITG_PAYManager;

/**
 * 
 * @Project：ithinkgo   
 * @Type：   PayManager 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-11-26 下午11:11:00
 * @Comment
 * 
 */

public class PayManager {

	public void changePay(Connection con,ITG_PAY pay) throws JadoException{
		ITG_PAYManager ipm = new ITG_PAYManager();
		ipm.createPay(con,pay);
		
	}
}

