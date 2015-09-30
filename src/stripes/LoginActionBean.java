package stripes;

import com.telkomsel.itvas.webstarter.User;
import com.telkomsel.itvas.webstarter.UserLogWriter;
import com.telkomsel.itvas.webstarter.UserManager;
import com.telkomsel.itvas.webstarter.WebStarterActionBean;
import com.telkomsel.itvas.webstarter.WebStarterActionBeanContext;
import net.sourceforge.stripes.action.RedirectResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.validation.LocalizableError;
import net.sourceforge.stripes.validation.Validate;
import net.sourceforge.stripes.validation.ValidationError;
import net.sourceforge.stripes.validation.ValidationErrors;

public class LoginActionBean extends WebStarterActionBean {
	@Validate(required = true)
	private String username;
	@Validate(required = true)
	private String password;
	private String targetUrl;

	public void setUsername(String username) {
		this.username = username;
	}

	public String getUsername() {
		return this.username;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getPassword() {
		return this.password;
	}

	public String getTargetUrl() {
		return this.targetUrl;
	}

	public void setTargetUrl(String targetUrl) {
		this.targetUrl = targetUrl;
	}

	public Resolution login() {
		UserManager pm = new UserManager();
		User person = pm.getUser(this.username, this.password);
		if (person == null) {
			int loginAttempt = pm.incLoginAttempt(this.username);
			LocalizableError error = loginAttempt <= 3 ? new LocalizableError("usernameDoesNotExist", new Object[0])
					: new LocalizableError("userBlock", new Object[0]);
			this.getContext().getValidationErrors().add("username", (ValidationError) error);
			UserLogWriter.writeLog((String) this.username, (String) "Login failed");
			return this.getContext().getSourcePageResolution();
		}
		if (person.getLoginAttempt() > 3) {
			LocalizableError error = new LocalizableError("userBlock", new Object[0]);
			this.getContext().getValidationErrors().add("username", (ValidationError) error);
			UserLogWriter.writeLog((String) this.username, (String) "Login failed, because the user is blocked");
			return this.getContext().getSourcePageResolution();
		}
		if (person.getAccountExpiry() != null && person.isAccountExpired()) {
			LocalizableError error = new LocalizableError("userExpired", new Object[0]);
			this.getContext().getValidationErrors().add("username", (ValidationError) error);
			UserLogWriter.writeLog((String) this.username, (String) "Login failed, because the user is expired");
			return this.getContext().getSourcePageResolution();
		}
		if (person.isPasswordExpired()) {
			person.updateLoginAttempt();
			this.getContext().setUser(person);
			UserLogWriter.writeLog((String) this.username, (String) "Login successful");
			return new RedirectResolution("/web-starter/ChangePassword.jsp");
		}
		if (this.targetUrl != null) {
			person.updateLoginAttempt();
			this.getContext().setUser(person);
			UserLogWriter.writeLog((String) this.username, (String) "Login successful");
			return new RedirectResolution(this.targetUrl);
		}
		person.updateLoginAttempt();
		long nbSession = person.getNbSession();
		if (nbSession <= 2) {
			this.getContext().setUser(person);
			UserLogWriter.writeLog((String) this.username, (String) "Login successful");
			return new RedirectResolution("/Dashboard.jsp");
		}
		LocalizableError error = new LocalizableError("userMaxSession", new Object[0]);
		this.getContext().getValidationErrors().add("username", (ValidationError) error);
		UserLogWriter.writeLog((String) this.username,
				(String) "Login failed, maximum number of sessions (2) has been reached");
		return this.getContext().getSourcePageResolution();
	}
}