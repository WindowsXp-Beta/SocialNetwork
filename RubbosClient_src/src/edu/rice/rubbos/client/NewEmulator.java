package edu.rice.rubbos.client;


import edu.rice.rubbos.beans.TimeManagement;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;
import java.io.File;
import java.io.FileOutputStream;
import java.io.PrintStream;
import java.lang.Runtime;
import java.net.URL;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.LinkedList;
import java.util.Queue;
import java.util.Random;
import java.util.Vector;
import java.lang.Integer;
import java.io.InputStream;

/**
 * RUBBoS client emulator. 
 * This class plays random user sessions emulating a Web browser.
 *
 * @author <a href="mailto:cecchet@rice.edu">Emmanuel Cecchet</a> and <a href="mailto:julie.marguerite@inrialpes.fr">Julie Marguerite</a>
 * @version 1.0
 */
public class NewEmulator
{
	private RUBBoSProperties rubbos = null;        // access to rubbos.properties file
	private URLGenerator    urlGen = null;        // URL generator corresponding to the version to be used (PHP, EJB or Servlets)
	private static float    slowdownFactor = 0;
	private static boolean  endOfSimulation = false;

	static PrintStream buddy = null;
	static InputStream stderr = null;
	static InputStreamReader isr = null;
	static BufferedReader br = null;
	static boolean m_IsMainClient = true;

	static TransitionTable transitionA, transitionU;
	static Random rand = new Random();   // random number generator
	
	static Queue<UserSession> list = new LinkedList<UserSession>();
	public static int[] wks;
	//private final static  int interval = 600000;
	private final static  int interval = 30000;
	public static int perct;

	/**
	 * Creates a new <code>NewEmulator</code> instance.
	 * The program is stopped on any error reading the configuration files.
	 */
	public NewEmulator()
	{
		try{
			buddy = new PrintStream(new FileOutputStream("/tmp/buddysays"));
		} catch (Exception e){}


		// Initialization, check that all files are ok
		rubbos = new RUBBoSProperties();
		rubbos.isMainClient = m_IsMainClient;
		rubbos.buddy = buddy;

		urlGen = rubbos.checkPropertiesFileAndGetURLGenerator();
		wks = rubbos.getworkloads();
		perct = rubbos.getPercentageOfAuthors();
		
		if (urlGen == null)
			Runtime.getRuntime().exit(1);

		// Check that the transition table is ok and print it
		transitionU = new TransitionTable(rubbos.getNbOfColumns(), rubbos.getNbOfRows(), null, rubbos.useTPCWThinkTime());
		transitionA = new TransitionTable(rubbos.getNbOfColumns(), rubbos.getNbOfRows(), null, rubbos.useTPCWThinkTime());

		if (!transitionU.ReadExcelTextFile(rubbos.getUserTransitionTable()))
			Runtime.getRuntime().exit(1);
		else
			transitionU.displayMatrix("User");
		if (!transitionA.ReadExcelTextFile(rubbos.getAuthorTransitionTable()))
			Runtime.getRuntime().exit(1);
		else
			transitionA.displayMatrix("Author");

		buddy.println("Finsihed consturctor");
		buddy.flush();

	}


	/**
	 * Updates the slowdown factor.
	 *
	 * @param newValue new slowdown value
	 */
	private synchronized void setSlowDownFactor(float newValue)
	{
		slowdownFactor = newValue;
	}


	/**
	 * Get the slowdown factor corresponding to current ramp (up, session or down).
	 */
	public static synchronized float getSlowDownFactor()
	{
		return slowdownFactor;
	}

	/**
	 * Set the end of the current simulation
	 */
	private synchronized void setEndOfSimulation()
	{
		endOfSimulation = true;
	}

	/**
	 * True if end of simulation has been reached.
	 */
	public static synchronized boolean isEndOfSimulation()
	{
		return endOfSimulation;
	}

	public static synchronized UserSession createSession(int i, URLGenerator URLGen, RUBBoSProperties RUBBoS, Stats statistics){
		UserSession us = null;
		if (rand.nextInt(100) < perct)
			us = new UserSession("AuthorSession"+i, URLGen, RUBBoS, statistics, true, transitionA);
		else
			us = new UserSession("UserSession"+i, URLGen, RUBBoS, statistics, false, transitionU);
		return us;
	}

	public static void sleep(long millis){
		try {
			Thread.sleep(millis);
		} catch (InterruptedException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
	}
	/**
	 * Main program take an optional output file argument only 
	 * if it is run on as a remote client.
	 *
	 * @param args optional output file if run as remote client
	 */
	public static void main(String[] args)
	{
		GregorianCalendar startDate;
		GregorianCalendar endDate;
		GregorianCalendar ExpBeginDate;
		GregorianCalendar ExpEndDate;
		Process           webServerMonitor = null;
		Process           servletsServerMonitor = null;
		Process           cjdbcServerMonitor = null;
		Process           dbServerMonitor = null;
		Process           clientMonitor = null;
		Process[]         dbServersMonitor = null;
		Process[]         servletServersMonitor = null;
		Process[]         remoteClientMonitor = null;
		Process[]         remoteClient = null;
		String            reportDir = "";
		String            tmpDir = "/tmp/";
		boolean           isMainClient = args.length == 0; // Check if we are the main client

		m_IsMainClient = isMainClient;

		if (isMainClient)
		{ 
			// Start by creating a report directory and redirecting output to an index.html file
			System.out.println("RUBBoS client emulator - (C) Rice University/INRIA 2001\n");
			reportDir = "bench/"+TimeManagement.currentDateToString()+"/";
			reportDir = reportDir.replace(' ', '@');
			reportDir = reportDir.replace(':', '-');
			try
			{
				System.out.println("Creating report directory "+reportDir);
				File dir = new File(reportDir);
				dir.mkdirs();
				if (!dir.isDirectory())
				{
					System.out.println("Unable to create "+reportDir+" using current directory instead");
					reportDir = "./";
				}
				else
					reportDir = dir.getCanonicalPath()+"/";
				System.out.println("Redirecting output to '"+reportDir+"index.html'");
				PrintStream outputStream = new PrintStream(new FileOutputStream(reportDir+"index.html"));
				System.out.println("Please wait while experiment is running ...");
				System.setOut(outputStream);
				System.setErr(outputStream);
			}
			catch (Exception e)
			{
				System.out.println("Output redirection failed, displaying results on standard output ("+e.getMessage()+")");
			}
			System.out.println("<h2>RUBBoS client emulator - (C) Rice University/INRIA 2001</h2><p>\n");
			startDate = new GregorianCalendar();
			System.out.println("<h3>Test date: "+TimeManagement.dateToString(startDate)+"</h3><br>\n");

			System.out.println("<A HREF=\"#config\">Test configuration</A><br>");
			System.out.println("<A HREF=\"trace_client0.html\">Test trace</A><br>");
			System.out.println("<A HREF=\"perf.html\">Test performance report</A><br><p>");
			System.out.println("<p><hr><p>");

			System.out.println("<CENTER><A NAME=\"config\"></A><h2>*** Test configuration ***</h2></CENTER>");
		}
		else
		{
			System.out.println("RUBBoS remote client emulator - (C) Rice University/INRIA 2001\n");
			startDate = new GregorianCalendar();
		}


		NewEmulator client = new NewEmulator(); // Get also rubbos.properties info

		buddy.println("created clientemultor");

		Stats          stats = new Stats(client.rubbos.getNbOfRows());
		Stats          allStats = new Stats(client.rubbos.getNbOfRows());
//		UserSession[]  sessions = new UserSession[client.rubbos.getNbOfClients()];

		System.out.println("<p><hr><p>");


		if (isMainClient)
		{
			buddy.println("in main client");
			Integer numClients = new Integer(client.rubbos.getRemoteClients().size());
			buddy.println("There are "+numClients.toString()+" clients");
			// Start remote clients
			System.out.println("Total number of clients for this experiment: "+(client.rubbos.getNbOfClients()*(client.rubbos.getRemoteClients().size()+1))+"<br>");
			remoteClient = new Process[client.rubbos.getRemoteClients().size()];
			for (int i = 0 ; i < client.rubbos.getRemoteClients().size() ; i++)
			{
				try
				{
					System.out.println("NewEmulator: Starting remote client on "+client.rubbos.getRemoteClients().get(i)+"<br>\n");
					// String[] rcmdClient = new String[4];
					String[] rcmdClient = new String[5];
					rcmdClient[0] = client.rubbos.getMonitoringRsh();
					rcmdClient[1] = "-x";
					rcmdClient[2] = (String)client.rubbos.getRemoteClients().get(i);

					String[] splitRcmd = new String[2];
					splitRcmd = client.rubbos.getClientsRemoteCommand().split(" ", 2);

					rcmdClient[3] = splitRcmd[0];
					rcmdClient[4] = splitRcmd[1] + " " +
						tmpDir+"trace_client"+(i+1)+".html" + " " +
						tmpDir+"stat_client"+(i+1)+".html" +" " +
						tmpDir+"result"+(i+1)+".jtl";

					/*
					   ProcessBuilder pb = new ProcessBuilder(rcmdClient[0] + " " +
					   rcmdClient[1] + " " +
					   rcmdClient[2] + " \"" +
					   rcmdClient[3] + " " +
					   rcmdClient[4] + "\"");
					   */
					remoteClient[i] = Runtime.getRuntime().exec(rcmdClient);
					Thread t = new ReadLineThread(remoteClient[i].getInputStream());
					t.start();
					/*
					   remoteClient[i] = Runtime.getRuntime().exec(
					   rcmdClient[0] + " " +
					   rcmdClient[1] + " " +
					   rcmdClient[2] + " \"" +
					   rcmdClient[3] + " " +
					   rcmdClient[4] + "\"");
					   */

					buddy.println("done executing remoteClient" + i);


					System.out.println("&nbsp &nbsp Command is: "+rcmdClient[0]+" "+rcmdClient[1]+" "+rcmdClient[2]+" "+rcmdClient[3]+ " " + rcmdClient[4] + "<br>\n");
				}
				catch (IOException ioe)
				{
					System.out.println("An error occured while executing remote client ("+ioe.getMessage()+")");
				}
			}
		}
		else
		{ // Redirect output of remote clients
			System.out.println("Redirecting output to '"+args[0]+"'");
			try
			{
				PrintStream outputStream = new PrintStream(new FileOutputStream(args[0]));
				buddy.println(args[0]);
				System.out.println("Please wait while experiment is running ...");
				System.setOut(outputStream);
				System.setErr(outputStream);
			}
			catch (Exception e)
			{
				System.out.println("Output redirection failed, displaying results on standard output ("+e.getMessage()+")");
			}
			startDate = new GregorianCalendar();
		}


		// #############################
		// ### TEST TRACE BEGIN HERE ###
		// #############################

		if(!isMainClient)
		{
			buddy.println("entered test trace " + args[0] + " " + args[1]);
		} else
			buddy.println("entered test trace");


		System.out.println("<CENTER></A><A NAME=\"trace\"><h2>*** Test trace ***</h2></CENTER><p>");
		System.out.println("<A HREF=\"trace_client0.html\">Main client traces</A><br>");
		for (int i = 0 ; i < client.rubbos.getRemoteClients().size() ; i++)
			System.out.println("<A HREF=\"trace_client"+(i+1)+".html\">client"+(i+1)+" ("+client.rubbos.getRemoteClients().get(i)+") traces</A><br>");

		System.out.println("<br><p>");
		System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#up\">Up ramp trace</A><br>");
		System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#run\">Runtime session trace</A><br>");
		System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#down\">Down ramp trace</A><br><p><p>");

		// Run user sessions
		System.out.println("<br><A NAME=\"Exp Begin\"></A>");
		System.out.println("<h3>NewEmulator: Begin Experiment</h3><br><p>");
		client.setSlowDownFactor(1);
		System.out.println("NewEmulator: Starting workloads"+client.rubbos.getworkloads()+"<br>");
		int count = 0;
		UserSession us =null;
		ExpBeginDate = new GregorianCalendar();
		int period = interval/wks[0]; // interval is the warm-up time, each us would be delayed for period
		for (int i = 0 ; i < wks[0] ; i++){
			us = createSession(count++,client.urlGen,client.rubbos,stats);// create us one by one
			us.start();
			list.offer(us);
			sleep(period);
		}
                Date mark = new Date();
                buddy.println(mark+" current workload is: "+wks[0]+" list size:"+list.size());
		//sleep(200000);
		sleep(400000);
		//sleep(1800000000);
		//for (int i = 1 ; i < wks.length ; i++)
		//{
			
		//	if(wks[i]>wks[i-1]){
		//		period = interval/(wks[i]-wks[i-1]);
		//		for(int j= wks[i-1];j<wks[i];j++){
		//			us = createSession(count++,client.urlGen,client.rubbos,stats);
		//			us.start();
		//			list.offer(us);
		//			sleep(period);
		//		}
		//	}else{
		//		period = interval/(wks[i-1]-wks[i]);
		//		for(int j=wks[i];j<wks[i-1];j++){
		//			if(!list.isEmpty()){
		//				us = list.poll();
		//				us.setEndOfSimulation();
		//				sleep(period);
		//			}
		//		}				
		//	}
		//	Date mark = new Date();
		//	buddy.println(mark+" current workload is: "+wks[i]+" list size:"+list.size());
//			sleep(30000);
		//}

		while(!list.isEmpty()){
			us = list.poll();
			us.setEndOfSimulation();
		}
		ExpEndDate = new GregorianCalendar();

		// Wait for completion
		client.setEndOfSimulation();
		System.out.println("NewEmulator: Shutting down threads ...<br>");
		buddy.println("Shutting down threads");

		if (isMainClient) {
			String path = reportDir + "/result0.jtl";
			stats.getresult(path, TimeManagement.diffTimeInMs(ExpBeginDate, ExpEndDate));
		} else
			stats.getresult(args[2], TimeManagement.diffTimeInMs(ExpBeginDate, ExpEndDate));

//		System.out.println("<br><A NAME=\"all_stat\"></A>");
//		allStats.display_stats("Overall", TimeManagement.diffTimeInMs(ExpBeginDate, ExpEndDate), false);
		// JB
		// scp the sar log files over at this point
		try
		{
			Thread.currentThread().sleep(3000);

			String [] scpCmd = new String[3];
			Process p;
			scpCmd[0] =  client.rubbos.getMonitoringScp();
			scpCmd[2] = reportDir + "/";

			// Fetch html files created by the remote clients
			for (int i = 0 ; i < client.rubbos.getRemoteClients().size() ; i++)
			{
				scpCmd[1] =  (String)client.rubbos.getRemoteClients().get(i)
					+ ":"+tmpDir+"/trace_client"+(i+1)+".html";
				buddy.println("scping trace_client html files");
				buddy.println("bud says: " + scpCmd[0]);
				buddy.println("bud says: " + scpCmd[1]);
				buddy.println("bud says: " + scpCmd[2]);
				buddy.flush();

				p = Runtime.getRuntime().exec(scpCmd);
				p.waitFor();
				buddy.println("done scping html files");
				scpCmd[1] =  (String)client.rubbos.getRemoteClients().get(i)
					+ ":"+tmpDir+"/stat_client"+(i+1)+".html";


				buddy.println("scping stat_client html files");
				buddy.println("bud says: " + scpCmd[0]);
				buddy.println("bud says: " + scpCmd[1]);
				buddy.println("bud says: " + scpCmd[2]);
				buddy.flush();
				p = Runtime.getRuntime().exec(scpCmd);
				p.waitFor();
				buddy.println("done scping html files");

				scpCmd[1] =  (String)client.rubbos.getRemoteClients().get(i)
					+ ":"+tmpDir+"/result"+(i+1)+".jtl";


				buddy.println("scping resutl jtl files");
				buddy.println("bud says: " + scpCmd[0]);
				buddy.println("bud says: " + scpCmd[1]);
				buddy.println("bud says: " + scpCmd[2]);
				buddy.flush();
				p = Runtime.getRuntime().exec(scpCmd);
				p.waitFor();
				buddy.println("done scping html files");
			}
		} 
		catch (Exception e) 
		{
			System.out.println("An error occured while scping the files over ("+e.getMessage()+")");
			buddy.println("error while scping files over "+e.getMessage());
		}

		System.out.println("Done\n");
		endDate = new GregorianCalendar();
		allStats.merge(stats);
		System.out.println("<p><hr><p>");


		// #############################################
		// ### EXPERIMENT IS OVER, COLLECT THE STATS ###
		// #############################################

		buddy.println("collecting stats");

		// All clients completed, here is the performance report !
		// but first redirect the output
		try
		{
			PrintStream outputStream;
			if (isMainClient)
				outputStream = new PrintStream(new FileOutputStream(reportDir+"perf.html"));
			else
				outputStream = new PrintStream(new FileOutputStream(args[1]));
			System.setOut(outputStream);
			System.setErr(outputStream);
		}
		catch (Exception e)
		{
			System.out.println("Output redirection failed, displaying results on standard output ("+e.getMessage()+")");
		}


		System.out.println("<center><h2>*** Performance Report ***</h2></center><br>");    
		System.out.println("<A HREF=\"perf.html\">Overall performance report</A><br>");
		System.out.println("<A HREF=\"stat_client0.html\">Main client (localhost) statistics</A><br>");
		for (int i = 0 ; i < client.rubbos.getRemoteClients().size() ; i++)
			System.out.println("<A HREF=\"stat_client"+(i+1)+".html\">client1 ("+client.rubbos.getRemoteClients().get(i)+") statistics</A><br>");

		System.out.println("<p><br>&nbsp&nbsp&nbsp<A HREF=\"perf.html#node\">Node information</A><br>");
		System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#time\">Test timing information</A><br>");
		System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#up_stat\">Up ramp statistics</A><br>");
		System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#run_stat\">Runtime session statistics</A><br>");
		System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#down_stat\">Down ramp statistics</A><br>");
		System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#all_stat\">Overall statistics</A><br>");
		System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#cpu_graph\">CPU usage graphs</A><br>");
		System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#procs_graph\">Processes usage graphs</A><br>");
		System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#mem_graph\">Memory usage graph</A><br>");
		System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#disk_graph\">Disk usage graphs</A><br>");
		System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#net_graph\">Network usage graphs</A><br>");



		if (isMainClient)
		{
			// Get information about each node
			System.out.println("<br><A NAME=\"node\"></A><h3>Node Information</h3><br>");
			try
			{
				File dir = new File(".");
				String nodeInfoProgram = "/bin/echo \"Host  : \"`/bin/hostname` ; " +
					"/bin/echo \"Kernel: \"`/bin/cat /proc/version` ; " +
					"/bin/grep net /proc/pci ; " +
					"/bin/grep processor /proc/cpuinfo ; " +
					"/bin/grep vendor_id /proc/cpuinfo ; " +
					"/bin/grep model /proc/cpuinfo ; " +
					"/bin/grep MHz /proc/cpuinfo ; " +
					"/bin/grep cache /proc/cpuinfo ; " +
					"/bin/grep MemTotal /proc/meminfo ; " +
					"/bin/grep SwapTotal /proc/meminfo ";


				// Web server
				System.out.println("<B>Web server</B><br>");
				String[] cmdWeb = new String[4];
				cmdWeb[0] = client.rubbos.getMonitoringRsh();
				cmdWeb[1] = "-x";
				cmdWeb[2] = client.rubbos.getWebServerName();
				cmdWeb[3] = nodeInfoProgram;
				Process p = Runtime.getRuntime().exec(cmdWeb);
				buddy.println("web server cmdWeb: "+cmdWeb[0]+" "+cmdWeb[1]+" "+cmdWeb[2]+" "+cmdWeb[3]+" ");
				BufferedReader read = new BufferedReader(new InputStreamReader(p.getInputStream()));
				String msg;
				while ((msg = read.readLine()) != null)
					System.out.println(msg+"<br>");
				read.close();

				// CJDBC Server
				if(client.rubbos.getCJDBCServerName() != null
						&& !client.rubbos.getCJDBCServerName().equals("")) {
					System.out.println("<br><B>CJDBC server</B><br>");
					cmdWeb[0] = client.rubbos.getMonitoringRsh();
					cmdWeb[1] = "-x";
					cmdWeb[2] = client.rubbos.getCJDBCServerName();
					cmdWeb[3] = nodeInfoProgram;
					p = Runtime.getRuntime().exec(cmdWeb);
					read = new BufferedReader(new InputStreamReader(p.getInputStream()));
					while ((msg = read.readLine()) != null)
						System.out.println(msg+"<br>");
					read.close();
				}


				// Database server
				System.out.println("<br><B>Database server</B><br>");
				String[] cmdDB = new String[4];
				cmdDB[0] = client.rubbos.getMonitoringRsh();
				cmdDB[1] = "-x";
				cmdDB[2] = client.rubbos.getDBServerName();
				cmdDB[3] =nodeInfoProgram;
				p = Runtime.getRuntime().exec(cmdDB);
				buddy.println("dbserver cmdDB: "+cmdDB[0]+" "+cmdDB[1]+" "+cmdDB[2]+" "+cmdDB[3]+" ");
				read = new BufferedReader(new InputStreamReader(p.getInputStream()));
				while ((msg = read.readLine()) != null)
					System.out.println(msg+"<br>");
				read.close();

				// Client
				System.out.println("<br><B>Local client</B><br>");
				String[] cmdClient = new String[4];
				cmdClient[0] = client.rubbos.getMonitoringRsh();
				cmdClient[1] = "-x";
				cmdClient[2] = (String)client.rubbos.getbenchmarkNode();
				cmdClient[3] = nodeInfoProgram;
				p = Runtime.getRuntime().exec(cmdClient);
				read = new BufferedReader(new InputStreamReader(p.getInputStream()));
				while ((msg = read.readLine()) != null)
					System.out.println(msg+"<br>");
				read.close();

				// Remote Clients
				for (int i = 0 ; i < client.rubbos.getRemoteClients().size() ; i++)
				{
					System.out.println("<br><B>Remote client "+i+"</B><br>");
					String[] rcmdClient = new String[4];
					rcmdClient[0] = client.rubbos.getMonitoringRsh();
					rcmdClient[1] = "-x";
					rcmdClient[2] = (String)client.rubbos.getRemoteClients().get(i);
					rcmdClient[3] = nodeInfoProgram;
					p = Runtime.getRuntime().exec(rcmdClient);
					read = new BufferedReader(new InputStreamReader(p.getInputStream()));
					while ((msg = read.readLine()) != null)
						System.out.println(msg+"<br>");
					read.close();
				}

				PrintStream outputStream = new PrintStream(new FileOutputStream(reportDir+"stat_client0.html"));
				System.setOut(outputStream);
				// Yasu:
				// System.setErr(outputStream);
				System.out.println("<center><h2>*** Performance Report ***</h2></center><br>");    
				System.out.println("<A HREF=\"perf.html\">Overall performance report</A><br>");
				System.out.println("<A HREF=\"stat_client0.html\">Main client (localhost) statistics</A><br>");
				for (int i = 0 ; i < client.rubbos.getRemoteClients().size() ; i++)
					System.out.println("<A HREF=\"stat_client"+(i+1)+".html\">client "+(i+1) +" ("+client.rubbos.getRemoteClients().get(i)+") statistics</A><br>");
				System.out.println("<p><br>&nbsp&nbsp&nbsp<A HREF=\"perf.html#node\">Node information</A><br>");
				System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#time\">Test timing information</A><br>");
				System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#up_stat\">Up ramp statistics</A><br>");
				System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#run_stat\">Runtime session statistics</A><br>");
				System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#down_stat\">Down ramp statistics</A><br>");
				System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#all_stat\">Overall statistics</A><br>");
				System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#cpu_graph\">CPU usage graphs</A><br>");
				System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#procs_graph\">Processes usage graphs</A><br>");
				System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#mem_graph\">Memory usage graph</A><br>");
				System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#disk_graph\">Disk usage graphs</A><br>");
				System.out.println("&nbsp&nbsp&nbsp<A HREF=\"#net_graph\">Network usage graphs</A><br>");

			}
			catch (Exception ioe)
			{
				System.out.println("An error occured while getting node information ("+ioe.getMessage()+")");
			}
		}




		boolean servletsFlag = false;
		if(client.rubbos.getServletsServerName() != null
				&& !client.rubbos.getServletsServerName().equals("")
				&& !client.rubbos.getServletsServerName().equals(client.rubbos.getWebServerName())) {
			servletsFlag = true;
		}
		boolean cjdbcFlag = false;
		if(client.rubbos.getCJDBCServerName() != null
				&& !client.rubbos.getCJDBCServerName().equals("")) {
			cjdbcFlag = true;
		}

		buddy.println("writing out html");

		System.out.println("<br><A NAME=\"cpu_graph\"></A>");
		System.out.println("<br><h3>CPU Usage graphs</h3><p>");
		System.out.println("<TABLE>");
		System.out.println("<TR><TD><IMG SRC=\"cpu_busy."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(servletsFlag)
		{
			System.out.println("<TD><IMG SRC=\"servlets_server_cpu_busy."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("<TR><TD><IMG SRC=\"client_cpu_busy."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(cjdbcFlag)
		{
			System.out.println("<TD><IMG SRC=\"cjdbc_server_cpu_busy."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("<TR><TD><IMG SRC=\"cpu_idle."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(servletsFlag)
		{
			System.out.println("<TD><IMG SRC=\"servlets_server_cpu_idle."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("<TR><TD><IMG SRC=\"client_cpu_idle."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(cjdbcFlag)
		{
			System.out.println("<TD><IMG SRC=\"cjdbc_server_cpu_idle."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("<TR><TD><IMG SRC=\"cpu_user_kernel."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(servletsFlag)
		{
			System.out.println("<TD><IMG SRC=\"servlets_server_cpu_user_kernel."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("<TR><TD><IMG SRC=\"client_cpu_user_kernel."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(cjdbcFlag)
		{
			System.out.println("<TD><IMG SRC=\"cjdbc_server_cpu_user_kernel."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("</TABLE><p>");

		System.out.println("<br><A NAME=\"procs_graph\"></A>");
		System.out.println("<TABLE>");
		System.out.println("<br><h3>Processes Usage graphs</h3><p>");
		System.out.println("<TR><TD><IMG SRC=\"procs."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(servletsFlag)
		{
			System.out.println("<TD><IMG SRC=\"servlets_server_procs."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("<TR><TD><IMG SRC=\"client_procs."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(cjdbcFlag)
		{
			System.out.println("<TD><IMG SRC=\"cjdbc_server_procs."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("<TR><TD><IMG SRC=\"ctxtsw."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(servletsFlag)
		{
			System.out.println("<TD><IMG SRC=\"servlets_server_ctxtsw."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("<TR><TD><IMG SRC=\"client_ctxtsw."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(cjdbcFlag)
		{
			System.out.println("<TD><IMG SRC=\"cjdbc_server_ctxtsw."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("</TABLE><p>");

		System.out.println("<br><A NAME=\"mem_graph\"></A>");
		System.out.println("<br><h3>Memory Usage graph</h3><p>");
		System.out.println("<TABLE>");
		System.out.println("<TR><TD><IMG SRC=\"mem_usage."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(servletsFlag)
		{
			System.out.println("<TD><IMG SRC=\"servlets_server_mem_usage."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("<TR><TD><IMG SRC=\"client_mem_usage."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(cjdbcFlag)
		{
			System.out.println("<TD><IMG SRC=\"cjdbc_server_mem_usage."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("<TR><TD><IMG SRC=\"mem_cache."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(servletsFlag)
		{
			System.out.println("<TD><IMG SRC=\"servlets_server_mem_cache."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("<TR><TD><IMG SRC=\"client_mem_cache."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(cjdbcFlag)
		{
			System.out.println("<TD><IMG SRC=\"cjdbc_server_mem_cache."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("</TABLE><p>");

		System.out.println("<br><A NAME=\"disk_graph\"></A>");
		System.out.println("<br><h3>Disk Usage graphs</h3><p>");
		System.out.println("<TABLE>");
		System.out.println("<TR><TD><IMG SRC=\"disk_rw_req."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(servletsFlag)
		{
			System.out.println("<TD><IMG SRC=\"servlets_server_disk_rw_req."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("<TR><TD><IMG SRC=\"client_disk_rw_req."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(cjdbcFlag)
		{
			System.out.println("<TD><IMG SRC=\"cjdbc_server_disk_rw_req."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("<TR><TD><IMG SRC=\"disk_tps."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(servletsFlag)
		{
			System.out.println("<TD><IMG SRC=\"servlets_server_disk_tps."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("<TR><TD><IMG SRC=\"client_disk_tps."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(cjdbcFlag)
		{
			System.out.println("<TD><IMG SRC=\"cjdbc_server_disk_tps."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("</TABLE><p>");

		System.out.println("<br><A NAME=\"net_graph\"></A>");
		System.out.println("<br><h3>Network Usage graphs</h3><p>");
		System.out.println("<TABLE>");
		System.out.println("<TR><TD><IMG SRC=\"net_rt_byt."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(servletsFlag)
		{
			System.out.println("<TD><IMG SRC=\"servlets_server_net_rt_byt."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("<TR><TD><IMG SRC=\"client_net_rt_byt."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(cjdbcFlag)
		{
			System.out.println("<TD><IMG SRC=\"cjdbc_server_net_rt_byt."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("<TR><TD><IMG SRC=\"net_rt_pack."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(servletsFlag)
		{
			System.out.println("<TD><IMG SRC=\"servlets_server_net_rt_pack."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("<TR><TD><IMG SRC=\"client_net_rt_pack."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(cjdbcFlag)
		{
			System.out.println("<TD><IMG SRC=\"cjdbc_server_net_rt_pack."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("<TR><TD><IMG SRC=\"socks."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(servletsFlag)
		{
			System.out.println("<TD><IMG SRC=\"servlets_server_socks."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("<TR><TD><IMG SRC=\"client_socks."+client.rubbos.getGnuPlotTerminal()+"\">");
		if(cjdbcFlag)
		{
			System.out.println("<TD><IMG SRC=\"cjdbc_server_socks."+client.rubbos.getGnuPlotTerminal()+"\">");
		}
		System.out.println("</TABLE><p>");


		if (isMainClient)
		{
			buddy.println("compute global stats");
			// Compute the global stats
			try
			{
				String[] cmd = new String[6];
				cmd[0] = "./bench/compute_global_stats.awk";
				cmd[1] = "-v";
				cmd[2] = "path="+reportDir;
				cmd[3] = "-v";
				cmd[4] = "nbscript="+Integer.toString(client.rubbos.getRemoteClients().size()+1);
				cmd[5] = reportDir+"stat_client0.html";
				Process computeStats = Runtime.getRuntime().exec(cmd);	
				// Need to read input so program does not stall.
				BufferedReader read = new BufferedReader(new InputStreamReader(computeStats.getInputStream()));
				String msg;
				while ((msg = read.readLine()) != null)
					System.out.println(msg+"<br>");
				read.close();
				computeStats.waitFor();
			}
			catch (Exception e)
			{
				System.out.println("An error occured while generating the graphs ("+e.getMessage()+")");
			}
		}


		buddy.println("exiting");
		Runtime.getRuntime().exit(0);
	}
}
