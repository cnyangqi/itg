<%@ page language="java" errorPage="/error.jsp" contentType="text/html; charset=utf-8" pageEncoding="UTF-8"%>
<%@ include file="/include/header.jsp"%>
<%@page import="com.jado.JadoException"%>
<%@ page import="com.nfwl.itg.alipay.*"%>
<%@ page import="com.nfwl.itg.user.ITG_RECHARGEREC"%>
<%@ page import="com.nfwl.itg.common.Message"%>
<%@ page import="com.nfwl.itg.common.TokenManager"%>
<%@ page import="com.jado.JLog"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=gb18030">
		<title>支付宝即时到帐付款</title>
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
			//request.setCharacterEncoding("UTF-8");
			//AlipyConfig.java中配置信息（不可以修改）
			String input_charset = AlipayConfig.input_charset;
			String sign_type = AlipayConfig.sign_type;
			String seller_email = AlipayConfig.seller_email;
			String partner = AlipayConfig.partner;
			String key = AlipayConfig.key;

			String show_url = AlipayConfig.show_url;
			String notify_url = AlipayConfig.rechargenotify_url;
			String return_url = AlipayConfig.rechargereturn_url;
			
			///////////////////////////////////////////////////////////////////////////////////
			
			//以下参数是需要通过下单时的订单数据传入进来获得
			//必填参数
			//UtilDate date = new UtilDate();//调取支付宝工具类生成订单号
	        //String out_trade_no = date.getOrderNum();//请与贵网站订单系统中的唯一订单号匹配
	        //订单名称，显示在支付宝收银台里的“商品名称”里，显示在支付宝的交易管理的“商品名称”的列表里。
	        //String subject = new String(request.getParameter("aliorder").getBytes("ISO-8859-1"),"utf-8");
	        //订单描述、订单详细、订单备注，显示在支付宝收银台里的“商品描述”里
	        //String body = new String(request.getParameter("alibody").getBytes("ISO-8859-1"),"utf-8");
	        //订单总金额，显示在支付宝收银台里的“应付总额”里
	        //String total_fee = request.getParameter("alimoney");
	        
	        //扩展功能参数——默认支付方式
	        //String pay_mode = request.getParameter("pay_bank");
	        //String paymethod = "";		//默认支付方式，四个值可选：bankPay(网银); cartoon(卡通); directPay(余额); CASH(网点支付)
	        //String defaultbank = "";	//默认网银代号，代号列表见http://club.alipay.com/read.php?tid=8681379
	        // if(pay_mode.equals("directPay")){
	         //	paymethod = "directPay";
	        // }
	        // else{
	        // 	paymethod = "bankPay";
	        // 	defaultbank = pay_mode;
	        //  }
			        
	        String out_trade_no="";
	        String subject="";
	        String body="";
	        String total_fee="";
	        String paymethod="";
	        String defaultbank="";
	        String sHtmlText="";
			if (TokenManager.isTokenValid(request, true)) {
				try
				{
					ITG_RECHARGEREC cr =   (ITG_RECHARGEREC)request.getAttribute("recharge");
					
					if(cr==null){
						JLog.getLogger().info("支付时支付订单信息!");
						Message ms = new Message();
						ms.setFlag(false);
						ms.setError("支付时支付订单信息!");
						request.setAttribute("message", ms);
					
						ServletContext sc = getServletContext();
				        RequestDispatcher rd = null;
				        rd = sc.getRequestDispatcher("/b2c/uc/ucFailed.jsp");
				        rd.forward(request, response);
					}
			        out_trade_no = cr.getRcr_id();
			        subject="订单号："+cr.getRcr_id();
			        body="想购网支付宝冲值";
			        //total_fee=igo.getOr_money().toString();
			        if(cr.getRcr_money()!=null){
			        	total_fee=cr.getRcr_money().toString();
			        }
			        
			       
			        
					paymethod="directPay";//Pub.convertNull(request.getParameter("paymethod"));
					defaultbank="";//Pub.convertNull(request.getParameter("defaultbank"));
			        //扩展功能参数——防钓鱼
			        //请慎重选择是否开启防钓鱼功能
					//exter_invoke_ip、anti_phishing_key一旦被设置过，那么它们就会成为必填参数
					//开启防钓鱼功能后，服务器、本机电脑必须支持远程XML解析，请配置好该环境。
					//建议使用POST方式请求数据
			        String anti_phishing_key  = "";				//防钓鱼时间戳
			        String exter_invoke_ip= "";					//获取客户端的IP地址，建议：编写获取客户端IP地址的程序
			        //如：
			        //anti_phishing_key = AlipayFunction.query_timestamp(partner);	//获取防钓鱼时间戳函数
			        //exter_invoke_ip = "202.1.1.1";
			        
			        //扩展功能参数——其他
			        String extra_common_param = "";				//自定义参数，可存放任何内容（除=、&等特殊字符外），不会显示在页面上
			        String buyer_email = "";					//默认买家支付宝账号
			        
			        //扩展功能参数——分润(若要使用，请按照注释要求的格式赋值)
			        String royalty_type = "";					//提成类型，该值为固定值：10，不需要修改
			        String royalty_parameters ="";
					//提成信息集，与需要结合商户网站自身情况动态获取每笔交易的各分润收款账号、各分润金额、各分润说明。最多只能设置10条
					//各分润金额的总和须小于等于total_fee
					//提成信息集格式为：收款方Email_1^金额1^备注1|收款方Email_2^金额2^备注2
					//如：
					//royalty_type = "10"
					//royalty_parameters	= "111@126.com^0.01^分润备注一|222@126.com^0.01^分润备注二"
	
			        /////////////////////////////////////////////////////////////////////////////////////////////////////
	
					//构造函数，生成请求URL
			        sHtmlText = AlipayService.BuildForm(partner,seller_email,return_url,notify_url,show_url,out_trade_no,
					subject,body,total_fee,paymethod,defaultbank,anti_phishing_key,exter_invoke_ip,extra_common_param,buyer_email,
					royalty_type,royalty_parameters,input_charset,key,sign_type);
					
			        /*JXC_PAYLOG jpl = new JXC_PAYLOG();
				
			        jpl.setOrid(out_trade_no);
			        jpl.setType(PayLogEnum.alipay.getCode());
			        jpl.setSource(PayLogEnum.alipay.getSource());
			        jpl.setTotalfee(total_fee);
			        jpl.setMemo(jo.getMemo());
					
					JXC_PAYLOGManager jplm = new JXC_PAYLOGManager();
					jplm.newPayLog(jpl);*/
						
				}catch(Exception e){
					e.printStackTrace();
					//throw new JError("显示订单信息出错!");	
				}
			}else{
				JLog.getLogger().info("非法的支付!");
				Message ms = new Message();
				ms.setFlag(false);
				ms.setError("非法的支付!");
				request.setAttribute("message", ms);
				
				
				ServletContext sc = getServletContext();
		        RequestDispatcher rd = null;
		        rd = sc.getRequestDispatcher("/user/Failed.jsp");
		        rd.forward(request, response);

			}
			%>
				 <table align="center" width="350" cellpadding="5" cellspacing="0">
		            <tr>
		                <td align="center" class="font_title" colspan="2">订单确认</td>
		            </tr>
		            <tr>
		                <td class="font_content" align="right">订单号：</td>
		                <td class="font_content" align="left"><%=out_trade_no%></td>
		            </tr>
		            <tr>
		                <td class="font_content" align="right">总金额：</td>
		                <td class="font_content" align="left"><%=total_fee%></td>
		            </tr>
		            <tr>
		                <td align="center" colspan="2"><%=sHtmlText%></td>
		            </tr>
		        </table>
				<%
			
	%>

	
       
	</body>
</html>
