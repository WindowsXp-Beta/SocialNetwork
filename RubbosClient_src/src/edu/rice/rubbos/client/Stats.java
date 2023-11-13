package edu.rice.rubbos.client;

import java.util.Vector;
import java.util.Random;
import java.lang.Long;
import java.sql.Timestamp;
import java.io.FileOutputStream;
import java.io.PrintStream;
/**
 * This class provides thread-safe statistics. Each statistic entry is composed as follow:
 * <pre>
 * count     : statistic counter
 * error     : statistic error counter
 * minTime   : minimum time for this entry (automatically computed)
 * maxTime   : maximum time for this entry (automatically computed)
 * totalTime : total time for this entry
 * </pre>
 *
 * @version 1.0
 */

public class Stats
{
    private int nbOfStats;
    private int count[];
    private int error[];
    private long minTime[];
    private long maxTime[];
    private long totalTime[];
    private Vector allTransactions[];
    private Vector allTransactions2[];
    private int  nbSessions;   // Number of sessions succesfully ended
    private long sessionsTime; // Sessions total duration

    //add by hchen
    private Vector allIndex;
    private Vector allTime;
    private Vector allEndtime;

    //add by Xuhang
    private Vector allUrl;

    /**
     * Creates a new <code>Stats</code> instance.
     * The entries are reset to 0.
     *
     * @param NbOfStats number of entries to create
     */
    public Stats(int NbOfStats)
    {
        nbOfStats = NbOfStats;
        count = new int[nbOfStats];
        error = new int[nbOfStats];
        minTime = new long[nbOfStats];
        maxTime = new long[nbOfStats];
        totalTime = new long[nbOfStats];
        allTransactions = new Vector[nbOfStats];
        allTransactions2 = new Vector[nbOfStats];
        for ( int i=0; i<nbOfStats; i++ )
        {
            allTransactions[i]=new Vector<Long>();
            allTransactions2[i]=new Vector<Long>();
        }
        allIndex=new Vector<Integer>();
        allTime=new Vector<Long>();
        allEndtime=new Vector<Long>();

	allUrl = new Vector<String>(); //By Xuhang

        reset();
    }


    /**
     * Resets all entries to 0
     */
    public synchronized void reset()
    {
        int i;

        for (i = 0 ; i < nbOfStats ; i++)
        {
            count[i] = 0;
            error[i] = 0;
            minTime[i] = Long.MAX_VALUE;
            maxTime[i] = 0;
            totalTime[i] = 0;
            allTransactions[i].clear();
            allTransactions2[i].clear();
        }
        allIndex.clear();
        allEndtime.clear();
        allTime.clear();
	allUrl.clear();
        nbSessions = 0;
        sessionsTime = 0;
    }

    /**
     * Add a session duration to the total sessions duration and
     * increase the number of succesfully ended sessions.
     *
     * @param time duration of the session
     */
    public synchronized void addSessionTime(long time)
    {
        nbSessions++;
        if (time < 0)
        {
            System.err.println("Negative time received in Stats.addSessionTime("+time+")<br>\n");
            return ;
        }
        sessionsTime = sessionsTime + time;
    }

    /**
     * Increment the number of succesfully ended sessions.
     */
    public synchronized void addSession()
    {
        nbSessions++;
    }


    /**
     * Increment an entry count by one.
     *
     * @param index index of the entry
     */
    public synchronized void incrementCount(int index)
    {
        count[index]++;
    }


    /**
     * Increment an entry error by one.
     *
     * @param index index of the entry
     */
    public synchronized void incrementError(int index)
    {
        error[index]++;
    }


    /**
     * Add a new time sample for this entry. <code>time</code> is added to total time
     * and both minTime and maxTime are updated if needed.
     *
     * @param index index of the entry
     * @param time response time of this entry
     * @param end  time to add to this entry
     */
    public synchronized void updateTime(int index, long time, long endTime)
    {
        if (time < 0)
        {
            System.err.println("Negative time received in Stats.updateTime("+time+")<br>\n");
            return ;
        }
        totalTime[index] += time;
        if (time > maxTime[index])
            maxTime[index] = time;
        if (time < minTime[index])
            minTime[index] = time;
        allTransactions[index].add(new Long(time));
        allTransactions2[index].add(new Long(endTime));
        allIndex.add(index);
        allTime.add(time);
        allEndtime.add(endTime);
    }

	public synchronized void addUrl(int index, String url) {
		allUrl.add(url);				
	}



    /**
     * Get current count of an entry
     *
     * @param index index of the entry
     *
     * @return entry count value
     */
    public synchronized int getCount(int index)
    {
        return count[index];
    }


    /**
     * Get current error count of an entry
     *
     * @param index index of the entry
     *
     * @return entry error value
     */
    public synchronized int getError(int index)
    {
        return error[index];
    }


    /**
     * Get the minimum time of an entry
     *
     * @param index index of the entry
     *
     * @return entry minimum time
     */
    public synchronized long getMinTime(int index)
    {
        return minTime[index];
    }


    /**
     * Get the maximum time of an entry
     *
     * @param index index of the entry
     *
     * @return entry maximum time
     */
    public synchronized long getMaxTime(int index)
    {
        return maxTime[index];
    }


    /**
     * Get the total time of an entry
     *
     * @param index index of the entry
     *
     * @return entry total time
     */
    public synchronized long getTotalTime(int index)
    {
        return totalTime[index];
    }

    public synchronized Vector getTrasaction(int index)
    {
        return allTransactions[index];
    }

    public synchronized Vector getTrasaction2(int index)
    {
        return allTransactions2[index];
    }

    public synchronized Vector getAllIndex()
    {
        return allIndex;
    }

    public synchronized Vector getAllEndtime()
    {
        return allEndtime;
    }

    public synchronized Vector getAllTime()
    {
        return allTime;
    }

	public synchronized Vector getAllUrl() {
		return allUrl;
	}


    /**
     * Get the total number of entries that are collected
     *
     * @return total number of entries
     */
    public int getNbOfStats()
    {
        return nbOfStats;
    }


    /**
     * Adds the entries of another Stats object to this one.
     *
     * @param anotherStat stat to merge with current stat
     */
    public synchronized void merge(Stats anotherStat)
    {
        if (this == anotherStat)
        {
            System.out.println("You cannot merge a stats with itself");
            return;
        }
        if (nbOfStats != anotherStat.getNbOfStats())
        {
            System.out.println("Cannot merge stats of differents sizes.");
            return;
        }
        Vector tempIndex=anotherStat.getAllIndex();
        Vector tempEndtime=anotherStat.getAllEndtime();
        Vector tempTime = anotherStat.getAllTime();
	Vector tempUrl = anotherStat.getAllUrl(); 	//
        for (int k=0; k< anotherStat.allIndex.size();k++){
            allIndex.add(tempIndex.elementAt(k));
            allEndtime.add(tempEndtime.elementAt(k));
            allTime.add(tempTime.elementAt(k));
	    allUrl.add(tempUrl.elementAt(k));  //Xuhang
        }
        for (int i = 0 ; i < nbOfStats ; i++)
        {
            count[i] += anotherStat.getCount(i);
            error[i] += anotherStat.getError(i);
            if (minTime[i] > anotherStat.getMinTime(i))
                minTime[i] = anotherStat.getMinTime(i);
            if (maxTime[i] < anotherStat.getMaxTime(i))
                maxTime[i] = anotherStat.getMaxTime(i);
            totalTime[i] += anotherStat.getTotalTime(i);
            for ( int j=0; j< anotherStat.allTransactions[i].size(); j++ )
            {
                Vector tempVec = anotherStat.getTrasaction(i);
                Vector tempVec2 = anotherStat.getTrasaction2(i);
                try {
                    allTransactions[i].add(tempVec.elementAt(j) );
                    allTransactions2[i].add(tempVec2.elementAt(j) );
                }
                catch (Exception e){}

            }
        }
        nbSessions   += anotherStat.nbSessions;
        sessionsTime += anotherStat.sessionsTime;
    }


    /**
     * Display an HTML table containing the stats for each state.
     * Also compute the totals and average throughput
     *
     * @param title table title
     * @param sessionTime total time for this session
     * @param exclude0Stat true if you want to exclude the stat with a 0 value from the output
     */
    public void display_stats(String title, long sessionTime, boolean exclude0Stat)
    {
        int counts = 0;
        int errors = 0;
        long time = 0;

        System.out.println("<br><h3>"+title+" statistics</h3><p>");
        System.out.println("<TABLE BORDER=1>");
        System.out.println("<THEAD><TR><TH>State name<TH>% of total<TH>Count<TH>Errors<TH>Minimum Time<TH>Maximum Time<TH>Average Time<TBODY>");
        // Display stat for each state
        for (int i = 0 ; i < getNbOfStats() ; i++)
        {
            counts += count[i];
            errors += error[i];
            time += totalTime[i];
        }

        for (int i = 0 ; i < getNbOfStats() ; i++)
        {
            if ((exclude0Stat && count[i] != 0) || (!exclude0Stat))
            {
                System.out.print("<TR><TD><div align=left>"+TransitionTable.getStateName(i)+"</div><TD><div align=right>");
                if ((counts > 0) && (count[i] > 0))
                    System.out.print(100*count[i]/(float)counts+" %");
                else
                    System.out.print("0 %");

                System.out.print("</div><TD><div align=right>"+count[i]+"</div><TD><div align=right>");

                if (error[i] > 0)
                    System.out.print("<B>"+error[i]+"</B>");
                else
                    System.out.print(error[i]);

                System.out.print("</div><TD><div align=right>");


                if (minTime[i] != Long.MAX_VALUE)
                    System.out.print(minTime[i]);
                else
                    System.out.print("0");

                System.out.print(" ms</div><TD><div align=right>"+maxTime[i]+" ms</div><TD><div align=right>");

                int success = count[i] - error[i];
                if (success > 0)
                    System.out.println(totalTime[i]/(float)success+" ms</div>");
                else
                    System.out.println("0 ms</div>");
            }
        }

        // Display total
        if (counts > 0)
        {
            System.out.print("<TR><TD><div align=left><B>Total</B></div><TD><div align=right><B>100 %</B></div><TD><div align=right><B>"+counts+
                    "</B></div><TD><div align=right><B>"+errors+ "</B></div><TD><div align=center>-</div><TD><div align=center>-</div><TD><div align=right><B>");
            counts += errors;
            System.out.println(time/counts+" ms</B></div>");
            // Display stats about sessions
            System.out.println("<TR><TD><div align=left><B>Average throughput</div></B><TD colspan=6><div align=center><B>"+1000*counts/sessionTime+" req/s</B></div>");
            System.out.println("<TR><TD><div align=left>Completed sessions</div><TD colspan=6><div align=left>"+nbSessions+"</div>");
            System.out.println("<TR><TD><div align=left>Total time</div><TD colspan=6><div align=left>"+sessionsTime/1000L+" seconds</div>");
            System.out.print("<TR><TD><div align=left><B>Average session time</div></B><TD colspan=6><div align=left><B>");
            if (nbSessions > 0)
                System.out.print(sessionsTime/(long)nbSessions/1000L+" seconds");
            else
                System.out.print("0 second");
            System.out.println("</B></div>");
        }
        System.out.println("</TABLE><p>");

        //Transaction level details
        System.out.println("<h1>Transaction Details</h1>");
        System.out.println("<div id=\"detailedout\">");
        System.out.println("<table>");

        for (int i = 0 ; i < getNbOfStats() ; i++)
        {
            if ((exclude0Stat && count[i] != 0) || (!exclude0Stat))
            {
                for ( int j=0; j<allTransactions[i].size(); j++ )
                {

                    System.out.print("<TR><TD>"+TransitionTable.getStateName(i)+"</TD><TD>");
                    Long tmptime;
                    Long tmptime2;
                    try
                    {
                        tmptime = (Long) allTransactions[i].elementAt(j);
                        System.out.print(tmptime.toString()+"</TD><TD>");
                        tmptime2 = (Long) allTransactions2[i].elementAt(j);
                        Timestamp ts = new Timestamp(tmptime2.longValue());
                        System.out.print(ts.toString());
                    }
                    catch ( Exception e) {}
                    System.out.print("</TD></TR>");


                }
                if ((counts > 0) && (count[i] > 0))
                    System.out.print(100*count[i]/(float)counts+" %");
                else
                    System.out.print("0 %");

            }
        }

        System.out.println("</table>");
        System.out.println("</div>");
    }

    public void getresult(String reportDir,long sessiontime){
        try{
            PrintStream outfile = new PrintStream(new FileOutputStream(reportDir));
            int counts = 0;
            int errors = 0;
            long time = 0;
            for (int i = 0 ; i < getNbOfStats() ; i++)
            {
                counts += count[i];
                errors += error[i];
                time += totalTime[i];
            }
            outfile.println("#count error avg-th avg-rs");
            outfile.println("#"+counts+" "+errors+" "+1000*(counts+errors)/sessiontime+" "+time/(counts+errors));

            for ( int j=0; j<allIndex.size(); j++ )
            {

                Long tmptime;
                Long tmptime2;
		String tmpurl;
                Integer i;
                try
                {
                    tmptime = (Long) allEndtime.elementAt(j);
                    tmptime2 = (Long) allTime.elementAt(j);
		    tmpurl = (String) allUrl.elementAt(j);	//
                    outfile.print(tmptime.toString()+" ");
                    outfile.print(tmptime2.toString()+" ");
                    i=(Integer)allIndex.elementAt(j);
                    //outfile.print(TransitionTable.getStateName(i.intValue())+"\n");
                    outfile.print(TransitionTable.getStateName(i.intValue())+" ");
		    outfile.print(tmpurl + "\n");		//Xuhang
                }
                catch ( Exception e) {}
            }
            outfile.close();
        }catch(Exception e){}
    }

}
