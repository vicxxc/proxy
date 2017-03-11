// 加密前 <Buffer 01 7f 00 00 01 18 08>
// 加密后 <Buffer 76 0d d7 e1 53 a9 c9>
// iv <Buffer 3d 32 95 5f 86 15 09 6e ee 96 03 8b a2 dc 4b 61>
// aes-256-cfb
bytes_to_key_results = {};
EVP_BytesToKey = function(password, key_len, iv_len) {
    var count, d, data, i, iv, key, m, md5, ms;
    if (bytes_to_key_results["" + password + ":" + key_len + ":" + iv_len]) {
        return bytes_to_key_results["" + password + ":" + key_len + ":" + iv_len];
    }
    m = [];
    i = 0;
    count = 0;
    while (count < key_len + iv_len) {
        md5 = crypto.createHash('md5');
        data = password;
        console.log('i=>', i);
        if (i > 0) {
            data = Buffer.concat([m[i - 1], password]);
        }
        console.log('data=>', data);
        md5.update(data);
        d = md5.digest();
        console.log('d=>', d);
        m.push(d);
        count += d.length;
        console.log('count=>', count);
        console.log('======================================');
        i += 1;
    }
    console.log('m=>>', m);
    ms = Buffer.concat(m);
    key = ms.slice(0, key_len);
    iv = ms.slice(key_len, key_len + iv_len);
    console.log("key================>", key);
    console.log("iv=================>", iv);
    bytes_to_key_results[password] = [key, iv];
    return [key, iv];
};

var crypto = require('crypto');
var cryptkey = "barfoo!";
password = new Buffer(cryptkey, 'binary');
_ref = EVP_BytesToKey(password, 32, 16),
key = _ref[0],
iv_ = _ref[1];
return;
// console.log(key);
// var key = new Buffer("b3adc47839e047eb228870526dc8fc30b347287ffca3045dcea06b3fdf090acb",'hex');
var iv = new Buffer("3d32955f8615096eee96038ba2dc4b61", 'hex') var encryptdata = new Buffer("017f0000011808", 'hex');
console.log('key============>', key);
console.log('iv=============>', iv);
var encipher = crypto.createCipheriv('aes-256-cfb', key, iv),
encryptdata = encipher.update(encryptdata);
console.log(encryptdata);