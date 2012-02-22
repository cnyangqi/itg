package com.nfwl.itg.user;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Date;
import java.util.Properties;

import javax.mail.Message;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeUtility;

import nps.core.Database;

import com.nfwl.itg.dddw.ITG_FIXEDPOINT;

/**
 * 用户服务类
 * 
 * @author yangq
 */
public class UserService {

	/** 通过用户账户找回用户密码 */
	public static boolean retrieveUserPwdByAccount(String account) throws Exception {
		Connection con = Database.GetDatabase("nps").GetConnection();
		StringBuilder sb = new StringBuilder("select t.password,t.email from users t where t.account='");
		sb.append(account.toUpperCase()).append("' ");

		PreparedStatement ps = con.prepareStatement(sb.toString());
		ResultSet rs = ps.executeQuery();
		if (rs.next()) {
			String pwd = rs.getString(1);
			String email = rs.getString(2);

			Properties properties = new Properties();
			properties.put("mail.smtp.host", "smtp.qq.com");
			properties.put("mail.smtp.port", "25");
			properties.put("mail.transport.protocol", "smtp");
			properties.put("mail.smtp.auth", "true");

			/** 创建邮件会话 */
			Session session = Session.getInstance(properties);
			Message message = new MimeMessage(session);

			message.setFrom(new InternetAddress("autotransport@qq.com"));
			message.setRecipient(Message.RecipientType.TO, new InternetAddress(email));
			message.setSentDate(new Date());
			message.setSubject(MimeUtility.encodeText("密码找回", "UTF-8", "B"));
			message.setText(pwd);

			Transport transport = session.getTransport();
			transport.connect(properties.getProperty("mail.smtp.host"), "autotransport@qq.com", "221133a");// 密码填写处
			transport.sendMessage(message, message.getAllRecipients());
			System.out.println("邮件发送成功");
			return true;
		} else {
			return false;
		}
	}

	/** 通过定点单位管理员查询定点单位管理员的定点单位 */
	public static ITG_FIXEDPOINT queryFIXEDPOINTById(User user) throws Exception {
		if (user != null) {
			String id = user.getItg_fixedpoint();
			Connection con = Database.GetDatabase("nps").GetConnection();
			StringBuilder sb = new StringBuilder("select * from itg_fixedpoint t where t.fp_id='");
			sb.append(id);
			sb.append("'");

			PreparedStatement ps = con.prepareStatement(sb.toString());
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				ITG_FIXEDPOINT temp = new ITG_FIXEDPOINT();
				temp.setId(rs.getString("FP_ID"));
				temp.setName(rs.getString("FP_NAME"));
				temp.setAddress(rs.getString("FP_ADDRESS"));
				temp.setLinker(rs.getString("FP_LINKER"));
				temp.setPhone(rs.getString("FP_PHONE"));
				temp.setEmail(rs.getString("FP_EMAIL"));
				temp.setCode(rs.getString("FP_CODE"));
				return temp;
			}
			rs.close();
		}
		return null;
	}

	/** 通过用户账户查询是否定点单位用户 */
	public static boolean isFixedPointUser(String account) throws Exception {
		// select * from users t where t.utype='5' and t.account='YJW';

		Connection con = Database.GetDatabase("nps").GetConnection();
		StringBuilder sb = new StringBuilder("select * from users t where t.utype='5' and t.account='");
		sb.append(account.toUpperCase()).append("'");

		PreparedStatement ps = con.prepareStatement(sb.toString());
		ResultSet rs = ps.executeQuery();
		if (rs.next()) {
			return true;
		}
		return false;
	}

}
