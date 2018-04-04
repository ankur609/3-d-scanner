function surf2stl(filename,x,y,z,mode)
error(nargchk(4,5,nargin));

if (ischar(filename)==0)
    error( 'Invalid filename');
end

if (nargin < 5)
    mode = 'binary';
elseif (strcmp(mode,'ascii')==0)
    mode = 'binary';
end

if (ndims(z) ~= 2)
    error( 'Variable z must be a 2-dimensional array' );
end

if any( (size(x)~=size(z)) | (size(y)~=size(z)) )
    
   
    if ( (length(x)==1) & (length(y)==1) )

        dx = x;
        dy = y;
        x = ((1:size(z,2))-1)*dx;
        y = ((1:size(z,1))-1)*dy;
    end
        
    if ( (length(x)==size(z,2)) & (length(y)==size(z,1)) )
       
        xvec=x;
        yvec=y;
        [x,y]=meshgrid(xvec,yvec);
    else
        error('Unable to resolve x and y variables');
    end
        
end

if strcmp(mode,'ascii')
    
    fid = fopen(filename,'w');
else
   
    fid = fopen(filename,'wb+');
end

if (fid == -1)
    error( sprintf('Unable to write to %s',filename) );
end

title_str = sprintf('Created by surf2stl.m %s',datestr(now));

if strcmp(mode,'ascii')
    fprintf(fid,'solid %s\r\n',title_str);
else
    str = sprintf('%-80s',title_str);    
    fwrite(fid,str,'uchar');         
    fwrite(fid,0,'int32');          
end

nfacets = 0;

for i=1:(size(z,1)-1)
    for j=1:(size(z,2)-1)
        
        p1 = [x(i,j)     y(i,j)     z(i,j)];
        p2 = [x(i,j+1)   y(i,j+1)   z(i,j+1)];
        p3 = [x(i+1,j+1) y(i+1,j+1) z(i+1,j+1)];
        val = local_write_facet(fid,p1,p2,p3,mode);
        nfacets = nfacets + val;
        
        p1 = [x(i+1,j+1) y(i+1,j+1) z(i+1,j+1)];
        p2 = [x(i+1,j)   y(i+1,j)   z(i+1,j)];
        p3 = [x(i,j)     y(i,j)     z(i,j)];        
        val = local_write_facet(fid,p1,p2,p3,mode);
        nfacets = nfacets + val;
        
    end
end

if strcmp(mode,'ascii')
    fprintf(fid,'endsolid %s\r\n',title_str);
else
    fseek(fid,0,'bof');
    fseek(fid,80,'bof');
    fwrite(fid,nfacets,'int32');
end

fclose(fid);

disp( sprintf('Wrote %d facets',nfacets) );




function num = local_write_facet(fid,p1,p2,p3,mode)

if any( isnan(p1) | isnan(p2) | isnan(p3) )
    num = 0;
    return;
else
    num = 1;
    n = local_find_normal(p1,p2,p3);
    
    if strcmp(mode,'ascii')
        
        fprintf(fid,'facet normal %.7E %.7E %.7E\r\n', n(1),n(2),n(3) );
        fprintf(fid,'outer loop\r\n');        
        fprintf(fid,'vertex %.7E %.7E %.7E\r\n', p1);
        fprintf(fid,'vertex %.7E %.7E %.7E\r\n', p2);
        fprintf(fid,'vertex %.7E %.7E %.7E\r\n', p3);
        fprintf(fid,'endloop\r\n');
        fprintf(fid,'endfacet\r\n');
        
    else
        
        fwrite(fid,n,'float32');
        fwrite(fid,p1,'float32');
        fwrite(fid,p2,'float32');
        fwrite(fid,p3,'float32');
        fwrite(fid,0,'int16');  
        
    end
    
end


function n = local_find_normal(p1,p2,p3)

v1 = p2-p1;
v2 = p3-p1;
v3 = cross(v1,v2);
n = v3 ./ sqrt(sum(v3.*v3));
