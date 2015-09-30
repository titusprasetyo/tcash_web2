package com.telkomsel.itvas.webstarter;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import net.sourceforge.stripes.action.ActionBeanContext;

public class WebStarterActionBeanContext extends ActionBeanContext {
	public WebStarterActionBeanContext() {
	}

	public User getUser() {
		return (User) getRequest().getSession().getAttribute("user");
	}

	public void setUser(User currentUser) {
		getRequest().getSession().setAttribute("user", currentUser);
	}

	public void logout() {
		getRequest().getSession().invalidate();
	}
}