# Visualisation


Owl is an OCaml numerical library. Besides its extensive supports to matrix operations, it also has a flexible plotting module. Owl's ``Plot`` module is designed to help you in making fairly complicated plots with minimal coding efforts. It is built atop of `Plplot <http://plplot.sourceforge.net/index.php>`_ but hides its complexity from users.

The module is cross-platform since ``Plplot`` calls the underlying graphics device driver to plot. However, based on my experience, the `Cairo Package <https://cran.r-project.org/web/packages/Cairo/index.html>`_ provides the best quality and most accurate figure so I recommend installing Cairo.

The examples in this tutorial are generated by using ``Cairo PNG Driver``.


## Create Plots

However, in most cases, you do want to have a full control over the figure you are creating and do want to configure it a bit especially if you don't like the default red on black theme. Then, here is the standard way of creating a plot using ``Plot.create`` function. Here is its type definition in ``Owl_plot.mli``


  val create : ?m:int -> ?n:int -> string -> handle


This chapter teaches you how to use visualisation functionality in Owl.

```ocaml
# let f x = Maths.sin x /. x in
  let h = Plot.create "plot_001.png" in

  Plot.set_title h "Function: f(x) = sine x / x";
  Plot.set_xlabel h "x-axis";
  Plot.set_ylabel h "y-axis";
  Plot.set_font_size h 8.;
  Plot.set_pen_size h 3.;
  Plot.plot_fun ~h f 1. 15.;

  Plot.output h
- : unit = ()
```

The generated figure is as below.

<img src="images/visualisation/plot_001.png" alt="plot 001" title="Plot example 1" width="500px" />

Another example follows,

```ocaml
# let x, y = Mat.meshgrid (-2.5) 2.5 (-2.5) 2.5 50 50 in
  let z = Mat.(sin ((x * x) + (y * y))) in
  let h = Plot.create ~m:2 ~n:3 "plot_023.png" in

  Plot.subplot h 0 0;
  Plot.(mesh ~h ~spec:[ ZLine XY ] x y z);

  Plot.subplot h 0 1;
  Plot.(mesh ~h ~spec:[ ZLine X ] x y z);

  Plot.subplot h 0 2;
  Plot.(mesh ~h ~spec:[ ZLine Y ] x y z);

  Plot.subplot h 1 0;
  Plot.(mesh ~h ~spec:[ ZLine Y; NoMagColor ] x y z);

  Plot.subplot h 1 1;
  Plot.(mesh ~h ~spec:[ ZLine Y; Contour ] x y z);

  Plot.subplot h 1 2;
  Plot.(mesh ~h ~spec:[ ZLine XY; Curtain ] x y z);

  Plot.output h;;
- : unit = ()
```

<img src="images/visualisation/plot_023.png" alt="plot 023" title="Plot example two" width="600px" />


## Specification


## Subplots

```ocaml
# let f p i = match i with
    | 0 -> Stats.gaussian_rvs ~mu:0. ~sigma:0.5 +. p.(1)
    | _ -> Stats.gaussian_rvs ~mu:0. ~sigma:0.1 *. p.(0)
  in
  let y = Stats.gibbs_sampling f [|0.1;0.1|] 5_000 |> Mat.of_arrays in
  let h = Plot.create ~m:2 ~n:2 "plot_002.png" in
  Plot.set_background_color h 255 255 255;

  (* focus on the subplot at 0,0 *)
  Plot.subplot h 0 0;
  Plot.set_title h "Bivariate model";
  Plot.scatter ~h (Mat.col y 0) (Mat.col y 1);

  (* focus on the subplot at 0,1 *)
  Plot.subplot h 0 1;
  Plot.set_title h "Distribution of y";
  Plot.set_xlabel h "y";
  Plot.set_ylabel h "Frequency";
  Plot.histogram ~h ~bin:50 (Mat.col y 1);

  (* focus on the subplot at 1,0 *)
  Plot.subplot h 1 0;
  Plot.set_title h "Distribution of x";
  Plot.set_ylabel h "Frequency";
  Plot.histogram ~h ~bin:50 (Mat.col y 0);

  (* focus on the subplot at 1,1 *)
  Plot.subplot h 1 1;
  Plot.set_foreground_color h 255 0 0;
  Plot.set_title h "Sine function";
  Plot.(plot_fun ~h ~spec:[ LineStyle 2 ] Maths.sin 0. 28.);
  Plot.autocorr ~h (Mat.sequential 1 28);

  (* output your final plot *)
  Plot.output h
- : unit = ()
```

<img src="images/visualisation/plot_002.png" alt="plot 002" title="Plot example 002" width="600px" />


## Multiple Lines


## Legend


## Drawing

```ocaml
# let h = Plot.create "plot_004.png" in
  Plot.set_background_color h 255 255 255;
  Plot.set_pen_size h 2.;
  Plot.(draw_line ~h ~spec:[ LineStyle 1 ] 1. 1. 9. 1.);
  Plot.(draw_line ~h ~spec:[ LineStyle 2 ] 1. 2. 9. 2.);
  Plot.(draw_line ~h ~spec:[ LineStyle 3 ] 1. 3. 9. 3.);
  Plot.(draw_line ~h ~spec:[ LineStyle 4 ] 1. 4. 9. 4.);
  Plot.(draw_line ~h ~spec:[ LineStyle 5 ] 1. 5. 9. 5.);
  Plot.(draw_line ~h ~spec:[ LineStyle 6 ] 1. 6. 9. 6.);
  Plot.(draw_line ~h ~spec:[ LineStyle 7 ] 1. 7. 9. 7.);
  Plot.(draw_line ~h ~spec:[ LineStyle 8 ] 1. 8. 9. 8.);
  Plot.set_xrange h 0. 10.;
  Plot.set_yrange h 0. 9.;
  Plot.output h
- : unit = ()
```

<img src="images/visualisation/plot_004.png" alt="plot 004" title="Plot example 004" width="600px" />

This example demonstrates patterns.

```ocaml
# let h = Plot.create "plot_005.png" in

  Array.init 9 (fun i ->
    let x0, y0 = 0.5, float_of_int i +. 1.0 in
    let x1, y1 = 4.5, float_of_int i +. 0.5 in
    Plot.(draw_rect ~h ~spec:[ FillPattern i ] x0 y0 x1 y1);
    Plot.(text ~h ~spec:[ RGB (0,255,0) ] 2.3 (y0-.0.2) ("pattern: " ^ (string_of_int i)))
  ) |> ignore;

  Plot.output h
- : unit = ()
```

<img src="images/visualisation/plot_005.png" alt="plot 005" title="Plot example 005" width="600px" />


## Line Plot


## Scatter Plot
```ocaml
# let x = Mat.uniform 1 30 in
  let y = Mat.uniform 1 30 in
  let h = Plot.create ~m:3 ~n:3 "plot_006.png" in
  Plot.set_background_color h 255 255 255;
  Plot.subplot h 0 0;
  Plot.(scatter ~h ~spec:[ Marker "#[0x2295]"; MarkerSize 5. ] x y);
  Plot.subplot h 0 1;
  Plot.(scatter ~h ~spec:[ Marker "#[0x229a]"; MarkerSize 5. ] x y);
  Plot.subplot h 0 2;
  Plot.(scatter ~h ~spec:[ Marker "#[0x2206]"; MarkerSize 5. ] x y);
  Plot.subplot h 1 0;
  Plot.(scatter ~h ~spec:[ Marker "#[0x229e]"; MarkerSize 5. ] x y);
  Plot.subplot h 1 1;
  Plot.(scatter ~h ~spec:[ Marker "#[0x2217]"; MarkerSize 5. ] x y);
  Plot.subplot h 1 2;
  Plot.(scatter ~h ~spec:[ Marker "#[0x2296]"; MarkerSize 5. ] x y);
  Plot.subplot h 2 0;
  Plot.(scatter ~h ~spec:[ Marker "#[0x2666]"; MarkerSize 5. ] x y);
  Plot.subplot h 2 1;
  Plot.(scatter ~h ~spec:[ Marker "#[0x22a1]"; MarkerSize 5. ] x y);
  Plot.subplot h 2 2;
  Plot.(scatter ~h ~spec:[ Marker "#[0x22b9]"; MarkerSize 5. ] x y);
  Plot.output h
- : unit = ()
```

<img src="images/visualisation/plot_006.png" alt="plot 006" title="Plot example 006" width="600px" />


## Stairs Plot

```ocaml
# let x = Mat.linspace 0. 6.5 20 in
  let y = Mat.map Maths.sin x in
  let h = Plot.create ~m:1 ~n:2 "plot_007.png" in
  Plot.set_background_color h 255 255 255;
  Plot.subplot h 0 0;
  Plot.plot_fun ~h Maths.sin 0. 6.5;
  Plot.(stairs ~h ~spec:[ RGB (0,128,255) ] x y);
  Plot.subplot h 0 1;
  Plot.(plot ~h ~spec:[ RGB (0,0,0) ] x y);
  Plot.(stairs ~h ~spec:[ RGB (0,128,255) ] x y);
  Plot.output h
- : unit = ()
```

<img src="images/visualisation/plot_007.png" alt="plot 007" title="Plot example 007" width="600px" />


## Box Plot

```ocaml
# let y1 = Mat.uniform 1 10 in
  let y2 = Mat.uniform 10 100 in
  let h = Plot.create ~m:1 ~n:2 "plot_008.png" in
  Plot.subplot h 0 0;
  Plot.(bar ~h ~spec:[ RGB (0,153,51); FillPattern 3 ] y1);
  Plot.subplot h 0 1;
  Plot.(boxplot ~h ~spec:[ RGB (0,153,51) ] y2);
  Plot.output h
- : unit = ()
```

<img src="images/visualisation/plot_008.png" alt="plot 008" title="Plot example 008" width="600px" />


## Stem Plot

Stem plot is simple, as the following code shows.

```ocaml
# let x = Mat.linspace 0.5 2.5 25 in
  let y = Mat.map (Stats.exponential_pdf ~lambda:0.1) x in
  let h = Plot.create ~m:1 ~n:2 "plot_009.png" in
  Plot.set_background_color h 255 255 255;
  Plot.subplot h 0 0;
  Plot.set_foreground_color h 0 0 0;
  Plot.stem ~h x y;
  Plot.subplot h 0 1;
  Plot.(stem ~h ~spec:[ Marker "#[0x2295]"; MarkerSize 5.; LineStyle 1 ] x y);
  Plot.output h
- : unit = ()
```

<img src="images/visualisation/plot_009.png" alt="plot 009" title="Plot example 009" width="600px" />

Stem plot is often used to show the autocorrelation of a variable, therefore Plot module already includes `autocorr` for your convenience.

```ocaml
# let x = Mat.linspace 0. 8. 30 in
  let y0 = Mat.map Maths.sin x in
  let y1 = Mat.uniform 1 30 in
  let h = Plot.create ~m:1 ~n:2 "plot_010.png" in
  Plot.subplot h 0 0;
  Plot.set_title h "Sine";
  Plot.autocorr ~h y0;
  Plot.subplot h 0 1;
  Plot.set_title h "Gaussian";
  Plot.autocorr ~h y1;
  Plot.output h
- : unit = ()
```

<img src="images/visualisation/plot_010.png" alt="plot 010" title="Plot example 010" width="600px" />


## Area Plot


## Histogram & CDF Plot


## Log Plot


## 3D Plot


## Advanced Statistical Plot



Finished.
