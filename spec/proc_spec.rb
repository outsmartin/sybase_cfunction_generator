require("~/sybase_cfunction_generator/lib/generator.rb")
require("helpers.rb")
include GeneratorHelperMethods
describe Generator do
  it "should process complete call procedure" do
    pending  
    @generator.sql= "CREATE PROCEDURE avg_old_per_ort (@ort CHAR(20), @result INT output) AS SELECT @result = (SELECT AVG(datediff(yy, Gebdat, getdate())) FROM Mitarbeiter WHERE Ort = @ort)"
    @generator.to_function.should 'void avgOldPerOrt()
{
  DBCHAR avg_old[15];
  BYTE *ret;

  dbrpcinit(dbproc, "avg_old_per_ort", 0);
  dbrpcparam(dbproc, "@ort", 0, SYBCHAR, 20, strlen(answer), answer);
  dbrpcparam(dbproc, "@result", DBRPCRETURN, SYBINT4, -1, -1, avg_old);
  dbrpcsend(dbproc);
  dbsqlok(dbproc);
  dbresults(dbproc);
  printf("retnum: %d, retlen: %d\n", dbnumrets(dbproc), dbretlen(dbproc,1));
  ret=dbretdata(dbproc, 1);
  printf("return value from proc: %d\n", *(DBINT *)ret);

}'
  end
end
