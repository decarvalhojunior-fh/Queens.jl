

 config const size: uint(16) = 10;

config const serial_search: string = "sqb";

//needs to be int because the search uses an int depth.
config const initial_depth: int(32) = 4;
config const scheduler: string = "static";
config const lchunk: int = 1;
config const mlchunk: int = 1;
config const mode: string = "none";
config const num_threads: int = here.maxTaskPar;
config const profiler: bool = false;

use queens_aux;
use queens_call_mcore_search;
use queens_call_multilocale_search;

proc main(){

	select mode{
		when "serial"{
			queens_caller(serial_search,size);
		}
		when "mcore"{
			queens_node_call_search(size, initial_depth,scheduler,lchunk,num_threads);
		}
		when "mlocale"{
			queens_node_call_multilocale_search(size, initial_depth,scheduler,mlchunk,lchunk,profiler);

		}
		otherwise{
			writeln("#### Wrong parameters ####");
		}
	}

}
