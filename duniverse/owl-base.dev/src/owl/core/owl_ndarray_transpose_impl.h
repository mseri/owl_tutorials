/*
 * OWL - OCaml Scientific and Engineering Computing
 * Copyright (c) 2016-2020 Liang Wang <liang.wang@cl.cam.ac.uk>
 */

#ifdef OWL_ENABLE_TEMPLATE


// Level 1 optimisation
void FUNCTION (c, transpose_1) (struct slice_pair *p) {
  TYPE *x = (TYPE *) p->x;
  TYPE *y = (TYPE *) p->y;
  int64_t d = p->dim - 1;
  int64_t n = p->n[d];
  int64_t posx = p->posx + p->ofsx[d];
  int64_t posy = p->posy + p->ofsy[d];
  int64_t incx = p->incx[d];
  int64_t incy = p->incy[d];

  for (int64_t i = 0; i < n; i++) {
    MAPFUN (*(x + posx), *(y + posy));
    posx += incx;
    posy += incy;
  }
}


// Level 2 optimisation
void FUNCTION (c, transpose_2) (struct slice_pair *p) {
    TYPE *x = (TYPE *) p->x;
    TYPE *y = (TYPE *) p->y;
    int64_t d0 = p->dim - 2;
    int64_t d1 = p->dim - 1;
    int64_t n0 = p->n[d0];
    int64_t n1 = p->n[d1];
    int64_t ofsx0 = p->ofsx[d0];
    int64_t ofsy0 = p->ofsy[d0];
    int64_t incx0 = p->incx[d0];
    int64_t incy0 = p->incy[d0];
    int64_t ofsx1 = p->ofsx[d1];
    int64_t ofsy1 = p->ofsy[d1];
    int64_t incx1 = p->incx[d1];
    int64_t incy1 = p->incy[d1];

    int64_t posx0 = p->posx + ofsx0;
    int64_t posy0 = p->posy + ofsy0;
    int64_t posx1;
    int64_t posy1;

    for (int64_t i0 = 0; i0 < n0; i0++) {
      posx1 = posx0 + ofsx1;
      posy1 = posy0 + ofsy1;

      for (int64_t i1 = 0; i1 < n1; i1++) {
        MAPFUN (*(x + posx1), *(y + posy1));
        posx1 += incx1;
        posy1 += incy1;
      }

      posx0 += incx0;
      posy0 += incy0;
    }
}


// Level 3 optimisation
void FUNCTION (c, transpose_3) (struct slice_pair *p) {
  TYPE *x = (TYPE *) p->x;
  TYPE *y = (TYPE *) p->y;
  int64_t d0 = p->dim - 3;
  int64_t d1 = p->dim - 2;
  int64_t d2 = p->dim - 1;
  int64_t n0 = p->n[d0];
  int64_t n1 = p->n[d1];
  int64_t n2 = p->n[d2];
  int64_t ofsx0 = p->ofsx[d0];
  int64_t ofsy0 = p->ofsy[d0];
  int64_t incx0 = p->incx[d0];
  int64_t incy0 = p->incy[d0];
  int64_t ofsx1 = p->ofsx[d1];
  int64_t ofsy1 = p->ofsy[d1];
  int64_t incx1 = p->incx[d1];
  int64_t incy1 = p->incy[d1];
  int64_t ofsx2 = p->ofsx[d2];
  int64_t ofsy2 = p->ofsy[d2];
  int64_t incx2 = p->incx[d2];
  int64_t incy2 = p->incy[d2];

  int64_t posx0 = p->posx + ofsx0;
  int64_t posy0 = p->posy + ofsy0;
  int64_t posx1;
  int64_t posy1;
  int64_t posx2;
  int64_t posy2;

  for (int64_t i0 = 0; i0 < n0; i0++) {
    posx1 = posx0 + ofsx1;
    posy1 = posy0 + ofsy1;

    for (int64_t i1 = 0; i1 < n1; i1++) {
      posx2 = posx1 + ofsx2;
      posy2 = posy1 + ofsy2;

      for (int64_t i2 = 0; i2 < n2; i2++) {
        MAPFUN (*(x + posx2), *(y + posy2));
        posx2 += incx2;
        posy2 += incy2;
      }

      posx1 += incx1;
      posy1 += incy1;
    }

    posx0 += incx0;
    posy0 += incy0;
  }
}


// Level 4 optimisation
void FUNCTION (c, transpose_4) (struct slice_pair *p) {
  TYPE *x = (TYPE *) p->x;
  TYPE *y = (TYPE *) p->y;
  int64_t d0 = p->dim - 4;
  int64_t d1 = p->dim - 3;
  int64_t d2 = p->dim - 2;
  int64_t d3 = p->dim - 1;
  int64_t n0 = p->n[d0];
  int64_t n1 = p->n[d1];
  int64_t n2 = p->n[d2];
  int64_t n3 = p->n[d3];
  int64_t ofsx0 = p->ofsx[d0];
  int64_t ofsy0 = p->ofsy[d0];
  int64_t incx0 = p->incx[d0];
  int64_t incy0 = p->incy[d0];
  int64_t ofsx1 = p->ofsx[d1];
  int64_t ofsy1 = p->ofsy[d1];
  int64_t incx1 = p->incx[d1];
  int64_t incy1 = p->incy[d1];
  int64_t ofsx2 = p->ofsx[d2];
  int64_t ofsy2 = p->ofsy[d2];
  int64_t incx2 = p->incx[d2];
  int64_t incy2 = p->incy[d2];
  int64_t ofsx3 = p->ofsx[d3];
  int64_t ofsy3 = p->ofsy[d3];
  int64_t incx3 = p->incx[d3];
  int64_t incy3 = p->incy[d3];

  int64_t posx0 = p->posx + ofsx0;
  int64_t posy0 = p->posy + ofsy0;
  int64_t posx1;
  int64_t posy1;
  int64_t posx2;
  int64_t posy2;
  int64_t posx3;
  int64_t posy3;

  for (int64_t i0 = 0; i0 < n0; i0++) {
    posx1 = posx0 + ofsx1;
    posy1 = posy0 + ofsy1;

    for (int64_t i1 = 0; i1 < n1; i1++) {
      posx2 = posx1 + ofsx2;
      posy2 = posy1 + ofsy2;

      for (int64_t i2 = 0; i2 < n2; i2++) {
        posx3 = posx2 + ofsx3;
        posy3 = posy2 + ofsy3;

        for (int64_t i3 = 0; i3 < n3; i3++) {
          MAPFUN (*(x + posx3), *(y + posy3));
          posx3 += incx3;
          posy3 += incy3;
        }

        posx2 += incx2;
        posy2 += incy2;
      }

      posx1 += incx1;
      posy1 += incy1;
    }

    posx0 += incx0;
    posy0 += incy0;
  }
}


// transpose a ndarray, i.e. permute the axis
void FUNCTION (c, transpose) (struct slice_pair *p) {
  if (p->dep == p->dim - 1)
    FUNCTION (c, transpose_1) (p);
  else if (p->dep == p->dim - 2)
    FUNCTION (c, transpose_2) (p);
  else if (p->dep == p->dim - 3)
    FUNCTION (c, transpose_3) (p);
  else if (p->dep == p->dim - 4)
    FUNCTION (c, transpose_4) (p);
  else {
    const int64_t d = p->dep;
    const int64_t n = p->n[d];
    const int64_t incx = p->incx[d];
    const int64_t incy = p->incy[d];
    const int64_t save_posx = p->posx;
    const int64_t save_posy = p->posy;
    p->posx += p->ofsx[d];
    p->posy += p->ofsy[d];

    for (int64_t i = 0; i < n; i++) {
      p->dep += 1;
      FUNCTION (c, transpose) (p);
      p->dep -= 1;
      p->posx += incx;
      p->posy += incy;
    }

    p->posx = save_posx;
    p->posy = save_posy;
  }
}


// stub function of transpose
CAMLprim value FUNCTION (stub, transpose) (value vX, value vY, value vA, value vB) {
  struct caml_ba_array *X = Caml_ba_array_val(vX);
  TYPE *X_data = (TYPE *) X->data;

  struct caml_ba_array *Y = Caml_ba_array_val(vY);
  TYPE *Y_data = (TYPE *) Y->data;

  struct caml_ba_array *A = Caml_ba_array_val(vA);
  int64_t *incx = (int64_t *) A->data;

  struct caml_ba_array *B = Caml_ba_array_val(vB);
  int64_t *incy = (int64_t *) B->data;

  struct slice_pair * sp = calloc(1, sizeof(struct slice_pair));
  sp->dim = X->num_dims;
  sp->dep = 0;
  sp->n = X->dim;
  sp->x = X_data;
  sp->y = Y_data;
  sp->posx = 0;
  sp->posy = 0;
  sp->ofsx = calloc(sp->dim, sizeof(int64_t));
  sp->ofsy = calloc(sp->dim, sizeof(int64_t));
  sp->incx = incx;
  sp->incy = incy;

  FUNCTION (c, transpose) (sp);

  free(sp->ofsx);
  free(sp->ofsy);
  free(sp);

  return Val_unit;
}



#endif /* OWL_ENABLE_TEMPLATE */
