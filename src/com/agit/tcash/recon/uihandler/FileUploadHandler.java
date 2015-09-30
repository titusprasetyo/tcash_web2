package com.agit.tcash.recon.uihandler;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.List;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.io.FilenameUtils;

import com.agit.tcash.recon.dao.ParseDao;
import com.agit.tcash.recon.model.UploadLog;
import com.agit.tcash.recon.parseworker.Parser;
import com.agit.tcash.recon.util.UploadUtils;
import com.telkomsel.itvas.webstarter.User;

import jdk.nashorn.internal.ir.RuntimeNode.Request;

/**
 * Servlet to handle File upload request from Client
 * 
 * @author Titus Adi Prasetyo - Agit ESD Telkomsel
 */
public class FileUploadHandler extends HttpServlet {

	private String UPLOAD_DIRECTORY;
	private String message = "";

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		System.out.println("doGet()");

	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		ServletContext servletContext = getServletContext();
		UPLOAD_DIRECTORY = servletContext.getRealPath(File.separator) + "uploadedFiles";
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHms");
		String name = null;
		User userModel = (User) request.getSession(false).getAttribute("user");
		String user = userModel.getUsername();
		String datePart = sdf.format(Calendar.getInstance().getTime());
		System.out.println("doPost");
		System.out.println("User : " + user);
		// process only if its multipart content
		if (ServletFileUpload.isMultipartContent(request)) {
			System.out.println("isMultipartContent");
			try {
				List<FileItem> multiparts = new ServletFileUpload(new DiskFileItemFactory()).parseRequest(request);
				System.out.println("multiparts size : " + multiparts.size());
				for (FileItem item : multiparts) {
					System.out.println("isFormField: " + item.isFormField());
					if (!item.isFormField()) {
						name = new File(item.getName()).getName() + datePart;
						System.out.println("filename : " + name);
						System.out.println("UPLOAD_DIRECTORY : " + UPLOAD_DIRECTORY);
						item.write(new File(UPLOAD_DIRECTORY + File.separator + name));
					}
				}
				// start import to DB
				message = "File Saved as filename " + name + "\n";
				save(UPLOAD_DIRECTORY + File.separator + name, user);
				// File uploaded successfully
				request.setAttribute("message", message.trim());
			} catch (Exception ex) {
				request.setAttribute("message", "File Upload Failed due to " + ex);
			}

		} else {
			request.setAttribute("message", "Sorry this Servlet only handles file upload request");
		}

		request.getRequestDispatcher("./agit/bank_statement_upload_result.jsp").forward(request, response);
		// response.sendRedirect("./agit/bank_statement_upload_result.jsp");

	}

	private void save(String filename, String uploadedBy) {
		message += "Start reading file from " + FilenameUtils.getName(filename) + "\n";
		String uuid = UploadUtils.generateUUID();
		Parser parser = null;
		UploadLog log = null;
		ParseDao dao = null;
		// save upload log table
		try {

			dao = new ParseDao();
			if (dao.isParsed(UploadUtils.getChecksumString(filename))) {
				message += "File already parsed before\n";
				return;
			}
			log = new UploadLog();
			log.setBatchID(uuid);
			log.setFilename(FilenameUtils.getName(filename));
			log.setChecksum(UploadUtils.getChecksumString(filename));
			log.setUploadedBy(uploadedBy);
			log.setDtStamp();
			dao.saveUploadLog(log);
			message += "Saved to upload log table\n";
			try {
				message += "Start parsing file\n";
				parser = new Parser();
				message += parser.doParse(filename, uuid) + "\n";
			} catch (Exception e) {
				message += "Error Parsing file " + e.getMessage();
			}
		} catch (Exception e) {
			message += "Error saving to log table " + e.getMessage();
		}
	}

}