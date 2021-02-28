function u = pollutionProfile_backward(W, theta, a1, a2, params)

nx = params.nx;
ny = params.ny;
dt = params.dt;
tf = params.tf;
dx = params.dx;
dy = params.dy;
D = params.D;
x = 0:dx:1;
y = 0:dy:1;
t = 0:dt:tf;
nt = length(t);

% the first dimension of u is the flattened spatial dimension,
% and the second dimension is time
u = zeros(ny*nx, nt);

boundaries = [1:ny 1:ny:ny*nx ny:ny:ny*nx nx*(ny-1)+1:nx*ny];
% (above) might be less confusing to use the G function for this...

%% initial condition
u0 = a1*exp(-100*bsxfun(@plus, (x-0.25).^2, (y'-0.25).^2)) + ...
     a2*exp(-150*bsxfun(@plus, (x-0.65).^2, (y'-0.4).^2));
u(:,1) = u0(:);
u(boundaries,1) = 0; % set initial condition at boundaries to 0

%% build matrix
if ~params.spdiag
    G = @(i,j) i + (j-1)*ny; % G = @(i,j) sub2ind([ny nx], i, j);
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
%     nnz(A)
else
    % We build the sparse matrix A using spdiags
    % The size of A is ny*nx by ny*nx, so the B matrix should have ny*nx rows.
    % The number of columns of the B matrix is the number of non-zero diagonals
    % of A. 
    % Each grid point influences 5 points: itself ann the 4 neighbours. 
    % So there are 5 nonzero diagonals of A. So the size of B is 5 by ny*nx.
    B = zeros(ny*nx, 5);
    % Now we need to know the indices of the diagonal. 
    d = [-ny; -1; 0; 1; ny];
    % Now we create B
    B(:,1) = -W*cos(theta)/2/dx - D/dx/dx;
    B(:,2) = -W*sin(theta)/2/dy - D/dy/dy;
    B(:,3) = 1/dt + 2*D*(1/dx/dx+1/dy/dy);
    B(:,4) =  W*sin(theta)/2/dy - D/dy/dy;
    B(:,5) =  W*cos(theta)/2/dx - D/dx/dx;

    B = B*dt;
    A = spdiags(B, d, ny*nx, ny*nx);
    % Boundary conditions are handled here...
    A(boundaries,:)=0;
    A(sub2ind([ny*nx, ny*nx], boundaries, boundaries)) = 1;
end

%% main loop
if params.LU
    [L, U] = lu(A);
    for n = 2:nt
        u(:,n) = U\(L\(u(:,n-1)));
    end
else
    for n = 2:nt
        u(:,n) = A\u(:,n-1);
    end
end


