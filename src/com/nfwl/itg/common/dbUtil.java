package com.nfwl.itg.common;

import java.sql.Connection;



/**
 * 
 * @Project：ithinkgo   
 * @Type：   dbUtil 
 * @Author:  yjw 
 * @Email:   y.jinwei@gmail.com
 * @Mobile:  13738192139
 * @WebSite: http://51maibb.taobao.com
 * @Date:    2011-11-20 上午11:43:53
 * @Comment
 * 
 */

public class dbUtil {

	public static Connection getNfwlCon() throws Exception{
		return nps.core.Database.GetDatabase("nfwl").GetConnection();
	}
}

