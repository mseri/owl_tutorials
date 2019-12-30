(*
 * OWL - OCaml Scientific and Engineering Computing
 * OWL-ODE - Ordinary Differential Equation Solvers
 *
 * Copyright (c) 2019 Ta-Chu Kao <tck29@cam.ac.uk>
 * Copyright (c) 2019 Marcello Seri <m.seri@rug.nl>
 *)

module Types = Owl_ode_base.Types

type mat = Owl_dense_matrix_s.mat

module Euler :
  Types.Solver
    with type state = mat
     and type f = mat -> float -> mat
     and type step_output = mat * float
     and type solve_output = mat * mat

module Midpoint :
  Types.Solver
    with type state = mat
     and type f = mat -> float -> mat
     and type step_output = mat * float
     and type solve_output = mat * mat

module RK4 :
  Types.Solver
    with type state = mat
     and type f = mat -> float -> mat
     and type step_output = mat * float
     and type solve_output = mat * mat

(** Default tol = 1e-7 *)
module RK23 :
  Types.Solver
    with type state = mat
     and type f = mat -> float -> mat
     and type step_output = mat * float * float * bool
     and type solve_output = mat * mat

module RK45 :
  Types.Solver
    with type state = mat
     and type f = mat -> float -> mat
     and type step_output = mat * float * float * bool
     and type solve_output = mat * mat

val euler
  : (module Types.Solver
       with type state = mat
        and type f = mat -> float -> mat
        and type step_output = mat * float
        and type solve_output = mat * mat)

val midpoint
  : (module Types.Solver
       with type state = mat
        and type f = mat -> float -> mat
        and type step_output = mat * float
        and type solve_output = mat * mat)

val rk4
  : (module Types.Solver
       with type state = mat
        and type f = mat -> float -> mat
        and type step_output = mat * float
        and type solve_output = mat * mat)

val rk23
  :  tol:float
  -> dtmax:float
  -> (module Types.Solver
        with type state = mat
         and type f = mat -> float -> mat
         and type step_output = mat * float * float * bool
         and type solve_output = mat * mat)

val rk45
  :  tol:float
  -> dtmax:float
  -> (module Types.Solver
        with type state = mat
         and type f = mat -> float -> mat
         and type step_output = mat * float * float * bool
         and type solve_output = mat * mat)

(* ----- helper function ----- *)

val to_state_array : ?axis:int -> int * int -> mat -> mat array
