package com.telkomsel.itvas.webstarter;

import net.sourceforge.stripes.action.ActionBean;
import net.sourceforge.stripes.action.ActionBeanContext;
import org.apache.log4j.Logger;

public abstract class WebStarterActionBean implements ActionBean {
	protected Logger log = Logger.getLogger(getClass());

	public WebStarterActionBean() {
	}

	public void setContext(ActionBeanContext context) {
		this.context = ((WebStarterActionBeanContext) context);
	}

	private WebStarterActionBeanContext context;

	public WebStarterActionBeanContext getContext() {
		return context;
	}
}