function [Data,Atts,GAtts] = readnetcdf(inPath,inFile)
%READNETCDF Read NetCDF variables, variable attributes, and global
%attributes.
%   [DATA,ATTS,GATTS] = READNETCDF(INPATH,INFILE) reads the NetCDF file 
%   given by INPATH/INFILE and stores all variable data in the structure  
%   DATA, all variable attribute information in the structure ATTS, and all
%   global attribute information in the structure GATTS.
%
%   This function is able to read any NetCDF convention (e.g. CF, NCAR-RAF,
%   CDC, etc) and does not require the user to make any changes to the 
%   source code.
%
%   See also netcdf
%
%   Author: Kirk North
%   Created: 2011.08.26

ncID = netcdf.open(strcat(inPath,inFile),'NC_NOWRITE');
[nDims,nVars,nGlobalAtts,unlimDim] = netcdf.inq(ncID);

%%% NetCDF dimensions %%%
for i=0:nDims-1
    [dimName,dimLength] = netcdf.inqDim(ncID,i);
    fprintf('Dimension name and length = %s; %.f\n',dimName,dimLength)
end

%%% NetCDF variables and variable attributes %%%
for i=0:nVars-1
    [varName,dType,dimID,nAtts] = netcdf.inqVar(ncID,i);
    varData = netcdf.getVar(ncID,i,class(dType));
    Data.(varName) = varData;
    for j=0:nAtts-1
        attName = netcdf.inqAttName(ncID,i,j);
        attValue = netcdf.getAtt(ncID,i,attName);
        if (strcmp(attName,'_FillValue'))
            Atts.(varName).('FillValue_') = attValue;
        else
            Atts.(varName).(attName) = attValue;
        end
    end
end

%%% Global attributes %%%
for i=0:nGlobalAtts-1
    gAttName = netcdf.inqAttName(ncID,netcdf.getConstant('NC_GLOBAL'),i);
    gAttValue = netcdf.getAtt(ncID,netcdf.getConstant('NC_GLOBAL'),gAttName);
    try
        GAtts.(gAttName) = gAttValue;
    catch
        GAtts.(removewhitespace(gAttName)) = gAttValue;
    end
end

netcdf.close(ncID)

function [string] = removewhitespace(string)
%REMOVEWHITESPACE Remove whitespace and replace it with underscores
%   [STRING] = REMOVEWHITESPACE(STRING) removes any whitespace found in STRING
%   and replaces it with underscores.
%
%   Author: Kirk North
%   Created: 2012.09.24

string = regexprep(string,'\s','_');