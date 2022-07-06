
"""

# d_separation

$(SIGNATURES)

Computes the d_separation between 2 sets of nodes conditioned on a third set.

### Required arguments
```julia
d_separation(
* `d::DAG`                             : DAG
* `f::SymbolList`                      : First set
*  s::SymbolList`                      : Second set
)
```

### Keyword arguments
```julia
* `c::SymbolListOrNothing=nothing`     : Conditioning set
* `debug=false`                        : Trace execution
```

### Returns
```julia
* `res::Bool`                          : Boolean result of test
```

# Extended help

### Example

### d_separation between mechanics and statistics, conditioning on algebra
```julia
using StructuralCausalModels, CSV

df = DataFrame!(CSV.File(scm_path("..", "data", "marks.csv"));

d = OrderedDict(
  :mechanics => [:vectors, :algebra],
  :vectors => [:algebra],
  :analysis => [:algebra],
  :statistics => [:algebra, :analysis]
);

dag = DAG("marks", d, df);
d_separation(marks, [:statistics], [:mechanics]; c=[:algebra]))
```
### Acknowledgements

Original author:                       Giovanni M. Marchetti

Translated to Julia:                   Rob J Goedman

### License

The R package ggm is licensed under License: GPL-2.

The Julia translation is licenced under: MIT.

Part of the API, exported.
"""
function d_separation(d::DAG, f::SymbolList, s::SymbolList; 
  c::SymbolListOrNothing=nothing, debug=false)
  
  e = induced_covariance_graph(d, vcat(f, s), c; debug=debug)
  sum(e[f, s]) == 0

end

export
  d_separation
