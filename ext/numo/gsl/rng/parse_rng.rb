require_relative "../gen/erbpp_gsl"

class DefRng < DefGslClass
  def lookup(h)
    case h
    when FM(name:/_free$/);             false
    when FM(name:/_alloc$/);            "rng_alloc"
    when FM(tp, type:dbl);              "rng_DFloat"
    when FM(tp, ulong, type:ulong);     "rng_UInt"
    when FM(tp, type:str);              "c_str_f_void"
    when FM(tp, type:szt);              "c_sizet_f_void"
    when FM(tp, type:ulong);            "c_ulong_f_void"
    when FM(tp, type:tp);               "c_other_f_void"
    when FM(tp, ulong);                 "c_void_f_ulong"
    when FM(tp, tp);                    "c_self_f_other"
    end
  end

  def check_func(h)
    if t = lookup(h)
      m = h[:func_name].sub(/^gsl_rng_/,"")
      DefMethod.new(self, t, name:m, **h)
      if /_alloc$/ =~ h[:func_name]
        read_type.each do |tp|
          DefSubclassNew.new(self, "rng_type_new", tp, **h)
        end
      end
      return true
    end
    $stderr.puts "skip #{h[:func_name]}"
    false
  end
end

# ----------------------------------------------------------

class DefRan < DefGslModule
  def lookup(h)
    dblbk = [dbl,/\[\]/]
    uintbk = [uint,/\[\]/]
    case h
    when FM(tp, type:dbl);              "ran"
    when FM(tp, dbl, type:dbl);         "ran"
    when FM(tp, *[dbl]*2, type:dbl);    "ran"
    when FM(tp, dbl, type:uint);        "ran"
    when FM(tp, *[dbl]*2, type:uint);   "ran"
    when FM(tp, dbl,uint, type:uint);   "ran"
    when FM(tp, *[uint]*3, type:uint);  "ran"
    when FM(tp, *[dbl]*3,*[dblp]*2,);   "ran_DFloat_x2"
    when FM(tp, *[dblp]*2,);            "ran_DFloat_x2"
    when FM(tp, *[dblp]*3,);            "ran_DFloat_x3"
    when FM(tp, szt,dblp,);             false
    when FM(tp, szt,*[dblbk]*2);        "ran_DFloat_f_DFloat"
    when FM(tp, szt,uint,dblbk,uintbk); "ran_multinomial"
    end
  end

  def define_method(t,**h)
    RanMethod.new(self, t, **h)
  end
end


class RanMethod < DefMethod

  def initialize(parent,tmpl,**h)
    name = h[:func_name].sub(/^gsl_ran_/,"")
    super(parent, tmpl, name:name, **h)

    args = get(:args).dup
    unless /gsl_rng */ =~ args.shift[0]
      $stderr.puts h.inspect
      raise
    end
    if desc
      desc.gsub!(/@{/,"[")
      desc.gsub!(/@}/,"]")
    end

    case h[:func_type]
    when "double"
      set func_type_var: "cDF"
      set ret_class: "Float or DFloat"
    when "unsigned int"
      set func_type_var: "cUInt"
      set ret_class: "Integer or UInt"
    end

    @an = []
    @vn = []
    @vardef = []
    @varconv = []
    @params = []

    unknown = false
    args.each_with_index do |tn,i|
      if /^\w+$/ !~ tn[1] # pointer?
        unknown = true
        break
      end
      a = "a#{i}"
      v = "v#{i}"
      case tn[0]
      when "double"
        @varconv << "#{a} = NUM2DBL(#{v});"
        @params << [tn[1],"Float"]
      when "unsigned int"
        @varconv << "#{a} = NUM2UINT(#{v});"
        @params << [tn[1],"Integer"]
      when "double *"
        # skip
        next
      else
        unknown = true
        break
      end
      @vn << v
      @an << a
      @vardef << "#{tn[0]} #{a}"
    end
    if unknown
      $stderr.puts "not defined: #{name} #{h[:args].inspect}"
    end
  end

end
