module queens_call_mcore_search{

    use queens_tree_exploration;
    use queens_constants;
    use queens_node_module;
    use queens_prefix_generation;
    use DynamicIters;
    use Time; // Import the Time module to use Timer objects
    /* config param methodStealing = Method.Whole; */
    /* config param methodStealing = Method.RoundRobin; */
    config param methodStealing = Method.WholeTail;



    proc queens_node_call_search(const size: uint(16), const initial_depth: int(32), 
        const scheduler: string = "static", const chunk: int = 32, const num_threads: int){

        var maximum_number_prefixes: uint(64) = queens_get_number_prefixes(size,initial_depth);
        var set_of_nodes: [0..maximum_number_prefixes-1] queens_node;
        var metrics: (uint(64),uint(64)) = (0:uint(64),0:uint(64));

        var initial_num_prefixes : uint(64) = 0;
        var initial_tree_size : uint(64) = 0;
        var number_of_solutions: uint(64) = 0;
        var final_tree_size: uint(64) = 0;
        var parallel_tree_size: uint(64) = 0;
        var performance_metrics: real = 0.0;
        var timer: Timer;

        writeln("\n ### NODES ### \n Mcore N-Queens for size: ", size ,".\n\tCreating ", num_threads ," threads.\n " );
        
        timer.start(); // Start timer

        metrics += queens_node_generate_initial_prefixes(size,initial_depth, set_of_nodes );

        initial_num_prefixes = metrics[0];
        initial_tree_size = metrics[1];
        metrics[0] = 0; //restarting for the parallel search_type
        metrics[1] = 0;

        //writeln(set_of_nodes);

        
        var aux: int = initial_num_prefixes: int;
        var rangeDynamic: range = 0..aux-1;
        
        select scheduler{

            when "static" {
                forall idx in 0..initial_num_prefixes-1 with (+ reduce metrics) do {
                     metrics+=queens_node_subtree_exporer(size,initial_depth,set_of_nodes[idx].board,set_of_nodes[idx].control);    
                }
            }
            when "dynamic" {
                writeln("\n\tChunk size: ", chunk, " (if dynamic).\n");
                forall idx in dynamic(rangeDynamic, chunk, num_threads) with (+ reduce metrics) do {
                    metrics+=queens_node_subtree_exporer(size,initial_depth,set_of_nodes[idx:uint(64)].board,set_of_nodes[idx:uint(64)].control);
                }
            }
            when "guided" {
                forall idx in guided(rangeDynamic,num_threads) with (+ reduce metrics) do {
                    metrics+=queens_node_subtree_exporer(size,initial_depth,set_of_nodes[idx:uint(64)].board, set_of_nodes[idx:uint(64)].control);
                }
            }
            when "stealing" {
                forall idx in adaptive(rangeDynamic,num_threads) with (+ reduce metrics) do {
                    metrics+=queens_node_subtree_exporer(size,initial_depth,set_of_nodes[idx:uint(64)].board, set_of_nodes[idx:uint(64)].control);
                }
            }
            otherwise{
                writeln("\n\n ###### error ######\n\n ###### error ######\n\n ###### error ###### ");
            }
        }//select


        timer.stop(); // Start timer

        number_of_solutions = metrics[0];
        parallel_tree_size =  metrics[1] ;
        final_tree_size = initial_tree_size + parallel_tree_size;
        performance_metrics = (final_tree_size:real)/timer.elapsed();


        writeln("\n### Multicore N-Queens - ", scheduler ," ###\n\tProblem size (N): ", size,"\n\tCutoff depth: ",
         initial_depth,"\n\tInitial number of prefixes: ", initial_num_prefixes,
         "\n\n\tInitial tree size: ", initial_tree_size,
         "\n\tParallel tree size: ", parallel_tree_size,
         "\n\tFinal tree size: ", final_tree_size,
         "\n\n\tNumber of solutions found: ", number_of_solutions
         );

         writef("\n\nElapsed time: %.3dr ms.", timer.elapsed()*1000);

         writef("\n\tPerformance: %.3dr (n/s)\n\n\n",  performance_metrics);

         timer.clear();

   }//end of caller


}
