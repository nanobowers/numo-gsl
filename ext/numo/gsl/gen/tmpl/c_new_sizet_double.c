<%
set name: "new"
set singleton: true
%>
/*
  @overload <%=name%>(<%=args.map{|a| a[1]}.join(",")%>)
  @param  [Integer]  <%=args[0][1]%>
  @param  [Float]  <%=args[1][1]%>

  allocate instance of <%=class_name%> class.

<%= desc %>
 */
static VALUE
<%=c_func%>(VALUE self, VALUE v1, VALUE v2)<% set n_arg:2 %>
{
    <%=struct%> *w;
    w = <%=func_name%>(NUM2SIZET(v1), NUM2DBL(v2));

    return TypedData_Wrap_Struct(<%=class_var%>, &<%=data_type_var%>, (void*)w);
}
