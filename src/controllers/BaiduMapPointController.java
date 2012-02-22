package controllers;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;


import com.et.mvc.JsonView;
import com.et.mvc.View;
import models.BaiduMapPointModels;

import com.gemway.partner.JDatabase;
import com.gemway.partner.JLog;
import com.gemway.util.JError;

public class BaiduMapPointController extends ApplicationController{
  
  
  
  public static String getBusinessJsonScript(BaiduMapPointModels bmp){
    bmp.content = "名称："+bmp.title+"<br />";
    bmp.content += "联系人："+bmp.linkman+"<br />";
    bmp.content += "联系手机："+bmp.mobile+"<br />";
    bmp.content += "联系电话："+bmp.telephone+"<br />";
    bmp.content += "主营业务："+bmp.business+"<br />";
    bmp.content += "地址："+bmp.address+"<br />";
    String script = "{title:\""+bmp.title+"\",content:\""+bmp.content+"\",point:\""+bmp.longitude+"|"+bmp.latitude+"\",isOpen:"+bmp.isOpen
        +",icon:{w:"+bmp.tagWidth+",h:"+bmp.tagHeight+",l:"+bmp.tagIcon+",t:"+bmp.parameterT+",x:"+bmp.parameterX+",lb:"+bmp.parameterLB+"}}";
    return script;
  }
  public static String getJsonScript(BaiduMapPointModels bmp){
    String script = "{title:\""+bmp.title+"\",content:\""+bmp.content+"\",point:\""+bmp.longitude+"|"+bmp.latitude+"\",isOpen:"+bmp.isOpen
        +",icon:{w:"+bmp.tagWidth+",h:"+bmp.tagHeight+",l:"+bmp.tagIcon+",t:"+bmp.parameterT+",x:"+bmp.parameterX+",lb:"+bmp.parameterLB+"}}";
    return script;
  }
  /**
   * 返回全部用户资料
   */
  public View getUsers() throws Exception{
    Map<String,Object> result = new HashMap<String,Object>();
    if(points == null){
      
      Connection con = null;
      try {
        con = JDatabase.getJDatabase().getConnection();
        points = getBMPS(con, null, null, null);
        
      }catch(Exception e){
        
      }finally{
        if(con!=null) try{con.close();}catch(Exception e){}
      }
    }
    
    result.put("total", points.size());
    result.put("rows", points);
    
    return new JsonView(result);
  }
  
  
  public View getUsers(Integer tp,String csbm,String title) throws Exception{
    Map<String,Object> result = new HashMap<String,Object>();
      
      Connection con = null;
      try {
        con = JDatabase.getJDatabase().getConnection();
        points = getBMPS(con, tp, csbm, title);
        
      }catch(Exception e){
        e.printStackTrace();
      }finally{
        if(con!=null) try{con.close();}catch(Exception e){}
      }
    
    result.put("total", points.size());
    result.put("rows", points);
    
    return new JsonView(result);
  }
  /**
   * 
   * @param con
   * @param tp 类型
   * @param csbm 城市编码
   * @param title 标题
   * @return
   * @throws JError 
   */
  public static ArrayList<BaiduMapPointModels> getBMPS(Connection con,Integer tp,String csbm,String title) throws JError{
    ArrayList<BaiduMapPointModels> albmps = null;

    PreparedStatement pstmt=null;
    ResultSet rs = null;
    BaiduMapPointModels bmp = null;
    try{
        String sql= "select id, title, type, longitude, latitude,content, tagicon, tagwidth, tagheight, isopen, parametert " +
            ", parameterx, parameterlb, linkman, mobile, telephone, business, memo, csbm, creater, creatername, createtime,address " +
            " from baidumappoint where 1=1 ";
        if(tp!=null){
          sql +=" and type = ? ";
        }
        if(csbm!=null){
          sql +=" and csbm = ? ";
        }
        if(title!=null){
          sql +=" and title like ? ";
        }
        
        pstmt=con.prepareStatement(sql);
        
        int pos = 1;
        if(tp!=null){
          pstmt.setInt(pos++,tp);
        }
        if(csbm!=null){
          pstmt.setString(pos++,csbm);
        }
        if(title!=null){
          pstmt.setString(pos++,"%"+title+"%");
        }
        rs  = pstmt.executeQuery();
        while(rs.next()){
          if(albmps ==null ) albmps = new ArrayList<BaiduMapPointModels>();
          bmp = new BaiduMapPointModels();
          bmp.setId(rs.getString("id"));
          bmp.setTitle(rs.getString("title"));
          bmp.setType(rs.getInt("type"));
          bmp.setLongitude(rs.getDouble("longitude"));
          bmp.setLatitude(rs.getDouble("latitude"));
          bmp.setContent(rs.getString("content"));
          bmp.setTagIcon(rs.getInt("tagicon"));
          bmp.setTagWidth(rs.getInt("tagwidth"));
          bmp.setTagHeight(rs.getInt("tagheight"));
          bmp.setIsOpen(rs.getInt("isopen"));
          bmp.setParameterT(rs.getInt("parametert"));
          bmp.setParameterX(rs.getInt("parameterx"));
          bmp.setParameterLB(rs.getInt("parameterlb"));
          bmp.setLinkman(rs.getString("linkman"));
          bmp.setMobile(rs.getString("mobile"));
          bmp.setTelephone(rs.getString("telephone"));
          bmp.setBusiness(rs.getString("business"));
          bmp.setMemo(rs.getString("memo"));
          bmp.setCsbm(rs.getString("csbm"));
          bmp.setCreater(rs.getString("creater"));
          bmp.setCreatername(rs.getString("creatername"));
          bmp.setCreatetime(rs.getDate("createtime"));
          bmp.setAddress(rs.getString("address"));
          
          albmps.add(bmp);
        }
    }
    catch(Exception ex){
        if(ex instanceof JError) throw (JError)ex;
        JLog.getLogger().error("写入地图信息点（baidumappoint）时出错:",ex);
        throw new JError("写入写入地图信息点（baidumappoint时出错！");
    }
    finally{
        if(rs!=null) try{rs.close();}catch(Exception ex){}
        if(pstmt!=null) try{pstmt.close();}catch(Exception ex){}
    }

    
    return albmps;
  }
  /**
   * 取得指定的用户资料
   */
  public View getUser(String id) throws Exception{
    Connection con = null;
    BaiduMapPointModels bmp = null;
    try {
      con = JDatabase.getJDatabase().getConnection();
      //bmp = BaiduMapPointModels.get(con, id);
      
    }catch(Exception e){
      
    }finally{
      if(con!=null) try{con.close();}catch(Exception e){}
    }
    return new JsonView(bmp);
  }
  
  /**
   * 保存用户资料，这里对用户名称进行非空检验，仅供演示用
   */
  public View save(BaiduMapPointModels bmp) throws Exception{
    Map<String,Object> result = new HashMap<String,Object>();
    if (bmp.getTitle()==null||bmp.getTitle().length()==0){
      result.put("failure", true);
      result.put("msg", "名称必须填写。");
    } else {
      
      Connection con = null;
      
      try {
        con = JDatabase.getJDatabase().getConnection();
        //bmp.insert(con);
      }catch(Exception e){
        
      }finally{
        if(con!=null) try{con.close();}catch(Exception e){}
      }
      
      result.put("success", true);
      points.add(bmp);
    }
    View view = new JsonView(result);
    view.setContentType("text/html;charset=utf-8");
    return view;
  }
  
  /**
   * 更新指定的用户资料
   */
  public View update(Integer index) throws Exception{
    Map<String,Object> result = new HashMap<String,Object>();
    BaiduMapPointModels point = (BaiduMapPointModels) points.get(index-1);
    updateModel(point);
    if (point.getTitle().length() == 0){
      result.put("failure", true);
      result.put("msg", "名称必须填写。");
      Connection con = null;
      
      try {
        con = JDatabase.getJDatabase().getConnection();
        //point.update(con);
      }catch(Exception e){
        
      }finally{
        if(con!=null) try{con.close();}catch(Exception e){}
      }
      
    } else {
      result.put("success", true);
    }
    View view = new JsonView(result);
    view.setContentType("text/html;charset=GBK");
    return view;
  }
  
  // 用户资料测试数据
  private static ArrayList<BaiduMapPointModels> points = null;
  
}
