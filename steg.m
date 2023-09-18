function [encoded_image] = embedLSB(cover_image, secret_image, key)
% Embeds a secret image into a cover image using LSB steganography and AES encryption.

% Check if cover image and secret image are the same size
if size(cover_image) ~= size(secret_image)
    error('Cover image and secret image must be the same size.');
end

% Resize secret image to match cover dimensions
secret_image_resized = imresize(secret_image, size(cover_image));

% Convert secret image to binary
secret_image_bin = dec2bin(secret_image_resized(:));

% Encrypt secret image using AES
secret_image_encrypted = AESEncrypt(secret_image_bin, key);

% Embed encrypted secret bits into cover pixels
encoded_image = cover_image;
for i = 1:3
    % Convert cover image to binary
    cover_image_bin = dec2bin(cover_image(:, :, i));

    % Embed encrypted secret in LSB of each cover pixel
    cover_image_bin(:, :, end) = secret_image_encrypted(:, i);
    encoded_image(:, :, i) = bin2dec(cover_image_bin);
end

end

function [secret_image_decrypted] = decodeLSB(encoded_image, key, secret_image_size)
% Decodes a secret image from an encoded image using LSB steganography and AES decryption.

% Extract encrypted secret bits from LSB of each encoded pixel
secret_image_encrypted = encoded_image(:, :, end)[-secret_image_size(1):end, -secret_image_size(2):end];

% Decrypt secret image using AES
secret_image_bin = AESDecrypt(secret_image_encrypted, key);

% Convert secret bits to decimal and reshape to original image size
secret_image_decrypted = bin2dec(secret_image_bin);
secret_image_decrypted = reshape(secret_image_decrypted, secret_image_size);

end

function [encrypted_data] = AESEncrypt(data, key)
% Encrypts data using AES encryption.

cipher = Cipher('AES', key);
encrypted_data = encrypt(cipher, data);

end

function [decrypted_data] = AESDecrypt(encrypted_data, key)
% Decrypts data using AES encryption.

cipher = Cipher('AES', key);
decrypted_data = decrypt(cipher, encrypted_data);

end

% Function to generate a random encryption key
function key = generateRandomKey()
% Generates a random 16-byte encryption key.

key = rng(12345); % Set random seed for reproducibility
key = randbytes(16);

end

% Example usage:

% Generate a random encryption key
key = generateRandomKey();

% Load cover and secret images
cover_image = imread('cover.jpg');
secret_image = imread('secret.jpg');

% Embed secret image into cover image
encoded_image = embedLSB(cover_image, secret_image, key);

% Save encoded image
imwrite(encoded_image, 'encoded.png');

% Extract and decode secret image
secret_image_decrypted = decodeLSB(encoded_image, key, size(secret_image));

% Save decoded secret image
imwrite(secret_image_decrypted, 'secret_decoded.jpg');
