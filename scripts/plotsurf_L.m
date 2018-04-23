function plotsurf(faces,vertices,data,custommap,mincol,maxcol)
aplot = trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3),data);
view([270 0]);
colormap(custommap)
caxis([mincol; maxcol]);
%caxis([NAval; max_data])
daspect([1 1 1]);
axis tight;
axis vis3d off;
lighting gouraud; %phong; 
material metal %shiny %metal; 
shading flat;
camlight;
alpha(1)