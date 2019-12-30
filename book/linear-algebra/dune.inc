(alias
 (name runtest)
 (deps
  (:x README.md)
  (package mdx)
  (package owl-plplot)
  (package owl-top)
  (:y0 ../../examples/code/linear-algebra/example_00.ml)
  prelude.ml)
 (locks ../../global-lock)
 (action
  (progn
   (run ocaml-mdx test --prelude=prelude.ml --direction=to-md %{x})
   (diff? %{x} %{x}.corrected)
   (diff? %{y0} %{y0}.corrected))))
