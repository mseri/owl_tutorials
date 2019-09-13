open! Core_kernel
open! Import
open! Hash_queue

module Hq_arg = struct
  include String

  let hash (x : t) = Hashtbl.hash x
  let sexp_of_t = Sexplib.Conv.sexp_of_string
end

module Hq = Hash_queue.Make (Hq_arg)

let%test_unit _ =
  let hq = Hq.create () in
  let inv () = Hq.invariant hq in
  (* tests over empty queue *)
  inv ();
  assert (Hq.is_empty hq);
  assert (Hq.dequeue_front hq = None);
  assert (
    try
      ignore (Hq.dequeue_front_exn hq);
      false
    with
    | _ -> true);
  assert (Hq.dequeue_front_with_key hq = None);
  assert (
    try
      ignore (Hq.dequeue_front_with_key_exn hq);
      false
    with
    | _ -> true);
  Hq.dequeue_all hq ~f:(fun _ -> assert false);
  assert (Hq.remove hq "foobar" = `No_such_key);
  assert (
    try
      ignore (Hq.remove_exn hq "foobar");
      false
    with
    | _ -> true);
  assert (Hq.replace hq "foobar" 0 = `No_such_key);
  assert (
    try
      ignore (Hq.replace_exn hq "foobar" 0);
      false
    with
    | _ -> true);
  assert ([] = Hq.foldi hq ~init:[] ~f:(fun ac ~key:_ ~data:_ -> () :: ac));
  assert ([] = Hq.fold hq ~init:[] ~f:(fun ac _ -> () :: ac));
  Hq.iteri hq ~f:(fun ~key:_ ~data:_ -> assert false);
  (* test with 10 elems *)
  let n = 10 in
  for i = 1 to n do
    assert (Hq.enqueue_back hq (string_of_int i) i = `Ok);
    inv ()
  done;
  assert (Hq.length hq = n);
  assert (
    List.rev (Hq.foldi hq ~init:[] ~f:(fun ac ~key ~data -> (key, data) :: ac))
    = List.init n ~f:(fun i ->
      let i = i + 1 in
      string_of_int i, i));
  assert (
    List.rev (Hq.fold hq ~init:[] ~f:(fun ac data -> data :: ac))
    = List.init n ~f:(fun i -> i + 1));
  Hq.iteri hq ~f:(fun ~key ~data -> assert (key = string_of_int data));
  (* test removing the first element from the queue *)
  let sum = ref 0 in
  Hq.iter hq ~f:(fun x -> sum := !sum + x);
  assert (!sum = n * (n + 1) / 2);
  assert (Hq.mem hq "1");
  ignore (Hq.dequeue_front hq);
  inv ();
  assert (not (Hq.mem hq "1"));
  assert (Hq.length hq = n - 1);
  (* remove the last *)
  assert (Hq.remove hq (string_of_int n) = `Ok);
  (* double remove *)
  assert (Hq.remove hq (string_of_int n) = `No_such_key);
  inv ();
  assert (Hq.length hq = n - 2);
  (* remove everything *)
  let num = ref 0 in
  Hq.dequeue_all hq ~f:(fun _ -> num := !num + 1);
  inv ();
  assert (!num = n - 2);
  assert (Hq.is_empty hq);
  inv ();
  Hq.clear hq;
  assert (Hq.is_empty hq);
  (* add 100 *)
  for i = 1 to 100 do
    assert (Hq.enqueue_back hq (string_of_int i) i = `Ok)
  done;
  (* double booking *)
  assert (Hq.enqueue_back hq "42" 42 = `Key_already_present);
  assert (
    try
      Hq.enqueue_back_exn hq "42" 42;
      false
    with
    | _ -> true);
  assert (Hq.replace hq "1" 42 = `Ok);
  assert (Hq.lookup hq "1" = Some 42);
  assert (Hq.lookup_exn hq "1" = 42);
  assert (Hq.dequeue_front_with_key hq = Some ("1", 42));
  assert (Hq.replace hq "1" 42 = `No_such_key);
  assert (
    try
      Hq.replace_exn hq "1" 42;
      false
    with
    | _ -> true);
  assert (Hq.lookup hq "1" = None);
  assert (
    try
      ignore (Hq.lookup_exn hq "1");
      false
    with
    | ( Not_found_s _ | Caml.Not_found ) -> true
    | _ -> false);
  Hq.clear hq;
  assert (Hq.is_empty hq);
  let add i = Hq.enqueue_back_exn hq (Int.to_string i) i in
  List.iter [ 1; 2; 3 ] ~f:add;
  assert ([ "1"; "2"; "3" ] = Hq.keys hq);
  (try
     Hq.iter hq ~f:(fun _ -> add 13);
     assert false
   with
   | _ -> ());
  (try
     Hq.iter hq ~f:(fun _ -> ignore (Hq.remove hq "foo"));
     assert false
   with
   | _ -> ());
  [%test_result: int] (Hq.lookup_and_move_to_back_exn hq "2") ~expect:2;
  [%test_result: string * int] (Hq.dequeue_front_with_key_exn hq) ~expect:("1", 1);
  [%test_result: string * int] (Hq.dequeue_front_with_key_exn hq) ~expect:("3", 3);
  [%test_result: string * int] (Hq.dequeue_front_with_key_exn hq) ~expect:("2", 2);
  [%test_result: (string * int) option] (Hq.dequeue_front_with_key hq) ~expect:None
;;

let%expect_test "enqueue_front, enqueue_front_exn" =
  let open Expect_test_helpers_kernel in
  let hq = Hq.create () in
  let ok_exn = function
    | `Key_already_present -> raise_s [%message "Key already present"]
    | `Ok -> ()
  in
  for i = 1 to 10 do
    Hq.enqueue_front hq (Int.to_string i) i |> ok_exn
  done;
  print_s [%sexp (Hq.to_list hq : int list)];
  [%expect {| (10 9 8 7 6 5 4 3 2 1) |}];
  let hq_rev = Hq.create () in
  for i = 1 to 10 do
    Hq.enqueue_back hq_rev (Int.to_string i) i |> ok_exn
  done;
  print_s [%sexp (Hq.to_list hq_rev : int list)];
  [%expect {| (1 2 3 4 5 6 7 8 9 10) |}];
  (* Test the _exn version *)
  let hq2 = Hq.create () in
  let n = 10 in
  for i = 1 to n do
    Hq.enqueue_front_exn hq2 (string_of_int i) i
  done;
  require [%here] ([%compare.equal: int list] (Hq.to_list hq2) (Hq.to_list hq))
;;

let test_enqueue_fn (back_or_front : [`back | `front]) enqueue_fn =
  let hq, hq' = Hq.create (), Hq.create () in
  let n = 10 in
  for i = 1 to n do
    assert (Hq.enqueue hq back_or_front (string_of_int i) i = `Ok);
    assert (enqueue_fn hq' (string_of_int i) i = `Ok)
  done;
  [%test_result: int list] (Hq.to_list hq) ~expect:(Hq.to_list hq');
  (* make sure they both return [`Key_already_present] *)
  [%test_result: [`Key_already_present | `Ok]]
    (Hq.enqueue hq back_or_front (string_of_int 5) 5)
    ~expect:`Key_already_present;
  [%test_result: [`Key_already_present | `Ok]]
    (enqueue_fn hq' (string_of_int 5) 5)
    ~expect:`Key_already_present
;;

let%expect_test "enqueue t `back := enqueue_back" = test_enqueue_fn `back Hq.enqueue_back

let%expect_test "enqueue t `front := enqueue_front" =
  test_enqueue_fn `front Hq.enqueue_front
;;

let%expect_test "lookup_and_move_to_back_exn" =
  let hq = Hq.create () in
  let n = 10 in
  for i = 1 to n do
    Hq.enqueue_back_exn hq (string_of_int i) i
  done;
  print_s [%sexp (Hq.to_list hq : int list)];
  [%expect {| (1 2 3 4 5 6 7 8 9 10) |}];
  print_s [%sexp (Hq.lookup_and_move_to_back_exn hq "5" : int)];
  [%expect {| 5 |}];
  print_s [%sexp (Hq.to_list hq : int list)];
  [%expect {| (1 2 3 4 6 7 8 9 10 5) |}]
;;

let%expect_test "lookup_and_move_to_front_exn" =
  let hq = Hq.create () in
  let n = 10 in
  for i = 1 to n do
    Hq.enqueue_back_exn hq (string_of_int i) i
  done;
  print_s [%sexp (Hq.to_list hq : int list)];
  [%expect {| (1 2 3 4 5 6 7 8 9 10) |}];
  print_s [%sexp (Hq.lookup_and_move_to_front_exn hq "5" : int)];
  [%expect {| 5 |}];
  print_s [%sexp (Hq.to_list hq : int list)];
  [%expect {| (5 1 2 3 4 6 7 8 9 10) |}]
;;

let%expect_test "dequeue_back, dequeue_back_exn" =
  let open Expect_test_helpers_kernel in
  let make_hq () =
    let hq = Hq.create () in
    for i = 1 to 10 do
      Hq.enqueue_front_exn hq (Int.to_string i) i
    done;
    hq
  in
  let hq = make_hq () in
  for _ = 1 to 11 do
    print_s [%sexp (Hq.dequeue_back hq : int option)]
  done;
  [%expect
    {|
    (1)
    (2)
    (3)
    (4)
    (5)
    (6)
    (7)
    (8)
    (9)
    (10)
    () |}];
  let hq = make_hq () in
  for _ = 1 to 10 do
    print_s [%sexp (Hq.dequeue_back_exn hq : int)]
  done;
  [%expect {|
    1
    2
    3
    4
    5
    6
    7
    8
    9
    10 |}]
;;

let%expect_test "drop" =
  let open Expect_test_helpers_kernel in
  let make_hq () =
    let hq = Hq.create () in
    for i = 1 to 10 do
      Hq.enqueue_back_exn hq (Int.to_string i) i
    done;
    hq
  in
  let hq = make_hq () in
  Hq.drop_back ~n:3 hq;
  print_s [%sexp (Hq.to_list hq : int list)];
  [%expect {| (1 2 3 4 5 6 7) |}];
  let hq = make_hq () in
  Hq.drop_front ~n:4 hq;
  print_s [%sexp (Hq.to_list hq : int list)];
  [%expect {| (5 6 7 8 9 10) |}];
  (* Check when n > length of list *)
  let hq = make_hq () in
  Hq.drop_back ~n:20 hq;
  print_s [%sexp (Hq.to_list hq : int list)];
  [%expect {| () |}]
;;
