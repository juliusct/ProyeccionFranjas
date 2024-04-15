clc, close all, clear all
% Parámetros de calibración
distance_camera_projector = 280; % Distancia entre la cámara y el proyector en milímetros
distance_camera_reference_plane = 650; % Distancia entre la cámara y el plano de referencia en milímetros
% Definir las dimensiones físicas conocidas del área observada
physical_width_mm = 300; % Ancho físico de la imagen en milímetros
physical_height_mm = 250; % Altura física de la imagen en milímetros

%% Cargar los patrones de franjas
[FileName, PathName] = uigetfile('*.jpg', 'Select the JPG file');
FP = imread([PathName FileName]);
FP = double(rgb2gray(FP));
figure, imshow(FP,[])
% Imprimir información sobre la resolución de la imagen
disp(['Resolución de la Imagen Cargada: ' num2str(size(FP, 1)) 'x' num2str(size(FP, 2))]);

%% Ajustar píxeles por milímetro
% Definir las dimensiones físicas conocidas del área observada
physical_width_mm = 600; % Ancho físico de la imagen en milímetros
physical_height_mm = 500; % Altura física de la imagen en milímetros

% Calcular píxeles por milímetro en longitud y ancho
pixels_per_mm_length = size(FP, 2) / physical_width_mm;
pixels_per_mm_width = size(FP, 1) / physical_height_mm;

disp(['Píxeles por Milímetro en Longitud: ' num2str(pixels_per_mm_length)]);
disp(['Píxeles por Milímetro en Ancho: ' num2str(pixels_per_mm_width)]);

%% four-step PSA coefficients
cn = [1 -1i -1 1i];
N = length(cn);

%% phase measurement - reference plane
Arp = 0;
for i = 0:N-1
    tempvar = imread([PathName 'REF_' num2str(i) '.jpg']);
    tempvar = double(rgb2gray(tempvar));

    Arp = Arp + cn(i+1) * tempvar;
end

PhiRP = angle(Arp);
figure, imshow(PhiRP,[])
%% phase measurement - object
Aob = 0;
for i = 0:N-1
    tempvar = imread([PathName 'HUACO2_' num2str(i) '.jpg']);
    tempvar = double(rgb2gray(tempvar));

    Aob = Aob + cn(i+1) * tempvar;
end

PhiOB = angle(Aob);
figure, imshow(PhiOB,[])
%% Diferencia de fase
Adiff = exp(1i * PhiOB) .* exp(-1i * PhiRP);
PhiW = angle(Adiff);
figure, imshow(PhiW,[])
%% Desenvolvimiento de Fase (phase unwrapping)
PhiUW = phase_unwrap(PhiW(290:1954,800:2450));
figure, imshow(PhiUW,[])
%% Contar franjas verticales
franjas_contadas_vertical = count_franjas(FP, 'vertical');
disp(['Franjas Contadas Verticalmente: ' num2str(franjas_contadas_vertical)]);

%% Cálculo del periodo de las franjas
periodo_franjas_mm = physical_width_mm / franjas_contadas_vertical;
disp(['Periodo de Franjas Calculado (mm): ' num2str(periodo_franjas_mm)]);

% Cálculo del ángulo
theta = atan((periodo_franjas_mm * franjas_contadas_vertical) / (2 * pi * distance_camera_reference_plane)) * (180/pi);
disp(['Ángulo Calculado (grados): ' num2str(theta)]);

%% Calcular píxeles por milímetro en longitud y ancho
pixels_per_mm_length = size(FP, 2) / physical_width_mm;
pixels_per_mm_width = size(FP, 1) / physical_height_mm;

disp(['Píxeles por Milímetro en Longitud: ' num2str(pixels_per_mm_length)]);
disp(['Píxeles por Milímetro en Ancho: ' num2str(pixels_per_mm_width)]);

%% Ajustar a unidades de longitud reales en los ejes length y width
length_mm = size(PhiUW, 2) / pixels_per_mm_length;
width_mm = size(PhiUW, 1) / pixels_per_mm_width;

disp(['Longitud Calculada (mm): ' num2str(length_mm)]);
disp(['Ancho Calculado (mm): ' num2str(width_mm)]);

%% Calcular factores de escala para longitud y ancho
length_scaling_factor = physical_width_mm / length_mm;
width_scaling_factor = physical_height_mm / width_mm;

disp(['Factor de Escala para Longitud: ' num2str(length_scaling_factor)]);
disp(['Factor de Escala para Ancho: ' num2str(width_scaling_factor)]);

%% Aplicar escalamiento por separado a longitud y ancho
scaled_length_mm = linspace(0, length_mm, size(PhiUW, 2)) * length_scaling_factor;
scaled_width_mm = linspace(0, width_mm, size(PhiUW, 1)) * width_scaling_factor;

%% Aplicar escalamiento a la altura
scaled_hxy = PhiUW * periodo_franjas_mm / (2 * pi * tan(45));

%% Visualización en 3D
figure,

% Ajustar a unidades de longitud reales en los ejes length y width
length_mm = physical_width_mm;
width_mm = physical_height_mm;

length_scaling_factor = size(scaled_hxy, 2) / length_mm;
width_scaling_factor = size(scaled_hxy, 1) / width_mm;

% Escalar las dimensiones físicas
length_real = size(scaled_hxy, 2) / pixels_per_mm_length / length_scaling_factor;
width_real = size(scaled_hxy, 1) / pixels_per_mm_width / width_scaling_factor;

% Visualización en 3D con escala de color ajustada
figure,
surf(linspace(0, length_real, size(scaled_hxy, 2)), ...
     linspace(0, width_real, size(scaled_hxy, 1)), ...
     scaled_hxy, 'EdgeColor', 'none');

% Configuración de ejes y etiquetas
axis tight
xlabel('Length (mm)', 'FontSize', 15), ylabel('Width (mm)', 'FontSize', 15), zlabel('Height (mm)', 'FontSize', 15)

% Configuración de la escala de color
colormap(jet);  % cambiar a 'parula' ó a otras paletas de colores según tu preferencia

% Barra de color
colorbar

% Configuración de la vista
view(-35, 60)
camlight left