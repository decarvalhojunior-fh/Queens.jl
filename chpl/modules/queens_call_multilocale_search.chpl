module queens_call_multilocale_search{

    use queens_tree_exploration;
    use queens_constants;
    use queens_node_module;
    use queens_prefix_generation;
    use Time;
    use BlockDist;
    use CyclicDist;
    use VisualDebug;
    use DistributedIters;

    proc print_locales_information(){
        writeln("\nNumber of locales: ",numLocales,".");
        for loc in Locales do{
            on loc {
                writeln("\n\tLocale ", here.id, ", name: ", here.name,".");
            }
        }//end for
    }//print locales

    proc queens_node_call_multilocale_search(const size: uint(16), const initial_depth: int(32),
        const scheduler: string = "dynamic", const mlchunk: int = 1, const lchunk: int = 1, const profiler: bool = false){

    	
        print_locales_information();
        
        writeln("\n ### Multi-locale N-Queens for size: ", size, ".\n\t");
        writeln("\n\tType: ", scheduler,".\n\tML-Chunk: ", mlchunk, " L-Chunk:", lchunk,".\n");
        

        var metrics: (uint(64),uint(64)) = (0:uint(64),0:uint(64));

        var initial_num_prefixes : uint(64);
        var initial_tree_size : uint(64) = 0;
        var number_of_solutions: uint(64) = 0;
        var final_tree_size: uint(64) = 0;
        var parallel_tree_size: uint(64) = 0;
        var performance_metrics: real = 0.0;
        var parallel_search: Timer;
        var initial_procedure: Timer;

        initial_procedure.start(); // Start timer

        var real_number_prefixes: uint(64) = queens_how_many_prefixes(size,initial_depth);
    	var maximum_number_prefixes: uint(64) = queens_get_number_prefixes(size,initial_depth);
        var local_set_of_nodes: [0..maximum_number_prefixes-1] queens_node;

    	const Space = {0..(real_number_prefixes-1):int}; //otherwise 
		const D: domain(1) dmapped Block(boundingBox=Space) = Space; //1d block
    	//const D = Space dmapped Cyclic(startIdx=Space.low);
        var set_of_nodes: [D] queens_node;

                
       // metrics += queens_mlocale_generate_initial_prefixes(size,initial_depth, set_of_nodes );
        metrics+=queens_node_generate_initial_prefixes(size,initial_depth, local_set_of_nodes );

        //profiler
        if(profiler){
            startVdebug("search");
            tagVdebug("initial forall");
            writeln("Starting profiler");
        }//end of profiler

        forall i in Space do
            set_of_nodes[i] = local_set_of_nodes[i:uint(64)];
        
        initial_procedure.stop();
        

        initial_num_prefixes = metrics[0];
        initial_tree_size = metrics[1];
        metrics[0] = 0; //restarting for the parallel search_type
        metrics[1] = 0;


        if(profiler){
            tagVdebug(scheduler);
        }
        
        parallel_search.start();

        select scheduler{
            when "static" {
                forall n in set_of_nodes with (+ reduce metrics) do {
                    metrics+=queens_node_subtree_exporer(size,initial_depth,n.board, n.control);
                }
            }
            when "dynamic" {
                
                forall idx in distributedDynamic(c=Space,chunkSize=lchunk,localeChunkSize=mlchunk) with (+ reduce metrics) do {
                    metrics+=queens_node_subtree_exporer(size,initial_depth,set_of_nodes[idx].board,set_of_nodes[idx].control);
                }
            }
            when "guided" {              
                forall idx in distributedGuided(c=Space,minChunkSize=mlchunk) with (+ reduce metrics) do {
                    metrics+=queens_node_subtree_exporer(size,initial_depth,set_of_nodes[idx].board,set_of_nodes[idx].control);
                }
            }
            otherwise{
                writeln("\n\n ###### error ######\n\n ###### error ######\n\n ###### error ###### \n\n ###### WRONG PARAMETERS ###### ");
            }
        }

        parallel_search.stop(); // Start timer


        if(profiler){
            stopVdebug();
        }

        number_of_solutions = metrics[0];
        parallel_tree_size =  metrics[1] ;
        final_tree_size = initial_tree_size + parallel_tree_size;
        performance_metrics = (final_tree_size:real)/(parallel_search.elapsed()+initial_procedure.elapsed());


        writeln("\n### Multi-locale N-Queens ###\n\tProblem size (N): ", size,"\n\tCutoff depth: ",
         initial_depth,"\n\tInitial number of prefixes: ", initial_num_prefixes,
         "\n\n\tInitial tree size: ", initial_tree_size,
         "\n\tParallel tree size: ", parallel_tree_size,
         "\n\tFinal tree size: ", final_tree_size,
         "\n\n\tNumber of solutions found: ", number_of_solutions
         );

         writef("\n\nElapsed time: %.3dr ms.", (parallel_search.elapsed()+initial_procedure.elapsed())*1000);
         writef("\n\tElapsed time -  Initial Procedure: %.3dr ms.", (initial_procedure.elapsed())*1000);
         writef("\n\tElapsed time -  Initial Multi-Locale Search: %.3dr ms.", (parallel_search.elapsed())*1000);

         writef("\n\tPerformance: %.3dr (n/s)\n\n\n",  performance_metrics);

        parallel_search.clear();
        initial_procedure.clear();    
    }
}//end of mudule