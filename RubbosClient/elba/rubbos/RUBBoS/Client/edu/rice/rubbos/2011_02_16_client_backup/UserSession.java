package edu.rice.rubbos.client;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.net.URL;
import java.net.HttpURLConnection;
import java.util.GregorianCalendar;
import java.util.Random;
import java.util.Vector;
import java.util.Date;

/**
 * RUBBoS user session emulator. 
 * This class plays a random user session emulating a Web browser.
 *
 * @author <a href="mailto:cecchet@rice.edu">Emmanuel Cecchet</a> and <a href="mailto:julie.marguerite@inrialpes.fr">Julie Marguerite</a>
 * @version 1.0
 */
public class UserSession extends Thread
{
  private RUBBoSProperties rubbos = null;         // access to rubbos.properties file
  private URLGenerator     urlGen = null;         // URL generator corresponding to the version to be used (PHP, EJB or Servlets)
  private TransitionTable  transition = null;     // transition table user for this session
  private String           lastHTMLReply = null;  // last HTML reply received from 
  private Random           rand = new Random();   // random number generator
  private int              userId;                // User id for the current session
  private String           username = null;       // User name for the current session
  private String           password = null;       // User password for the current session
  private URL              lastURL = null;        // Last accessed URL
  private int              lastStoryId = -1;      // This is to deal with back because the storyId cannot be retrieved from the current page
  private int              lastCategoryId = -1;   // This is to deal with back when the categoryId cannot be retrieved from the current page
  private String         lastCategoryName = null; // This is to deal with back when the categoryName cannot be retrieved from the current page
  private Stats            stats;                 // Statistics to collect errors, time, ...
  private int              debugLevel = 0;        // 0 = no debug message, 1 = just error messages, 2 = error messages+HTML pages, 3 = everything!
  private int              thisYear;              // Current year (2001)
    //  private RandomAccessFile dictionary = null;     // Dictionary file to use to generate random words
  private WordList dictionary = null;     // Dictionary file to use to generate random words
  private String           lastRandomWord = null; // Last word used for free text search
  private int              lastSearch = 0;        // Last search state (stories, comments or users)
  private boolean          isAuthorSession = false;

  /**
   * Creates a new <code>UserSession</code> instance.
   * @param threadId a thread identifier
   * @param URLGen the URLGenerator to use
   * @param RUBBoS rubbos.properties
   * @param statistics where to collect statistics
   * @param isAuthor true if this user session is for an author, false for a regular user
   */
    public UserSession(String threadId, URLGenerator URLGen, RUBBoSProperties RUBBoS, Stats statistics, boolean isAuthor, TransitionTable theTransition)
  {
    super(threadId);
    urlGen = URLGen;
    rubbos  = RUBBoS;
    stats  = statistics;
    debugLevel = rubbos.getMonitoringDebug();
    isAuthorSession = isAuthor;

    transition = new TransitionTable(rubbos.getNbOfColumns(), rubbos.getNbOfRows(), statistics, rubbos.useTPCWThinkTime());
    /*
    if (isAuthorSession)
    {
	//if (!transition.ReadExcelTextFile(rubbos.getAuthorTransitionTable()))
        //Runtime.getRuntime().exit(1);
    }
    else
    {
	//if (!transition.ReadExcelTextFile(rubbos.getUserTransitionTable()))
        //Runtime.getRuntime().exit(1);
    }
    */
    	transition.transitions = (float[][])theTransition.transitions.clone();
	transition.transitionsTime = (int[])theTransition.transitionsTime.clone();
	transition.stateNames = (String[])theTransition.stateNames.clone();

  }


  /**
   * Call the HTTP Server according to the given URL and get the reply
   *
   * @param url URL to access
   * @return <code>String</code> containing the web server reply (HTML file)
   */
  private String callHTTPServer(URL url)
  {
    String              HTMLReply = "";
    BufferedInputStream in = null;
    int                 retry = 0;
    HttpURLConnection   urlc = null;
    long                stime, etime, tmp_time;
    String              logMessage = null;

    if (debugLevel > 2)
      System.out.println("Thread "+this.getName()+": "+url+"<br>");
    
    stime = System.currentTimeMillis();
    logMessage = "Yasu0,Thread:" + this.getName() + ",url:" + url + ",st:" + stime;

    while (retry < 5)
    {
      // Open the connexion
      try
      {
        urlc = (HttpURLConnection)url.openConnection();
        in = new BufferedInputStream(urlc.getInputStream(), 4096);
        //in = new BufferedInputStream(url.openStream(), 4096);
      }
      catch (IOException ioe) 
      {
        //if (debugLevel>0)
          System.err.println("Yasu1: Thread "+this.getName()+": Unable to open URL "+url+" ("+ioe.getMessage()+") retry="+retry+"<br>");
        retry++;
        try
        {
          Thread.currentThread().sleep(1000L);
        }
        catch (InterruptedException i) 
        {
          if (debugLevel>0)
            System.err.println("Thread "+this.getName()+": Interrupted in callHTTPServer()<br>");
          return null;
        }
        continue;
      }

      tmp_time = System.currentTimeMillis();
      logMessage += ",t1:" + tmp_time;

      // Get the data
      try 
      {
        byte[] buffer = new byte[4096];
        int    read;

        while ((read = in.read(buffer, 0, buffer.length)) != -1)
        {
          if (read > 0) 
            HTMLReply = HTMLReply + new String(buffer, 0, read);
        }
      }
      catch (IOException ioe) 
      {
		  //        if (debugLevel>0)
          System.err.println("Yasu2: Thread "+this.getName()+": Unable to read from URL "+url+" ("+ioe.getMessage()+") retry="+retry+"<br>");
        return null;
      }

      // No retry at this point
      break;
    }        
    try
    {
      if (in != null)
        in.close();
      if (urlc != null) {
        int resCode = urlc.getResponseCode();
        logMessage += ",rc1:" + resCode;
        urlc.disconnect();
      }
    } 
    catch (IOException ioe) 
    {
      if (debugLevel>0)
        System.err.println("Thread "+this.getName()+": Unable to close URL "+url+" ("+ioe.getMessage()+")<br>");
    }


    tmp_time = System.currentTimeMillis();
    logMessage += ",t2:" + tmp_time;

    if (retry == 5)
      return null;

    // Look for any image to download
    Vector images = new Vector();
    int index = HTMLReply.indexOf("<IMG SRC=\"");
    while (index != -1)
    {
      int startQuote = index + 10; // 10 equals to length of <IMG SRC"
      int endQuote = HTMLReply.indexOf("\"", startQuote+1);
      images.add(HTMLReply.substring(startQuote, endQuote));
      index = HTMLReply.indexOf("<IMG SRC=\"", endQuote);
    }
    
    // Download all images
    byte[] buffer = new byte[4096];
	int num = 0;
    while (images.size() > 0)
    {
      tmp_time = System.currentTimeMillis();
      logMessage += ",t3:" + tmp_time;

      num++;
      URL imageURL = urlGen.genericHTMLFile((String)images.elementAt(0));
      try
      {
        urlc = (HttpURLConnection)imageURL.openConnection();
        BufferedInputStream inImage = new BufferedInputStream(urlc.getInputStream(), 4096);
        //BufferedInputStream inImage = new BufferedInputStream(imageURL.openStream(), 4096);
        while (inImage.read(buffer, 0, buffer.length) != -1); // Just download, skip data
        inImage.close();
        int resCode = urlc.getResponseCode();
        logMessage += ",rc2:" + resCode;
	urlc.disconnect();
      }          
      catch (IOException ioe) 
      {
		  //        if (debugLevel>0)
          System.err.println("Yasu3: Thread "+this.getName()+": Error while downloading image "+imageURL+" ("+ioe.getMessage()+") retry="+retry+",num="+num+"<br>");
      }
      images.removeElementAt(0);

      tmp_time = System.currentTimeMillis();
      logMessage += ",t4:" + tmp_time;
    }

    etime = System.currentTimeMillis();
    long rt = etime - stime;
    if (rt > 3000) {
	logMessage += ",et:" + etime + ",rt:" + rt;
	System.err.println(logMessage);
    }

    return HTMLReply;
  }


  /**
   * Internal method that returns the min between last_index 
   * and x if x is not equal to -1.
   *
   * @param last_index last_index value
   * @param x value to compare with last_index
   * @return x if (x<last_index and x!=-1) else last_index
   */
  private int isMin(int last_index, int x)
  {
    if (x == -1)
      return last_index;
    if (last_index <= x)
      return last_index;
    else
      return x;
  }


  /**
   * Internal method to compute the index of the end character
   * of a key value. If the key is not found, the lastIndex
   * value is returned unchanged.
   *
   * @param key the key to look for
   * @param lastIndex index to start the lookup in lastHTMLReply
   * @return new lastIndex value
   */
  private int computeLastIndex(String key, int lastIndex)
  {
    int keyIndex = lastHTMLReply.indexOf(key, lastIndex);
    if (keyIndex == -1)
    {
      if (debugLevel>0)
        System.err.println("Thread "+this.getName()+": Cannot find "+key+" in last HTML reply<br>");
      if (debugLevel>1)
        System.err.println("Thread "+this.getName()+": Last HTML reply is: "+lastHTMLReply+"<br>");
    }
    else
    {
      keyIndex += key.length();
      lastIndex = lastHTMLReply.indexOf('\"', keyIndex);
      lastIndex = isMin(lastIndex, lastHTMLReply.indexOf('?', keyIndex));
      lastIndex = isMin(lastIndex, lastHTMLReply.indexOf('&', keyIndex));
      lastIndex = isMin(lastIndex, lastHTMLReply.indexOf('>', keyIndex));
    }
    return lastIndex;
  }


  /**
   * Internal method to compute the index of the end character
   * of a key value. If the key is not found, the lastIndex
   * value is returned unchanged.
   *
   * @param key the key to look for
   * @param skipFirst true if the first occurence of key must be ignored
   * @return new lastIndex value
   */
  private int[] randomComputeLastIndex(String key, boolean skipFirst)
  {
    int count = 0;
    int keyIndex = lastHTMLReply.indexOf(key);
    // 1. Count the number of times we find key
    while (keyIndex != -1)
    {
      count++;
      keyIndex = lastHTMLReply.indexOf(key, keyIndex+key.length());
    }
    if ((count == 0) || (skipFirst && (count <= 1)))
    {
      if (debugLevel>0)
        System.err.println("Thread "+this.getName()+": Cannot find "+key+" in last HTML reply<br>");
      if (debugLevel>1)
        System.err.println("Thread "+this.getName()+": Last HTML reply is: "+lastHTMLReply+"<br>");
      return null;
    }

    // 2. Pickup randomly a key
    keyIndex = -key.length();
    count = rand.nextInt(count)+1;
    if ((skipFirst) && (count == 1))
      count++; // Force to skip the first element
    while (count > 0)
    {
      keyIndex = lastHTMLReply.indexOf(key, keyIndex+key.length());
      count--;
    }
    keyIndex += key.length();
    int lastIndex = isMin(Integer.MAX_VALUE, lastHTMLReply.indexOf('\"', keyIndex));
    lastIndex = isMin(lastIndex, lastHTMLReply.indexOf('?', keyIndex));
    lastIndex = isMin(lastIndex, lastHTMLReply.indexOf('&', keyIndex));
    lastIndex = isMin(lastIndex, lastHTMLReply.indexOf('>', keyIndex));
    int[] result = new int[2];
    result[0] = keyIndex;
    result[1] = lastIndex;
    return result;
  }


  /**
   * Extract a storyId from the last HTML reply. If several storyId entries
   * are found, one of them is picked up randomly.
   *
   * @return an item identifier or -1 on error
   */
  private int extractStoryIdFromHTML()
  {
    if (lastHTMLReply == null)
    {
      if (debugLevel>0)
        System.err.println("Thread "+this.getName()+": There is no previous HTML reply<br>");
      return -1;
    }

    // Choose randomly a story
    int[] pos = randomComputeLastIndex("storyId=", false);
    if (pos == null)
      return lastStoryId;
    Integer foo = new Integer(lastHTMLReply.substring(pos[0], pos[1]));
    lastStoryId = foo.intValue();
    return lastStoryId;
  }


  /**
   * Extract a category (id+name) from the last HTML reply. If several entries
   * are found, one of them is picked up randomly.
   *
   * @return a vector containing first the category identifier (Integer) and then the category name (String)
   */
  private Vector extractCategoryFromHTML()
  {
    if (lastHTMLReply == null)
    {
      if (debugLevel>0)
        System.err.println("Thread "+this.getName()+": There is no previous HTML reply<br>");
      return null;
    }

    // Choose randomly a category
    int[] pos = randomComputeLastIndex("category=", false);
    if (pos == null)
      return null;
    Integer categoryId = new Integer(lastHTMLReply.substring(pos[0], pos[1]));
    String  categoryName = null;
    int newLast = computeLastIndex("categoryName=", pos[1]);
    if (newLast != pos[1])
      categoryName = lastHTMLReply.substring(pos[1]+"categoryName=".length()+1, newLast);
    Vector result = new Vector(2);
    result.add(categoryId);
    result.add(categoryName);
    return result;
  }

  /**
   * Extract post comment parameters (comment_table+storyId+parent) from the last HTML reply.
   * If several entries are found, one of them is picked up randomly.
   *
   * @return a vector containing first the comment table (String), then the story identfier (Integer) and finally the parent identifier (Integer)
   */
  private Vector extractPostCommentFromHTML(String scriptName)
  {
    if (lastHTMLReply == null)
    {
      if (debugLevel>0)
        System.err.println("Thread "+this.getName()+": There is no previous HTML reply<br>");
      return null;
    }

    int[] pos = randomComputeLastIndex(scriptName, false);
    if (pos == null)
      return null;

    // Now we have chosen a 'scriptName?...' we can extract the parameters
    String  comment_table = null;
    Integer storyId = null;
    Integer parent  = null;

    int newLast = computeLastIndex("comment_table=", pos[1]);
    if (newLast != pos[1])
      comment_table = lastHTMLReply.substring(pos[1]+"comment_table=".length()+1, newLast);
    pos[1] = newLast;
    newLast = computeLastIndex("storyId=", pos[1]);
    if (newLast != pos[1])
      storyId = new Integer(lastHTMLReply.substring(pos[1]+"storyId=".length()+1, newLast));
    pos[1] = newLast;
    newLast = computeLastIndex("parent=", pos[1]);
    if (newLast != pos[1])
      parent = new Integer(lastHTMLReply.substring(pos[1]+"parent=".length()+1, newLast));

    Vector result = new Vector(3);
    result.add(comment_table);
    result.add(storyId);
    result.add(parent);
    return result;
  }

  /**
   * Extract post comment parameters (comment_table+storyId+parent+commentId+filter+display) from the last HTML reply.
   * If several entries are found, one of them is picked up randomly.
   *
   * @return a vector containing first the comment table (String), then the story identfier (Integer) and finally the parent identifier (Integer)
   */
  private Vector extractViewCommentFromHTML(String scriptName)
  {
    if (lastHTMLReply == null)
    {
      if (debugLevel>0)
        System.err.println("Thread "+this.getName()+": There is no previous HTML reply<br>");
      return null;
    }

    int[] pos = randomComputeLastIndex(scriptName, true);
    if (pos == null)
      return null;

    // Now we have chosen a 'scriptName?...' we can extract the parameters
    String  comment_table = null;
    Integer storyId   = null;
    Integer commentId = null;
    Integer filter    = null;
    Integer display   = null;

    int newLast = computeLastIndex("comment_table=", pos[1]);
    if (newLast != pos[1])
      comment_table = lastHTMLReply.substring(pos[1]+"comment_table=".length()+1, newLast);
    pos[1] = newLast;
    newLast = computeLastIndex("storyId=", pos[1]);
    if (newLast != pos[1])
      storyId = new Integer(lastHTMLReply.substring(pos[1]+"storyId=".length()+1, newLast));
    pos[1] = newLast;
    newLast = computeLastIndex("commentId=", pos[1]);
    if (newLast != pos[1])
      commentId = new Integer(lastHTMLReply.substring(pos[1]+"commentId=".length()+1, newLast));
    pos[1] = newLast;
    newLast = computeLastIndex("filter=", pos[1]);
    if (newLast != pos[1])
      filter = new Integer(lastHTMLReply.substring(pos[1]+"filter=".length()+1, newLast));
    pos[1] = newLast;
    newLast = computeLastIndex("display=", pos[1]);
    if (newLast != pos[1])
      display = new Integer(lastHTMLReply.substring(pos[1]+"display=".length()+1, newLast));
    
    Vector result = new Vector(5);
    result.add(comment_table);
    result.add(storyId);
    result.add(commentId);
    result.add(filter);
    result.add(display);
    return result;
  }


  /**
   * Extract the comment table and identifier from the last page for a moderation.
   * If several entries are found, one of them is picked up randomly.
   *
   * @return First the comment table value (String), then the comment identifier (Integer)
   */
  private Vector extractModerateCommentIdFromHTML(String scriptName)
  {
    if (lastHTMLReply == null)
    {
      if (debugLevel>0)
        System.err.println("Thread "+this.getName()+": There is no previous HTML reply<br>");
      return null;
    }

    int[] pos = randomComputeLastIndex(scriptName, false);
    if (pos == null)
      return null;

    // Now we have chosen a 'scriptName?...' we can extract the parameters
    String  comment_table = null;
    Integer commentId = null;

    int newLast = computeLastIndex("comment_table=", pos[1]);
    if (newLast != pos[1])
      comment_table = lastHTMLReply.substring(pos[1]+"comment_table=".length()+1, newLast);
    pos[1] = newLast;
    newLast = computeLastIndex("commentId=", pos[1]);
    if (newLast != pos[1])
      commentId = new Integer(lastHTMLReply.substring(pos[1]+"commentId=".length()+1, newLast));
    pos[1] = newLast;

    Vector result = new Vector(2);
    result.add(comment_table);
    result.add(commentId);
    return result;
  }


  /**
   * Extract the story identifier from the review story page for an accept or reject.
   * If several entries are found, one of them is picked up randomly.
   *
   * @return the selected story identifier
   */
  private Integer extractAcceptRejectStoryIdFromHTML(String scriptName)
  {
    Integer storyId = null;

    if (lastHTMLReply == null)
    {
      if (debugLevel>0)
        System.err.println("Thread "+this.getName()+": There is no previous HTML reply<br>");
      return null;
    }

    int[] pos = randomComputeLastIndex(scriptName, false);
    if (pos == null)
      return null;

    // Now we have chosen a 'scriptName?...' we can extract the parameters
    int newLast = computeLastIndex("storyId=", pos[1]);
    if (newLast != pos[1])
      storyId = new Integer(lastHTMLReply.substring(pos[1]+"storyId=".length()+1, newLast));

    return storyId;
  }


  /**
   * Extract a page value from the last HTML reply (used from BrowseCategories like functions)
   *
   * @return a page value
   */
  private int extractPageFromHTML()
  {
    if (lastHTMLReply == null)
      return 0;

    int firstPageIndex = lastHTMLReply.indexOf("&page=");
    if (firstPageIndex == -1)
      return 0;
    int secondPageIndex = lastHTMLReply.indexOf("&page=", firstPageIndex+6); // 6 equals to &page=
    int chosenIndex = 0;
    if (secondPageIndex == -1)
      chosenIndex = firstPageIndex; // First or last page => go to next or previous page
    else
    {  // Choose randomly a page (previous or next)
      if (rand.nextInt(100000) < 50000)
        chosenIndex = firstPageIndex;
      else
        chosenIndex = secondPageIndex;
    }
    int lastIndex = lastHTMLReply.indexOf('\"', chosenIndex+6);
    lastIndex = isMin(lastIndex, lastHTMLReply.indexOf('?', chosenIndex+6));
    lastIndex = isMin(lastIndex, lastHTMLReply.indexOf('&', chosenIndex+6));
    lastIndex = isMin(lastIndex, lastHTMLReply.indexOf('>', chosenIndex+6));
    Integer foo = new Integer(lastHTMLReply.substring(chosenIndex+6, lastIndex));
    return foo.intValue();
  }


  /**
   * Extract an int value corresponding to the given key
   * from the last HTML reply. Example : 
   * <pre>int userId = extractIdFromHTML("&userId=")</pre>
   *
   * @param key the pattern to look for
   * @return the <code>int</code> value or -1 on error.
   */
  private int extractIntFromHTML(String key)
  {
    if (lastHTMLReply == null)
    {
      if (debugLevel>0)
        System.err.println("Thread "+this.getName()+": There is no previous HTML reply");
      return -1;
    }

    // Look for the key
    int keyIndex = lastHTMLReply.indexOf(key);
    if (keyIndex == -1)
    {
      if (debugLevel > 0)
        System.err.println("Thread "+this.getName()+": Cannot find "+key+" in last HTML reply<br>");
      if (debugLevel > 1)
        System.err.println("Thread "+this.getName()+": Last HTML reply is: "+lastHTMLReply+"<br>");
      return -1;
    }
    int lastIndex = lastHTMLReply.indexOf('\"', keyIndex+key.length());
    lastIndex = isMin(lastIndex, lastHTMLReply.indexOf('?', keyIndex+key.length()));
    lastIndex = isMin(lastIndex, lastHTMLReply.indexOf('&', keyIndex+key.length()));
    lastIndex = isMin(lastIndex, lastHTMLReply.indexOf('>', keyIndex+key.length()));
    Integer foo = new Integer(lastHTMLReply.substring(keyIndex+key.length(), lastIndex));
    return foo.intValue();
  }


  /**
   * This method chooses randomly a word from the dictionary.
   *
   * @return random word
   */
  public String randomWordFromDictionary(boolean withPunctuation)
  {

    String word = null;

    try
    {
      // We don't want to seek to the end of the file
	//      int pos = rand.nextInt((int)dictionary.length()-250);
	int pos = rand.nextInt(dictionary.wordarray.length);
	//dictionary.seek(pos);
	dictionary.seek(pos);
	
	//word = dictionary.readLine(); // we surely only get the end of a word
	//word = dictionary.readLine(); // this one should be ok

	// JB
	// calling this once is enough
	word = dictionary.readLine();
    }
    catch (Exception e)
    {
      System.err.println("Unable to read dictionary file '"+rubbos.getStoryDictionary()+"' to generate random word (got exception: "+e.getMessage()+")<br>");
      return null;
    }

    
     // Ignore everything after the first space
    if (word.indexOf(' ') != -1)
      word = word.substring(0, word.indexOf(' '));
    
    if (withPunctuation)
    {
      switch (rand.nextInt(10))
      {
      case 0: 
        word += ", ";
        break;
      case 1: 
        word += ". ";
        break;
      case 2: 
        word += " ? ";
        break;
      case 3: 
        word += " ! ";
        break;
      case 4: 
        word += ": ";
        break;
      case 5: 
        word += " ; ";
        break;
      default: 
        word += " ";
        break;
      }
    }
    return word;
  }


  /**
   * Computes the URL to be accessed according to the given state.
   * If any parameter are needed, they are computed from last HTML reply.
   *
   * @param state current state
   * @return URL corresponding to the state
   */
  public URL computeURLFromState(int state)
  {
    if (lastHTMLReply != null)
    {
      if (lastHTMLReply.indexOf("Sorry") != -1) // Nothing matched the request, we have to go back
        state = transition.backToPreviousState();
    }
    if ((state < 17) || (state > 19)) // Reset lastSearch if we don't stay in a search state
      lastSearch = 0;

    switch (state)
    {
    case -1: // An error occured, reset to home page
      transition.resetToInitialState();
    case 0: // Home Page == Stories of the Day
      return urlGen.homePage();
    case 1: // Register User Page
      return urlGen.register();
    case 2: // Register the user in the database
      { // Choose a random nb over already known attributed ids
        int i = rubbos.getNbOfUsers()+rand.nextInt(1000000)+1; 
        String firstname = "Great"+i;
        String lastname = "User"+i;
        String nickname = "user"+i;
        String email = firstname+"."+lastname+"@rubbos.com";
        String password = "password"+i;
        
        return urlGen.registerUser(firstname, lastname, nickname, email, password);
      }
    case 3: // Browse Page
      return urlGen.browse();
    case 4: // Browse Categories
      return urlGen.browseCategories();
    case 5: // Browse stories in a category
      { // We randomly pickup a category from the generated HTML page
        Vector c = extractCategoryFromHTML();
        int    categoryId;
        String categoryName;
        if (c == null)
        {
          categoryId = lastCategoryId;
          categoryName = lastCategoryName;
        }
        else
        {
          categoryId = ((Integer)c.get(0)).intValue();
          categoryName = (String)c.get(1);
          lastCategoryId = categoryId;
          lastCategoryName = categoryName;          
        }
        return urlGen.browseStoriesByCategory(categoryId, categoryName, extractPageFromHTML(), rubbos.getNbOfStoriesPerPage());
      }
    case 6: // Older stories
      {
        // We have to make hit on past days more successful than hits on 10 years old stories
        int day;
        int month;
        int year;
        int when = rand.nextInt(100);
        if (when > 95)
        { // Pickup any date
          day = rand.nextInt(31) + 1;
          month = rand.nextInt(12) + 1;
          year = rubbos.getOldestStoryYear()+rand.nextInt(3);
        }
        else
        { // Some date in the past week
          GregorianCalendar y = new GregorianCalendar();
          when = when / 10;
          if (when == 0)
            when = 1;
          if (when > 7)
            when = 7;
          for (int i = 0 ; i < when ; i++)
            y.roll(GregorianCalendar.DAY_OF_MONTH, false);
          day = y.get(GregorianCalendar.DAY_OF_MONTH);
          month = y.get(GregorianCalendar.MONTH)+1; // Month start at 0
          year = y.get(GregorianCalendar.YEAR);
        }
        if (year > thisYear)
          year = thisYear;
        if (year == rubbos.getOldestStoryYear())
        {
          if (month <= rubbos.getOldestStoryMonth())
            month = rubbos.getOldestStoryMonth();
        }
        // Yasu: Avoid to generate wrong combination of month and day
        switch (month) {
          case 2:
            if (day > 28) {
              day = 28;
            }
            break;
          case 4:
          case 6:
          case 9:
          case 11:
            if (day > 30) {
              day = 30;
            }
            break;
          default:
            break;
        }
        return urlGen.OlderStories(day, month, year, extractPageFromHTML(), rubbos.getNbOfStoriesPerPage());
      }
    case 7: // View a story
      { // We randomly pickup a story from the generated HTML page
        int storyId = extractStoryIdFromHTML();
        if (storyId == -1)
          return computeURLFromState(transition.backToPreviousState()); // Nothing then go back
        else
          return urlGen.viewStory(storyId);
      }
    case 8: // Post Comment
      {
        Vector p = extractPostCommentFromHTML(urlGen.PostCommentScript());
        if (p == null)
        {
          if (debugLevel > 0)
            // Yasu:
            // System.out.println("Thread "+this.getName()+": Unable to extract PostComment parameters from last HTML reply.<br>");
            System.err.println("Thread "+this.getName()+": Unable to extract PostComment parameters from last HTML reply.<br>");
          return null;
        }
        String  comment_table = (String)p.get(0);
        Integer storyId = (Integer)p.get(1);
        Integer parent  = (Integer)p.get(2);

        if ((comment_table == null) || (storyId == null) || (parent == null))
          return computeURLFromState(transition.backToPreviousState()); // Nothing then go back
        else
          return urlGen.postComment(storyId.intValue(), parent.intValue(), comment_table);
      }
    case 9: // Store comment
      {
        String subject = "";
        String body = "";

        int size = rand.nextInt(100); // Subject size must be smaller than 100 characters
        do
          subject += randomWordFromDictionary(true);
        while ((subject != null) && (subject.length() < size));
	// Yasu: Subject size must be smaller than 100 characters
	if (subject.length() > 100) {
	    subject = subject.substring(0, 100);
	}

	size = rand.nextInt(rubbos.getCommentMaxLength());
        do
          body += randomWordFromDictionary(true);
        while ((body != null) && (body.length() < size));

        int[] pos = randomComputeLastIndex("name=comment_table value=", false);
        if (pos == null)
          return null;
        String comment_table = lastHTMLReply.substring(pos[0], pos[1]);
        return urlGen.storeComment(username, password, extractIntFromHTML("name=storyId value="), extractIntFromHTML("name=parent value="),
                                   subject, body, comment_table);
      }
    case 10: // View comment
      {
        Vector p = extractViewCommentFromHTML(urlGen.ViewCommentScript());
        if (p == null)
        {
          state = transition.backToPreviousState();
          return computeURLFromState(state);
        }
        String  comment_table = (String)p.get(0);
        Integer storyId   = (Integer)p.get(1);
        Integer commentId = (Integer)p.get(2);
        Integer filter    = (Integer)p.get(3);
        Integer display   = (Integer)p.get(4);

        if ((comment_table == null) || (storyId == null) || (commentId == null) || (filter == null) || (display == null))
          return computeURLFromState(transition.backToPreviousState()); // Nothing then go back
        else
          return urlGen.viewComment(commentId.intValue(), filter.intValue(), display.intValue(), storyId.intValue(), comment_table);
      }
    case 11: // Moderate comment
      {
        Vector c = extractModerateCommentIdFromHTML(urlGen.ModerateCommentScript());
        if (c == null)
        {
          state = transition.backToPreviousState();
          return computeURLFromState(state);
        }
        String  comment_table = (String)c.get(0);
        Integer commentId = (Integer)c.get(1);
        if ((comment_table == null) || (commentId == null))
          return computeURLFromState(transition.backToPreviousState()); // Nothing then go back
        else
          return urlGen.moderateComment(commentId.intValue(), comment_table);
      }
    case 12: // Moderate log
      {
        int rating = rand.nextInt(2)-1; // random value between -1 and 1

        int[] pos = randomComputeLastIndex("name=comment_table value=", false);
        if (pos == null)
          return null;
        String comment_table = lastHTMLReply.substring(pos[0], pos[1]);

        return urlGen.storeModerateLog(username, password, extractIntFromHTML("name=commentId value="), rating, comment_table);
      }
    case 13: // Submit story
      return urlGen.submitStory();
    case 14: // Store story
      {
        String title = "";
        String body = "";

        int size = rand.nextInt(100); // title size must be smaller than 100 characters
        do
          title += randomWordFromDictionary(true);
        while ((title != null) && (title.length() < size));
	// Yasu: title size must be smaller than 100 characters
	if (title.length() > 100) {
	    title = title.substring(0, 100);
	}
        
        size = rand.nextInt(rubbos.getStoryMaximumLength());
        do
          body += randomWordFromDictionary(true);
        while ((body != null) && (body.length() < size));

        int[] pos = randomComputeLastIndex("OPTION value=\"", false);
        if (pos == null)
          return null;
        Integer categoryId = new Integer(lastHTMLReply.substring(pos[0], pos[1]));
        return urlGen.storeStory(username, password, title, body, categoryId.intValue());
      }
    case 15: // Search
      return urlGen.search(null, null, 0, 0);
    case 16: // Search stories
      {
        if (lastSearch != 17)
          lastRandomWord = randomWordFromDictionary(false); // Generate randomly a word to look for
        lastSearch = 17;
        return urlGen.search(lastRandomWord, "0", extractPageFromHTML(), rubbos.getNbOfStoriesPerPage());
      }
    case 17: // Search comments
      {
        if (lastSearch != 18)
          lastRandomWord = randomWordFromDictionary(false);
        lastSearch = 18;
        return urlGen.search(lastRandomWord, "1", extractPageFromHTML(), rubbos.getNbOfStoriesPerPage());
      }
    case 18: // Search users
      {
        if (lastSearch != 19) // Generate randomly a user to look for
          lastRandomWord = "user"+(rand.nextInt(rubbos.getNbOfUsers())+1);
        lastSearch = 19;
        return urlGen.search(lastRandomWord, "2", extractPageFromHTML(), rubbos.getNbOfStoriesPerPage());
      }
    case 19: // Author login
      return urlGen.authorLogin();
    case 20: // Author tasks
      return urlGen.authorTasks(username, password);
    case 21: // Review stories
      return urlGen.reviewStories();
    case 22: // Accept story
      {
        Integer storyId = extractAcceptRejectStoryIdFromHTML(urlGen.AcceptStoryScript());
        if (storyId == null)
        { // No more stories to process go back to home page
          transition.resetToInitialState();
          return urlGen.homePage();
        }
        else
          return urlGen.acceptStory(storyId.intValue());
      }
    case 23: // Reject story
      {
        Integer storyId = extractAcceptRejectStoryIdFromHTML(urlGen.RejectStoryScript());
        if (storyId == null)
        { // No more stories to process go back to home page
          transition.resetToInitialState();
          return urlGen.homePage();
        }
        else
          return urlGen.rejectStory(storyId.intValue());
      }
    default:
      if (debugLevel > 0)
        System.err.println("Thread "+this.getName()+": This state is not supported ("+state+")<br>");
      return null;
    }
  }


  /**
   * Emulate a user session using the current transition table.
   */
  public void run()
  {
    int  nbOfTransitions;
    int  next;
    long time, time2;
    long startSession, endSession;

    GregorianCalendar cal = new GregorianCalendar();
    thisYear = cal.get(GregorianCalendar.YEAR);

    try
    {
	//dictionary = new RandomAccessFile(rubbos.getStoryDictionary(), "r");
	dictionary = new WordList();
    }
    catch (Exception e)
    {
	System.err.println("Unable to open dictionary file '"+rubbos.getStoryDictionary()+"' (got exception: "+e.getMessage()+")<br>");
		return ;
    }

    while (!ClientEmulator.isEndOfSimulation())
    {
      // Select a random user for this session
      if (isAuthorSession)
      {
        userId = rand.nextInt(rubbos.getNbOfAuthors());
        username = "author"+(userId+1);
      }
      else
      {
        userId = rand.nextInt(rubbos.getNbOfUsers());
        username = "user"+(userId+1);
      }
      password = "password"+(userId+1);
      nbOfTransitions = rubbos.getMaxNbOfTransitions();
      if (debugLevel > 2)
        System.out.println("Thread "+this.getName()+": Starting a new user session for "+username+" ...<br>");
      startSession = System.currentTimeMillis();
      // Start from Home Page
      transition.resetToInitialState();
      next = transition.getCurrentState();
      while (!ClientEmulator.isEndOfSimulation() && !transition.isEndOfSession() && (nbOfTransitions > 0))
      {
        // Compute next step and call HTTP server (also measure time spend in server call)
        lastURL = computeURLFromState(next);
        if (lastURL == null)
        {
          // Yasu:
          // System.out.println("Thread "+this.getName()+": Fatal error in computing next: " + next + " URL. Restarting from home page.<br>");
          System.err.println("Thread "+this.getName()+": Fatal error in computing next: " + next + " URL. Restarting from home page.<br>");
          transition.resetToInitialState();
          lastURL = urlGen.homePage();
        }
	next = transition.getCurrentState(); // Yasu: State may be changed in getCurrentState()
        time = System.currentTimeMillis();
        lastHTMLReply = callHTTPServer(lastURL);
	// Yasu:
        time2 = System.currentTimeMillis();
        stats.incrementCount(next);

        // If an error occured, reset to Home page
        if ((lastHTMLReply == null) || (lastHTMLReply.indexOf("ERROR") != -1))
        {
          if (debugLevel > 0)
            // Yasu:
            // System.out.println("Thread "+this.getName()+": Error returned from access to "+lastURL+"<br>");
            System.err.println("Thread "+this.getName()+": Error returned from access to "+lastURL+"<br>");
          stats.incrementError(next);
          if (debugLevel > 1)
			System.out.println("Thread "+this.getName()+": HTML reply was: "+lastHTMLReply+"<br>");
          transition.resetToInitialState();
          next = transition.getCurrentState();
        }
	// Yasu: Only in success case, we can increase the amount of time
        else {
          stats.updateTime(next, time2 - time, time2);
          next = transition.nextState();
	}
        nbOfTransitions--;
      }
      if ((transition.isEndOfSession()) || (nbOfTransitions == 0))
      {
        if (debugLevel > 2)
          System.out.println("Thread "+this.getName()+": Session of "+username+" successfully ended<br>");
        endSession= System.currentTimeMillis();
        long sessionTime = endSession - startSession;
        stats.addSessionTime(sessionTime);
      }
      else
      {
        if (debugLevel > 2)
          System.out.println("Thread "+this.getName()+": Session of "+username+" aborted<br>");
      }
    }

    try
    {
	//      dictionary.close();
    }
    catch (Exception e)
    {
      System.err.println("Unable to close dictionary file '"+rubbos.getStoryDictionary()+"' (got exception: "+e.getMessage()+")<br>");
    }

  }

}
