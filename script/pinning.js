// start with:
//   frida -U -l pinning.js -f [APP_ID] --no-pause

Java.perform(function () {
    console.log('')
    console.log('===')
    console.log('* Injecting hooks into common certificate pinning methods *')
    console.log('===')

    var X509TrustManager = Java.use('javax.net.ssl.X509TrustManager');
    var SSLContext = Java.use('javax.net.ssl.SSLContext');

    // build fake trust manager
    var TrustManager = Java.registerClass({
        name: 'com.sensepost.test.TrustManager',
        implements: [X509TrustManager],
        methods: {
            checkClientTrusted: function (chain, authType) {
            },
            checkServerTrusted: function (chain, authType) {
            },
            getAcceptedIssuers: function () {
                return [];
            }
        }
    });

    // pass our own custom trust manager through when requested
    var TrustManagers = [TrustManager.$new()];
    var SSLContext_init = SSLContext.init.overload(
        '[Ljavax.net.ssl.KeyManager;', '[Ljavax.net.ssl.TrustManager;', 'java.security.SecureRandom'
    );
    SSLContext_init.implementation = function (keyManager, trustManager, secureRandom) {
        console.log('! Intercepted trustmanager request');
        SSLContext_init.call(this, keyManager, TrustManagers, secureRandom);
    };

    console.log('* Setup custom trust manager');

    // okhttp3
    try {
        var CertificatePinner = Java.use('okhttp3.CertificatePinner');
        CertificatePinner.check.overload('java.lang.String', 'java.util.List').implementation = function (str) {
            console.log('! Intercepted okhttp3: ' + str);
            return;
        };

        console.log('* Setup okhttp3 pinning')
    } catch(err) {
        console.log('* Unable to hook into okhttp3 pinner')
    }

    // trustkit
    try {
        var Activity = Java.use("com.datatheorem.android.trustkit.pinning.OkHostnameVerifier");
        Activity.verify.overload('java.lang.String', 'javax.net.ssl.SSLSession').implementation = function (str) {
            console.log('! Intercepted trustkit{1}: ' + str);
            return true;
        };

        Activity.verify.overload('java.lang.String', 'java.security.cert.X509Certificate').implementation = function (str) {
            console.log('! Intercepted trustkit{2}: ' + str);
            return true;
        };

        console.log('* Setup trustkit pinning')
    } catch(err) {
        console.log('* Unable to hook into trustkit pinner')
    }

    // TrustManagerImpl
    try {
        var TrustManagerImpl = Java.use('com.android.org.conscrypt.TrustManagerImpl');
        TrustManagerImpl.verifyChain.implementation = function (untrustedChain, trustAnchorChain, host, clientAuth, ocspData, tlsSctData) {
            console.log('! Intercepted TrustManagerImp: ' + host);
            return untrustedChain;
        }

        console.log('* Setup TrustManagerImpl pinning')
    } catch (err) {
        console.log('* Unable to hook into TrustManagerImpl')
    }

    // Appcelerator
    try {
        var PinningTrustManager = Java.use('appcelerator.https.PinningTrustManager');
        PinningTrustManager.checkServerTrusted.implementation = function () {
            console.log('! Intercepted Appcelerator');
        }

        console.log('* Setup Appcelerator pinning')
    } catch (err) {
        console.log('* Unable to hook into Appcelerator pinning')
    }
});