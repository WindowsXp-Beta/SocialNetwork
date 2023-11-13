package edu.rice.rubbos.client;

import java.net.*;
import java.io.*;

import java.util.Random;
import java.util.Date;
import java.util.Vector;
public class MMPP {

/********************************
 * Each state in MMPP
********************************/
class STATE {
    double  mean;            // mean service time
    double[]   p;               /* transmission probabilities
                                p[i*#states+j] is the probability of
                                transmission from this state to state j
                                in D_i */
    Random	rand_ind;        // rand stream index of service time
    Random	rand_trans;      // rand stream index of state transmission
    double 	during;          // during time in this state

	public STATE() {
		mean		= 0.0;
		rand_ind	= null;
		rand_trans	= null;
		during		= 0.0;
		p			= null;
	}
} //class States


	STATE[]	states;     // states in BMAP
	int     numState;   // number of states
	int     numBulk;    // number of bulk arrivals
	int     curr_ind;   // index of current state
	double  mean;       // mean
	double  svar;       // \sum (x_i - mean)
	int   number;     	// number of intervals generated

	final double INF	= 999999999;

	// Constructor of MMPP
	// rand: rand seed for random to be used in this object
	public MMPP(Random rand){
		initialization(rand);	
	}

	public MMPP(){
  		Random rand = new Random();
		initialization(rand);	
	}


	// To initialize the MMPP
	// Get D0 and D1
    void initialization(Random rand) {
		int i, j, k;

		try {

		numState	= 2;
		numBulk		= 1;
		
		//2-state MAP with Z=7sec,I=4000
/*		double [][][] D =
		{	{	{-0.03443249765465439,  0},
   				{0,    -192.8605531916577}
			},
			{	{0.03439111976070266,     0.00004137789395173437},
   				{0.07354649281846881,     192.7870066988392}
			}
		};
*/
		
	//		I = 4000, threshold = 0.4, www_map(7, 4000, 5000)
//		  double [][][] D =
//				{	{	{-0.0347,  0},
//		   				{0,    -173.3485}
//					},
//					{	{0.0346,     0},
//		   				{0.0652,     173.3193}
//					}
//				};
//
//                                        //I = 1000 threshold = 0.4, www_map(7, 1000, 5000)
//                                 double [][][] D =
//                                                {       {       {-0.0347,  0},
//                                                                {0,    -173.3845}
//                                                        },
//                                                        {       {0.0345,     0.0002},
//                                                                {0.2645,     173.1200}
//                                                        }
//                                                };
//

		  //I = 1000 threshold = 0.4, www_map(7, 1000, 1000)
//                  double [][][] D =
//                                {       {       {-0.0357,  0},
//                                                {0,    -693.53}
//                                        },
//                                        {       {0.0356,     0.0002},
//                                                {1.0335,     692.5044}
//                                        }
//                                };
//




					//I = 400 threshold = 0.4, www_map(7, 400, 5000)
//				 double [][][] D =
//				{	{	{-0.0347,  0},
//				   				{0,    -173.3845}
//						},
//							{	{0.0343,     0.0004},
//				   				{0.6580,     172.7264}
//							}
//						};


                                        //I = 400 threshold = 0.4, www_map(7, 400, 1000)
//                                 double [][][] D =
//                                        {       {       {-0.0357,  0},
//                                                                {0,    -693.5379}
//                                                },
//                                                        {       {0.0353,     0.0004},
//                                                                {2.5858,     690.9521}
//                                                        }
//                                                };
//


                                        //I = 200 threshold = 0.4, www_map(7, 400, 5000)
                                 double [][][] D =
                                {       {       {-0.0357,  0},
                                                                {0,    -693.5379}
                                                },
                                                        {       {0.0349,     0.0008},
                                                                {5.2651,     688.2727}
                                                        }
                                                };








				//I = 100 www_map(7, 100, 1000)	
//						 double [][][] D =
//							{	{	{-0.0357,  0},
//					   				{0,    -693.5379}
//								},
//								{	{0.0357,     0.0016},
//						   			{10.3894,     683.1485}
//								}
//							};
//

                                //I = 50 threshold = 0.2
//                                 double [][][] D =
//                                                {       {       {-0.0347, 0},
//                                                                { 0, -173.3845}
//                                                        },
//                                                        {       {0.0313, 0.0034},
//                                                                {5.3896, 167.9949}
//                                                        }
//                                                };

				//I = 30 threshold = 0.2	
//	                           double [][][] D =
//						{	{	{-0.0347, 0},
//				   				{ 0, -173.3845}
//							},
//							{	{0.0290 , 0.0057},
//				   				{9.0626 , 164.3219}
//							}
//						};		

				//I = 20 threshold = 0.2
//	                           double [][][] D =
//						{	{	{-0.0347, 0},
//				   				{ 0, -173.3845}
//							},
//							{	{0.0261 , 0.0085},
//				   				{13.6826 , 159.7019}
//							}
//						};		

//		

		states	= new STATE[numState];
		for (i = 0; i < numState; i++) {
			states[i]=new STATE();
			states[i].mean       = 0.0;
            states[i].rand_ind   = new Random(rand.nextLong());
            states[i].rand_trans = new Random(rand.nextLong());
            states[i].during     = 0.0;
            states[i].p          = new double[(numBulk+1) * numState];
        }

	//D[j][i][k]: j={D0,D1}, i={state0, state1}, ki={state0, state1}, e.g., D[0][1][0]=-192.86 	
	//states[i].p[j*numState+k]: i state 0 D_0^00, D_0^01, D_1^00, D_1^01; i state 1 D_0^10, D_0^11, D_1^10, D_1^11

	for (j = 0; j < numBulk + 1; j++) {
            for (i = 0; i < numState; i++) {
                for (k = 0; k < numState; k++) {
                    states[i].p[j*numState+k]	= D[j][i][k];
                    if (states[i].p[j*numState+k] < 0.0) states[i].p[j*numState+k] = 0.0; //diagonal in D0
                    states[i].mean += states[i].p[j*numState+k];
                } // k
            } // i
        } // j

	//further adjust the probibility for each state
        //(1) normalized by mean --> small than 1.0 (2) sum the previous probs, p0, p0+p1, p0+p1+p2...1
        for (j = 0; j < numBulk + 1; j++) {
            for (i = 0; i < numState; i++) {
                for (k = 0; k < numState; k++) {
					if (states[i].mean == 0)
                    	states[i].p[j*numState+k] = 0;
					else
						states[i].p[j*numState+k] = states[i].p[j*numState+k] / states[i].mean;
                    if (j*numState+k > 0)
                        states[i].p[j*numState+k] += states[i].p[j*numState+k-1];
                } // k
            } // i
        } // j

		} catch (java.lang.Exception ex) {
			System.out.println("Error in initialize MMPP");
			ex.printStackTrace();
		}
	} // initialization()


	/*************************************************************************
 	 * PURPOSE:     Generate interarrival time for BMAP
 	 * RETURN:      the number which follows BMAP distribution
     	            bulk -- number of arrivals
 	 ************************************************************************/
	public synchronized double gen_interval()
	{
    	double  interval    = 0.0;
    	double  theo_mean   = 0.0;
    	double  prob;
    	int i, bulk;
    
    	theo_mean = states[curr_ind].mean;
		if (theo_mean < 0.000001) 
			states[curr_ind].during = INF;
		else
            states[curr_ind].during = Expo(1/theo_mean, states[curr_ind].rand_ind);
    
    	interval += states[curr_ind].during;
    	if (interval == INF) 
        	return interval;
    	
	//find the next state based on prob
    	prob = states[curr_ind].rand_trans.nextDouble();
    	for (i = 0; i < numState*(numBulk+1); i++)
        	if (prob <= states[curr_ind].p[i]) break;
    
    	bulk= i / numState; //D0, D1
    	i   = i % numState; //state 0, state 1
    	curr_ind = i;
    
    	if (bulk == 0) //instate transition, continue; otherwise enter absorb state, stop, one job completed
        	interval += gen_interval();
    	
		return interval;
	} // get_interval()


    /*********************************************
	 * Exponential distribution
	**********************************************/
	private double Expo(double m, Random rand)
	{
		return (-m * Math.log(1.0 - rand.nextDouble()));
	}


	/********************************************************
 	 * Print out transmission probabilities
	 ********************************************************/
	private void print_P()
	{
    	int i, j;

   		for (i = 0; i < numState; i++) {
       		System.out.print("\n--------------------- State " + i + " ----------------------\n");
     		for (j = 0; j < numState * (numBulk+1); j++) 
           		System.out.print(states[i].p[j] + "\t");
	       		System.out.println();
   		} // for i
	} // print_P
} // class MMPP



