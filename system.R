x = system('perl -e \'print "2+2"\'', intern=TRUE)

string=sprintf("echo test123 %s", "some text")
system(string, intern=TRUE)

