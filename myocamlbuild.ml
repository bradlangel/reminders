open Ocamlbuild_plugin;;

let f = function
  | After_rules ->
    flag ["ocaml"; "compile"; "no_warn_unused_value"] (S [A "-w"; A"-32"]);
    ()
  | _ -> ()
in
dispatch (fun h -> f h; Ocamlbuild_atdgen.dispatcher h)
;;
