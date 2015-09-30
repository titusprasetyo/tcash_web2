package stripes;

import com.telkomsel.itvas.webstarter.User;
import com.telkomsel.itvas.webstarter.UserLogWriter;
import com.telkomsel.itvas.webstarter.WebStarterActionBean;
import com.telkomsel.itvas.webstarter.WebStarterActionBeanContext;
import com.telkomsel.itvas.webstarter.WebStarterUtil;
import net.sourceforge.stripes.action.LocalizableMessage;
import net.sourceforge.stripes.validation.LocalizableError;
import net.sourceforge.stripes.validation.Validate;
import net.sourceforge.stripes.validation.ValidationError;
import net.sourceforge.stripes.validation.ValidationErrors;

public class ChangePasswordActionBean extends WebStarterActionBean {
	@Validate(required = true)
	private String oldPassword;
	@Validate(required = true)
	private String newPassword;
	@Validate(required = true)
	private String rePassword;

	public ChangePasswordActionBean() {
	}

	public net.sourceforge.stripes.action.Resolution changePassword() {
		User user = getContext().getUser();
		UserLogWriter.writeLog(user.getUsername(), "Change password");
		if (user == null) {
			throw new RuntimeException("user null");
		}
		if (!user.testPassword(oldPassword)) {
			ValidationError error = new LocalizableError("oldPasswordFalse", new Object[0]);
			getContext().getValidationErrors().add("oldPassword", error);
			return getContext().getSourcePageResolution();
		}
		if (!WebStarterUtil.isPasswordValid(newPassword)) {
			ValidationError error = new LocalizableError("passwordInvalid", new Object[0]);
			getContext().getValidationErrors().add("newPassword", error);
			return getContext().getSourcePageResolution();
		}
		if (!rePassword.equals(newPassword)) {
			ValidationError error = new LocalizableError("passwordNotMatched", new Object[0]);
			getContext().getValidationErrors().add("newPassword", error);
			getContext().getValidationErrors().add("rePassword", error);
			return getContext().getSourcePageResolution();
		}
		if (user.isInPasswordHistory(newPassword)) {
			ValidationError error = new LocalizableError("passwordMonth", new Object[0]);
			getContext().getValidationErrors().add("newPassword", error);
			getContext().getValidationErrors().add("rePassword", error);
			return getContext().getSourcePageResolution();
		}
		user.updatePassword(newPassword);
		user.setPasswordExpired(false);
		getContext().getRequest().getSession().setAttribute("user", user);
		getContext().getMessages().add(new LocalizableMessage("/ChangePassword.action.successMessage", new Object[0]));
		return new net.sourceforge.stripes.action.RedirectResolution("/web-starter/ChangePassword.jsp");
	}

	public String getNewPassword() {
		return newPassword;
	}

	public void setNewPassword(String newPassword) {
		this.newPassword = newPassword;
	}

	public String getOldPassword() {
		return oldPassword;
	}

	public void setOldPassword(String oldPassword) {
		this.oldPassword = oldPassword;
	}

	public String getRePassword() {
		return rePassword;
	}

	public void setRePassword(String rePassword) {
		this.rePassword = rePassword;
	}
}