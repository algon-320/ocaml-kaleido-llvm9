(*===----------------------------------------------------------------------===
 * Top-Level parsing and JIT Driver
 *===----------------------------------------------------------------------===*)

open Llvm
open Llvm_executionengine

let toplevel_count = ref 0

(* top ::= definition | external | expression | ';' *)
let rec main_loop the_fpm stream =
  match Stream.peek stream with
  | None -> ()

  (* ignore top-level semicolons. *)
  | Some (Token.Kwd ';') ->
      Stream.junk stream;
      main_loop the_fpm stream

  | Some token ->
      begin
        try match token with
        | Token.Def ->
            let e = Parser.parse_definition stream in
            print_endline "parsed a function definition.";
            dump_value (Codegen.codegen_func the_fpm e);
        | Token.Extern ->
            let e = Parser.parse_extern stream in
            print_endline "parsed an extern.";
            dump_value (Codegen.codegen_proto e);
        | _ ->
            (* Evaluate a top-level expression into an anonymous function. *)
            let e = Parser.parse_toplevel stream in
            print_endline "parsed a top-level expr";
            let the_function = Codegen.codegen_func the_fpm e in

            let ee = Llvm_executionengine.create Codegen.the_module in
            add_module Codegen.the_module ee;

            let func_name = "_toplevel_" ^ (string_of_int !toplevel_count) in
            set_value_name func_name the_function;
            dump_value the_function;

            toplevel_count := !toplevel_count + 1;

            (* JIT the function, returning a function pointer. *)
            let fp = get_function_address func_name (Foreign.funptr Ctypes.(void @-> returning double)) ee in
            print_string "Evaluated to ";
            print_float (fp ());
            print_newline ();

        with Stream.Error s | Codegen.Error s ->
          (* Skip token for error recovery. *)
          Stream.junk stream;
          print_endline s;
      end;
      print_string "ready> "; flush stdout;
      main_loop the_fpm stream
