(* (c) 2017, 2018 Hannes Mehnert, all rights reserved *)

open Lwt.Infix

open Mirage_types_lwt

module Main (R : RANDOM) (P : PCLOCK) (M : MCLOCK) (T : TIME) (S : STACKV4) (RES: Resolver_lwt.S) (CON: Conduit_mirage.S) = struct

  let start _rng pclock mclock _ s resolver conduit _ =
    let (module Context) = Irmin_mirage.context (resolver, conduit) in
    let module Store = Store.Make(Context)(Inflator) in
    Store.pull () >>= fun () ->
    Store.get ["README.md"] >>= fun data ->
    Logs.info (fun m -> m "README.md: %s" data) ;
    Store.retrieve [] >>= fun bindings ->
    Logs.info (fun m -> m "found %d bindings: %a" (List.length bindings)
                  Fmt.(list ~sep:(unit ",@ ") (pair ~sep:(unit ": ") string int))
                  (List.map (fun (k, v) -> String.concat "/" k, String.length v) bindings)) ;
    Lwt.return_unit
end
