function count = count_franjas(image, direction)
    % image: imagen del patrón de franjas
    % direction: 'horizontal' o 'vertical'

    if strcmpi(direction, 'horizontal')
        count = 0; % No hay franjas horizontales
    elseif strcmpi(direction, 'vertical')
        % Obtener la proyección vertical (suma a lo largo de las columnas)
        projection = sum(image, 1);

        % Normalizar la proyección al rango [-1, 1]
        normalized_projection = (projection - mean(projection)) / max(abs(projection - mean(projection)));

        % Aplicar un umbral para determinar las transiciones
        threshold = 0.5;
        transitions = normalized_projection > threshold;

        % Contar el número de transiciones
        count = sum(diff(transitions) == 1);
    else
        error('Dirección no válida. Use ''horizontal'' o ''vertical''.');
    end
end
