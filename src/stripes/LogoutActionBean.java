package stripes;

import com.telkomsel.itvas.webstarter.User;
import com.telkomsel.itvas.webstarter.UserLogWriter;
import com.telkomsel.itvas.webstarter.WebStarterActionBean;
import com.telkomsel.itvas.webstarter.WebStarterActionBeanContext;
import net.sourceforge.stripes.action.Resolution;

public class LogoutActionBean extends WebStarterActionBean {
	public LogoutActionBean() {
	}

	public Resolution logout() throws Exception {
		User user = getContext().getUser();
		if ((user != null) && (user.getUsername() != null)) {
			UserLogWriter.writeLog(user.getUsername(), "Logout successful");
			user.killSession(getContext().getRequest().getRemoteAddr());
		}
		getContext().logout();
		return new net.sourceforge.stripes.action.RedirectResolution("/web-starter/Exit.jsp");
	}
}