using Aqua

@testset "Aqua.jl" begin
   Aqua.test_all(
      Singular;
      ambiguities=false,         # TODO: fix ambiguities
      unbound_args=false,        # TODO: fix unbound args
      undefined_exports=true,
      project_extras=true,
      stale_deps=true,
      deps_compat=true,
      project_toml_formatting=true,
      piracy=false               # TODO: fix piracy
   )
end
