%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%metodo de fase desenvuelta basado en el calculo de minimos cuadrados en la fase envuelta con el uso DCT,
%capitulo 5.3.2, ec. 5.60 del libro TWO DIMENSIONAL PHASE UWRAPPING, Dennis Ghiglia y Mark D. Pritt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function phi = phase_unwrap(psi)
        
        %size(psi,1) es el numero de filas de la matriz psi
        %zeros([size(psi,1),1]) entrega como cero 1a primera columna de todas las filas de la matriz psi
        %diff(psi, 1, 2)) resta los elemnetos de las columnas (j+1)-j de la matriz psi
        %wrapToPi envuelve el angulo en radianes de pi a -pi. si es positivo seria (xy)-npi, si es negativo npi+(xy)
        %(xy) s el valor en cada pixel
        
        %size(psi,2) es el numero de columnas de la matriz psi
        %zeros([1,size(b,2)]) entrega como cero la primera fila de todas las columnas de la matriz psi
        %diff(psi, 1, 1)) resta los elemnetos de las filas (i+1)-i de la matriz psi
        
        dx = [zeros([size(psi,1),1]), wrapToPi(diff(psi, 1, 2)), zeros([size(psi,1),1])];  
        dy = [zeros([1,size(psi,2)]); wrapToPi(diff(psi, 1, 1)); zeros([1,size(psi,2)])];
       % dx y dy son las primeras diferenciales de la matriz psi
       
        rho = diff(dx, 1, 2) + diff(dy, 1, 1);
        % diff(dx, 1, 2)  y diff(dy, 1, 1) respresenta las segundas derivadasde la matriz psi,
        %la suma representa la ecuacion de poisson
        

   
    dctRho = dct2(rho); %dct2 la transforma discreta coseno de Fourier aplicada a la ec. Poisson
    [N, M] = size(rho);
    [I, J] = meshgrid([0:M-1], [0:N-1]); % crea matriz salida de igua dimensiones que rho,
    %se usa para no confundir con el uso de M y N en la ec. dctPhi  
    dctPhi = dctRho ./ 2 ./ (cos(pi*I/M) + cos(pi*J/N) -2);     
    dctPhi(1,1) = 0; % el termino (1,1) es indeterminado entonces se reemplaza (i,j)=(0,0)   
    
    % now invert to get the result
    phi = idct2(dctPhi); %se aplica la inversa de la dct2  (idct2) 
end