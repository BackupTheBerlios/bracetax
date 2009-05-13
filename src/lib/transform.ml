(******************************************************************************)
(*      Copyright (c) 2009, Sebastien MONDET                                  *)
(*                                                                            *)
(*      Permission is hereby granted, free of charge, to any person           *)
(*      obtaining a copy of this software and associated documentation        *)
(*      files (the "Software"), to deal in the Software without               *)
(*      restriction, including without limitation the rights to use,          *)
(*      copy, modify, merge, publish, distribute, sublicense, and/or sell     *)
(*      copies of the Software, and to permit persons to whom the             *)
(*      Software is furnished to do so, subject to the following              *)
(*      conditions:                                                           *)
(*                                                                            *)
(*      The above copyright notice and this permission notice shall be        *)
(*      included in all copies or substantial portions of the Software.       *)
(*                                                                            *)
(*      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,       *)
(*      EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES       *)
(*      OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND              *)
(*      NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT           *)
(*      HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,          *)
(*      WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING          *)
(*      FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR         *)
(*      OTHER DEALINGS IN THE SOFTWARE.                                       *)
(******************************************************************************)

open Signatures

let opt_may ~f = function None -> () | Some o -> f o

let brtx_to_html ~writer ?doc ?css_link ?(filename="<IN>") ~input_char () = (

    opt_may doc ~f:(fun title ->
        writer.w_write (HtmlPrinter.header
            ~comment:"Generated with BraceTax" ~title
            ?stylesheet_link:css_link ()
        );
    );
    let printer = HtmlPrinter.build ~writer in
    Parser.do_transformation printer input_char filename;
    
    opt_may doc ~f:(fun _ ->
        writer.w_write (HtmlPrinter.footer ());
    );

)


let brtx_to_latex ~writer ?doc ?use_package ?(filename="<IN>") ~input_char () = (

    opt_may doc ~f:(fun title ->
        writer.w_write (LatexPrinter.header
            ~comment:"Generated with BraceTax" ~title
            ?stylesheet_link:use_package ()
        );
    );
    let printer = LatexPrinter.build ~writer in
    Parser.do_transformation printer input_char filename;
    
    opt_may doc ~f:(fun _ ->
        writer.w_write (LatexPrinter.footer ());
    );

)





