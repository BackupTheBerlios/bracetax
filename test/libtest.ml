#! /usr/bin/env ocamlrun ocaml
open Printf
#use "topfind";;

#directory "../_build/src/lib/";;

#load "Bracetax.cmo";;

let b2h = Bracetax.Transform.brtx_to_html;;
let b2l = Bracetax.Transform.brtx_to_latex;;

let writer =
    let error = function
        | `undefined s ->
            prerr_string (s ^ "\n")
        | `message ((_, gravity, _) as msg) ->
            prerr_string ((Bracetax.Error.to_string msg) ^ "\n") in
    Bracetax.Signatures.make_writer ~write:print_string ~error
;;

let input_char_of_str str =
    let b = ref 0 in
    let e = String.length str - 1 in
    fun () -> if !b > e then (b := 0; None) else (let c = str.[!b] in incr b; Some c)

;;

let () = (
    let input_char =
        input_char_of_str
            "{i|Italic {link link/to/|Thing}}, {image path/image}" in
    printf "==== URL HOOKS ====\n";
    let url_hook = String.uppercase in
    b2h ~writer ~input_char ~url_hook ();
    b2l ~writer ~input_char ~url_hook ();
    printf "\n";
    let url_hook = (^) "local:" in
    b2h ~writer ~input_char ~url_hook ();
    b2l ~writer ~input_char ~url_hook ();
    printf "\n";
    printf "==== IMAGE HOOKS ====\n";
    let img_hook = String.uppercase in
    b2h ~writer ~input_char ~img_hook ();
    b2l ~writer ~input_char ~img_hook ();
    printf "\n";
    let img_hook s = s ^ ".png" in b2h ~writer ~input_char ~img_hook ();
    let img_hook s = s ^ ".pdf" in b2l ~writer ~input_char ~img_hook ();
    printf "\n";
    printf "==== Header separation ====\n";
    let input_char = 
        input_char_of_str
            "{header|{title|TI{~}TLE}{authors|Auth%}Ingored} {b|bold text}" in
    let separate_header = ref ("","","") in
    b2l ~writer ~input_char (); printf "\n";
    let t,a,s = !separate_header in printf "T:%s\nA:%s\nS:%s\n" t a s;
    let separate_header = ref ("","","") in
    b2l ~writer ~input_char ~separate_header (); printf "\n";
    let t,a,s = !separate_header in printf "T:%s\nA:%s\nS:%s\n" t a s;
    let separate_header = ref ("","","") in
    b2h ~writer ~input_char (); printf "\n";
    let t,a,s = !separate_header in printf "T:%s\nA:%s\nS:%s\n" t a s;
    let separate_header = ref ("","","") in
    b2h ~writer ~input_char ~separate_header (); printf "\n";
    let t,a,s = !separate_header in printf "T:%s\nA:%s\nS:%s\n" t a s;
);;
