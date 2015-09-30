package com.telkomsel.itvas.webstarter;

import java.io.IOException;
import java.io.PrintStream;
import java.net.URLEncoder;
import java.util.Set;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class DefaultAccessFilter implements javax.servlet.Filter {
	private static Set<String> publicUrls = new java.util.HashSet();

	static {
		publicUrls.add("/web-starter/Login.jsp");
		publicUrls.add("/web-starter/Exit.jsp");
		publicUrls.add("/Login.action");
		publicUrls.add("/Logout.action");
	}

	public DefaultAccessFilter() {
	}

	public void init(FilterConfig filterConfig) throws ServletException {
	}

	public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain)
			throws IOException, ServletException {
		HttpServletRequest request = (HttpServletRequest) servletRequest;
		HttpServletResponse response = (HttpServletResponse) servletResponse;
		if (request.getSession().getAttribute("user") != null) {
			User user = (User) request.getSession().getAttribute("user");
			user.updateSession(request.getRemoteAddr());
			if (MenuManager.isEligible(request.getServletPath(), (User) request.getSession().getAttribute("user"))) {
				filterChain.doFilter(request, response);
			} else {
				String targetUrl = URLEncoder.encode(request.getServletPath(), "UTF-8");
				response.sendRedirect(request.getContextPath() + "/web-starter/Login.jsp?targetUrl=" + targetUrl);
			}
		} else if (isPublicResource(request)) {
			filterChain.doFilter(request, response);
		} else {
			String targetUrl = URLEncoder.encode(request.getServletPath(), "UTF-8");
			if (!request.getServletPath().startsWith("/Dashboard.jsp")) {
				System.out.println(request.getServletPath());
				response.sendRedirect(request.getContextPath() + "/Dashboard.jsp?targetUrl=" + targetUrl);
			} else {
				response.sendRedirect(request.getContextPath() + "/web-starter/Login.jsp?targetUrl=" + targetUrl);
			}
		}
	}

	protected boolean isPublicResource(HttpServletRequest request) {
		String resource = request.getServletPath();

		return (publicUrls.contains(request.getServletPath()))
				|| ((!resource.endsWith(".jsp")) && (!resource.endsWith(".action")));
	}

	public void destroy() {
	}
}