function A = createA(D, W, theta, nx, ny, dx, dy, dt)
    

G = @(i,j) i + (j-1)*ny; 

A = zeros(nx*ny);
for i = 1:ny
    for j = 1:nx
        if i == 1 || j == 1 || i == ny || j == nx
            A(G(i,j),G(i,j)) = 1;  % boundary condition
        else
            A(G(i,j),G(i,j))   = 1 + 2*D*dt*(1/dx/dx+1/dy/dy); 
            A(G(i,j),G(i,j+1)) = dt*(-D/dx/dx + W*cos(theta)/2/dx);
            A(G(i,j),G(i,j-1)) = dt*(-D/dx/dx - W*cos(theta)/2/dx);
            A(G(i,j),G(i+1,j)) = dt*(-D/dy/dy + W*sin(theta)/2/dy);
            A(G(i,j),G(i-1,j)) = dt*(-D/dy/dy - W*sin(theta)/2/dy);
        end
    end
end

A = sparse(A);