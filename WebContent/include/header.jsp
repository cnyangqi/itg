<%
  response.setHeader("Cache-Control","no-store"); //HTTP 1.1
  response.setHeader("Pragma","no-cache"); //HTTP 1.0
  response.setDateHeader ("Expires", 0); 	//防止被proxy server cache 
	
  nps.core.User user = (nps.core.User) session.getAttribute("user");
  if(user == null)
  {
	   throw new nps.exception.NpsException(nps.exception.ErrorHelper.ACCESS_NOTLOGIN);
  }
%>  