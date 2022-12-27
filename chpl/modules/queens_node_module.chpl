

module queens_node_module{

	use queens_constants;
	
	record queens_node{
		var control: uint(32);
        var board: [0.._MAX_DPTH_] int(8);
	}

	proc queens_print_all_nodes(set_of_nodes: [] queens_node, const qtd: uint(64), const depth: int(32)){
		writeln("### PRINTING ALL NODES ###\n");
		for n in 0..qtd-1{
			writeln("\nNode ", n,": ");
			for d in 0..depth-1{
				write(set_of_nodes[n].board[d], " - ");
			}
		writeln("\n");
		}
	}

}//end of module