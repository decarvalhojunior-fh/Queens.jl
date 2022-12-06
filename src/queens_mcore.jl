# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

function queens_mcore_caller(size, number_of_subproblems, subproblems) 

	cutoff_depth = getCutoffDepth()
    num_threads = Threads.nthreads()
	thread_tree_size = zeros(Int64, num_threads)
	thread_num_sols  = zeros(Int64, num_threads)
	thread_load = fill(div(number_of_subproblems, num_threads), num_threads)
	stride = div(number_of_subproblems, num_threads)
	thread_load[num_threads] += mod(number_of_subproblems, num_threads)

	@sync begin
		for ii in 0:(num_threads-1)

			local local_thread_id = ii
			local local_load = thread_load[local_thread_id + 1]

			Threads.@spawn begin
			    # @info  "thread: $(string(local_thread_id)) has $(string(local_load)) iterations"
				for j in 1:local_load

					s = local_thread_id * stride + j

					local_number_of_solutions, local_partial_tree_size = queens_tree_explorer_parallel(Val(size), Val(cutoff_depth), subproblems[s][1], subproblems[s][2])
					thread_tree_size[local_thread_id + 1] += local_partial_tree_size
					thread_num_sols[local_thread_id + 1]  += local_number_of_solutions
				end
			end

		end
	end
	mcore_number_of_solutions = sum(thread_num_sols)
	mcore_tree_size = sum(thread_tree_size)

	return mcore_number_of_solutions, mcore_tree_size

end #caller

function init_queens_mcore()
	@info "running mcore queens"
end

function queens_mcore(size)

	cutoff_depth = getCutoffDepth()
	size += 1

	(subproblems, number_of_subproblems, partial_tree_size) = queens_partial_search!(Val(size), cutoff_depth)

	number_of_solutions, tree_size = queens_mcore_caller(size, number_of_subproblems, subproblems) 
	tree_size += partial_tree_size

	return number_of_solutions, tree_size

end #caller


