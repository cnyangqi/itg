<%
   java.util.ResourceBundle module_bundle = java.util.ResourceBundle.getBundle("langs.jsp_visualtemplate",user.GetLocale(), nps.core.Config.RES_CLASSLOADER);
   request.setAttribute("module",module);
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
                        <A title="<%=module_bundle.getString("TEMPLATE_DELETE_HINT")%>" onclick="man.removeById('<%=module.GetId()%>',true); return false;" href="#">
                            <IMG src="/images/modules/editor_delete.gif">
                        </A>
                    </DIV>
                </LI>
                <LI>
                    <DIV id="<%=module.HTML_ButtonUp()%>">
                        <A title="<%=module_bundle.getString("TEMPLATE_UP_HINT")%>" onclick="man.moveUp('<%=module.GetId()%>'); return false;" href="#">
                            <IMG src="/images/modules/editor_up.gif">
                        </A>
                    </DIV>
                </LI>
                <LI>
                    <DIV id="<%=module.HTML_ButtonDown()%>">
                        <A title="<%=module_bundle.getString("TEMPLATE_DOWN_HINT")%>" onclick="man.moveDown('<%=module.GetId()%>'); return false;" href="#">
                            <IMG src="/images/modules/editor_down.gif">
                        </A>
                    </DIV>
                </LI>
                <LI>
                    <DIV id="<%=module.HTML_ButtonRight()%>">
                        <A title="<%=module_bundle.getString("TEMPLATE_FLOATRIGHT_HINT")%>" onclick="man.moveRight('<%=module.GetId()%>'); return false;" href="#">
                            <IMG src="/images/modules/editor_float.gif">
                         </A>
                    </DIV>
                </LI>
                <LI>
                    <DIV id="<%=module.HTML_ButtonLeft()%>">
                        <A title="<%=module_bundle.getString("TEMPLATE_FLOATLEFT_HINT")%>" onclick="man.moveLeft('<%=module.GetId()%>'); return false;" href="#">
                            <IMG src="/images/modules/editor_left.gif">
                         </A>
                    </DIV>
                </LI>
                <LI>
                    <DIV id="<%=module.HTML_ButtonFull()%>">
                        <A title="<%=module_bundle.getString("TEMPLATE_FLOATNONE_HINT")%>" onclick="man.moveCenter('<%=module.GetId()%>'); return false;" href="#">
                          <IMG src="/images/modules/editor_full.gif">
                        </A>
                    </DIV>
                </LI>
                <LI>
                    <A style="DISPLAY: none" id="<%=module.HTML_ButtonDiscard()%>" title="<%=module_bundle.getString("TEMPLATE_DISCARD_HINT")%>" onclick="man.getById('<%=module.GetId()%>').discard(); return false;" href="#">
                    <SPAN class=discardbtn><%=module_bundle.getString("TEMPLATE_DISCARD_BUTTON")%>&nbsp;</SPAN>
                    </A>
                </LI>
                <LI>
                    <A id="<%=module.HTML_ButtonEdit()%>" title="<%=module_bundle.getString("TEMPLATE_EDIT_HINT")%>" onclick="man.onedit('<%=module.GetId()%>'); return false;" href="#">
                        <SPAN id="<%=module.HTML_Edit()%>" class=editbtn><%=module_bundle.getString("TEMPLATE_EDIT_BUTTON")%></SPAN>
                    </A>
                </LI>
            </UL>
        </DIV>
        <DIV style="DISPLAY: none" id="<%=module.HTML_Titlebar()%>" class=titlebar>
            <LABEL><%=module_bundle.getString("TEMPLATE_MODULE_TITLE")%></LABEL>
            <INPUT type=text  id="<%=module.HTML_TitleInput()%>" name="<%=module.HTML_TitleInput()%>" size=60 value="<%=nps.util.Utils.Null2Empty(nps.util.Utils.TransferToHtmlEntity(module.GetTitle()))%>">
            &nbsp;&nbsp;
            <input type="checkbox" id="<%=module.HTML_DisplayTitleInput()%>" name="<%=module.HTML_DisplayTitleInput()%>" <%=module.GetDisplayTitle()?"":"checked=\"true\""%>> <%=module_bundle.getString("TEMPLATE_MODULE_DISPLAYTITLE")%>
        </DIV>
        <DIV style="DISPLAY: none" id="<%=module.HTML_Colorbar()%>" class=colorbar>
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
        <form id="<%=module.HTML_Form()%>" name="<%=module.HTML_Form()%>" method="get">
        <DIV style="DISPLAY: none" id="<%=module.HTML_Editor()%>" class=moduleedit>
        <%
            //Load edit.jsp
            out.flush();
            RequestDispatcher dispatcher_editor = request.getRequestDispatcher(module.GetEditPage());
            dispatcher_editor.include(request, response);
        %>
        </DIV>
        </form>
    </DIV>

    <%
        String style_backgroundcolor = null;
        if(module.GetBackgroundColor()!=null && module.GetBackgroundColor().length()>0)
        {
            style_backgroundcolor = "background:" + module.GetBackgroundColor() + ";";
        }

        String style_height = null;
        if(module.GetHeight()!=null && module.GetHeight().length()>0)
        {
            style_height = "height:" + module.GetHeight() + ";";
        }

        String style_border = null;
        if(module.GetBorder()!=null && module.GetBorder().length()>0)
        {
            style_border = "border:" + style_border + ";";
        }

        String style_overflow = null;
        if(module.GetOverflow()!=null && module.GetOverflow().length()>0)
        {
            style_overflow = "overflow:" + module.GetOverflow() + ";";
        }

        String style_module = null;
        if(   style_backgroundcolor!=null || style_height!=null || style_overflow!=null || style_border!=null)
        {
            style_module = "style=\"";
            if(style_backgroundcolor!=null) style_module += style_backgroundcolor;
            if(style_height!=null) style_module += style_height;
            if(style_border!=null) style_module += style_border;
            if(style_overflow!=null) style_module += style_overflow;
            style_module += "\"";
        }

        String style_textalign = null;
        if(module.GetTextAlign()!=null && module.GetTextAlign().length()>0)
        {
            style_textalign = "text-align:" + style_textalign + ";";
        }
        String style_txtd = null;
        if(style_textalign!=null)
        {
            style_txtd = "style=\"" + style_textalign + "\"";
        }

    %>
    <DIV id="<%=module.HTML_Content()%>" class="module" <%=nps.util.Utils.Null2Empty(style_module)%>>
        <H2 style="DISPLAY:<%=(module.IsNullTitle()||!module.GetDisplayTitle())?"none":"block"%>" id="<%=module.HTML_Title()%>"><%=nps.util.Utils.Null2Empty(module.GetTitle())%></H2>
        <P style="DISPLAY:<%=module.IsNull()?"block":"none"%>;PADDING-TOP: 20px; PADDING-BOTTOM: 20px; PADDING-LEFT: 20px; PADDING-RIGHT: 20px;" id="<%=module.HTML_EmptyHint()%>"><%=module_bundle.getString("TEMPLATE_MODULE_EMPTY_HINT")%></P>

        <%
            //Load view.jsp, format=HTML always
            RequestDispatcher dispatcher_view = request.getRequestDispatcher(module.GetViewPage() + "?preview=1&format=HTML");
        %>
        <DIV id="<%=module.HTML_Text()%>" class="txtd" <%=nps.util.Utils.Null2Empty(style_txtd)%>><% out.flush(); dispatcher_view.include(request, response); %></DIV>
    </DIV>
</DIV>
<%
    request.removeAttribute("module");
%>