package com.antiaddiction.sdk.utils;

import android.util.Base64;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

public class AesUtil {

    public static String getEncrptStr(String origin,String pass) throws Exception {
        Key key = createAESKey(pass);
        return new String(encrypt(key,origin));
    }

    public static String getDecryptStr(String content,String pass) throws Exception {
        Key key = createAESKey(pass);
        return new String(decrypt(content.getBytes(StandardCharsets.UTF_8),key));
    }

    public static Key createAESKey(String origin) {
        try {
            // 生成key
            KeyGenerator keyGenerator;
            //构造密钥生成器，指定为AES算法,不区分大小写
            keyGenerator = KeyGenerator.getInstance("AES");
            //生成一个128位的随机源,根据传入的字节数组
            keyGenerator.init(128,new SecureRandom(origin.getBytes()));
            //产生原始对称密钥
            SecretKey secretKey = keyGenerator.generateKey();
            //获得原始对称密钥的字节数组
            byte[] keyBytes = secretKey.getEncoded();
            // key转换,根据字节数组生成AES密钥
            Key key = new SecretKeySpec(keyBytes, "AES");
            return key;
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            return null;
        }


    }

    public static byte[] encrypt(Key key, String content) throws Exception {
        // 创建密码器
        Cipher cipher = Cipher.getInstance("AES");
        // 初始化加密器
        cipher.init(Cipher.ENCRYPT_MODE, key);
        // 加密
        return Base64.encode(cipher.doFinal(content.getBytes(StandardCharsets.UTF_8)),Base64.DEFAULT);
    }

    public static byte[] decrypt(byte[] content, Key key) throws Exception {
        // 创建密码器
        Cipher cipher = Cipher.getInstance("AES");
        // 初始化解密器
        cipher.init(Cipher.DECRYPT_MODE, key);
        // 解密
        return cipher.doFinal(Base64.decode(content,Base64.DEFAULT));
    }
}
