static void
iter_<%=c_func%>(na_loop_t *const lp)
{
    size_t   n, i;
    char    *p1;
    ssize_t  s1;
    size_t  *idx1;
    double   x;
    <%=struct%> *w = (<%=struct%>*)(lp->opt_ptr);

    INIT_COUNTER(lp, n);
    INIT_PTR_IDX(lp, 0, p1, s1, idx1);

    if (idx1) {
        for (i=0; i<n; i++) {
            GET_DATA_INDEX(p1,idx1,double,x);
            gsl_<%=c_func%>(x, w);
        }
    } else {
        for (i=0; i<n; i++) {
            GET_DATA_STRIDE(p1,s1,double,x);
            gsl_<%=c_func%>(x, w);
        }
    }
}

/*
  @overload <%=name%>(data)
  @param  [DFloat]  data  Data array.

  <%= description %>
*/
static VALUE
<%=c_func%>(VALUE self, VALUE data)<% set n_arg:1 %>
{
    <%=struct%> *w;
    ndfunc_arg_in_t ain[1] = {{numo_cDFloat,0}};
    ndfunc_t ndf = {iter_<%=c_func%>, FULL_LOOP, 1, 0, ain, 0};

    TypedData_Get_Struct(self, <%=struct%>, &<%=data_type_var%>, w);
    na_ndloop3(&ndf, w, 1, data);
    return self;
}