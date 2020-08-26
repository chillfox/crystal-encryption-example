require "random/secure"
require "openssl/pkcs5"
require "openssl/cipher"



def key_derivation(password, salt)
  OpenSSL::PKCS5.pbkdf2_hmac(password, salt, 100_000, OpenSSL::Algorithm::SHA256, 32)
end


def encrypt(data, key)
  iv = Random::Secure.random_bytes(32)

  cipher = OpenSSL::Cipher.new("aes-256-gcm")
  cipher.encrypt
  cipher.key = key
  cipher.iv = iv

  io = IO::Memory.new
  io.write(iv)
  io.write(cipher.update(data))
  io.write(cipher.final)
  io.rewind

  io.to_slice
end


def decrypt(data, key)
  cipher = OpenSSL::Cipher.new("aes-256-gcm")
  cipher.decrypt
  cipher.key = key
  cipher.iv = data[0, 32]
  data += 32

  io = IO::Memory.new
  io.write(cipher.update(data))
  io.write(cipher.final)
  io.rewind

  io.gets_to_end
end



password = "password"
salt = Random::Secure.random_bytes(32)
data = "Secret data that needs to be encrypted"

key = key_derivation password, salt


encrypted_data = encrypt data, key
puts "Encrypted data: #{encrypted_data.to_s}"
puts "--------------------"
decrypted_data = decrypt encrypted_data, key
puts "Decrypted data: #{decrypted_data.to_s}"

