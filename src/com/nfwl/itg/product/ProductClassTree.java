package com.nfwl.itg.product;

import org.jdom.Element;

import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.util.TreeMap;
import java.util.ArrayList;

import com.gemway.skin.Skin;
import com.gemway.partner.JUtil;

/**
 * Created by IntelliJ IDEA.
 * User: Administrator
 * Date: 2005-4-5
 * Time: 10:30:26
 * To change this template use Options | File Templates.
 */
public class ProductClassTree {
  private static final String IMAGEFILE = "nodelevel";
  private static final String ROOTID = "root";

  /**
   *constructor
   */
  public ProductClassTree()
  {
  }

  /**
   * @param conn
   * @param sql
   * @return  element(tree)
   * @throws Exception
   */
    public static Element getProductClassTree(Connection conn, String sql) throws Exception
    {
      String id = null;
      String pid = null;
      String name = "";
      Statement stmt = null;
      ResultSet res = null;
        String caption ="";
        String target= "_self";
        String target_page_url = "";

      if(conn == null)throw new Exception("无法连接数据源。");
      //Vector orgn_vec = new Vector();
      TreeMap recd_has = new TreeMap();
        TreeMap orgn_has = new TreeMap();
      ArrayList sortid = new ArrayList();

      Element root = new Element("root");
      root.setAttribute("id", ROOTID);
      root.setAttribute("parentId", ROOTID);
      root.setAttribute("icon", "<input type='checkbox' name='chkall' value=''  onClick='checkAll()'>");
      root.setAttribute("caption", "产品类别");
      root.setAttribute("target", "_self");
      root.setAttribute("url", "");

        String sqlQry = "select id ps_id,parentid ps_pid,name ps_name from topic where is_business = 1  ";
      if(sql != null && sql.trim().length() > 0) sqlQry = sql;

      try
      {
          stmt = conn.createStatement();
          res = stmt.executeQuery(sqlQry);
          while(res.next())
          {
            id = res.getString("ps_id");
            pid = JUtil.convertNull(res.getString("ps_pid"));
            name = JUtil.convertNull(res.getString("ps_name"));
            Element tmp_this_elm = new Element("node");
            tmp_this_elm.setAttribute("id", id);
            tmp_this_elm.setAttribute("parentid", pid);
            tmp_this_elm.setAttribute("caption", name);
            tmp_this_elm.setAttribute("target", target);
            tmp_this_elm.setAttribute("level", "1");
              tmp_this_elm.setAttribute("icon", "<input type='checkbox' name='productClass' value='" + id + "'><input type='hidden' name='productClassName' value='"+name+"' >");
            tmp_this_elm.setAttribute("url", "");

                //如果是根节点就自动加入到根节点列表中
                if(pid==null || pid.length()==0)
            {
                root.addContent(tmp_this_elm);
              recd_has.put(id,tmp_this_elm);
            }
            else{
                    //orgn_vec.add(id);
                  sortid.add(id);
                    orgn_has.put(id,tmp_this_elm);
                }
          }
        }
      finally
      {
          if(res != null)try {res.close(); } catch(Exception res_e) {}
          if(stmt != null)try{stmt.close();} catch(Exception stmt_e) {}
      }

      //Enumeration e = orgn_vec.keys();
    for(int i=0; i < sortid.size(); i++)
    {
      id=(String)sortid.get(i);
            if(procDoc(orgn_has, recd_has,id, root) == null) continue;
        }
      //while(e.hasMoreElements())
      //{
      //  id = (String)(e.nextElement());
      //  if(procDoc(orgn_has, recd_has, id, root, skin) == null) continue;
      //}

      return root;
    }

  /**
   * @param orgn_has
   * @param recd_has
   * @param id
   * @param root
   * @return
   */
  private static Element procDoc(TreeMap orgn_has,TreeMap recd_has, String id, Element root){
      String pid = null, name=null;
      int level = 0;
      Element tmp_this_elm = (Element)(orgn_has.get(id));
      if(tmp_this_elm == null)return null;
      orgn_has.remove(id);
      if(recd_has.get(id) == null) recd_has.put(id, tmp_this_elm);
      pid = tmp_this_elm.getAttribute("parentid").getValue().trim();
      name = tmp_this_elm.getAttribute("caption").getValue().trim();
      Element tmp_parent_elm = null;
      if(pid.length() == 0){
          level = 1;
      }
      else  {
          tmp_parent_elm = (Element)(orgn_has.get(pid));
          if(tmp_parent_elm == null)
              tmp_parent_elm = (Element)(recd_has.get(pid)); //确认是否已经从orgn_has中删除，移到recd_has中
          else
          tmp_parent_elm = procDoc(orgn_has, recd_has, pid, tmp_this_elm);
          if(tmp_parent_elm == null)
              level = 1;
          else
              level = Integer.parseInt(tmp_parent_elm.getAttribute("level").getValue()) + 1;
      }

      tmp_this_elm.setAttribute("level", String.valueOf(level));
      tmp_this_elm.setAttribute("icon", "<input type='checkbox' name='productClass' value='" + id + "'> <input type='hidden' name='productClassName' value='"+name+"' >");
      try{
          if(tmp_parent_elm==null){
              root.addContent(tmp_this_elm);
          }
          else{
              tmp_parent_elm.addContent(tmp_this_elm);
          }
      }
      catch(Exception e){
      }

      return tmp_this_elm;
  }
}
