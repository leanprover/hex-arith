import Lake

open System Lake DSL

package «hex-arith» where
  leanOptions := #[⟨`doc.verso, true⟩, ⟨`doc.verso.suggestions, false⟩]

private def hexArithOTarget (pkg : Package) (src : String) : FetchM (Job FilePath) := do
  let stem := (src.dropEnd 2).toString
  let oFile := pkg.dir / defaultBuildDir / "HexArith" / "ffi" / s!"{stem}.o"
  let srcTarget ← inputTextFile <| pkg.dir / "HexArith" / "ffi" / src
  buildFileAfterDep oFile srcTarget fun srcFile => do
    compileO oFile srcFile #["-I", (← getLeanIncludeDir).toString, "-fPIC", "-O3"]

extern_lib hexarithffi (pkg) := do
  let name := nameToStaticLib "hexarithffi"
  let targets ← #["wide_arith.c", "mpz_gcdext.c"].mapM (hexArithOTarget pkg)
  buildStaticLib (pkg.staticLibDir / name) targets

@[default_target]
lean_lib HexArith where
  precompileModules := true
  moreLinkArgs := #["-lgmp"]
