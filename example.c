

void print_berufe(void){
        printf("\n\n.Anzeige aller Berufe\n");
        dbcmd(dbproc,"SELECT Beruf FROM Mitarbeiter group by Beruf");
        dbsqlexec(dbproc);

        while (dbresults(dbproc)!=NO_MORE_RESULTS)
        {
                dbbind(dbproc,1,NTBSTRINGBIND,0,Beruf);
                while (dbnextrow(dbproc)!=NO_MORE_ROWS)
                {
                        printf("Berufe:      %s\n",Beruf);
                }
        }

}