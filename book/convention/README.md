# Conventions

Every software system has its own rules and conventions which require the developers to comply with. Owl is not an exception, for example our :doc:`rules on broadcasting operation <broadcast>` and :doc:`conventions on slicing definition <slicing>`. In this chapter, I will cover the naming conventions of Owl's functions.


## Pure vs. Impure

`Ndarray` module contains a lot of functions to manipulate arrays and perform mathematical operations over them. The **pure functions** (aka immutable functions) refer to those which do not modify the passed in variables but always return a new one as result. In contrast, **impure functions** (aka mutable functions) refer to those which modifies the passed-in variables in place.

The arguments between pure and impure functions will never end. Functional programming in general promotes the use of immutable data structures. However, the introduction of impure functions to Owl is under many careful and practical considerations. One primary motivation of using in-place modification is to avoid expensive memory allocation and deallocation, this can significantly improve the performance of a numerical application especially when large ndarrays and matrices involved.

Using impure functions makes it difficult to reason the correctness of the code, therefore, you need to be careful when you decide to use them. Always remember that you can use `Lazy` functor to achieve the same effect but offload the "dangerous task" to Owl. Please refer to :doc:`Laziness and Dataflow <lazy>` chapter for more details.

Many pure functions in Owl have their corresponding impure version, the difference is that impure version has an extra underscore "`_`" as their ending. For example, the following functions are the pure functions in `Arr` module.

```ocaml

  Arr.sin;;
  Arr.cos;;
  Arr.log;;
  Arr.abs;;
  Arr.add;;
  Arr.mul;;

```

Their corresponding impure functions are as follows.

```ocaml

  Arr.sin_;;
  Arr.cos_;;
  Arr.log_;;
  Arr.abs_;;
  Arr.add_;;
  Arr.mul_;;

```

For unary operators such as `Arr.sin x`, the situation is rather straightforward, `x` will be modified in place. However, for binary operates such as `Arr.add_scalar_ x a` and `Arr.add_ x y`, the situation needs some clarifications. For `Arr.add_scalar x a`, `x` will be modified in place and stores the final result, this is trivial.

For `Arr.add_ x y`, the first argument `x` will be modified in place. Because the binary operators in Owl support broadcasting operations by default, this indicates when using impure functions every dimension of the first argument `x` must not be smaller than that of the second argument `y`. In other words, impure function only allows broadcasting smaller `y` onto `x`.

Most binary math functions in Owl are associated with a shorthand operator, such as `+`, `-`, `*`, and `/`. The impure versions also have their own operators. For exmaple, corresponding to `Arr.(x + y)` which returns the result in a new ndarray, you can write `Arr.(x += y)` which adds up `x` and `y` and saves the result into `x`.

```text

==============    ==============    ==============
Function Name     Pure              Impure
==============    ==============    ==============
add               `+`             `+=`
sub               `-`             `-=`
mul               `*`             `*=`
div               `/`             `/=`
add_scalar        `+$`            `+$=`
sub_scalar        `-$`            `-$=`
mul_scalar        `*$`            `*$=`
div_scalar        `/$`            `/$=`
==============    ==============    ==============

```


##  Ndarray vs. Scalar

There are many functions can be categorised into reduction operations, such as `Arr.sum`, `Arr.prod`, `Arr.min`, `Arr.mean`, `Arr.std`, and etc. All the reduction functions in Owl has a name parameter called `axis`. When you apply these reduction operations on a multi-dimensional array, there are two possible cases:

* if axis is explicitly specified, then reduce along one specified axis;
* if axis is not specified, then flatten the ndarray into a vector then reduce all the elements (i.e., reduce along axis 0).

If the passed in ndarray is already one-dimensional, then two cases are equivalent. In the following code snippet, `a` has shape `[|3;1;3|]` whereas `b` has shape `[|1|]` since it only contains one element.

```ocaml

  let x = Arr.sequential [|3;3;3|];;
  let a = Arr.sum ~axis:1 x;;
  let b = Arr.sum x;;

```

If you plan to add the result in `b` with another float number, you need to retrieve the value by calling `get` function.

```ocaml

  let c = Arr.get b [|0|] in
  c +. 10.;;

```

This does not look very convenient if we always need to extract a scalar value from the return of reduction operations. This is not a problem for the languages like Python and Julia since the return type is dynamically determined. However, for OCaml, this turns out to be challenging: we either use a unified type; or we implement another set of functions. In the end, we picked the latter in Owl's design. As a result, every reduction operation has two versions:

* one allows you to reduce along the specified axis, or reduce all the elements, but always returns an ndarray;
* one only reduces all the elements and always returns a scalar value.

The difference between the two is that the functions returning a scalar ends up with an extra prime "`'`" character in their names. For example, for the first type of functions that return an ndarray, their function names look like these.

```ocaml

  Arr.sum;;
  Arr.min;;
  Arr.prod;;
  Arr.mean;;

```

For the second type of functions that return a scalar, their name looks like these.

```ocaml

  Arr.sum';;
  Arr.min';;
  Arr.prod';;
  Arr.mean';;

```


Technically, `Arr.sum'` is equivalent to the following code.

```ocaml

  let sum' x =
    let y = Arr.sum x in
    Arr.get y [|0|]

```

Let's extend the previous code snippet, and test it in OCaml's toplevel. Then you will understand the difference immediately.

```ocaml

  let x = Arr.sequential [|3;3;3|];;
  let a = Arr.sum ~axis:1 x;;
  let b = Arr.sum x;;
  let c = Arr.sum' x;;

```

Rules and conventions often represent the tradeoffs in a design. By clarifying the restrictions, we hope the programmers can choose the right functions to use in a specific scenario. This chapter may be updated in future to reflect the recent changes in Owl's design.


## Basic Operators
=================================================

This chapter will go through the operators and `Ext` module. The operators in Owl are implemented in the functors defined in the `Owl_operator` module. These operators are categorised into `Basic`, `Extend`, `Matrix`, and `Ndarray` four module type signatures, because some operations are only meaningful for certain data structures. E.g., matrix multiplication `*@` is only defined in `Matrix` signature.

As long as a module implements the functions defined in the module signature, you can use these functors to generate corresponding operators. However, you do not need to work with functors directly in Owl since I have done the generation part for you already.

The operators have been included in each `Ndarray` and `Matrix` module. The following table summarises the operators currently implemented in Owl. In the table, both `x` and `y` represent either a matrix or an ndarray while `a` represents a scalar value.

```ocaml

============  ============  ========================  ============  =================
Operator      Example       Operation                 Dense/Sparse  Ndarray/Matrix
============  ============  ========================  ============  =================
`+`           `x + y`       element-wise add          both          both
`-`           `x - y`       element-wise sub          both          both
`*`           `x * y`       element-wise mul          both          both
`/`           `x / y`       element-wise div          both          both
`+$`          `x +$ a`      add scalar                both          both
`-$`          `x -$ a`      sub scalar                both          both
`*$`          `x *$ a`      mul scalar                both          both
`/$`          `x /$ a`      div scalar                both          both
`$+`          `a $+ x`      scalar add                both          both
`$-`          `a $- x`      scalar sub                both          both
`$*`          `a $* x`      scalar mul                both          both
`$/`          `a $/ x`      scalar div                both          both
`=`           `x = y`       comparison                both          both
`!=`          `x != y`      comparison                both          both
`<>`          `x <> y`      same as `!=`              both          both
`>`           `x > y`       comparison                both          both
`<`           `x < y`       comparison                both          both
`>=`          `x >= y`      comparison                both          both
`<=`          `x <= y`      comparison                both          both
`=.`          `x =. y`      element-wise cmp          Dense         both
`!=.`         `x !=. y`     element-wise cmp          Dense         both
`<>.`         `x <>. y`     same as `!=.`             Dense         both
`>.`          `x >. y`      element-wise cmp          Dense         both
`<.`          `x <. y`      element-wise cmp          Dense         both
`>=.`         `x >=. y`     element-wise cmp          Dense         both
`<=.`         `x <=. y`     element-wise cmp          Dense         both
`=$`          `x =$ y`      comp to scalar            Dense         both
`!=$`         `x !=$ y`     comp to scalar            Dense         both
`<>$  `       `x <>$ y`     same as `!=`              Dense         both
`>$`          `x >$ y`      compare to scalar         Dense         both
`<$`          `x <$ y`      compare to scalar         Dense         both
`>=$`         `x >=$ y`     compare to scalar         Dense         both
`<=$`         `x <=$ y`     compare to scalar         Dense         both
`=.$`         `x =.$ y`     element-wise cmp          Dense         both
`!=.$`        `x !=.$ y`    element-wise cmp          Dense         both
`<>.$`        `x <>.$ y`    same as `!=.$`            Dense         both
`>.$`         `x >.$ y`     element-wise cmp          Dense         both
`<.$`         `x <.$ y`     element-wise cmp          Dense         both
`>=.$`        `x >=.$ y`    element-wise cmp          Dense         both
`<=.$`        `x <=.$ y`    element-wise cmp          Dense         both
`=~`          `x =~ y`      approx `=`                Dense         both
`=~$`         `x =~$ y`     approx `=$`               Dense         both
`=~.`         `x =~. y`     approx `=.`               Dense         both
`=~.$`        `x =~.$ y`    approx `=.$`              Dense         both
`%`           `x % y`       mod divide                Dense         both
`%$`          `x %$ a`      mod divide scalar         Dense         both
`**`          `x ** y`      power function            Dense         both
`*@`          `x *@ y`      matrix multiply           both          Matrix
`/@`          `x /@ y`      solve linear system       both          Matrix
`**@`         `x **@ a`     matrix power              both          Matrix
`min2`        `min2 x y`    element-wise min          both          both
`max2`        `max2 x y`    element-wise max          both          both
`@=`          `x @= y`      concatenate vertically    Dense         both
`@||`         `x @|| y`     concatenate horizontally  Dense         both
============  ============  ========================  ============  =================

```


There are a list of things worth your attention as below.

- `*` is for element-wise multiplication; `*@` is for matrix multiplication. You can easily understand the reason if you read the source code of `Algodiff <https://github.com/ryanrhymes/owl/blob/master/src/owl/optimise/owl_algodiff_generic.ml>`_ module. Using `*` for element-wise multiplication (for matrices) leads to the consistent implementation of algorithmic differentiation.

- `+$` has its corresponding operator `$+` if we flip the order of parameters. However, be very careful about the operator precedence since OCaml determines the precedence based on the first character of an infix. `+$` preserves the precedence whereas `$+` does not. Therefore, I do not recommend using `$+`. If you do use it, please use parentheses to explicitly specify the precedence. The same argument also applies to `$-`, `$*`, and `$/`.

- For comparison operators, e.g. both `=` and `=.` compare all the elements in two variables `x` and `y`. The difference is that `=` returns a boolean value whereas `=.` returns a matrix or ndarray of the same shape and same type as `x` and `y`. In the returned result, the value in a given position is `1` if the values of the corresponding position in `x` and `y` satisfy the predicate, otherwise it is `0`.

- For the comparison operators ended with `$`, they are used to compare a matrix/ndarray to a scalar value.

Operators are easy to use, here are some examples.

.. code-block:: ocaml

  let x = Mat.uniform 5 5;;
  let y = Mat.uniform 5 5;;

  Mat.(x + y);;
  Mat.(x * y);;
  Mat.(x ** y);;
  Mat.(x *@ y);;

  ...

  (* please compare the returns of the following two examples *)
  Mat.(x > y);;
  Mat.(x >. y);;


Extending indexing and slicing operators are not included in the table above, but you can find the detailed explanation in :doc:`Slicing Chapter <slicing>`.



Extension Module
-------------------------------------------------

As you can see, the operators above do not allow interoperation on different number types (which may not be bad thing in many cases actually). E.g., you cannot add a `float32` matrix to `float64` matrix unless you explicitly call the `cast` functions in `Generic` module :doc:`{read this} <basics>`.

`Owl.Ext` module is specifically designed for this purpose, to make prototyping faster and easier. Once you open the module, `Ext` immediately provides a set of operators to allow you to interoperate on different number types, as below. It automatically casts types for you if necessary.

```text
=============    =============     ==========================
Operator         Example           Operation
=============    =============     ==========================
`+`              `x + y`           add
`-`              `x - y`           sub
`*`              `x * y`           mul
`/`              `x / y`           div
`=`              `x = y`           comparison, return bool
`!=`             `x != y`          comparison, return bool
`<>`             `x <> y`          same as `!=`
`>`              `x > y`           comparison, return bool
`<`              `x < y`           comparison, return bool
`>=`             `x >= y`          comparison, return bool
`<=`             `x <= y`          comparison, return bool
`=.`             `x =. y`          element_wise comparison
`!=.`            `x !=. y`         element_wise comparison
`<>.`            `x <>. y`         same as `!=.`
`>.`             `x >. y`          element_wise comparison
`<.`             `x <. y`          element_wise comparison
`>=.`            `x >=. y`         element_wise comparison
`<=.`            `x <=. y`         element_wise comparison
`%`              `x % y`           element_wise mod divide
`**`             `x ** y`          power function
`*@`             `x *@ y`          matrix multiply
`min2`           `min2 x y`        element-wise min
`max2`           `max2 x y`        element-wise max
=============    =============     ==========================
```

You may have noticed, the operators ended with `$` (e.g., `+$`, `-$` ...) disappeared from the table, which is simply because we can add/sub/mul/div a scalar with a matrix directly and we do not need these operators any more. Similar for comparison operators, because we can use the same `>` operator to compare a matrix to another matrix, or compare a matrix to a scalar, we do not need `>$` any longer. Allowing interoperation makes the operator table much shorter.

Currently, the operators in `Ext` only support interoperation on dense structures. Besides binary operators, `Ext` also implements most of the common math functions which can be applied to float numbers, complex numbers, matrices, and ndarray. These functions are:

`im`; `re`; `conj`, `abs`, `abs2`, `neg`, `reci`, `signum`, `sqr`, `sqrt`, `cbrt`, `exp`, `exp2`, `expm1`, `log`, `log10`, `log2`, `log1p`, `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `sinh`, `cosh`, `tanh`, `asinh`, `acosh`, `atanh`, `floor`, `ceil`, `round`, `trunc`, `erf`, `erfc`, `logistic`, `relu`, `softplus`, `softsign`, `softmax`, `sigmoid`, `log_sum_exp`, `l1norm`, `l2norm`, `l2norm_sqr`, `inv`, `trace`, `sum`, `prod`, `min`, `max`, `minmax`, `min_i`, `max_i`, `minmax_i`.


Note that `Ext` contains its own `Ext.Dense` module which further contains the following submodules.

- `Ext.Dense.Ndarray.S`
- `Ext.Dense.Ndarray.D`
- `Ext.Dense.Ndarray.C`
- `Ext.Dense.Ndarray.Z`
- `Ext.Dense.Matrix.S`
- `Ext.Dense.Matrix.D`
- `Ext.Dense.Matrix.C`
- `Ext.Dense.Matrix.Z`

These modules are simply the wrappers of the original modules in `Owl.Dense` module so they provide most of the APIs already implemented. The extra thing these wrapper modules does is to pack and unpack the raw number types for you automatically. However, you can certainly use the raw data types then use the constructors defined in `Owl_ext_types` to wrap them up by yourself. The constructors are defined as below.

```ocaml

  type ext_typ =
    F   of float
    C   of Complex.t
    DMS of dms
    DMD of dmd
    DMC of dmc
    DMZ of dmz
    DAS of das
    DAD of dad
    DAC of dac
    DAZ of daz
    SMS of sms
    SMD of smd
    SMC of sms
    SMZ of smd
    SAS of sas
    SAD of sad
    SAC of sac
    SAZ of saz

```

There are also corresponding `packing` and `unpacking` functions you can use, please read `owl_ext_types.ml <https://github.com/ryanrhymes/owl/blob/master/src/owl/ext/owl_ext_types.ml>`_ for more details.


Let's see some examples to understand how convenient it is to use `Ext` module.

```ocaml

  open Owl.Ext;;

  let x = Dense.Matrix.S.uniform 5 5;;
  let y = Dense.Matrix.C.uniform 5 5;;
  let z = Dense.Matrix.D.uniform 5 5;;

  x + F 5.;;
  x * C Complex.({re = 2.; im = 3.});;
  x - y;;
  x / y;;
  x *@ y;;

  ...

  x > z;;
  x >. z;;
  (x >. z) * x;;
  (x >. F 0.5) * x;;
  (F 10. * x) + y *@ z;;

  ...

  round (F 10. * (x *@ z));;
  sin (F 5.) * cos (x + z);;
  tanh (x * F 10. - z);;

  ...


Before we finish this chapter, I want to point out the caveat. `Ext` tries to mimic the dynamic languages like Python by with unified types. This prevents OCaml compiler from doing type checking in compilation phase and introduces extra overhead in calling functions. Therefore, besides fast experimenting in toplevel, I do not recommend to use `Ext` module in the production code.