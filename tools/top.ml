
#use "topfind";;
#require "unix";;
let pr = Printf.printf ;;
let spr = Printf.sprintf ;;

#directory "_build/src/lib/";;
#directory "_build/src/app/";;
#load "_build/src/lib/ocamlbracetax.cma";;

pr "\n   Welcome to the Bracetax-loaded toplevel\n";;

