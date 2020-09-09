require "random/secure"
require "openssl/pkcs5"
require "openssl/cipher"


password = "password"
salt = Random::Secure.random_bytes(32)
data = "Secret data that needs to be encrypted"
key = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, 100_000, OpenSSL::Algorithm::SHA256, 32)


iv = Random::Secure.random_bytes(32)

cipher = OpenSSL::Cipher.new("aes-256-cbc")
# cipher = OpenSSL::Cipher.new("aes-256-gcm")
cipher.encrypt
cipher.key = key
cipher.iv = iv

io = IO::Memory.new
io.write(iv)
io.write(cipher.update(data))
io.write(cipher.final)
io.rewind

bytes = IO::Memory.new
bytes.write salt
bytes.write io.to_slice
bytes.rewind

encrypted_data = bytes.to_slice
# encrypted_data[65] = 1 # data corruption

File.write "encrypted_data", encrypted_data
