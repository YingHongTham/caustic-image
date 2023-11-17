using Graphs
using GraphPlot
using Plots
#need following for GraphPlot
using Compose
import Cairo, Fontconfig
using LinearAlgebra

product = Base.Iterators.product

# ============================================
# planar graph functionality

# will assume set of vertices is labeled by 1:N
# E[i] is dictionary { u => (l,r) }, where
# u,l,r are neighbors of i
# l is to the left of i->u, r is to the right
struct PlanarGraph
  N::Int
  E::Array{Dict{Int, Tuple{Int,Int}}}
end

# F = faces (u,v,w) - ordered counterclockwise
function PlanarGraph(N::Int, F::Array{Tuple{Int,Int,Int}})
  E = [Dict() for i ∈ 1:N]
  for f ∈ F
    for i ∈ 1:3
      u = f[i]
      v = f[(i+1) > 3 ? i-2 : i+1]
      w = f[(i+2) > 3 ? i-1 : i+2]
      !haskey(E[u], v) && (E[u][v] = (0,0))
      !haskey(E[u], w) && (E[u][w] = (0,0))
      E[u][v] = (w, E[u][v][2]) # tuples are not mutable
      E[u][w] = (E[u][w][1], v)
    end
  end
  return PlanarGraph(N,E)
end

neigh_left(G, u, v) = G.E[u][v][1]
neigh_right(G, u, v) = G.E[u][v][2]
# return value of 0 indicates that u->v is a boundary edge!


# ============================================
# initialize random points

# vertices
N = 1000
V = [[rand(), rand()] for v ∈  1:N]

#draw(PNG("lattice-torus.png", 8cm, 8cm), gplot(tri, nodelabel=1:N))


# =============================================
# main algo

# first sort vertices by x coord

sort!(V);

# construct Voronoi diagram on V[lo:hi]
function getVoronoi(lo, hi)
	println("$lo,$hi")
	if lo == hi
		return 0
	end
	if lo + 1 == hi
		return 0
	end
	mid = floor(Int, (lo + hi)/2)
	getVoronoi(lo,mid)
	getVoronoi(mid+1,hi)
end

# TODO convex hull function

# voronoi divide n conquer algo:
# https://cw.fel.cvut.cz/b181/_media/courses/cg/lectures/06-voronoi-split.pdf
#
# some work on inverse caustic image problem:
# https://www.uni-ulm.de/fileadmin/website_uni_ulm/iui.inst.100/institut/verz-ma-ehedem/holger/causticRecon.pdf
