<%@ page import="java.sql.*, java.net.*, tsel_tunai.*,java.text.*"%>

<%
	String username = request.getParameter("username");
	String password = request.getParameter("password");
	String msisdn = request.getParameter("msisdn");
	String bonus_id = request.getParameter("bonus_id");
	String counter = request.getParameter("counter");
	InetAddress thisIp =InetAddress.getLocalHost();

	String log_msg = username+"|"+password+"|"+msisdn+"|"+bonus_id+"|" + thisIp.getHostAddress();
	LogMo.record(log_msg);
	//InjekToPoinReward.submit(username, password, msisdn, bonus_id);
	
	boolean ret = false;
	boolean cek = true;
	String hasilRandom = "";
	String hasilRandom2, hasilRandom3 = "";	
	String test = "00|";
	//out.print(test);
	//if (username.equals("tsel") && password.equals("tsel2012")){
	if (Login.login(username, password)){
		if (Integer.parseInt(counter) > 0){
			out.print(test);
			for(int i = 1; i <= Integer.parseInt(counter); i++ ){
				while (cek == true){
					hasilRandom = InjekToPoinReward.randomString(5);
					if(InjekToPoinReward.getReward(hasilRandom) == true){
						cek = false;
					}else{
						cek = true;
					}
				}
				cek = true;
				if (InjekToPoinReward.insertPoin(hasilRandom, msisdn, bonus_id) == 1){
					if (i< Integer.parseInt(counter)){
						out.print(hasilRandom + "&");
					}else if (i <= Integer.parseInt(counter)){
						out.print(hasilRandom);
					}
					LogMo.record("Sukses | " +msisdn+ " | " +hasilRandom);
				}else{
					test = "02|";
					out.print(test + "Database Error");
				}
			}				
		}else {
			test = "03|";
			out.print (test+"Counter tidak boleh lebih kecil dari 1");
		}		
				
	}else{
		out.print ("01|Username dan Password Anda Salah");
	}		
%>
