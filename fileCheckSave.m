filename = ['AM001_',datestr(now,'yymmdd'),'.m'];
fileIndex = 0;
fileList = what;
while sum(strcmp(fileList.m,filename)) > 0
    fileIndex = fileIndex + 1;
    filename = ['AM001_',datestr(now,'yymmdd'),'_',num2str(fileIndex),'.m'];
    fileList = what;
end
save(filename,'fileIndex');
    