function plotFSsurf(faces,vertices,data,custommap,mincol,maxcol,viewangle)
%Plot data on surface rendering.
% FORMAT plotFSsurf(faces,vertices,data,custommap,mincol,maxcol,viewangle)
% faces       - faces returned from freesurfer_read_surf
% vertices    - vertice corodinates returned from freesurfer_read_surf
% data        - data to be displayed on the surface
% custommap   - color map
% mincol      - min value for color scale
% maxcol      - max value for color scale
% viewangle   - view angle of the surface shown in the figure
% Aaron Alexander-Bloch & Siyuan Liu 
% DemonSpinFS.m, 2018-04-22

trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3),data);
view(viewangle);
colormap(custommap)
caxis([mincol; maxcol]);
daspect([1 1 1]);
axis tight;
axis vis3d off;
lighting gouraud; 
material metal; 
shading flat;
camlight;
alpha(1)