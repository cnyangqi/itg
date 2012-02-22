package com.nfwl.itg.product;


import com.jado.JLog;
import com.gemway.util.JUtil;
import com.jado.JadoException;
import com.nfwl.itg.product.ITG_PRODUCTSORT;//ITG_PRODUCTSORT;
import org.jdom.Element;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.TreeMap;

/**
 * Created by IntelliJ IDEA.
 * product: Administrator
 * Date: 2005-4-5
 * Time: 17:13:59
 * To change this template use Options | File Templates.
 */
public class ProductTree {
  private static final String IMAGEFILE = "nodelevel";
  private static final String ROOTID = "root";
    private static Hashtable trees=null;

  /**
   *constructor
   */
  public ProductTree()
  {
  }


    public static Element getProductTree(Connection conn,String sql)throws Exception{
        return getProductTree(conn,sql,false);
    }
   /**
   * @param conn
   * @param sql
   * @return  element(tree)
   * @throws Exception
   */
    public static Element getProductTree(Connection conn, String sql,boolean onlyone) throws Exception
    {
        String key=onlyone+sql;
        if(trees!=null){
            Element tree=(Element)trees.get(key);
            if(tree!=null) return tree;
        }
        System.out.println("取数据!");
        String id = null;
      String pid = null;
      String name = "";
      Statement stmt = null;
        PreparedStatement pstmt  = null;
      ResultSet res=null, rs = null;
        String caption ="";
        String target= "_self";
        String target_page_url = "";
        Hashtable pc_list = new Hashtable();
        Element tmp_this_elm = null;

      if(conn == null)throw new Exception("无法连接数据源。");
      //Vector orgn_vec = new Vector();
      TreeMap recd_has = new TreeMap();
        TreeMap orgn_has = new TreeMap();

      Element root = new Element("root");
      root.setAttribute("id", ROOTID);
      root.setAttribute("parentId", ROOTID);
        if(onlyone) root.setAttribute("icon","");
        else  root.setAttribute("icon", "");
      root.setAttribute("caption", "果蔬品种");
      root.setAttribute("target", "_self");
      root.setAttribute("url", "");

        String sqlQry = "";//"select PRC_PC_ID, PC_PID, PC_NAME from ITG_PRODUCTSORT where PRC_PC_ID<>'-1' order by UNIT_CODE   ";
      if(sql != null && sql.trim().length() > 0) sqlQry = sql;

      try
      {
          stmt = conn.createStatement();
//System.out.print("sqlQry==="+sqlQry);
          res = stmt.executeQuery(sqlQry);
          while(res.next())
          {
            id = res.getString("PRD_ID");
            pid = JUtil.convertNull(res.getString("PRD_PC_ID"));
            name = JUtil.convertNull(res.getString("PRD_NAME"));
            tmp_this_elm = new Element("node");
            tmp_this_elm.setAttribute("id", id);
            tmp_this_elm.setAttribute("parentid", pid);
            tmp_this_elm.setAttribute("caption", name);
            tmp_this_elm.setAttribute("target", target);
            tmp_this_elm.setAttribute("level", "1");
              tmp_this_elm.setAttribute("icon", "<input type='"+(onlyone?"radio":"checkbox")+"' name='product' value='" + id + "' "+(onlyone?"onClick='javascript:doChoose();'":"")+"><input type='hidden' name='PRD_PC_ID' value='"+pid+"' ><input type='hidden' name='product_name' value='"+name+"' >");
            tmp_this_elm.setAttribute("url", "");

                if(pid==null || pid.length()==0)
                {
                    root.addContent(tmp_this_elm);
                    recd_has.put(id,tmp_this_elm);
                }
                else{
                    //orgn_vec.add(id);
                    orgn_has.put(id,tmp_this_elm);
                }

                pc_list.put(pid, pid);
            }
System.out.println("unit_list.size==="+pc_list.size());

            //取所有相关单位
            Enumeration  enum1 = pc_list.keys();
            pc_list = new Hashtable();
            Hashtable pcshash= ITG_PRODUCTSORT.getsHashtable(conn);
            while(enum1.hasMoreElements())
            {
                pid = (String)enum1.nextElement();
                //sqlQry="select PC_NAME,PC_PID from ITG_PRODUCTSORT where PC_ID=?";
                //pstmt=conn.prepareStatement(sqlQry);
                while(true){
                    //pstmt.setString(1,pid);
                    //rs=pstmt.executeQuery();
                    ITG_PRODUCTSORT npcobj=(ITG_PRODUCTSORT)pcshash.get(pid);
                    if(npcobj!=null){
                        id = pid;
                        //pid = JUtil.convertNull(rs.getString("PC_PID"));
                        //name = JUtil.convertNull(rs.getString("PC_NAME"));
                        pid = JUtil.convertNull(npcobj.getPid());
                        name = JUtil.convertNull(npcobj.getName());
                        tmp_this_elm = new Element("node");
                        tmp_this_elm.setAttribute("id", id);
                        tmp_this_elm.setAttribute("parentid", pid);
                        tmp_this_elm.setAttribute("caption", name);
                        tmp_this_elm.setAttribute("target", target);
                        tmp_this_elm.setAttribute("level", "1");
                       // if(onlyone) tmp_this_elm.setAttribute("icon", "<img src='/images/default/treeview/nodelevel2.gif'>");
                        tmp_this_elm.setAttribute("icon", "");
                        tmp_this_elm.setAttribute("url", "");
                    }

                    if(pc_list.get(id) == null){
                      pc_list.put(id, id);
                        //如果是根节点就自动加入到根节点列表中
                        if(pid==null || pid.length()==0)
                        {
                            root.addContent(tmp_this_elm);
                            recd_has.put(id,tmp_this_elm);
                            break;
                        }
                        else{
                            //orgn_vec.add(id);
                            orgn_has.put(id,tmp_this_elm);
                        }
                    }
                    else
                    {
                         if(pid==null || pid.length()==0) break;
                    }
                }
            }
        }
        catch(Exception e){
            JLog.getLogger().error(JLog.getExceptionInfo(e));
            throw new JadoException("在用户建树时,出现未知错误!");
        }
      finally
      {
            if(rs != null)try {rs.close(); } catch(Exception res_e) {}
          if(pstmt != null)try{pstmt.close();} catch(Exception stmt_e) {}
          if(res != null)try {res.close(); } catch(Exception res_e) {}
          if(stmt != null)try{stmt.close();} catch(Exception stmt_e) {}
      }

      while(orgn_has.size() > 0)
      {
            id=(String)orgn_has.firstKey();
            if(procDoc(orgn_has, recd_has,id, root) == null) continue;
        }
        if(trees==null) trees=new Hashtable();
        trees.put(key,root);
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
      //tmp_this_elm.setAttribute("icon", "<input type='checkbox' name='unit' value='" + id + "'>");
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
