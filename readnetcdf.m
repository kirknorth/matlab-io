function [Data,Atts,GAtts] = readnetcdf(inPath,inFile)
%READNETCDF Read NetCDF variables, variable attributes, and global
%attributes.
%   [Data,Atts,GAtts] = READNETCDF(inPath,inFile) reads the NetCDF file 
%   given by inPath/inFile and stores all variable data in the structure  
%   Data, all variable attribute information in the structure Atts, and all
%   global attribute information in the structure GAtts.
%
%   This function is able to read any NetCDF convention (e.g. CF, NCAR-RAF,
%   CDC, etc) and does not require the user to make any changes to the 
%   source code.
%
%   See also netcdf

%   Copyright (C) 2011 Kirk North
%   
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.

%% Open NetCDF.

ncID = netcdf.open(strcat(inPath,inFile),'NC_NOWRITE');
[nDims,nVars,nGlobalAtts,unlimDim] = netcdf.inq(ncID);

%% NetCDF dimensions.

for i = 0:nDims-1
    [dimName,dimLength] = netcdf.inqDim(ncID,i);
    fprintf('Dimension name and length = %s; %.f\n',dimName,dimLength)
end

%% NetCDF variables and variable attributes.

for i = 0:nVars-1
    [varName,dType,dimID,nAtts] = netcdf.inqVar(ncID,i);
    varData = netcdf.getVar(ncID,i,class(dType));
    Data.(varName) = varData;
    for j = 0:nAtts-1
        attName = netcdf.inqAttName(ncID,i,j);
        attValue = netcdf.getAtt(ncID,i,attName);
        if (strcmp(attName,'_FillValue'))
            Atts.(varName).('FillValue_') = attValue;
        else
            Atts.(varName).(attName) = attValue;
        end
    end
end

%% Global attributes.

for i = 0:nGlobalAtts-1
    gAttName = netcdf.inqAttName(ncID,netcdf.getConstant('NC_GLOBAL'),i);
    gAttValue = netcdf.getAtt(ncID,netcdf.getConstant('NC_GLOBAL'),gAttName);
    try
        GAtts.(gAttName) = gAttValue;
    catch
        GAtts.(regexprep(gAttName,'\s','_')) = gAttValue;
    end
end

%% Close NetCDF.

netcdf.close(ncID)