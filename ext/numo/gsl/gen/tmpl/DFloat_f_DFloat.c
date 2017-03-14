static void
iter_<%=c_func%>(na_loop_t *const lp)
{
    size_t   n, i;
    char    *p1, *p2;
    ssize_t  s1, s2;
    double   x, y;

    INIT_COUNTER(lp, n);
    INIT_PTR(lp, 0, p1, s1);
    INIT_PTR(lp, 1, p2, s2);

    for (i=0; i<n; i++) {
        GET_DATA_STRIDE(p1,s1,double,x);
        y = gsl_<%=c_func%>(x);
        SET_DATA_STRIDE(p2,s2,double,y);
    }
}

/*
  @overload <%=name%>(<%=args[0][1]%>)
  @param  [DFloat]   <%=args[0][1]%>
  @return [DFloat]   result

  <%= description %>
*/
static VALUE
<%=c_func%>(VALUE v0, VALUE v1)<% set n_arg:2 %>
{
    ndfunc_arg_in_t ain[1] = {{numo_cDFloat,0}};
    ndfunc_arg_out_t aout[1] = {{numo_cDFloat,0}};
    ndfunc_t ndf = {iter_<%=c_func%>, STRIDE_LOOP, 1,1, ain,aout};

    return na_ndloop(&ndf, 1, v0);
}