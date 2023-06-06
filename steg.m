% Load cover and secret images
cover = imread('cover.jpg');
secret = imread('secret.jpg');

% Get encryption key from user input
key = input('Enter encryption key: ', 's');

% Embed secret image into cover image
encoded = embedLSB(cover, secret, key);

% Save encoded image
imwrite(encoded, 'encoded.png');

% Extract and decode secret image
secret_decoded = decodeLSB(encoded, key, size(secret));

% Save decoded secret image
imwrite(secret_decoded, 'secret_decoded.jpg');

% Embed secret into cover using LSB steganography and AES encryption
function encoded = embedLSB(cover, secret, key)
% Resize secret to match cover dimensions
secret_resized = imresize(secret, [size(cover, 1), size(cover, 2)]);

% Convert secret to binary
secret_bin = reshape(dec2bin(secret_resized), [], 1);

% Encrypt secret using AES
secret_encrypted = AES_encrypt(secret_bin, key);

% Embed encrypted secret bits into cover pixels
encoded = cover;  % initialize encoded image with cover
for i = 1:3  % loop over color channels (red, green, blue)
    % Convert cover to binary
    cover_bin = dec2bin(cover(:,:,i));
    
    % Embed encrypted secret in LSB of each cover pixel
    cover_bin(:, end) = secret_encrypted(:, i);  
    encoded(:,:,i) = uint8(bin2dec(cover_bin));
end
end

% Decode secret from encoded image using LSB steganography and AES decryption
function secret_decoded = decodeLSB(encoded, key, secret_size)
% Extract encrypted secret bits from LSB of each encoded pixel
secret_encrypted = zeros(size(encoded,1), size(encoded,2), 3);  % initialize secret encrypted binary image
for i = 1:3  % loop over color channels (red, green, blue)
    encoded_bin = dec2bin(encoded(:,:,i));
    secret_encrypted(:, :, i) = encoded_bin(:, end);
end

% Decrypt secret using AES
secret_bin = AES_decrypt(secret_encrypted, key);

% Convert secret bits to decimal and reshape to original image size
secret_decoded = bin2dec(secret_bin);
secret_decoded = reshape(secret_decoded, secret_size);
end

% AES encryption function
function encrypted = AES_encrypt(data, key)
% Pad data to multiple of 16 bytes
data_padded = padarray(data, mod(16 - mod(numel(data), 16), 16), '0', 'post');

% Encrypt data with AES
encrypted = reshape(dec2hex(AES_Cipher(data_padded, key)), [], 2);

% Convert to binary
encrypted = dec2bin(hex2dec(encrypted(:)), 8)';
encrypted = reshape(encrypted, [], 3, 16);
end

% AES decryption function
function decrypted = AES_decrypt(data, key)
% Convert to hexadecimal
data_hex = dec2hex(bin2dec(reshape(data, [], 8))');

% Decrypt data with AES
decrypted = AES_Decipher(reshape(data_hex, [], 32), key);

% Convert to binary
decrypted = reshape(dec2bin(hex2dec(decrypted(:)), 8)', [], 1);
end