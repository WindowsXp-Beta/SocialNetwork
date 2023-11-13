package edu.rice.rubbos.client;

import java.io.BufferedReader;
import java.io.Reader;
import java.io.InputStreamReader;
import java.io.InputStream;

public class ReadLineThread extends Thread
{
    BufferedReader m_Reader;
    public ReadLineThread(InputStream ins)
    {
	m_Reader = new BufferedReader(new InputStreamReader(ins));
    }

    public void run()
    {
	String msg = "";
	try{
	    while((msg = m_Reader.readLine()) != null)
		{
		}
	    
	    m_Reader.close();
	} catch (Exception e){}
    }
}
