# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

function init_queens_sgpu()
	@info "running sgpu queens"
	configureHeap()
end

function queens_sgpu(size)

	size += 1

	cutoff_depth = getCutoffDepth()

	(subproblems, number_of_subproblems, partial_tree_size) = queens_partial_search!(Val(size), cutoff_depth)

	number_of_solutions, tree_size = queens_gpu_caller(size, cutoff_depth, number_of_subproblems, 1, subproblems)

    CUDA.reclaim()

	return number_of_solutions, tree_size + partial_tree_size

end #caller














#