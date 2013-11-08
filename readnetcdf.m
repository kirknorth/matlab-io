function [Data, Atts, Gatts] = readnetcdf(fname)
%READNETCDF Read NetCDF variables, variable attributes, and global
%attributes.
%   [Data, Atts, Gatts] = READNETCDF(fname) reads the NetCDF file fname
%   and stores all variable data in the structure Data, all variable
%   attribute information in the structure Atts, and all global attribute
%   information in the structure Gatts.
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

% Open NetCDF
nc = netcdf.open(fname, 'NC_NOWRITE');
[nDims, nVars, nGatts, unlimDim] = netcdf.inq(nc);

% Gather NetCDF dimensions
for i = 0:nDims-1
    [dimName, dimLen] = netcdf.inqDim(nc, i);
    fprintf('Dimension name and length = %s; %d\n', dimName, dimLen)
end

% Gather NetCDF variables and variable attributes
for i = 0:nVars-1
    [varName, xType, dimId, nAtts] = netcdf.inqVar(nc, i);
    varData = netcdf.getVar(nc, i);
    Data.(varName) = varData;
    for j = 0:nAtts-1
        attName = netcdf.inqAttName(nc, i, j);
        attValue = netcdf.getAtt(nc, i, attName);
        if (strcmp(attName, '_FillValue'))
            Atts.(varName).('FillValue_') = attValue;
        else
            Atts.(varName).(attName) = attValue;
        end
    end
end

% Gather global attributes
for i = 0:nGatts-1
    gAttName = netcdf.inqAttName(nc, netcdf.getConstant('NC_GLOBAL'), i);
    gAttValue = netcdf.getAtt(nc, netcdf.getConstant('NC_GLOBAL'), gAttName);
    Gatts.(regexprep(gAttName, '\s', '_')) = gAttValue; % Adds underscores whereever any whitespace exists
end

% Close NetCDF
netcdf.close(nc)
