require("../generator")
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
    @generator.function_start.should == "void #{name}(void){
  "
    @generator.function_end.should == "}\n"
  end
  it "should generate dbcmd and dbsqlexec" do
    @generator.dbcmd.should == "dbcmd(dbproc,\"#{@generator.sql}\");
  "
    @generator.dbsqlexec.should == "dbsqlexec(dbproc);

  "
  end
  it "should generate dbbind" do
    bind = @generator.dbbind
    bind[0].gsub(/\s/,'').should == "dbbind(dbproc,1,NTBSTRINGBIND,0,Beruf);"
  end
  it "should generate dbbind for all selectors" do
    @generator.sql = 'SELECT Name,Beruf FROM Mitarbeiter'
    @generator.dbbind.map{|i| i.gsub(/\s/,'')}.should == ["dbbind(dbproc,1,NTBSTRINGBIND,0,Name);","dbbind(dbproc,2,NTBSTRINGBIND,0,Beruf);"]
  end
  it "should generate correctly typed dbbind for all selectors" do
    @generator.sql = 'SELECT Name:string,Moneten:float FROM Mitarbeiter'
    @generator.dbbind.map{|i| i.gsub(/\s/,'')}.should == ["dbbind(dbproc,1,NTBSTRINGBIND,0,Name);","dbbind(dbproc,2,FLT8BIND,0,(BYTE*)&Moneten);"]
  end
  it "should generate printf statements" do
    @generator.get_printfs.map{|i| i.gsub(/\s/,'')}.should == ['printf("Beruf:%s\n",Beruf);']
  end
  it "should generate printfs according to select" do
    @generator.sql = 'SELECT Name:string,Moneten:float FROM Mitarbeiter'
    @generator.dbbind
    @generator.get_printfs.map{|i| i.gsub(/\s/,'')}.should == ['printf("Name:%s\n",Name);','printf("Moneten:%f\n",Moneten);']
  end
  it "should generate complete function for select" do
    @generator.to_function.should ==
'void function(void){
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

end



