require("../generator")
RSpec::Matchers.define :be_the_same_content do |expected|
  match do |actual|
    strip_whitespace(actual) == strip_whitespace(expected)
  end
  def strip_whitespace(input)
    if input.is_a? Array
      input.map!{|i| i.gsub(/\s/,'')}
    end
    if input.is_a? String
       input.gsub!(/\s/,'')
    end
    input
  end
end

describe Generator do
  before(:each) do
    @generator = Generator.new
    @generator.sql = 'SELECT Beruf FROM Mitarbeiter'
  end
  it "should return sql" do
    @generator.sql.should == 'SELECT Beruf FROM Mitarbeiter'
  end
  it "should have function stuff with name" do
    name = @generator.function_name
    @generator.function_start.should == "void #{name}(void){\n  "
    @generator.function_end.should == "}\n"
  end
  it "should generate dbcmd and dbsqlexec" do
    @generator.dbcmd.should == "dbcmd(dbproc,\"#{@generator.sql}\");\n  "
    @generator.dbsqlexec.should == "dbsqlexec(dbproc);\n\n  "
  end
  it "should generate dbbind" do
    bind = @generator.dbbind
    bind[0].gsub(/\s/,'').should == "dbbind(dbproc,1,NTBSTRINGBIND,0,Beruf);"
  end
  it "should generate dbbind for all selectors" do
    @generator.sql = 'SELECT Name,Beruf FROM Mitarbeiter'
    @generator.dbbind.should be_the_same_content ["dbbind(dbproc,1,NTBSTRINGBIND,0,Name);","dbbind(dbproc,2,NTBSTRINGBIND,0,Beruf);"]
  end
  it "should generate correctly typed dbbind for all selectors" do
    @generator.sql = 'SELECT Name:string,Moneten:float FROM Mitarbeiter'
    @generator.dbbind.should be_the_same_content ["dbbind(dbproc,1,NTBSTRINGBIND,0,Name);","dbbind(dbproc,2,FLT8BIND,0,(BYTE*)&Moneten);"]
  end
  it "should generate printf statements" do
    @generator.get_printfs.should be_the_same_content ['printf("Beruf:%s\n",Beruf);']
  end
  it "should generate printfs according to select" do
    @generator.sql = 'SELECT Name:string,Moneten:float FROM Mitarbeiter'
    @generator.dbbind
    @generator.get_printfs.should be_the_same_content ['printf("Name:%s\n",Name);','printf("Moneten:%f\n",Moneten);']
  end
  it "should generate complete function for select" do
    @generator.to_function.should be_the_same_content 'void function(void){
  dbcmd(dbproc,"SELECT Beruf FROM Mitarbeiter");
  dbsqlexec(dbproc);

  while (dbresults(dbproc)!=NO_MORE_RESULTS)
    {
      dbbind(dbproc,1,NTBSTRINGBIND,0,Beruf);
      while (dbnextrow(dbproc)!=NO_MORE_ROWS)
      {
        printf("Beruf: %s \n",Beruf);
      }
    }
}
'
  end
  it "should generate complex select from" do
    @generator.sql = 'SELECT Name:string,Moneten:float,Name2,Schlumpf:float FROM Mitarbeiter'
    @generator.to_function.should be_the_same_content 'void function(void){
  dbcmd(dbproc,"SELECT Name,Moneten,Name2,Schlumpf FROM Mitarbeiter");
  dbsqlexec(dbproc);

  while (dbresults(dbproc)!=NO_MORE_RESULTS)
    {
      dbbind(dbproc,1,NTBSTRINGBIND,0,Name);
      dbbind(dbproc,2,FLT8BIND,0,(BYTE*)&Moneten);
      dbbind(dbproc,3,NTBSTRINGBIND,0,Name2);
      dbbind(dbproc,4,FLT8BIND,0,(BYTE*)&Schlumpf);
      while (dbnextrow(dbproc)!=NO_MORE_ROWS)
      {
        printf("Name: %s \n",Name);
        printf("Moneten: %f \n",Moneten);
        printf("Name2: %s \n",Name2);
        printf("Schlumpf: %f \n",Schlumpf);
      }
    }
}
'
  end


end



