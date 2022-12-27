
module queens_aux{

    use	queens_serial;

    proc queens_caller(const search_type: string = "sqr", const size: uint(16)){

    	use Time; // Import the Time module to use Timer objects
    	var timer: Timer;
        var metrics: (uint(64),uint(64));


    	if(search_type == "sqr"){

    		timer.start(); // Start timer
    		metrics =  queens_serial_regular(size);
    		timer.stop(); // Start timer
    		writeln("\nSerial Regular Queens for size ", size, ".\n");
    		writeln("\tNumber of solutions: ", metrics[0], ".\n");
    		writeln("\tTree size: ", metrics[1], ".\n");
    		writeln("Elapsed time: ", timer.elapsed()*1000, " ms."); // Print elapsed time
    	 	timer.clear(); // Clear timer for parallel loop
            
     	}
     	else{

    	 		if(search_type == "sqb"){
    				timer.start(); // Start timer
    				metrics = queens_serial_bitset(size);
    				timer.stop(); // Start timer
    				writeln("\nSerial Bitset Queens for size ", size, ".\n");
    				writeln("\tNumber of solutions: ", metrics[0], ".\n");
    				writeln("\tTree size: ", metrics[1], ".\n");
    				writeln("Elapsed time: ", timer.elapsed()*1000, " ms."); // Print elapsed time
    			 	timer.clear(); // Clear timer for parallel loop
    			}
    			else
    				writeln("\n\n###Wrong parameters.###\n\n");
     	}

    }//parser



}//module
