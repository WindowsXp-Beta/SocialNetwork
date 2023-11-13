import java.util.Random;

class test 
{
    public static void main(String argv[])
    {
	Random r = new Random();

	System.out.println(r.nextInt(2));
	System.out.println(r.nextInt(2));
	System.out.println(r.nextInt(2));
	System.out.println(r.nextInt(2));
	System.out.println(r.nextInt(2));

	/*
	// pick a word len 2 ~ 10 characters
	int wordLen = r.nextInt(8) + 2;

	String word = "";
	System.out.println(wordLen);
	for(int i=0; i < wordLen; i++)
	    {
		if(r.nextInt(2) == 0)
		    {
		word += (char)(byte)(r.nextInt(24) + 65);
		    } else
			word += (char)(byte)(r.nextInt(24) + 97);
	    }
	System.out.println(word);
	*/
	
    }

}
