require "random/secure"
require "openssl/pkcs5"
require "openssl/cipher"


password = "password"
data = File.read("encrypted_data").to_slice
salt = data[0, 32]
key = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, 100_000, OpenSSL::Algorithm::SHA256, 32)


data += 32
# cipher = OpenSSL::Cipher.new("aes-256-cbc")
cipher = OpenSSL::Cipher.new("aes-256-gcm")
cipher.decrypt
cipher.key = key
cipher.iv = data[0, 32]
data += 32

io = IO::Memory.new
io.write(cipher.update(data))
io.write(cipher.final)
io.rewind

decrypted_data = io.gets_to_end

puts decrypted_data
