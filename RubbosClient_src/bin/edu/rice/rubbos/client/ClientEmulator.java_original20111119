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
import java.util.GregorianCalendar;
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
public class ClientEmulator
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

    
  /**
   * Creates a new <code>ClientEmulator</code> instance.
   * The program is stopped on any error reading the configuration files.
   */
  public ClientEmulator()
  {
    try{
      buddy = new PrintStream(new FileOutputStream("/tmp/buddysays"));
    } catch (Exception e){}


    // Initialization, check that all files are ok
    rubbos = new RUBBoSProperties();
    rubbos.isMainClient = m_IsMainClient;
    rubbos.buddy = buddy;

    urlGen = rubbos.checkPropertiesFileAndGetURLGenerator();
    
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
    GregorianCalendar upRampDate;
    GregorianCalendar runSessionDate;
    GregorianCalendar downRampDate;
    GregorianCalendar endDownRampDate;
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
    
    try{
      buddy = new PrintStream(new FileOutputStream("/tmp/buddysays"));
    } catch (Exception e){}


    buddy.println("entered main");

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


    ClientEmulator client = new ClientEmulator(); // Get also rubbos.properties info

    buddy.println("created clientemultor");
    
    Stats          stats = new Stats(client.rubbos.getNbOfRows());
    Stats          upRampStats = new Stats(client.rubbos.getNbOfRows());
    Stats          runSessionStats = new Stats(client.rubbos.getNbOfRows());
    Stats          downRampStats = new Stats(client.rubbos.getNbOfRows());
    Stats          allStats = new Stats(client.rubbos.getNbOfRows());
    UserSession[]  sessions = new UserSession[client.rubbos.getNbOfClients()];
    
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
          System.out.println("ClientEmulator: Starting remote client on "+client.rubbos.getRemoteClients().get(i)+"<br>\n");
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
          tmpDir+"stat_client"+(i+1)+".html";

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


      

      
      // Start monitoring programs
      System.out.println("<CENTER></A><A NAME=\"trace\"><h2>*** Monitoring ***</h2></CENTER>");
      try
      {

        // First clean up all of the log files as we could be
        // recording binary files. Sar by default "appends"
        try
        {
          String[] delFiles = new String[4];
          Process delProcess;
          delFiles[0] = client.rubbos.getMonitoringRsh();
          delFiles[1] = "-x";
          // Web server
          delFiles[2] = client.rubbos.getWebServerName();
          delFiles[3] = "rm -f "+tmpDir+"web_server";
          System.out.println("&nbsp &nbsp Command is: "+delFiles[0]+" "+delFiles[1]+" "+delFiles[2]+" "+delFiles[3]+"<br>\n");
          delProcess = Runtime.getRuntime().exec(delFiles);
          delProcess.waitFor();
          // Servlets server	
          if(client.rubbos.getServletsServerName() != null
             && !client.rubbos.getServletsServerName().equals("")
             && !client.rubbos.getServletsServerName().equals(client.rubbos.getWebServerName())) 
          {
            delFiles[2] = client.rubbos.getServletsServerName();
            delFiles[3] = "rm -f "+tmpDir+"servlets_server";
            System.out.println("&nbsp &nbsp Command is: "+delFiles[0]+" "+delFiles[1]+" "+delFiles[2]+" "+delFiles[3]+"<br>\n");
            delProcess = Runtime.getRuntime().exec(delFiles);
            delProcess.waitFor();
          }
          
          // Servlet Servers
          for (int i = 0 ; i < client.rubbos.getServletsServers().size() ; i++)
          {
            delFiles[2] =  (String)client.rubbos.getServletsServers().get(i);
            delFiles[3] = "rm -f "+tmpDir+"servlets_server"+(i+1);
            System.out.println("&nbsp &nbsp Command is: "+delFiles[0]+" "+delFiles[1]+" "+delFiles[2]+" "+delFiles[3]+"<br>\n");
            delProcess = Runtime.getRuntime().exec(delFiles);
            delProcess.waitFor();
          }          
          // CJDBC server	
          if(client.rubbos.getCJDBCServerName() != null
             && !client.rubbos.getCJDBCServerName().equals("")) 
          {
            delFiles[2] = client.rubbos.getCJDBCServerName();
            delFiles[3] = "rm -f "+tmpDir+"cjdbc_server";
            System.out.println("&nbsp &nbsp Command is: "+delFiles[0]+" "+delFiles[1]+" "+delFiles[2]+" "+delFiles[3]+"<br>\n");
            delProcess = Runtime.getRuntime().exec(delFiles);
            delProcess.waitFor();
          }
          // Database Server
          delFiles[2] = client.rubbos.getDBServerName();
          delFiles[3] = "rm -f "+tmpDir+"db_server";
          System.out.println("&nbsp &nbsp Command is: "+delFiles[0]+" "+delFiles[1]+" "+delFiles[2]+" "+delFiles[3]+"<br>\n");
          delProcess = Runtime.getRuntime().exec(delFiles);
          delProcess.waitFor();
          // Local client
          delFiles[2] = (String)client.rubbos.getbenchmarkNode();
          delFiles[3] = "rm -f "+tmpDir+"client0";
          System.out.println("&nbsp &nbsp Command is: "+delFiles[0]+" "+delFiles[1]+" "+delFiles[2]+" "+delFiles[3]+"<br>\n");
          delProcess = Runtime.getRuntime().exec(delFiles);
          delProcess.waitFor();
          
          // Database Servers
          for (int i = 0 ; i < client.rubbos.getDBServers().size() ; i++)
          {
            delFiles[2] =  (String)client.rubbos.getDBServers().get(i);
            delFiles[3] = "rm -f "+tmpDir+"db_server"+(i+1);
            System.out.println("&nbsp &nbsp Command is: "+delFiles[0]+" "+delFiles[1]+" "+delFiles[2]+" "+delFiles[3]+"<br>\n");
            delProcess = Runtime.getRuntime().exec(delFiles);
            delProcess.waitFor();
          }
          
          // Remote clients
          for (int i = 0 ; i < client.rubbos.getRemoteClients().size() ; i++)
          {
            delFiles[2] =  (String)client.rubbos.getRemoteClients().get(i);
            delFiles[3] = "rm -f "+tmpDir+"client"+(i+1);
            System.out.println("&nbsp &nbsp Command is: "+delFiles[0]+" "+delFiles[1]+" "+delFiles[2]+" "+delFiles[3]+"<br>\n");
            delProcess = Runtime.getRuntime().exec(delFiles);
            delProcess.waitFor();
          }
        }
        catch(java.lang.InterruptedException ie) 
        {
          ie.printStackTrace();
        }
        System.out.println("&nbsp &nbsp Finished deleting old files<br>\n");

        // Monitor Web server
        int fullTimeInSec = (client.rubbos.getUpRampTime()+client.rubbos.getSessionTime()+client.rubbos.getDownRampTime())/1000 + 5; // Give 5 seconds extra for init
        System.out.println("ClientEmulator: Starting monitoring program on Web server "+client.rubbos.getWebServerName()+"<br>\n");
        String[] cmdWeb = new String[6];
        cmdWeb[0] = client.rubbos.getMonitoringRsh();
        cmdWeb[1] = "-x";
        cmdWeb[2] = client.rubbos.getWebServerName();                                               
        cmdWeb[3] = "/bin/bash";
        cmdWeb[4] = "-c";
        cmdWeb[5] = "'LANG=en_GB.UTF-8 "+client.rubbos.getMonitoringProgram()+" "+client.rubbos.getMonitoringOptions()+" "+
          client.rubbos.getMonitoringSampling()+" "+fullTimeInSec+" -o "+tmpDir+"web_server'";
        webServerMonitor = Runtime.getRuntime().exec(cmdWeb);
        Thread tWebServerMonitor = new ReadLineThread(webServerMonitor.getInputStream());
        tWebServerMonitor.start();

        System.out.println("&nbsp &nbsp Command is: "+cmdWeb[0]+" "+cmdWeb[1]+" "+cmdWeb[2]+" "+cmdWeb[3]+" "+cmdWeb[4]+" "+cmdWeb[5]+"<br>\n");

      // Monitor Servlets server (if any)
	if(client.rubbos.getServletsServerName() != null
	   && !client.rubbos.getServletsServerName().equals("")
	   && !client.rubbos.getServletsServerName().equals(client.rubbos.getWebServerName())) {
          System.out.println("ClientEmulator: Starting monitoring program on Servlets server "+client.rubbos.getServletsServerName()+"<br>\n");
          cmdWeb[0] = client.rubbos.getMonitoringRsh();
          cmdWeb[1] = "-x";
          cmdWeb[2] = client.rubbos.getServletsServerName();                                               
          cmdWeb[3] = "/bin/bash";
          cmdWeb[4] = "-c";
          cmdWeb[5] = "'LANG=en_GB.UTF-8 "+client.rubbos.getMonitoringProgram()+" "+client.rubbos.getMonitoringOptions()+" "+
          client.rubbos.getMonitoringSampling()+" "+fullTimeInSec+" -o "+tmpDir+"servlets_server'";
          servletsServerMonitor = Runtime.getRuntime().exec(cmdWeb);
          Thread tServletsServerMonitor = new ReadLineThread(servletsServerMonitor.getInputStream());
          tServletsServerMonitor.start();
          
          System.out.println("&nbsp &nbsp Command is: "+cmdWeb[0]+" "+cmdWeb[1]+" "+cmdWeb[2]+" "+cmdWeb[3]+" "+cmdWeb[4]+" "+cmdWeb[5]+"<br>\n");
        }

    servletServersMonitor = new Process[client.rubbos.getServletsServers().size()];
    Thread[] tservletServersMonitor = new Thread[client.rubbos.getServletsServers().size()];
    // Monitor servletServers  //add by Qingyang
    for (int i = 0 ; i < client.rubbos.getServletsServers().size() ; i++)
    {
        System.out.println("ClientEmulator: Starting monitoring program on Servlet servers "+client.rubbos.getServletsServers().get(i)+"<br>\n");
      String[] cmdServlets = new String[6];
      cmdServlets[0] = client.rubbos.getMonitoringRsh();
      cmdServlets[1] = "-x";
      cmdServlets[2] = (String)client.rubbos.getServletsServers().get(i);
      cmdServlets[3] = "/bin/bash";
      cmdServlets[4] = "-c";
      cmdServlets[5] = "'LANG=en_GB.UTF-8 "+client.rubbos.getMonitoringProgram()+" "+client.rubbos.getMonitoringOptions()+" "+
        client.rubbos.getMonitoringSampling()+" "+fullTimeInSec+" -o "+tmpDir+"servlets_server"+(i+1)+"'";
      servletServersMonitor[i] = Runtime.getRuntime().exec(cmdServlets);
      tservletServersMonitor[i] = new ReadLineThread(servletServersMonitor[i].getInputStream());
      tservletServersMonitor[i].start();
      
      //remoteClientMonitor[i] = Runtime.getRuntime().exec(							     rcmdClient[0] +							     " " + rcmdClient[1] +							     " " + rcmdClient[2] +							   " \"" +  rcmdClient[3] +							    " " + rcmdClient[4] +							   " " + rcmdClient[5] + "\"");
      System.out.println("&nbsp &nbsp Command is: "+cmdServlets[0]+" "+cmdServlets[1]+" "+cmdServlets[2]+" "+cmdServlets[3]+" "+cmdServlets[4]+" "+cmdServlets[5]+"<br>\n");
    }	
	
	
      // Monitor C-JDBC server (if any)
        if(client.rubbos.getCJDBCServerName() != null
         && !client.rubbos.getCJDBCServerName().equals("")) {
          System.out.println("ClientEmulator: Starting monitoring program on CJDBC server "+client.rubbos.getCJDBCServerName()+"<br>\n");
          cmdWeb[0] = client.rubbos.getMonitoringRsh();
          cmdWeb[1] = "-x";
          cmdWeb[2] = client.rubbos.getCJDBCServerName();                                               
          cmdWeb[3] = "/bin/bash";
          cmdWeb[4] = "-c";
          cmdWeb[5] = "'LANG=en_GB.UTF-8 "+client.rubbos.getMonitoringProgram()+" "+client.rubbos.getMonitoringOptions()+" "+
          client.rubbos.getMonitoringSampling()+" "+fullTimeInSec+" -o "+tmpDir+"cjdbc_server'";
          cjdbcServerMonitor = Runtime.getRuntime().exec(cmdWeb);
          Thread tCjdbcServerMonitor = new ReadLineThread(cjdbcServerMonitor.getInputStream());
          tCjdbcServerMonitor.start();
          
          System.out.println("&nbsp &nbsp Command is: "+cmdWeb[0]+" "+cmdWeb[1]+" "+cmdWeb[2]+" "+cmdWeb[3]+" "+cmdWeb[4]+" "+cmdWeb[5]+"<br>\n");
        }
      
        // Monitor Database server
        System.out.println("ClientEmulator: Starting monitoring program on Database server "+client.rubbos.getDBServerName()+"<br>\n");
        String[] cmdDB = new String[6];
        cmdDB[0] = client.rubbos.getMonitoringRsh();
        cmdDB[1] = "-x";
        cmdDB[2] = client.rubbos.getDBServerName();
        cmdDB[3] = "/bin/bash";
        cmdDB[4] = "-c";
        cmdDB[5] = "'LANG=en_GB.UTF-8 "+client.rubbos.getMonitoringProgram()+" "+client.rubbos.getMonitoringOptions()+" "+
          client.rubbos.getMonitoringSampling()+" "+fullTimeInSec+" -o "+tmpDir+"db_server'";
        dbServerMonitor = Runtime.getRuntime().exec(cmdDB);
        Thread tDbServerMonitor = new ReadLineThread(dbServerMonitor.getInputStream());
        tDbServerMonitor.start();
    
        System.out.println("&nbsp &nbsp Command is: "+cmdDB[0]+" "+cmdDB[1]+" "+cmdDB[2]+" "+cmdDB[3]+" "+cmdDB[4]+" "+cmdDB[5]+"<br>\n");
        
        dbServersMonitor = new Process[client.rubbos.getDBServers().size()];
        Thread[] tDBServersMonitor = new Thread[client.rubbos.getDBServers().size()];
        // Monitor DBservers
        for (int i = 0 ; i < client.rubbos.getDBServers().size() ; i++)
        {
            System.out.println("ClientEmulator: Starting monitoring program on Database servers "+client.rubbos.getDBServers().get(i)+"<br>\n");
          String[] cmdDBs = new String[6];
          cmdDBs[0] = client.rubbos.getMonitoringRsh();
          cmdDBs[1] = "-x";
          cmdDBs[2] = (String)client.rubbos.getDBServers().get(i);
          cmdDBs[3] = "/bin/bash";
          cmdDBs[4] = "-c";
          cmdDBs[5] = "'LANG=en_GB.UTF-8 "+client.rubbos.getMonitoringProgram()+" "+client.rubbos.getMonitoringOptions()+" "+
            client.rubbos.getMonitoringSampling()+" "+fullTimeInSec+" -o "+tmpDir+"db_server"+(i+1)+"'";
          dbServersMonitor[i] = Runtime.getRuntime().exec(cmdDBs);
          tDBServersMonitor[i] = new ReadLineThread(dbServersMonitor[i].getInputStream());
          tDBServersMonitor[i].start();
          
          //remoteClientMonitor[i] = Runtime.getRuntime().exec(							     rcmdClient[0] +							     " " + rcmdClient[1] +							     " " + rcmdClient[2] +							   " \"" +  rcmdClient[3] +							    " " + rcmdClient[4] +							   " " + rcmdClient[5] + "\"");
          System.out.println("&nbsp &nbsp Command is: "+cmdDBs[0]+" "+cmdDBs[1]+" "+cmdDBs[2]+" "+cmdDBs[3]+" "+cmdDBs[4]+" "+cmdDBs[5]+"<br>\n");
        }
        
        
        
        
        // Monitor local client
        System.out.println("ClientEmulator: Starting monitoring program locally on client<br>\n");
        String[] cmdClient = new String[6];
        cmdClient[0] = client.rubbos.getMonitoringRsh();
        cmdClient[1] = "-x";
        cmdClient[2] = (String)client.rubbos.getbenchmarkNode();
        cmdClient[3] = "/bin/bash";
        cmdClient[4] = "-c";
        cmdClient[5] = "'LANG=en_GB.UTF-8 "+client.rubbos.getMonitoringProgram()+" "+client.rubbos.getMonitoringOptions()+" "+
          client.rubbos.getMonitoringSampling()+" "+fullTimeInSec+" -o "+reportDir+"client0'";
        clientMonitor = Runtime.getRuntime().exec(cmdClient);
        Thread tClientMonitor = new ReadLineThread(clientMonitor.getInputStream());
        tClientMonitor.start();
	  
        System.out.println("&nbsp &nbsp Command is: "+cmdClient[0]+" "+cmdClient[1]+" "+cmdClient[2]+" "+cmdClient[3]+" "+cmdClient[4]+" "+cmdClient[5]+"<br>\n");

        remoteClientMonitor = new Process[client.rubbos.getRemoteClients().size()];
        Thread[] tRemoteClientMonitor = new Thread[client.rubbos.getRemoteClients().size()];
	
        // Monitor remote clients
        for (int i = 0 ; i < client.rubbos.getRemoteClients().size() ; i++)
        {
          System.out.println("ClientEmulator: Starting monitoring program locally on client<br>\n");
          String[] rcmdClient = new String[6];
          rcmdClient[0] = client.rubbos.getMonitoringRsh();
          rcmdClient[1] = "-x";
          rcmdClient[2] = (String)client.rubbos.getRemoteClients().get(i);
          rcmdClient[3] = "/bin/bash";
          rcmdClient[4] = "-c";
          rcmdClient[5] = "'LANG=en_GB.UTF-8 "+client.rubbos.getMonitoringProgram()+" "+client.rubbos.getMonitoringOptions()+" "+
            client.rubbos.getMonitoringSampling()+" "+fullTimeInSec+" -o "+tmpDir+"client"+(i+1)+"'";
          remoteClientMonitor[i] = Runtime.getRuntime().exec(rcmdClient);
          tRemoteClientMonitor[i] = new ReadLineThread(remoteClientMonitor[i].getInputStream());
          tRemoteClientMonitor[i].start();
          
          //remoteClientMonitor[i] = Runtime.getRuntime().exec(							     rcmdClient[0] +							     " " + rcmdClient[1] +							     " " + rcmdClient[2] +							   " \"" +  rcmdClient[3] +							    " " + rcmdClient[4] +							   " " + rcmdClient[5] + "\"");
          System.out.println("&nbsp &nbsp Command is: "+rcmdClient[0]+" "+rcmdClient[1]+" "+rcmdClient[2]+" "+rcmdClient[3]+" "+rcmdClient[4]+" "+rcmdClient[5]+"<br>\n");
        }

        // Redirect output for traces
        PrintStream outputStream = new PrintStream(new FileOutputStream(reportDir+"trace_client0.html"));
        System.setOut(outputStream);
        System.setErr(outputStream);
      }
      catch (IOException ioe)
      {
        System.out.println("An error occured while executing monitoring program ("+ioe.getMessage()+")");
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
    System.out.println("ClientEmulator: Starting "+client.rubbos.getNbOfClients()+" session threads<br>");
    Random rand = new Random();   // random number generator
    for (int i = 0 ; i < client.rubbos.getNbOfClients() ; i++)
    {
      if (rand.nextInt(100) < client.rubbos.getPercentageOfAuthors())
        sessions[i] = new UserSession("AuthorSession"+i, client.urlGen, client.rubbos, stats, true, transitionA);
      else
        sessions[i] = new UserSession("UserSession"+i, client.urlGen, client.rubbos, stats, false, transitionU);
      sessions[i].start();
    }

    // Start up-ramp
    System.out.println("<br><A NAME=\"up\"></A>");
    System.out.println("<h3>ClientEmulator: Switching to ** UP RAMP **</h3><br><p>");
    client.setSlowDownFactor(client.rubbos.getUpRampSlowdown());
    upRampDate = new GregorianCalendar();
    try
    {
      Thread.currentThread().sleep(client.rubbos.getUpRampTime());
    }
    catch (java.lang.InterruptedException ie)
    {
      System.err.println("ClientEmulator has been interrupted.");
    }
    upRampStats.merge(stats);
    stats.reset(); // Note that as this is not atomic we may lose some stats here ...

    // Start runtime session
    System.out.println("<br><A NAME=\"run\"></A>");
    System.out.println("<h3>ClientEmulator: Switching to ** RUNTIME SESSION **</h3><br><p>");
    client.setSlowDownFactor(1);
    runSessionDate = new GregorianCalendar();
    try
    {
      Thread.currentThread().sleep(client.rubbos.getSessionTime());
    }
    catch (java.lang.InterruptedException ie)
    {
      System.err.println("ClientEmulator has been interrupted.");
    }
    runSessionStats.merge(stats);
    stats.reset(); // Note that as this is not atomic we may lose some stats here ...

    // Start down-ramp
    System.out.println("<br><A NAME=\"down\"></A>");
    System.out.println("<h3>ClientEmulator: Switching to ** DOWN RAMP **</h3><br><p>");
    client.setSlowDownFactor(client.rubbos.getDownRampSlowdown());
    downRampDate = new GregorianCalendar();
    try
    {
      Thread.currentThread().sleep(client.rubbos.getDownRampTime());
    }
    catch (java.lang.InterruptedException ie)
    {
      System.err.println("ClientEmulator has been interrupted.");
    }
    downRampStats.merge(stats);
    endDownRampDate = new GregorianCalendar();

    
    // Wait for completion
    client.setEndOfSimulation();
    System.out.println("ClientEmulator: Shutting down threads ...<br>");
    buddy.println("Shutting down threads");



	    // JB
      // scp the sar log files over at this point
      try
      {
        Thread.currentThread().sleep(3000);
	  
        String [] scpCmd = new String[3];
        Process p;
        scpCmd[0] =  client.rubbos.getMonitoringScp();
        scpCmd[2] = reportDir + "/";
        for (int i = 0 ; i < client.rubbos.getRemoteClients().size() ; i++)
        {
          scpCmd[1] = (String)client.rubbos.getRemoteClients().get(i) + ":"+tmpDir+"/client"+(i+1);
          buddy.println("bud says: " + scpCmd[0]);
          buddy.println("bud says: " + scpCmd[1]);
          buddy.println("bud says: " + scpCmd[2]);
          buddy.flush();
          buddy.println("<scp>");
          buddy.flush();
          p = Runtime.getRuntime().exec(scpCmd);
          p.waitFor();
          buddy.println("</scp>");
          buddy.flush();	  
        }
        scpCmd[1] =  client.rubbos.getWebServerName() + ":"+tmpDir+"/web_server";
        buddy.println("scping web_server files");
        buddy.println("bud says: " + scpCmd[0]);
        buddy.println("bud says: " + scpCmd[1]);
        buddy.println("bud says: " + scpCmd[2]);
        buddy.flush();
        p = Runtime.getRuntime().exec(scpCmd);
        p.waitFor();
        buddy.println("done scping web_server files");

	if(client.rubbos.getServletsServerName() != null
	   && !client.rubbos.getServletsServerName().equals("")
	   && !client.rubbos.getServletsServerName().equals(client.rubbos.getWebServerName())) {
          scpCmd[1] =  client.rubbos.getServletsServerName() + ":"+tmpDir+"/servlets_server";
          buddy.println("scping servlets_server files");
          buddy.println("bud says: " + scpCmd[0]);
          buddy.println("bud says: " + scpCmd[1]);
          buddy.println("bud says: " + scpCmd[2]);
          buddy.flush();
          p = Runtime.getRuntime().exec(scpCmd);
          p.waitFor();
          buddy.println("done scping servlets_server files");
        }
	 //add by Qingyang
    for (int i = 0 ; i < client.rubbos.getServletsServers().size() ; i++)
    {
      scpCmd[1] = (String)client.rubbos.getServletsServers().get(i) + ":"+tmpDir+"/servlets_server"+(i+1);
      buddy.println("bud says: " + scpCmd[0]);
      buddy.println("bud says: " + scpCmd[1]);
      buddy.println("bud says: " + scpCmd[2]);
      buddy.flush();
      buddy.println("<scp>");
      buddy.flush();
      p = Runtime.getRuntime().exec(scpCmd);
      p.waitFor();
      buddy.println("</scp>");
      buddy.flush();	  
    }
	

        if(client.rubbos.getCJDBCServerName() != null
         && !client.rubbos.getCJDBCServerName().equals("")) {
          scpCmd[1] =  client.rubbos.getCJDBCServerName() + ":"+tmpDir+"/cjdbc_server";
          buddy.println("scping cjdbc_server files");
          buddy.println("bud says: " + scpCmd[0]);
          buddy.println("bud says: " + scpCmd[1]);
          buddy.println("bud says: " + scpCmd[2]);
          buddy.flush();
          p = Runtime.getRuntime().exec(scpCmd);
          p.waitFor();
          buddy.println("done scping cjdbc_server files");
        }

        scpCmd[1] =  client.rubbos.getDBServerName() + ":"+tmpDir+"/db_server";
        buddy.println("scping db_server files");
        buddy.println("bud says: " + scpCmd[0]);
        buddy.println("bud says: " + scpCmd[1]);
        buddy.println("bud says: " + scpCmd[2]);
        buddy.flush();
        p = Runtime.getRuntime().exec(scpCmd);
        p.waitFor();
        buddy.println("done scping db_server files");

        
        for (int i = 0 ; i < client.rubbos.getDBServers().size() ; i++)
        {
          scpCmd[1] = (String)client.rubbos.getDBServers().get(i) + ":"+tmpDir+"/db_server"+(i+1);
          buddy.println("bud says: " + scpCmd[0]);
          buddy.println("bud says: " + scpCmd[1]);
          buddy.println("bud says: " + scpCmd[2]);
          buddy.flush();
          buddy.println("<scp>");
          buddy.flush();
          p = Runtime.getRuntime().exec(scpCmd);
          p.waitFor();
          buddy.println("</scp>");
          buddy.flush();	  
        }
        
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
    allStats.merge(runSessionStats);
    allStats.merge(upRampStats);
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

    // Test timing information
    System.out.println("<br><p><A NAME=\"time\"></A><h3>Test timing information</h3><p>");
    System.out.println("<TABLE BORDER=1>");
    System.out.println("<TR><TD><B>Test start</B><TD>"+TimeManagement.dateToString(startDate));
    System.out.println("<TR><TD><B>Up ramp start</B><TD>"+TimeManagement.dateToString(upRampDate));
    System.out.println("<TR><TD><B>Runtime session start</B><TD>"+TimeManagement.dateToString(runSessionDate));
    System.out.println("<TR><TD><B>Down ramp start</B><TD>"+TimeManagement.dateToString(downRampDate));
    System.out.println("<TR><TD><B>Test end</B><TD>"+TimeManagement.dateToString(endDate));
    System.out.println("<TR><TD><B>Up ramp length</B><TD>"+TimeManagement.diffTime(upRampDate, runSessionDate)+
                       " (requested "+client.rubbos.getUpRampTime()+" ms)");
    System.out.println("<TR><TD><B>Runtime session length</B><TD>"+TimeManagement.diffTime(runSessionDate, downRampDate)+
                       " (requested "+client.rubbos.getSessionTime()+" ms)");
    System.out.println("<TR><TD><B>Down ramp length</B><TD>"+TimeManagement.diffTime(downRampDate, endDownRampDate)+
                       " (requested "+client.rubbos.getDownRampTime()+" ms)");
    System.out.println("<TR><TD><B>Total test length</B><TD>"+TimeManagement.diffTime(startDate, endDate));
    System.out.println("</TABLE><p>");

    // Stats for each ramp
    System.out.println("<br><A NAME=\"up_stat\"></A>");
    upRampStats.display_stats("Up ramp", TimeManagement.diffTimeInMs(upRampDate, runSessionDate), false);
    System.out.println("<br><A NAME=\"run_stat\"></A>");
    runSessionStats.display_stats("Runtime session", TimeManagement.diffTimeInMs(runSessionDate, downRampDate), false);
    System.out.println("<br><A NAME=\"down_stat\"></A>");
    downRampStats.display_stats("Down ramp", TimeManagement.diffTimeInMs(downRampDate, endDownRampDate), false);
    System.out.println("<br><A NAME=\"all_stat\"></A>");
    allStats.display_stats("Overall", TimeManagement.diffTimeInMs(upRampDate, endDownRampDate), false);


    if (isMainClient)
    {

      // Wait for end of all monitors and remote clients

	/*
	// instead of waiting, implement time sync
	try
	    {
		// give enough time for other clients to catch up (10sec)
		Thread.currentThread().sleep(10000);
	    }
	catch (java.lang.InterruptedException ie)
	    {
		System.err.println("ClientEmulator has been interrupted.");
	    }	
	*/

    try
    {
      Thread.currentThread().sleep(8000);

	/*

	  for (int i = 0 ; i < client.rubbos.getRemoteClients().size() ; i++)
          {
	     {
		  // The waitFor method only does not work: it hangs forever
		  if (remoteClientMonitor[i].exitValue() != 0)
		      {
			  remoteClientMonitor[i].waitFor();
		      }
		  if (remoteClient[i].exitValue() != 0)
		      {
			  remoteClient[i].waitFor();
		      }
	     }
	  }
	*/
	  /*	       	  
        for (int i = 0 ; i < client.rubbos.getRemoteClients().size() ; i++)
        {
	  
	  buddy.println("bud says: waiting for remoteClientMonitor" + i);
	  remoteClientMonitor[i].waitFor();
	  
	  buddy.println("bud says: waiting for remoteClient "+i);
	  remoteClient[i].waitFor();
        }
	  */
	  
	buddy.println("bud says: webServerMonitor");
        webServerMonitor.waitFor();
	buddy.println("bud says: dbServerMonitor");
        dbServerMonitor.waitFor();

	if(client.rubbos.getCJDBCServerName() != null
	   && !client.rubbos.getCJDBCServerName().equals(""))
	    cjdbcServerMonitor.waitFor();
	    }
      catch (Exception e)
      {
        System.out.println("An error occured while waiting for remote processes termination ("+e.getMessage()+")");
      }
	

	

      // scp the sar log files over at this point
      try
      {
        String [] scpCmd = new String[3];
        Process p;
        scpCmd[0] =  client.rubbos.getMonitoringScp();
        scpCmd[2] = reportDir + "/";
        for (int i = 0 ; i < client.rubbos.getRemoteClients().size() ; i++)
        {
          scpCmd[1] = (String)client.rubbos.getRemoteClients().get(i) + ":"+tmpDir+"/client"+(i+1);
          buddy.println("bud says: " + scpCmd[0]);
          buddy.println("bud says: " + scpCmd[1]);
          buddy.println("bud says: " + scpCmd[2]);
          buddy.flush();
          buddy.println("<scp>");
          p = Runtime.getRuntime().exec(scpCmd);
          p.waitFor();
          buddy.println("</scp>");	  
        }

        scpCmd[1] =  client.rubbos.getWebServerName() + ":"+tmpDir+"/web_server";
        buddy.println("bud says: " + scpCmd[0]);
        buddy.println("bud says: " + scpCmd[1]);
        buddy.println("bud says: " + scpCmd[2]);
        buddy.flush();
        p = Runtime.getRuntime().exec(scpCmd);
        p.waitFor();

	if(client.rubbos.getServletsServerName() != null
	   && !client.rubbos.getServletsServerName().equals("")
	   && !client.rubbos.getServletsServerName().equals(client.rubbos.getWebServerName())) {
          scpCmd[1] =  client.rubbos.getServletsServerName() + ":"+tmpDir+"/servlets_server";
	  buddy.println("bud says: " + scpCmd[0]);
	  buddy.println("bud says: " + scpCmd[1]);
	  buddy.println("bud says: " + scpCmd[2]);
	  buddy.flush();
          p = Runtime.getRuntime().exec(scpCmd);
          p.waitFor();
        }
	
	 //add by Qingyang
    for (int i = 0 ; i < client.rubbos.getServletsServers().size() ; i++)
    {
      scpCmd[1] = (String)client.rubbos.getServletsServers().get(i) + ":"+tmpDir+"/ServletsServer"+(i+1);
      buddy.println("bud says: " + scpCmd[0]);
      buddy.println("bud says: " + scpCmd[1]);
      buddy.println("bud says: " + scpCmd[2]);
      buddy.flush();
      buddy.println("<scp>");
      p = Runtime.getRuntime().exec(scpCmd);
      p.waitFor();
      buddy.println("</scp>");	  
    }
	
        if(client.rubbos.getCJDBCServerName() != null
           && !client.rubbos.getCJDBCServerName().equals("")) {
          scpCmd[1] =  client.rubbos.getCJDBCServerName() + ":"+tmpDir+"/cjdbc_server";
	  buddy.println("bud says: " + scpCmd[0]);
	  buddy.println("bud says: " + scpCmd[1]);
	  buddy.println("bud says: " + scpCmd[2]);
	  buddy.flush();
          p = Runtime.getRuntime().exec(scpCmd);
          p.waitFor();
        }

        scpCmd[1] =  client.rubbos.getDBServerName() + ":"+tmpDir+"/db_server";
        buddy.println("bud says: " + scpCmd[0]);
        buddy.println("bud says: " + scpCmd[1]);
        buddy.println("bud says: " + scpCmd[2]);
        buddy.flush();
        p = Runtime.getRuntime().exec(scpCmd);
        p.waitFor();
        
        for (int i = 0 ; i < client.rubbos.getDBServers().size() ; i++)
        {
          scpCmd[1] = (String)client.rubbos.getDBServers().get(i) + ":"+tmpDir+"/DBServer"+(i+1);
          buddy.println("bud says: " + scpCmd[0]);
          buddy.println("bud says: " + scpCmd[1]);
          buddy.println("bud says: " + scpCmd[2]);
          buddy.flush();
          buddy.println("<scp>");
          p = Runtime.getRuntime().exec(scpCmd);
          p.waitFor();
          buddy.println("</scp>");	  
        }        
        
        // Fetch html files created by the remote clients
        for (int i = 0 ; i < client.rubbos.getRemoteClients().size() ; i++)
        {
          scpCmd[1] =  (String)client.rubbos.getRemoteClients().get(i)
              + ":"+tmpDir+"/trace_client"+(i+1)+".html";
          p = Runtime.getRuntime().exec(scpCmd);
          p.waitFor();
          scpCmd[1] =  (String)client.rubbos.getRemoteClients().get(i)
              + ":"+tmpDir+"/stat_client"+(i+1)+".html";

          buddy.println("bud says: " + scpCmd[0]);
          buddy.println("bud says: " + scpCmd[1]);
          buddy.println("bud says: " + scpCmd[2]);
          buddy.flush();
          p = Runtime.getRuntime().exec(scpCmd);
          p.waitFor();
        }
      } 
      catch (Exception e) 
      {
        System.out.println("An error occured while scping the files over ("+e.getMessage()+")");
      }


      buddy.println("bud says: doing graphs!");
      	buddy.flush();
      // Time to go and convert the binary files into something that generate_graphs.sh can understand
      try
      {
        String cmd;
        Process p;
        // Web server
        cmd = "mv "+reportDir+"/"+"web_server "+reportDir+"/"+"web_server.bin";
        p = Runtime.getRuntime().exec(cmd);
        p.waitFor();

        // Servlets server	
	if(client.rubbos.getServletsServerName() != null
	   && !client.rubbos.getServletsServerName().equals("")
	   && !client.rubbos.getServletsServerName().equals(client.rubbos.getWebServerName()))
        {
          cmd = "mv "+reportDir+"/"+"servlets_server "+reportDir+"/"+"servlets_server.bin";
          p = Runtime.getRuntime().exec(cmd);
          p.waitFor();
        }
	
	 //add by Qingyang
    for (int i = 0 ; i < client.rubbos.getServletsServers().size() ; i++)
    {
      buddy.println("converting the Servlet servers's sar file");
      cmd = "mv "+reportDir+"/"+"servlets_server"+(i+1)+" "+reportDir+"/"+"servlets_server"+(i+1)+".bin";
      p = Runtime.getRuntime().exec(cmd);
      p.waitFor();
    }

        // CJDBC server	
        if(client.rubbos.getCJDBCServerName() != null
         && !client.rubbos.getCJDBCServerName().equals("")) 
        {
          cmd = "mv "+reportDir+"/"+"cjdbc_server "+reportDir+"/"+"cjdbc_server.bin";
          p = Runtime.getRuntime().exec(cmd);
          p.waitFor();
        }

        // Database Server
        cmd = "mv "+reportDir+"/"+"db_server "+reportDir+"/"+"db_server.bin";
        p = Runtime.getRuntime().exec(cmd);
        p.waitFor();

        // Database Servers
        for (int i = 0 ; i < client.rubbos.getDBServers().size() ; i++)
        {
          buddy.println("converting the DB servers's sar file");
          cmd = "mv "+reportDir+"/"+"db_server"+(i+1)+" "+reportDir+"/"+"db_server"+(i+1)+".bin";
          p = Runtime.getRuntime().exec(cmd);
          p.waitFor();
        }
        
        // Localhost
        cmd = "mv "+reportDir+"/"+"client0 "+reportDir+"/"+"client0.bin";
        p = Runtime.getRuntime().exec(cmd);
        p.waitFor();
	
        // Remote clients
        for (int i = 0 ; i < client.rubbos.getRemoteClients().size() ; i++)
        {
          buddy.println("converting the remote client's sar file");
          cmd = "mv "+reportDir+"/"+"client"+(i+1)+" "+reportDir+"/"+"client"+(i+1)+".bin";
          p = Runtime.getRuntime().exec(cmd);
          p.waitFor();
        }

	

	  
        buddy.println("files rename, covert them to ascii");
        // All files rename at this point in time. Time to go forth and convert them into ascii
        String[] convCmd = new String[5];  
        int fullTimeInSec = (client.rubbos.getUpRampTime()+client.rubbos.getSessionTime()+client.rubbos.getDownRampTime())/1000 + 5; // Give 5 seconds extra for init
        String common = "'LANG=en_GB.UTF-8 "+
        client.rubbos.getMonitoringProgram()+" "+
        client.rubbos.getMonitoringOptions()+" "+
        client.rubbos.getMonitoringSampling()+" "+
        fullTimeInSec+" -f "+
        reportDir;
        convCmd[0] = client.rubbos.getMonitoringRsh();
        convCmd[1] = (String)client.rubbos.getbenchmarkNode();
        convCmd[2] =  "/bin/bash";
        convCmd[3] = "-c";
        convCmd[4] = common+"web_server.bin > "+reportDir+""+"web_server'";
        System.out.println("&nbsp &nbsp Command is: "+convCmd[0]+" "+convCmd[1]+" "+convCmd[2]+" "+convCmd[3]+" "+convCmd[4]+"<br>\n");
        buddy.println("Command is: "+convCmd[0]+" "+convCmd[1]+" "+convCmd[2]+" "+convCmd[3]+" "+convCmd[4]+"<br>\n");
        p = Runtime.getRuntime().exec(convCmd); 
        p.waitFor();
	
	if(client.rubbos.getServletsServerName() != null
	   && !client.rubbos.getServletsServerName().equals("")
	   && !client.rubbos.getServletsServerName().equals(client.rubbos.getWebServerName())) 
	{
          convCmd[4] = common+"servlets_server.bin > "+reportDir+""+"servlets_server'";
          System.out.println("&nbsp &nbsp Command is: "+convCmd[0]+" "+convCmd[1]+" "+convCmd[2]+" "+convCmd[3]+" "+convCmd[4]+"<br>\n");
          p = Runtime.getRuntime().exec(convCmd);
          p.waitFor();
        }
	 //add by Qingyang
    for (int i = 0 ; i < client.rubbos.getServletsServers().size() ; i++)
    {
		convCmd[4] =common+"servlets_server"+(i+1)+".bin > "+reportDir+""+"servlets_server"+(i+1)+"'";
		System.out.println("&nbsp &nbsp Command is: "+convCmd[0]+" "+convCmd[1]+" "+convCmd[2]+" "+convCmd[3]+" "+convCmd[4]+"<br>\n");
		p = Runtime.getRuntime().exec(convCmd);
		p.waitFor();

    }
	
        if(client.rubbos.getCJDBCServerName() != null
         && !client.rubbos.getCJDBCServerName().equals("")) 
        {
          convCmd[4] = common+"cjdbc_server.bin > "+reportDir+""+"cjdbc_server'";
          System.out.println("&nbsp &nbsp Command is: "+convCmd[0]+" "+convCmd[1]+" "+convCmd[2]+" "+convCmd[3]+" "+convCmd[4]+"<br>\n");
          p = Runtime.getRuntime().exec(convCmd);
          p.waitFor();
        }
	
        convCmd[4] = common+"db_server.bin > "+reportDir+""+"db_server'";
        System.out.println("&nbsp &nbsp Command is: "+convCmd[0]+" "+convCmd[1]+" "+convCmd[2]+" "+convCmd[3]+" "+convCmd[4]+"<br>\n");
        p = Runtime.getRuntime().exec(convCmd);
        p.waitFor();

        for (int i = 0 ; i < client.rubbos.getDBServers().size() ; i++)
        {
    		convCmd[4] =common+"db_server"+(i+1)+".bin > "+reportDir+""+"db_server"+(i+1)+"'";
    		System.out.println("&nbsp &nbsp Command is: "+convCmd[0]+" "+convCmd[1]+" "+convCmd[2]+" "+convCmd[3]+" "+convCmd[4]+"<br>\n");
    		p = Runtime.getRuntime().exec(convCmd);
    		p.waitFor();

        }        
        
        convCmd[4] = common+"client0.bin > "+reportDir+""+"client0'";
        System.out.println("&nbsp &nbsp Command is: "+convCmd[0]+" "+convCmd[1]+" "+convCmd[2]+" "+convCmd[3]+" "+convCmd[4]+"<br>\n");
        p = Runtime.getRuntime().exec(convCmd);
        p.waitFor();

	
        for (int i = 0 ; i < client.rubbos.getRemoteClients().size() ; i++)
        {
          // HOW DO YOU MAKE THIS MISTAKE RUBBOS!!!!!
          //convCmd[2] =common+"client"+(i+1)+".bin > "+reportDir+""+"client"+(i+1)+"'";
          convCmd[4] =common+"client"+(i+1)+".bin > "+reportDir+""+"client"+(i+1)+"'";
          System.out.println("&nbsp &nbsp Command is: "+convCmd[0]+" "+convCmd[1]+" "+convCmd[2]+" "+convCmd[3]+" "+convCmd[4]+"<br>\n");

          buddy.println("getRemoteClients: " + 
            convCmd[0] + " " +
            convCmd[1] + " " +
            convCmd[2] + " " +
            convCmd[3] + " " +
            convCmd[4]);
          buddy.flush();	  

	  
        p = Runtime.getRuntime().exec(convCmd);
//	  p = Runtime.getRuntime().exec(
//        convCmd[0] + " " +
//					convCmd[1] + " " +
//					convCmd[2] + " " +
//					convCmd[3] + " " +
//					convCmd[4]);
	  
        p.waitFor();

        }

      }
      catch (Exception e)
      {
        System.out.println("An error occured while convering log files ("+e.getMessage()+")");
        buddy.println("An error occured while convering log files ("+e.getMessage()+")");
      }


      buddy.println("generate grpahics");
      // Generate the graphics 
      try
      {
        String[] cmd = new String[4];
        cmd[0] = "./bench/generate_graphs.sh";
        cmd[1] = reportDir;
        cmd[2] = client.rubbos.getGnuPlotTerminal();
        cmd[3] = Integer.toString(client.rubbos.getRemoteClients().size()+1);
        cmd[4] = Integer.toString(client.rubbos.getServletsServers().size()+1); //add by Qingyang
        cmd[5] = Integer.toString(client.rubbos.getDBServers().size()+1); //add by Qingyang
        Process graph = Runtime.getRuntime().exec(cmd);

        buddy.println("waiting for graph to finsh: " +
		      cmd[0] + " " +
		      cmd[1] + " " +
		      cmd[2] + " " +
		      cmd[3]);

		
        // Need to read input so program does not stall.
        BufferedReader read = new BufferedReader(new InputStreamReader(graph.getInputStream()));
        String msg = null;
        while ((msg = read.readLine()) != null)
          System.out.println(msg+"<br>");
    
        read.close();

        graph.waitFor();
      }
      catch (Exception e)
      {
        System.out.println("An error occured while generating the graphs ("+e.getMessage()+")");
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
