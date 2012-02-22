<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="UTF-8"%>
<%@page import="com.jado.JadoException"%>
<%@ page import="java.util.*"%>
<%@ page import="java.util.Map"%>
<%@ page import="com.nfwl.itg.alipay.*"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="com.nfwl.itg.user.ITG_RECHARGERECManager"%>
<%@ page import="com.jado.JadoException"%>
<%@ page import="com.nfwl.itg.common.Message"%>
<%@ page import="com.nfwl.itg.common.dbUtil"%>
<%@ page import="com.jado.JLog"%>
<html>
  <head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>支付成功客户端返回</title>
<style type="text/css">
.font_content{
    font-family:"宋体";
    font-size:14px;
    color:#FF6600;
}
.font_title{
    font-family:"宋体";
    font-size:16px;
    color:#FF0000;
    font-weight:bold;
}
table{
    border: 1px solid #CCCCCC;
}
</style>
  </head>
  <body>
<%
	String key = AlipayConfig.key;
	//获取支付宝GET过来反馈信息
	Map params = new HashMap();
	Map requestParams = request.getParameterMap();
	for (Iterator iter = requestParams.keySet().iterator(); iter.hasNext();) {
		String name = (String) iter.next();
		String[] values = (String[]) requestParams.get(name);
		String valueStr = "";
		for (int i = 0; i < values.length; i++) {
			valueStr = (i == values.length - 1) ? valueStr + values[i]
					: valueStr + values[i] + ",";
		}
		//乱码解决，这段代码在出现乱码时使用。如果mysign和sign不相等也可以使用这段代码转化
		valueStr = new String(valueStr.getBytes("ISO-8859-1"), "utf-8");
		params.put(name, valueStr);
	}
	
	//判断responsetTxt是否为ture，生成的签名结果mysign与获得的签名结果sign是否一致
	//responsetTxt的结果不是true，与服务器设置问题、合作身份者ID、notify_id一分钟失效有关
	//mysign与sign不等，与安全校验码、请求时的参数格式（如：带自定义参数等）、编码格式有关
	String mysign = AlipayNotify.GetMysign(params,key);
	String responseTxt = AlipayNotify.Verify(request.getParameter("notify_id"));
	String sign = request.getParameter("sign");
	
	//写日志记录（若要调试，请取消下面两行注释）
	//String sWord = "responseTxt=" + responseTxt + "\n return_url_log:sign=" + sign + "&mysign=" + mysign + "\n return回来的参数：" + AlipayFunction.CreateLinkString(params);
	//AlipayFunction.LogResult(sWord);
	
	//获取支付宝的通知返回参数，可参考技术文档中页面跳转同步通知参数列表(以下仅供参考)//
	String trade_no = request.getParameter("trade_no");				//支付宝交易号
	String order_no = request.getParameter("out_trade_no");	        //获取订单号
	String total_fee = request.getParameter("total_fee");	        //获取总金额
	String subject = new String(request.getParameter("subject").getBytes("ISO-8859-1"),"utf-8");//商品名称、订单名称
	String body = "";
	if(request.getParameter("body") != null){
		body = new String(request.getParameter("body").getBytes("ISO-8859-1"), "utf-8");//商品描述、订单备注、描述
	}
	String buyer_email = request.getParameter("buyer_email");		//买家支付宝账号
	String trade_status = request.getParameter("trade_status");		//交易状态
	//获取支付宝的通知返回参数，可参考技术文档中页面跳转同步通知参数列表(以上仅供参考)//
		
	String verifyStatus = "";
	
	if(mysign.equals(sign) && responseTxt.equals("true")){
		//////////////////////////////////////////////////////////////////////////////////////////
		//请在这里加上商户的业务逻辑程序代码

		//——请根据您的业务逻辑来编写程序（以下代码仅作参考）——
		if(trade_status.equals("TRADE_FINISHED") || trade_status.equals("TRADE_SUCCESS")){
			//判断该笔订单是否在商户网站中已经做过处理（可参考“集成教程”中“3.4返回数据处理”）
				//如果没有做过处理，根据订单号（out_trade_no）在商户网站的订单系统中查到该笔订单的详细，并执行商户的业务程序
				//如果有做过处理，不执行商户的业务程序
		java.sql.Connection con=null;
		 try
			{
			 con = dbUtil.getNfwlCon();
			 ITG_RECHARGERECManager pm = new ITG_RECHARGERECManager();
			 pm.alipayRechargeSuccess(con,order_no,trade_no,buyer_email ,Double.valueOf(total_fee),trade_status);
				
			}/*catch(Exception e){
				JLog.getLogger().info("冲值确认支付出错!");
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("冲值确认支付出错!");
				request.setAttribute("message", ms);
				
				ServletContext sc = getServletContext();
		        RequestDispatcher rd = null;
		        rd = sc.getRequestDispatcher("/b2c/uc/order/orderFailed.jsp");
		        rd.forward(request, response);	
			}*/finally{
				if (con!=null) con.close();	
			}
		}
		verifyStatus = "验证成功";
		//——请根据您的业务逻辑来编写程序（以上代码仅作参考）——

		//////////////////////////////////////////////////////////////////////////////////////////
	}else{
		verifyStatus = "验证失败";
	}
%>
<table align="center" width="500" cellpadding="5" cellspacing="0">
            <tr>
                <td align="center" class="font_title" colspan="2">
                    通知返回</td>
            </tr>
            <tr>
                <td class="font_content" align="right">
                    宝交易号：</td>
                <td class="font_content" align="left"><%=trade_no %></td>
            </tr>
            <tr>
                <td class="font_content" align="right">
                    订单号：</td>
                <td class="font_content" align="left"><%=order_no %></td>
            </tr>
            <tr>
                <td class="font_content" align="right">
                    付款总金额：</td>
                <td class="font_content" align="left"><%=total_fee %></td>
            </tr>
            <tr>
                <td class="font_content" align="right">
                    买家账号：</td>
                <td class="font_content" align="left"><%=buyer_email %></td>
            </tr>
            <tr>
                <td class="font_content" align="right">
                    验证状态：</td>
                <td class="font_content" align="left"><%=verifyStatus %></td>
            </tr>
        </table>
  </body>
</html>
