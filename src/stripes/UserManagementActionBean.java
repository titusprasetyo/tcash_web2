package stripes;

import com.telkomsel.itvas.webstarter.User;
import com.telkomsel.itvas.webstarter.UserLogWriter;
import com.telkomsel.itvas.webstarter.UserManager;
import com.telkomsel.itvas.webstarter.WebStarterActionBean;
import com.telkomsel.itvas.webstarter.WebStarterActionBeanContext;
import java.util.List;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.HandlesEvent;
import net.sourceforge.stripes.action.LocalizableMessage;
import net.sourceforge.stripes.action.RedirectResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.validation.Validate;
import net.sourceforge.stripes.validation.ValidateNestedProperties;

public class UserManagementActionBean extends WebStarterActionBean {
	private int[] deleteIds;
	private int[] resetIds;
	private int[] unblockIds;
	@ValidateNestedProperties({ @Validate(field = "fullName", required = true, maxlength = 50),
			@Validate(field = "email", required = true, maxlength = 50), @Validate(field = "accountExpiry") })
	private List<User> user;
	private User newUser;
	@Validate(required = true)
	private String fullName;

	public UserManagementActionBean() {
	}

	public int[] getDeleteIds() {
		return deleteIds;
	}

	public void setDeleteIds(int[] deleteIds) {
		this.deleteIds = deleteIds;
	}

	public int[] getResetIds() {
		return resetIds;
	}

	public void setResetIds(int[] resetIds) {
		this.resetIds = resetIds;
	}

	public List<User> getUser() {
		return user;
	}

	public void setUser(List<User> people) {
		user = people;
	}

	@HandlesEvent("Save")
	@DefaultHandler
	public Resolution saveChanges() {
		User currentUser = getContext().getUser();
		UserManager pm = new UserManager();

		for (User singleUser : user) {
			if (!singleUser.update()) {
				getContext().getMessages().add(new LocalizableMessage("web-starter/UserManagement.action.failed",
						new Object[] { singleUser.getUsername() }));
			}
		}

		if (resetIds != null) {
			for (int id : resetIds) {
				if (pm.resetPasswordUser(id)) {
					User u = pm.getUser(id);
					UserLogWriter.writeLog(currentUser.getUsername(), "Reset password user : " + u.getUsername());
					getContext().getMessages()
							.add(new LocalizableMessage("web-starter/UserManagement.action.update_password.success",
									new Object[] { u.getUsername() }));
				}
			}
		}

		if (unblockIds != null) {
			for (int id : unblockIds) {
				if (pm.unblockUser(id)) {
					User u = pm.getUser(id);
					UserLogWriter.writeLog(currentUser.getUsername(), "Unblock user : " + u.getUsername());
					getContext().getMessages().add(new LocalizableMessage(
							"web-starter/UserManagement.action.unblock.success", new Object[] { u.getUsername() }));
				}
			}
		}

		if (deleteIds != null) {
			for (int id : deleteIds) {
				User u = pm.getUser(id);
				UserLogWriter.writeLog(currentUser.getUsername(), "Delete user : " + u.getUsername());
				pm.deleteUser(id);
			}
		}

		if ((newUser != null) && (newUser.getUsername() != null)) {
			UserLogWriter.writeLog(currentUser.getUsername(), "Add user : " + newUser.getUsername());
			if (!newUser.update()) {
				getContext().getMessages().add(new LocalizableMessage("web-starter/UserManagement.action.failed",
						new Object[] { newUser.getUsername() }));
			} else {
				getContext().getMessages().add(new LocalizableMessage(
						"web-starter/UserManagement.action.insert_success", new Object[] { newUser.getUsername() }));
			}
		}

		return new RedirectResolution("/web-starter/UserManagement.jsp");
	}

	public User getNewUser() {
		return newUser;
	}

	public void setNewUser(User newUser) {
		this.newUser = newUser;
	}

	public int[] getUnblockIds() {
		return unblockIds;
	}

	public void setUnblockIds(int[] unblockIds) {
		this.unblockIds = unblockIds;
	}
}