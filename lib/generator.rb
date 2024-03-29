class Generator
  attr_accessor :sql, :function_name
  def initialize
    @printfs = []
  end
  def function_start
    "void #{self.function_name}(void){\n  "
  end
  def function_end
    "}\n"
  end
  def dbcmd
    selectors = self.sql.match(/select (.+) FROM/i)[1]
    selectors = selectors.split(",") rescue selectors
    selectors.map!{|s| s.split(":")[0] rescue s}
    sql_stripped = self.sql.gsub(/select (.+) FROM/i,"SELECT #{selectors.join","} FROM")
    "dbcmd(dbproc,\"#{sql_stripped}\");\n  "
  end
  def dbsqlexec
    "dbsqlexec(dbproc);

  "
  end
  def no_more_results
    ["while (dbresults(dbproc)!=NO_MORE_RESULTS)
    {
      ","
    }\n"]
  end
  def no_more_rows
    ["while (dbnextrow(dbproc)!=NO_MORE_ROWS)
      {","\n      }"]
  end
  def dbbind
    selectors = self.sql.match(/select (.+) FROM/i)[1]
    selectors = selectors.split(",") rescue selectors
    i = 0
    selectors = selectors.collect do |s|
      i = i + 1
      selector = selector_to_sybase s
      "dbbind(dbproc,#{i},#{selector[1]},0,#{selector[0]});
      "
    end
  end
  def selector_to_sybase(input)
    selector = input.split(":")[0]
    type = input.split(":")[1] rescue "string"
    sybase_type = ""
    case type
      when "string"
        sybase_type = "NTBSTRINGBIND"
        sybase_selector = selector
      when "float"
        sybase_type = "FLT8BIND"
        sybase_selector = "(BYTE*)&" + selector
      else
      sybase_type = "NTBSTRINGBIND"
      sybase_selector = selector
    end
    [sybase_selector,sybase_type,selector,type]
  end
  def get_printfs
    selectors = self.sql.match(/select (.+) FROM/i)[1]
    selectors = selectors.split(",") rescue selectors

    printfs = selectors.collect do |s|
      selector = selector_to_sybase s
      "\n        printf(\"#{selector[2]}: %#{selector[3][0] rescue "s"}"+ ' \n"'+",#{selector[2]});"
    end

    printfs
  end
  def to_function
    @function_name = "function"
    output = ""
    output << function_start
      output << dbcmd
      output << dbsqlexec
      output << no_more_results[0]
        output << dbbind.join("")
        output << no_more_rows[0]
          output << get_printfs.join("")
        output << no_more_rows[1]
      output << no_more_results[1]
    output << function_end
  end


end
