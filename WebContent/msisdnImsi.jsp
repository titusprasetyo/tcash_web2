<%@page import="java.io.*, java.sql.*, java.util.*,java.text.*,java.net.*" contentType="text/html" pageEncoding="UTF-8"%>
<%!
String PluginRequest(String address) throws MalformedURLException, IOException, ClassCastException{
    String res = "";
    try{
            URL url = new URL(address);
            InputStream in = url.openStream();
            BufferedReader br = new BufferedReader(new InputStreamReader(in));
            String line = "";
            while((line = br.readLine()) != null)
            {
                    res = res.concat(line);
            }
            br.close();
            in.close();
    }
    catch(Exception e){
            res = "error";
            System.out.println(new java.util.Date()+" [ERROR] msisdnImsi=" + e.getMessage());
    }
    return res;
}

String trimIMSI(String IMSI){
    if(IMSI.equals("error")) return "999999999999999";
    else if(IMSI.equals("format_error3")) return "111111111111111";
	else return IMSI.substring(IMSI.lastIndexOf("IMSI")+6, IMSI.lastIndexOf("IMSI")+21);
}
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>MSISDN to IMSI</title>
    </head>
    <body>
        Opening file.. <br />

<%
String input = request.getParameter("input");
String output = request.getParameter("output");

if(input!=null && output!=null){
    if(!input.equalsIgnoreCase(output)){
        //lolos
        //untuk file input
        String pathFile = application.getRealPath("/")+input;
        //untuk file output
        String pathFile2 = application.getRealPath("/")+output;
        String urlRequest = "http://10.2.224.101:5000/?msisdn=";

        String thisLine;
        BufferedReader fileIn = null;
        BufferedWriter fileOut = null;

        try{
            fileIn = new BufferedReader(new FileReader(pathFile));
            if(fileIn!=null){
                //thisLine = fileIn.readLine();
                ArrayList<String> al = new ArrayList<String>();
                while((thisLine=fileIn.readLine())!=null){
                    //System.out.println(thisLine);
					if(!thisLine.equals(""))al.add(thisLine);
                }

                File f = new File(pathFile2);
                if(f.exists()) f.delete();
                if(!f.exists()) f.createNewFile();


                fileOut = new BufferedWriter(new FileWriter(pathFile2));
                for (int i=0;i<al.size();i++){
                    fileOut.write(al.get(i) + "," + trimIMSI(PluginRequest(urlRequest+al.get(i))) + "\n");
                }
                out.println("<b>Conversion success.</b>");
                fileIn.close();
                fileOut.close();
            }
            else{
                out.println("<b>File input not found.</b>");
            }
        }
        catch(Exception e){
            e.printStackTrace();
            out.println("<b>Conversion error.</b>");
            System.out.println(e.getMessage());
        }
        finally{
            if(fileIn!=null)fileIn.close();
            if(fileOut!=null)fileOut.close();
        }

    }
    else{
        out.println("<b>File names cannot be the same.<b>");
    }
}
else{
    out.println("<b>Incorrect parameter.<b>");
}

%>
    </body>
</html>
