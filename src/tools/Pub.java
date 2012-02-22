package tools;

import com.gemway.partner.JLog;
import com.gemway.util.JError;

import javax.servlet.ServletRequest;

import nps.core.NormalArticle;
import nps.core.NpsWrapper;
import nps.core.Topic;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Random;
import java.util.Vector;

/**
 * 公用方法类，因为该类及其方法会被广泛使用，所以类名和方法名尽量简短
 * User: XieZhiRong
 * Corp: Gemway
 * Date: 2007-5-22
 * Time: 0:18:59
 * @author : XieZhiRong
 */
public class Pub {
  
    public static final String SOLR_URL = "http://localhost:8983/solr/npscore/";
    /**
     * 默认的日期格式化对象
     */
    public static final SimpleDateFormat dateFormat=new SimpleDateFormat("yyyy-MM-dd");
    
    //局领导T_UNIT ID
    public static final String JLD_UNIT_ID="200501291227133175084773760000000004";
    
    //处室领导 T_Role ID
    
    public static final String CSLD_ROLD_ID = "200502021611562774426138200000000004";
    public static final String CSLD_ROLD_NAME = "处室领导";
    //

    /**
     * 性别常量 男
     */
    public static final int SEX_MALE=0;//男
    /**
     * 性别常量 女
     */
    public static final int SEX_FEMALE=1;//女

    /**
     * 拥有某类权限信息下面所有内容的标志符，用于T_ROLE_CONTENT表
     */
    public static final String ROLE_CONTENT_ALL="-1";

    /**
     * 整数值对应的布尔类型 是
     */
    public static final int BOOLEAN_TRUE=1;//是

    /**
     * 整数值对应的布尔类型 否
     */
    public static final int BOOLEAN_FALSE=0;//否

    /**
     * 字符串对应的布尔类型 是
     */
    public static final String BOOLEAN_TRUE_STR="1";//是

    /**
     * 字符串对应的布尔类型 否
     */
    public static final String BOOLEAN_FALSE_STR="0";//否


    public static final int ACCOUNT_STATUS_NORMAL=1;//正在处理

    public static final int ACCOUNT_STATUS_END=2;//结束

    public static final int ACCOUNT_STATUS_CANCEL=3;//被取消
    
    
    public static void downProduct(NpsWrapper wrapper){
      String cancel_art_id = "";
      String cancel_site_id = "itg";
      
      String sql = " select id,title from article where state = 3 and publishdate + validdays < sysdate and validdays >0 ";
      PreparedStatement pstmt = null;
      ResultSet rs = null;
      try{
        pstmt = wrapper.GetContext().GetConnection().prepareStatement(sql);
        rs = pstmt.executeQuery();
        while(rs.next()){
          cancel_art_id = rs.getString("id");
          wrapper.GetSite(cancel_site_id);
          NormalArticle art = wrapper.GetArticle(cancel_art_id);
          //没有发布，不用撤销
          if(art.GetState() == 3){
            art.Cancel();
             //重建栏目所有页面模板
            wrapper.GenerateAllPages(art.GetTopic());

            //重建所有从栏目
            Hashtable topic_slaves = art.GetSlaveTopics();
            if(topic_slaves!=null && !topic_slaves.isEmpty()){
                Enumeration enum_topic_slaves = topic_slaves.elements();
                while(enum_topic_slaves.hasMoreElements()){
                    Topic t = (Topic)enum_topic_slaves.nextElement();
                    wrapper.GenerateAllPages(t);
                }
            }
            art.ChangeState(8);                          
            //System.out.println("【"+rs.getString("id")+"】已经下架");   
          }
        }
      }
      catch(Exception e)
      {
          if(wrapper!=null) wrapper.Rollback();
          e.printStackTrace();
      }
  
    }

    public static String getStatus(int status){
        switch(status){
            case ACCOUNT_STATUS_NORMAL:
                return "正在处理";
            case ACCOUNT_STATUS_END:
                return "结束";
            case ACCOUNT_STATUS_CANCEL:
                return "被取消";
            default:
                return "未知";
        }
    }

    private static long temp_id = 0l;
    private static java.text.DecimalFormat unidFormat = new java.text.DecimalFormat(
            "0000000000");
    public static final long one_hour = 60 * 60 * 1000;
    static final public int BLOCK_SIZE = 256;

    /**
     * 生成36位unid YYYYMMddHHmmss(14位) + 12位随机数 + 10位计数器
     */
    public final static synchronized String createUNID() {
        Calendar cal = Calendar.getInstance();
        String id;
        String random = Double.toString((new Random()).nextDouble()).substring(
                2, 14);
        temp_id++;

        // 保证random 14位长
        if (random.length() < 12)
            random = "0000" + unidFormat.format(cal.getTime().getTime());

        id = formatDate(cal, "YYYYMMddHHmmss") + random
                + unidFormat.format(temp_id);
        if (id.length() > 36) id = id.substring(id.length() - 36);
        id = id.replace(' ', 'x');
        return id;
    }

    /**
     * 格式化时间
     *
     * @param dt
     * @param format 支持YYYY YY MM mm dd SS几种组合的格式化(MM 月份 mm分钟)
     * @return 格式化后的字符串
     */
    public static String formatDate(java.util.Date dt, String format) {
        java.util.Calendar cal = null;
        if (dt != null) cal = java.util.Calendar.getInstance();
        cal.setTime(dt);
        return formatDate(cal, format);
    }

    /**
     * 格式化时间
     *
     * @param cal
     * @param format 支持YYYY YY MM mm dd SS几种组合的格式化(MM 月份 mm分钟)
     * @return 格式化后的字符串
     */
    public static String formatDate(java.util.Calendar cal, String format) {
        if (cal == null) return null;
        int year = cal.get(Calendar.YEAR);
        int month = cal.get(Calendar.MONTH) + 1;
        int date = cal.get(Calendar.DATE);
        int hour24 = cal.get(Calendar.HOUR_OF_DAY);
        int hour = cal.get(Calendar.HOUR);
        int min = cal.get(Calendar.MINUTE);
        int sec = cal.get(Calendar.SECOND);

        if (format == null) return null;

        String tmp = Integer.toString(year);
        format = replaceAll(format, "YYYY", tmp);
        format = replaceAll(format, "yyyy", tmp);

        if (format.indexOf("YY") >= 0) {
            tmp = Integer.toString(year).substring(2);
            format = replaceAll(format, "YY", tmp);
        }

        if (format.indexOf("MM") >= 0) {
            tmp = Integer.toString(month);
            if (tmp.length() == 1) tmp = "0" + tmp;
            format = replaceAll(format, "MM", tmp);
        }
        if (format.indexOf("M") >= 0) {
            tmp = Integer.toString(month);
            format = replaceAll(format, "M", tmp);
        }

        if (format.indexOf("dd") >= 0) {
            tmp = Integer.toString(date);
            if (tmp.length() == 1) tmp = "0" + tmp;
            format = replaceAll(format, "dd", tmp);
        }
        if (format.indexOf("DD") >= 0) {
            tmp = Integer.toString(date);
            if (tmp.length() == 1) tmp = "0" + tmp;
            format = replaceAll(format, "DD", tmp);
        }
        if (format.indexOf("d") >= 0) {
            tmp = Integer.toString(date);
            format = replaceAll(format, "d", tmp);
        }
        if (format.indexOf("D") >= 0) {
            tmp = Integer.toString(date);
            format = replaceAll(format, "D", tmp);
        }

        if (format.indexOf("HH") >= 0) {
            tmp = Integer.toString(hour24);
            if (tmp.length() == 1) tmp = "0" + tmp;
            format = replaceAll(format, "HH", tmp);
        }

        if (format.indexOf("hh") >= 0) {
            tmp = Integer.toString(hour);
            if (tmp.length() == 1) tmp = "0" + tmp;
            format = replaceAll(format, "hh", tmp);
        }

        if (format.indexOf("mm") >= 0) {
            tmp = Integer.toString(min);
            if (tmp.length() == 1) tmp = "0" + tmp;
            format = replaceAll(format, "mm", tmp);
        }

        if (format.indexOf("ss") >= 0) {
            tmp = Integer.toString(sec);
            if (tmp.length() == 1) tmp = "0" + tmp;
            format = replaceAll(format, "ss", tmp);
        }
        if (format.indexOf("SS") >= 0) {
            tmp = Integer.toString(sec);
            if (tmp.length() == 1) tmp = "0" + tmp;
            format = replaceAll(format, "SS", tmp);
        }
        return format;
    }

    /**
     * 把srcStr中的所有str1字符串替换成str2 @ param src
     *
     * @return
     */
    public static String replaceAll(String srcStr, String str1, String str2) {
        if (srcStr == null || str1 == null || str2 == null) return null;
        StringBuffer buf = new StringBuffer();
        int beginIndex = 0, index = 0;
        int str1_length = str1.length();
        if (str1_length == 0) return srcStr;

        while (true) {
            index = srcStr.indexOf(str1, beginIndex);
            if (index < 0) break;
            buf.append(srcStr.substring(beginIndex, index));
            beginIndex = index + str1_length;
            buf.append(str2);
        }
        buf.append(srcStr.substring(beginIndex));

        return buf.toString();
    }

    public static int[] getStatusList(){
        return new int[]{1,2,3};
    }

    /**
     * 印章文件扩展名
     */
    public static final String STAMP_EXT="gif";

    public static final DecimalFormat DF_ZERO          = new DecimalFormat("#0");

    public static final DecimalFormat DF_ONE           = new DecimalFormat("#0.0");

    public static final DecimalFormat DF_TWO           = new DecimalFormat("#0.00");

    /**
     * 合同内容类型 1 产品
     */
    public static int ITEM_TYPE_PRODUCT=1;
    /**
     * 合同内容类型 1 零件
     */
    public static int ITEM_TYPE_PART=2;

    /**
     * 判断一个字符串是否为空值
     * @param str 待判断的字符串
     * @return 当str==null或者经过str.trim()处理后长度小于等于0时返回true,否则返回false
     */
    public static boolean isEmpty(String str){
        if(str==null||str.trim().length()<=0) return true;
        return false;
    }


    public static String getSequenceValue(Connection con,String seqName,int length,String lpad) throws JError {
        PreparedStatement pstmt=null;
        ResultSet rs=null;
        String sql=null;
        String val=null;
        sql="select lpad("+seqName+".Nextval,?,?) from dual ";
        try{
            pstmt=con.prepareStatement(sql);
            pstmt.setInt(1,length);
            pstmt.setString(2,lpad);
            rs=pstmt.executeQuery();
            if(rs.next()) val=rs.getString(1);
        }
        catch(Exception ex){
            JLog.getLogger().error("读取流水号("+seqName+")时出错",ex);
            throw new JError("读取流水号("+seqName+")时出错");
        }
        finally{
            if(rs!=null) try{rs.close();}catch(Exception ex){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return val;
    }

    public static String getSequenceValue(Connection con,String seqName) throws JError {
        PreparedStatement pstmt=null;
        ResultSet rs=null;
        String sql=null;
        String val=null;
        sql="select "+seqName+".Nextval from dual ";
        try{
            pstmt=con.prepareStatement(sql);
            rs=pstmt.executeQuery();
            if(rs.next()) val=rs.getString(1);
        }
        catch(Exception ex){
            JLog.getLogger().error("读取流水号("+seqName+")时出错",ex);
            throw new JError("读取流水号("+seqName+")时出错");
        }
        finally{
            if(rs!=null) try{rs.close();}catch(Exception ex){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return val;
    }
    public static Integer getSequenceIntegerValue(Connection con,String seqName) throws JError {
      PreparedStatement pstmt=null;
      ResultSet rs=null;
      String sql=null;
      Integer val=null;
      sql="select "+seqName+".Nextval from dual ";
      try{
          pstmt=con.prepareStatement(sql);
          rs=pstmt.executeQuery();
          if(rs.next()) val=rs.getInt(1);
      }
      catch(Exception ex){
          JLog.getLogger().error("读取流水号("+seqName+")时出错",ex);
          throw new JError("读取流水号("+seqName+")时出错");
      }
      finally{
          if(rs!=null) try{rs.close();}catch(Exception ex){}
          if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
      }
      return val;
  }
    /**
     * 判断一个字符串是否不为空值
     * @param str 待判断的字符串
     * @return 当str==null或者经过str.trim()处理后长度小于等于0时返回true,否则返回false
     */
    public static boolean notEmpty(String str){
        if(str!=null&&str.trim().length()>0) return true;
        return false;
    }

    /**
     * 用于decode方法，供判断是否需要进行转码
     * -1 未初始化 0 不需要 1 需要
     */
    private static int needdecode=-1;//-1 未初始化 0 不需要 1 需要

    public static java.sql.Date getSqlDate(String datestr) throws JError {
        if(datestr==null||datestr.trim().length()<=0) return null;
        java.sql.Date date=null;
        try{
            date=new java.sql.Date(dateFormat.parse(datestr).getTime());
        }
        catch(Exception ex){
            JLog.getLogger().error("解析日期字符串["+datestr+"]时出现错误:",ex);
            throw new JError("解析日期字符串["+datestr+"]时出现错误!");
        }
        return date;
    }

    public static Integer getInteger(String intstr) throws JError {
        if(intstr==null||intstr.trim().length()<=0) return null;
        Integer intobj=null;
        try{
            intobj=new Integer(intstr);
        }
        catch(Exception ex){
            JLog.getLogger().error("解析整数字符串["+intstr+"]时出现错误:",ex);
            throw new JError("解析整数字符串["+intstr+"]时出现错误!");
        }
        return intobj;
    }
    public static Integer getInteger(String intstr,int i) throws JError {
      if(intstr==null||intstr.trim().length()<=0) return new Integer(i);
      Integer intobj=null;
      try{
          intobj=new Integer(intstr);
      }
      catch(Exception ex){
          JLog.getLogger().error("解析整数字符串["+intstr+"]时出现错误:",ex);
          throw new JError("解析整数字符串["+intstr+"]时出现错误!");
      }
      return intobj;
  }
    public static Double getDouble(String doublestr) throws JError {
      if(doublestr==null||doublestr.trim().length()<=0) return null;
      Double doubleobj=null;
      try{
          doubleobj=new Double(doublestr);
      }
      catch(Exception ex){
          JLog.getLogger().error("解析数字字符串["+doublestr+"]时出现错误:",ex);
          throw new JError("解析数字字符串["+doublestr+"]时出现错误!");
      }
      return doubleobj;
  }
    public static Double getDouble(String doublestr,double d) throws JError {
      if(doublestr==null||doublestr.trim().length()<=0) return new Double(d);
      Double doubleobj=null;
      try{
          doubleobj=new Double(doublestr);
      }
      catch(Exception ex){
          JLog.getLogger().error("解析数字字符串["+doublestr+"]时出现错误:",ex);
          throw new JError("解析数字字符串["+doublestr+"]时出现错误!");
      }
      return doubleobj;
  }

    public static String getString(Double val, DecimalFormat df,String nullstr){
        if(val==null) return nullstr;
        String retval=null;
        if(df==null) retval=String.valueOf(val.doubleValue());
        else retval=df.format(val.doubleValue());
        if(retval.charAt(0)=='.') retval="0"+retval;
        return retval;
    }

    public static String getString(double val, DecimalFormat df){
      if(df==null) return String.valueOf(val);
      return df.format(val);
    }
    public static String getString(Float val){
      return String.valueOf(val);
      
    }

    public static String getString(Double val,String nullstr){
        if(val==null) return nullstr;
        return String.valueOf(val.doubleValue());
    }

    public static String getString(Integer val,String nullstr){
        if(val==null) return nullstr;
        return String.valueOf(val.intValue());
    }

    public static String getString(String val,String nullstr){
        if(val==null||val.trim().length()<=0) return nullstr;
        return val;
    }

    public static String getString(java.util.Date val,String nullstr){
        if(val==null) return nullstr;
        return dateFormat.format(val);
    }

    public static String getString(java.util.Date val,SimpleDateFormat df,String nullstr){
        if(val==null) return nullstr;
        if(df==null) return dateFormat.format(val);
        return df.format(val);
    }

    /**
     * Descript: 判断一个int数字和一个Integer的整数值是否相等
     * @param int_val 基础数据类型int整数
     * @param val Integer类型的证书
     * @return 相等的话返回true,否则返回false
     */
    public static boolean equal(int int_val,Integer val){
        if(val==null) return false;
        return int_val==val.intValue();
    }

    /**
     * Description : 获取当前数据库时间字符串
     * @param con 数据库链接
     * @return  当前数据库时间经默认格式(yyyy-mm-dd)格式化后得到的日期字符串
     * @throws JError
     */
    public static String currentDateStr(Connection con) throws JError {
        return currentDateStr(con,dateFormat);
    }

    /**
     * Description :获取当前数据库时间字符串
     * @param con 数据库链接
     * @param sdf 日期格式化对象
     * @return 当前数据库时间经格式化后得到的日期字符串
     * @throws JError
     */
    public static String currentDateStr(Connection con,SimpleDateFormat sdf) throws JError {
        if(sdf==null) throw new JError("必须指定日期格式化参数!");
        PreparedStatement pstmt=null;
        ResultSet rs=null;
        String sql=null;
        String val=null;
        java.sql.Date dt=null;
        sql="select sysdate from dual ";
        try{
            pstmt=con.prepareStatement(sql);
            rs=pstmt.executeQuery();
            if(rs.next()){
                dt=rs.getDate(1);
                val=sdf.format(dt);
            }
        }
        catch(Exception ex){
            JLog.getLogger().error("读取当前系统时间时出错",ex);
            throw new JError("读取当前系统时间时出错");
        }
        finally{
            if(rs!=null) try{rs.close();}catch(Exception ex){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return val;
    }

    /**
     * Description :获取当前数据库时间
     * @param con 数据库链接
     * @return 返回数据库当前时间对象
     * @throws JError
     */
    public static java.sql.Date currentDate(Connection con) throws JError {
        PreparedStatement pstmt=null;
        ResultSet rs=null;
        String sql=null;
        java.sql.Date dt=null;
        sql="select sysdate from dual ";
        try{
            pstmt=con.prepareStatement(sql);
            rs=pstmt.executeQuery();
            if(rs.next()){
                dt=rs.getDate(1);
            }
        }
        catch(Exception ex){
            JLog.getLogger().error("读取当前系统时间时出错",ex);
            throw new JError("读取当前系统时间时出错");
        }
        finally{
            if(rs!=null) try{rs.close();}catch(Exception ex){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return dt;
    }

    /**
     * Description :获取当前数据库时间的年份
     * @param con 数据库链接
     * @return 返回数据库当前时间对象
     * @throws JError
     */
    public static int currentYear(Connection con) throws JError {
        PreparedStatement pstmt=null;
        ResultSet rs=null;
        String sql=null;
        int year=-1;
        sql="select to_char(sysdate,'yyyy') from dual ";
        try{
            pstmt=con.prepareStatement(sql);
            rs=pstmt.executeQuery();
            if(rs.next()){
                year=rs.getInt(1);
            }
        }
        catch(Exception ex){
            JLog.getLogger().error("读取当前系统时间时出错",ex);
            throw new JError("读取当前系统时间时出错");
        }
        finally{
            if(rs!=null) try{rs.close();}catch(Exception ex){}
            if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
        }
        return year;
    }

    /**
     * 分析属性字符串，例如 type:0|name:xzhrboy|sex:male
     * @param srcStr 属性字符串
     * @param record 记录分隔符
     * @param field 字段分隔符
     * @return 代表属性名和对应值的Hashtable对象
     */
    public static Hashtable parseProperties(String srcStr, char record,char field) {
        Hashtable props=null;
        int start = 0, index = 0;
        index = srcStr.indexOf(record, start);
        while (index >= 0) {
            String recordstr=srcStr.substring(start, index);
            if(notEmpty(recordstr)){
                int fieldindex=recordstr.indexOf(field,0);
                String key=recordstr.substring(0,fieldindex);
                String val=recordstr.substring(fieldindex+1);
                if(props==null) props=new Hashtable();
                props.put(key.trim().toUpperCase(),val.trim());
            }
            start = index + 1;
            index = srcStr.indexOf(record, start);
        }
        String recordstr=srcStr.substring(start);
        if(notEmpty(recordstr)){
            int fieldindex=recordstr.indexOf(field,0);
            String key=recordstr.substring(0,fieldindex);
            String val=recordstr.substring(fieldindex+1);
            if(props==null) props=new Hashtable();
            props.put(key.trim().toUpperCase(),val.trim());
        }
        return props;
    }

    public static void deleteFile(String filepath){
        if(Pub.isEmpty(filepath)) return;
        try{
            File file=new File(filepath);
            if(file.exists()&&file.isFile()){
                if(!file.delete()){
                    file.deleteOnExit();
                }
            }
        }catch(Exception ex){
            JLog.getLogger().error("删除文件["+filepath+"]的时候出现错误",ex);
        }
    }

    /** *********** ******************** */
    /**
     * 将字符串按分隔符delim分隔
     *
     * @param srcStr
     * @param delim
     * @return 按分隔符分隔的字符串对象向量表
     */
    public static Vector token(String srcStr, String delim) {
        java.util.Vector resultVect = new java.util.Vector();
        int start = 0, index = 0;
        index = srcStr.indexOf(delim, start);
        while (index >= 0) {
            resultVect.add(srcStr.substring(start, index));
            start = index + delim.length();
            index = srcStr.indexOf(delim, start);
        }
        resultVect.add(srcStr.substring(start));

        return resultVect;
    }

    /** *********** ******************** */
    /**
     * 将字符串按分隔符delim分隔
     *
     * @param srcStr
     * @param delim
     * @return 按分隔符分隔的字符串对象向量表
     */
    public static Vector token(String srcStr, char delim) {
        java.util.Vector resultVect = new java.util.Vector();
        int start = 0, index = 0;
        index = srcStr.indexOf(delim, start);
        while (index >= 0) {
            resultVect.add(srcStr.substring(start, index));
            start = index + 1;
            index = srcStr.indexOf(delim, start);
        }
        resultVect.add(srcStr.substring(start));

        return resultVect;
    }

    /**
     * 把字符串转换为html格式 不支持html
     */
    public static String strToHtml(String text,String nullstr) {
        if (text == null || text.length() == 0) return nullstr;
        StringBuffer rBuf = new StringBuffer();
        boolean newLine = true; // 新行标记 直到出现非' '字符转换为false

        for (int i = 0; i < text.length(); i++) {
            char ch = text.charAt(i);
            if (newLine && ch != ' ') newLine = false;

            switch (ch) {
                case ' ':
                    if (i == 0) {
                        rBuf.append("&nbsp;");
                    } else {
                        if (text.charAt(i - 1) == ' ') rBuf.append("&nbsp;");
                        else {
                            rBuf.append(' ');
                        }
                    }
                    break;
                case '&':
                    rBuf.append("&amp;");
                    break;
                case '>':
                    rBuf.append("&gt;");
                    break;
                case '<':
                    rBuf.append("&lt;");
                    break;
                case '"':
                    rBuf.append("&quot;");
                    break;
                case '\n':
                    rBuf.append("<br>");
                    newLine = true;
                    break;
                default:
                    rBuf.append(ch);
            }
        }
        return rBuf.toString();
    }
}

