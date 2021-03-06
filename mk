#! /bin/sh

LIBMODS="
src/lib/error
src/lib/signatures
src/lib/escape
src/lib/commands
src/lib/parser
src/lib/latexPrinter
src/lib/genericPrinter
src/lib/htmlPrinter
src/lib/TOCOutput
src/lib/transform
src/lib/info
"

build ()
{
    local APPEXT="byte"
    local LIBEXT="cma"
    local CMEXT="cmo"
    local MKLIB="ocamlc -a"
    case "$1" in
        "opt" )
            APPEXT="native"
            LIBEXT="cmxa"
            CMEXT="cmx"
            MKLIB="ocamlopt -a"
            ;;
        "debug" )
            APPEXT="d.byte"
            ;;
    esac

    TAGOPT="-tags pkg_unix"
    echo "<**/[^B]*.cmx>: for-pack(Bracetax)" > _tags
    I_OPT="-I src/app -I src/lib"
    ocamlbuild $I_OPT $TAGOPT -cflags -dtypes src/app/main.$APPEXT
    $MKLIB -o _build/src/lib/ocamlbracetax.$LIBEXT _build/src/lib/Bracetax.$CMEXT
    rm -f brtx _tags ; ln -s main.$APPEXT brtx
}
build_no_ocamlbuild ()
{
    rm -fr _build
    mkdir _build
    cp -r src _build
    cd _build
    CCLIB="ocamlc -for-pack Bracetax -c -I src/lib/"
    CMOS=""
    for mod in $LIBMODS ; do
        CMOS="$CMOS $mod.cmo"
        $CCLIB $mod.ml
    done;
    ocamlc -pack -o src/lib/bracetax.cmo  $CMOS
    ocamlc -a -o src/lib/ocamlbracetax.cma src/lib/bracetax.cmo
    ocamlc -o brtx -I src/app/ -I . -I src/lib/ unix.cma ocamlbracetax.cma \
        src/app/main.ml
    cd -
    echo "--> _build/brtx"
}

install_library() {
    ocamlfind install bracetax src/lib/META \
        _build/src/lib/ocamlbracetax.* _build/src/lib/*.cm[iox]
}

document_library(){
    local docinput=" -sort -I _build/src/lib/ src/lib/*.ml"
    local docdir="doc/site/doclib/"
cat <<EOF > /tmp/intro
This is the ocamldoc documentation for the
{{:http://bracetax.berlios.de}{i Bracetax}} library.

Here are some hig-level graphs:
- {{:./bracetax_modules.png}Graph of Modules}
- {{:./bracetax_types.png}Graph of Types}

The modules (don't forget that all modules are "packed" inside the
Bracetax module):
{!modules: 
Transform
Info
Error
Signatures
Parser
LatexPrinter
HtmlPrinter
GenericPrinter
TOCOutput
Escape
Commands
}


Other indexes:

{!indexlist}

EOF
    rm -fr $docdir
    mkdir -p $docdir
    ocamldoc -d $docdir -t "Bracetax Library" -intro /tmp/intro \
        -html -colorize-code $docinput
    ocamldoc -o /tmp/brtxmods.dot -dot -dot-reduce -dot-include-all $docinput
    ocamldoc -o /tmp/brtxtyps.dot -dot -dot-types -dot-reduce $docinput
    grep -v rotate /tmp/brtxmods.dot | dot -Tpng > $docdir/bracetax_modules.png
    grep -v rotate /tmp/brtxtyps.dot | dot -Tpng > $docdir/bracetax_types.png
}

echo_help ()
{
    echo "\
$0 <cmd>
b: Build brtx (default action)
bg: Build brtx with debug symbols
o: Build brtx with native compilation
bc: Build brtx without ocamlfind and ocamlbuild (e.g. with ocaml 3.09.x)
i: Install the ocamlbracetax library with ocamlfind
ui: Uninstall the library
t: Do the tests
d: Build the documentation without building pdfs
doclib: Build the HTML documentation of the library
D: Build the whole documentation.
cd: Clean documentation
c: Clean
h: This help"
}

if [ $# -eq 0 ]; then
    build
    exit $?
fi

for todo in $* ; do
    case "$todo" in
        "b" ) build ;;
        "bg" ) build "debug" ;;
        "o" ) build "opt";;
        "bc" ) build_no_ocamlbuild ;;
        "i" ) install_library ;;
        "ui" ) ocamlfind remove bracetax ;;
        "t" ) test/do_tests ;;
        "d" ) cd doc/ ; make nopdf ; cd .. ;;
        "doclib" ) document_library ;;
        "D" ) cd doc/ ; make  ; cd .. ;;
        "cd" )rm -rf doc/site/ ;;
        "c" ) ocamlbuild -clean ; rm -rf _test_results/ doc/site/ ;;
        "h" ) echo_help ;;
        * ) echo "see \`mk h\`";;
    esac
done


