<%@ page language = "java" contentType = "text/xml;charset=UTF-8" errorPage="/error.jsp"%>
<%@ page import="java.util.Vector" %>
<%@ page import="nps.core.*" %>

<%@ include file = "/include/header.jsp" %>

<Templates imagesBasePath="/userdir/fcktemplate/">
<%
    request.setCharacterEncoding("UTF-8");

    NpsWrapper wrapper = null;
    try
    {
        wrapper = new NpsWrapper(user);
        Vector<FCKTemplate> v_templates = FCKTemplateManager.GetAllTemplates(wrapper.GetContext(),user.GetUnitId());
        for(FCKTemplate template:v_templates)
        {
%>
          <Template title="<%=template.GetTitle()%>" image="<%=template.GetId()+".jpg"%>">
              <Description><%=template.GetDescription()%></Description>
              <Html>
                  <![CDATA[
                     <% template.GetHtml(wrapper.GetContext(),out); %>
                  ]]>
              </Html>
          </Template>
<%
        }
    }
    finally
    {
        if(wrapper!=null) wrapper.Clear();
    }
%>
</Templates>