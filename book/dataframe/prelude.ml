#require "owl,owl-top";;

open Owl
open Bigarray

let () = Printexc.record_backtrace false
let () = 
  Owl_base_stats_prng.init 89;
  Owl_stats_prng.init 89