(alias
 (name runtest)
 (deps
  (:x README.md)
  (package jupyter)
  (package owl-plplot)
  (package mdx)
  (package owl)
  (package owl-top)
  prelude.ml)
 (locks ../../global-lock)
 (action
  (progn
   (run ocaml-mdx test --prelude=prelude.ml --direction=to-md %{x})
   (diff? %{x} %{x}.corrected))))
