<%@ page language = "java" contentType = "text/html;charset=UTF-8"%>
<%@ page import="nps.module.tabs.TabModule" %>

<%@ include file = "/include/header.jsp" %>

<%
   request.setCharacterEncoding("UTF-8");
   java.util.ResourceBundle module_bundle = java.util.ResourceBundle.getBundle("langs.jsp_visualtemplate",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);

   String tabs_id = request.getParameter("tabs_id");
   String tab_id = request.getParameter("tab_id");
   TabModule module = (TabModule)request.getAttribute("module");
%>
<DIV id="<%=module.HTML_Div()%>" class=mod>
    <DIV class=ctrlbar>
        <DIV id="<%=module.HTML_Dragbar()%>" class=dragbar>
            <DIV class=moduletype>
                <SPAN style="BACKGROUND: url(<%=module.GetIcon()%>) no-repeat left center" id=<%=module.HTML_Type()%>><%=module.GetDisplayType()%></SPAN>
            </DIV>
            <UL class=buttons>
                <LI>
                    <DIV id="<%=module.HTML_ButtonDelete()%>">
                        <A title="<%=module_bundle.getString("TEMPLATE_DELETE_HINT")%>" onclick="tabseditor_<%=tabs_id%>.removeModule('<%=tab_id%>','<%=module.GetId()%>'); return false;" href="#">
                            <IMG src="/images/modules/editor_delete.gif">
                        </A>
                    </DIV>
                </LI>
                <LI>
                    <DIV id="<%=module.HTML_ButtonUp()%>">
                        <A title="<%=module_bundle.getString("TEMPLATE_UP_HINT")%>" onclick="tabseditor_<%=tabs_id%>.moveModuleUp('<%=tab_id%>','<%=module.GetId()%>'); return false;" href="#">
                            <IMG src="/images/modules/editor_up.gif">
                        </A>
                    </DIV>
                </LI>
                <LI>
                    <DIV id="<%=module.HTML_ButtonDown()%>">
                        <A title="<%=module_bundle.getString("TEMPLATE_DOWN_HINT")%>" onclick="tabseditor_<%=tabs_id%>.moveModuleDown('<%=tab_id%>','<%=module.GetId()%>'); return false;" href="#">
                            <IMG src="/images/modules/editor_down.gif">
                        </A>
                    </DIV>
                </LI>
                <LI>
                    <DIV id="<%=module.HTML_ButtonRight()%>">
                        <A title="<%=module_bundle.getString("TEMPLATE_FLOATRIGHT_HINT")%>" onclick="tabseditor_<%=tabs_id%>.moveModuleRight('<%=tab_id%>','<%=module.GetId()%>'); return false;" href="#">
                            <IMG src="/images/modules/editor_float.gif">
                         </A>
                    </DIV>
                </LI>
                <LI>
                    <DIV id="<%=module.HTML_ButtonLeft()%>">
                        <A title="<%=module_bundle.getString("TEMPLATE_FLOATLEFT_HINT")%>" onclick="tabseditor_<%=tabs_id%>.moveModuleLeft('<%=tab_id%>','<%=module.GetId()%>'); return false;" href="#">
                            <IMG src="/images/modules/editor_left.gif">
                         </A>
                    </DIV>
                </LI>
                <LI>
                    <DIV id="<%=module.HTML_ButtonFull()%>">
                        <A title="<%=module_bundle.getString("TEMPLATE_FLOATNONE_HINT")%>" onclick="tabseditor_<%=tabs_id%>.moveModuleCenter('<%=tab_id%>','<%=module.GetId()%>'); return false;" href="#">
                          <IMG src="/images/modules/editor_full.gif">
                        </A>
                    </DIV>
                </LI>                
            </UL>
        </DIV>
        <DIV id="<%=module.HTML_Titlebar()%>" class=titlebar>
            <LABEL><%=module_bundle.getString("TEMPLATE_MODULE_TITLE")%></LABEL>
            <INPUT type=text  id="<%=module.HTML_TitleInput()%>" name="<%=module.HTML_TitleInput()%>" size=60 value="<%=nps.util.Utils.Null2Empty(nps.util.Utils.TransferToHtmlEntity(module.GetTitle()))%>">
            &nbsp;&nbsp;
            <input type="checkbox" id="<%=module.HTML_DisplayTitleInput()%>" name="<%=module.HTML_DisplayTitleInput()%>" <%=module.GetDisplayTitle()?"":"checked=\"true\""%>> <%=module_bundle.getString("TEMPLATE_MODULE_DISPLAYTITLE")%>
        </DIV>
        <DIV id="<%=module.HTML_Colorbar()%>" class=colorbar>
           <div>
            <LABEL><%=module_bundle.getString("TEMPLATE_MODULE_BACKGROUND")%></LABEL>
            <input type="text" id="<%=module.HTML_BackgroundInput()%>" name="<%=module.HTML_BackgroundInput()%>" style="width:200px;" size="60" value="<%=nps.util.Utils.Null2Empty(nps.util.Utils.TransferToHtmlEntity(module.GetBackgroundColor()))%>">
            &nbsp;&nbsp;
            <LABEL><%=module_bundle.getString("TEMPLATE_MODULE_BORDER")%></LABEL>
            <input type="text" id="<%=module.HTML_BorderInput()%>" name="<%=module.HTML_BorderInput()%>" style="width:160px" size="60" value="<%=nps.util.Utils.Null2Empty(nps.util.Utils.TransferToHtmlEntity(module.GetBorder()))%>">
           </div>
           <div style="padding-top:5px;">
            <LABEL><%=module_bundle.getString("TEMPLATE_MODULE_WIDTH")%></LABEL>
            <input type="text" id="<%=module.HTML_WidthInput()%>" name="<%=module.HTML_WidthInput()%>" style="width:60px" size="10" value="<%=nps.util.Utils.Null2Empty(nps.util.Utils.TransferToHtmlEntity(module.GetWidth()))%>">
            &nbsp;
            <LABEL><%=module_bundle.getString("TEMPLATE_MODULE_HEIGHT")%></LABEL>
            <input type="text" id="<%=module.HTML_HeightInput()%>" name="<%=module.HTML_HeightInput()%>" style="width:60px" size="10" value="<%=nps.util.Utils.Null2Empty(nps.util.Utils.TransferToHtmlEntity(module.GetHeight()))%>">
            &nbsp;
            <LABEL><%=module_bundle.getString("TEMPLATE_MODULE_TEXTALIGN")%></LABEL>
            <select id="<%=module.HTML_TextAlignInput()%>" name="<%=module.HTML_TextAlignInput()%>">
                <option value=""></option>
                <option value="left" <%="left".equalsIgnoreCase(module.GetOverflow())?"selected":""%>><%=module_bundle.getString("TEMPLATE_MODULE_TEXTALIGN_LEFT")%></option>
                <option value="right" <%="right".equalsIgnoreCase(module.GetOverflow())?"selected":""%>><%=module_bundle.getString("TEMPLATE_MODULE_TEXTALIGN_RIGHT")%></option>
                <option value="center" <%="center".equalsIgnoreCase(module.GetOverflow())?"selected":""%>><%=module_bundle.getString("TEMPLATE_MODULE_TEXTALIGN_CENTER")%></option>
                <option value="justify" <%="justify".equalsIgnoreCase(module.GetOverflow())?"selected":""%>><%=module_bundle.getString("TEMPLATE_MODULE_TEXTALIGN_JUSTIFY")%></option>
            </select>
            &nbsp;
            <LABEL><%=module_bundle.getString("TEMPLATE_MODULE_OVERFLOW")%></LABEL>
            <select id="<%=module.HTML_OverflowInput()%>" name="<%=module.HTML_OverflowInput()%>">
                <option value=""></option>
                <option value="auto" <%="auto".equalsIgnoreCase(module.GetOverflow())?"selected":""%>><%=module_bundle.getString("TEMPLATE_MODULE_OVERFLOW_AUTO")%></option>
                <option value="scroll" <%="scroll".equalsIgnoreCase(module.GetOverflow())?"selected":""%>><%=module_bundle.getString("TEMPLATE_MODULE_OVERFLOW_SCROLL")%></option>
                <option value="visible" <%="visible".equalsIgnoreCase(module.GetOverflow())?"selected":""%>><%=module_bundle.getString("TEMPLATE_MODULE_OVERFLOW_VISIBLE")%></option>
                <option value="hidden" <%="hidden".equalsIgnoreCase(module.GetOverflow())?"selected":""%>><%=module_bundle.getString("TEMPLATE_MODULE_OVERFLOW_HIDDEN")%></option>
            </select>
          </div>
        </DIV>
        <DIV id="<%=module.HTML_Editor()%>" class=moduleedit>
        <%
            //Load edit.jsp
            out.flush();
            RequestDispatcher dispatcher_editor = request.getRequestDispatcher(module.GetEditPage());
            dispatcher_editor.include(request, response);
        %>
        </DIV>
    </DIV>
</DIV>
<%
    out.flush();
%>