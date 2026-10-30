mkdir -p app/src/main/assets app/src/main/res/values app/src/main/java/com/nova/launcher
cp index.html app/src/main/assets/index.html
cat > settings.gradle <<'EOF_NOVA'
pluginManagement { repositories { google(); mavenCentral(); gradlePluginPortal() } }
dependencyResolutionManagement { repositories { google(); mavenCentral() } }
rootProject.name = "NovaLauncher"
include ':app'
EOF_NOVA
cat > build.gradle <<'EOF_NOVA'
plugins { id 'com.android.application' version '8.5.2' apply false }
EOF_NOVA
cat > gradle.properties <<'EOF_NOVA'
android.useAndroidX=true
EOF_NOVA
cat > app/build.gradle <<'EOF_NOVA'
plugins { id 'com.android.application' }
android {
    namespace 'com.nova.launcher'
    compileSdk 34
    defaultConfig { applicationId "com.nova.launcher"; minSdk 26; targetSdk 34; versionCode 1; versionName "1.0" }
    compileOptions { sourceCompatibility JavaVersion.VERSION_17; targetCompatibility JavaVersion.VERSION_17 }
}
EOF_NOVA
cat > app/src/main/res/values/strings.xml <<'EOF_NOVA'
<resources><string name="app_name">Nova Launcher</string></resources>
EOF_NOVA
mkdir -p $(dirname app/src/main/res/values/colors.xml)
cat > app/src/main/res/values/colors.xml <<'EOF_NOVA'
<resources><color name="ic_bg">#3A2A78</color></resources>
EOF_NOVA
mkdir -p $(dirname app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml)
cat > app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml <<'EOF_NOVA'
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_bg"/>
    <foreground android:drawable="@drawable/ic_fg"/>
    <monochrome android:drawable="@drawable/ic_fg"/>
</adaptive-icon>
EOF_NOVA
mkdir -p $(dirname app/src/main/res/drawable/ic_fg.xml)
cat > app/src/main/res/drawable/ic_fg.xml <<'EOF_NOVA'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#FFFFFF" android:pathData="M38,34h8v40h-8z"/>
    <path android:fillColor="#FFFFFF" android:pathData="M62,34h8v40h-8z"/>
    <path android:fillColor="#FFFFFF" android:pathData="M38,34h8l24,40h-8z"/>
    <path android:fillColor="#FFC857" android:pathData="M76,30m-5,0a5,5 0,1 1,10 0a5,5 0,1 1,-10 0"/>
</vector>
EOF_NOVA
cat > app/src/main/AndroidManifest.xml <<'EOF_NOVA'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <queries>
        <package android:name="com.activision.callofduty.shooter"/>
        <package android:name="com.garena.game.codm"/>
        <package android:name="com.roblox.client"/>
        <package android:name="com.instagram.android"/>
        <package android:name="com.platolite.android"/>
        <package android:name="com.miui.gallery"/>
        <intent>
            <action android:name="android.intent.action.MAIN"/>
            <category android:name="android.intent.category.LAUNCHER"/>
        </intent>
    </queries>
    <application android:label="@string/app_name" android:icon="@mipmap/ic_launcher" android:roundIcon="@mipmap/ic_launcher" android:usesCleartextTraffic="true" android:theme="@android:style/Theme.DeviceDefault.NoActionBar">
        <activity android:name=".MainActivity" android:exported="true" android:launchMode="singleTask"
            android:configChanges="orientation|screenSize|keyboardHidden" android:stateNotNeeded="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.HOME"/>
                <category android:name="android.intent.category.DEFAULT"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF_NOVA
cat > app/src/main/java/com/nova/launcher/MainActivity.java <<'EOF_NOVA'
package com.nova.launcher;

import android.app.Activity;
import android.app.role.RoleManager;
import android.content.Context;
import android.os.Build;
import android.provider.Settings;
import android.widget.Toast;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.provider.MediaStore;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.webkit.*;

public class MainActivity extends Activity {
    WebView web; ValueCallback<Uri[]> cb;
    class Bridge {
        @JavascriptInterface public String getApps() {
            try {
                PackageManager pm = getPackageManager();
                Intent q = new Intent(Intent.ACTION_MAIN);
                q.addCategory(Intent.CATEGORY_LAUNCHER);
                java.util.List<ResolveInfo> list = pm.queryIntentActivities(q, 0);
                java.util.Collections.sort(list, new ResolveInfo.DisplayNameComparator(pm));
                org.json.JSONArray arr = new org.json.JSONArray();
                java.util.HashSet<String> seen = new java.util.HashSet<>();
                for (ResolveInfo ri : list) {
                    String p = ri.activityInfo.packageName;
                    if (p.equals(getPackageName()) || !seen.add(p)) continue;
                    android.graphics.drawable.Drawable d = ri.loadIcon(pm);
                    int sz = 96;
                    android.graphics.Bitmap bm = android.graphics.Bitmap.createBitmap(sz, sz, android.graphics.Bitmap.Config.ARGB_8888);
                    android.graphics.Canvas cv = new android.graphics.Canvas(bm);
                    d.setBounds(0, 0, sz, sz);
                    d.draw(cv);
                    java.io.ByteArrayOutputStream bo = new java.io.ByteArrayOutputStream();
                    bm.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, bo);
                    org.json.JSONObject o = new org.json.JSONObject();
                    o.put("n", ri.loadLabel(pm).toString());
                    o.put("p", p);
                    o.put("i", android.util.Base64.encodeToString(bo.toByteArray(), android.util.Base64.NO_WRAP));
                    arr.put(o);
                }
                return arr.toString();
            } catch (Exception e) { return "[]"; }
        }
        @JavascriptInterface public void openByName(String name, String fallbackPkg) {
            runOnUiThread(() -> {
                try {
                    PackageManager pm = getPackageManager();
                    Intent q = new Intent(Intent.ACTION_MAIN);
                    q.addCategory(Intent.CATEGORY_LAUNCHER);
                    for (ResolveInfo ri : pm.queryIntentActivities(q, 0)) {
                        if (ri.loadLabel(pm).toString().toLowerCase().contains(name.toLowerCase())) {
                            Intent li = pm.getLaunchIntentForPackage(ri.activityInfo.packageName);
                            if (li != null) { startActivity(li); return; }
                        }
                    }
                } catch (Exception e) {}
                openApp(fallbackPkg);
            });
        }
        @JavascriptInterface public void openSystem(String what) {
            runOnUiThread(() -> {
                try {
                    if (what.equals("camera")) {
                        startActivity(new Intent(MediaStore.INTENT_ACTION_STILL_IMAGE_CAMERA));
                    } else if (what.equals("phone")) {
                        startActivity(new Intent(Intent.ACTION_DIAL));
                    } else if (what.equals("gallery")) {
                        try {
                            Intent g1 = new Intent(Intent.ACTION_MAIN);
                            g1.addCategory(Intent.CATEGORY_APP_GALLERY);
                            startActivity(g1);
                        } catch (Exception e1) {
                            Intent g2 = getPackageManager().getLaunchIntentForPackage("com.miui.gallery");
                            if (g2 == null) { g2 = new Intent(Intent.ACTION_VIEW); g2.setType("image/*"); }
                            startActivity(g2);
                        }
                    }
                } catch (Exception e) {}
            });
        }
        @JavascriptInterface public void openApp(String pkg) {
            runOnUiThread(() -> {
                try {
                    Intent li = getPackageManager().getLaunchIntentForPackage(pkg);
                    if (li == null && pkg.equals("com.activision.callofduty.shooter")) li = getPackageManager().getLaunchIntentForPackage("com.garena.game.codm");
                    if (li != null) { startActivity(li); return; }
                    try { startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + pkg))); }
                    catch (Exception e) { startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=" + pkg))); }
                } catch (Exception e) {}
            });
        }
        @JavascriptInterface public void openHomeSettings() {
            runOnUiThread(() -> {
                try {
                    startActivity(new Intent(Settings.ACTION_HOME_SETTINGS));
                } catch (Exception e) {
                    try { startActivity(new Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS)); } catch (Exception e2) {
                        try { startActivity(new Intent(Settings.ACTION_SETTINGS)); } catch (Exception e3) {}
                    }
                }
            });
        }
        @JavascriptInterface public void setDefault() {
            runOnUiThread(() -> {
                try {
                    if (Build.VERSION.SDK_INT >= 29) {
                        RoleManager rm = (RoleManager) getSystemService(Context.ROLE_SERVICE);
                        if (rm.isRoleHeld(RoleManager.ROLE_HOME)) {
                            Toast.makeText(MainActivity.this, "Nova Launcher is already the default", Toast.LENGTH_LONG).show();
                            return;
                        }
                        if (rm.isRoleAvailable(RoleManager.ROLE_HOME)) {
                            startActivityForResult(rm.createRequestRoleIntent(RoleManager.ROLE_HOME), 2);
                            return;
                        }
                    }
                    startActivity(new Intent(Settings.ACTION_HOME_SETTINGS));
                } catch (Exception e) {
                    try { startActivity(new Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS)); } catch (Exception e2) {}
                }
            });
        }
    }
    @Override protected void onCreate(Bundle b) {
        super.onCreate(b);
        getWindow().setStatusBarColor(android.graphics.Color.TRANSPARENT);
        getWindow().setNavigationBarColor(android.graphics.Color.TRANSPARENT);
        if (Build.VERSION.SDK_INT >= 28) {
            android.view.WindowManager.LayoutParams lp = getWindow().getAttributes();
            lp.layoutInDisplayCutoutMode = android.view.WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
            getWindow().setAttributes(lp);
        }
        web = new WebView(this);
        setContentView(web);
        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true); s.setDomStorageEnabled(true);
        s.setMediaPlaybackRequiresUserGesture(false);
        web.setWebViewClient(new WebViewClient() {
            @Override public boolean shouldOverrideUrlLoading(WebView v, WebResourceRequest r) {
                String u = r.getUrl().toString();
                if (u.startsWith("file:")) return false;
                startActivity(new Intent(Intent.ACTION_VIEW, r.getUrl())); return true;
            }
        });
        web.setWebChromeClient(new WebChromeClient() {
            @Override public boolean onShowFileChooser(WebView v, ValueCallback<Uri[]> c, FileChooserParams p) {
                if (cb != null) cb.onReceiveValue(null);
                cb = c;
                Intent i = new Intent(Intent.ACTION_GET_CONTENT);
                i.addCategory(Intent.CATEGORY_OPENABLE); i.setType("audio/*");
                i.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);
                startActivityForResult(i, 1); return true;
            }
        });
        web.addJavascriptInterface(new Bridge(), "NovaApp");
        web.loadUrl("file:///android_asset/index.html");
    }
    @Override protected void onActivityResult(int rq, int rs, Intent d) {
        if (rq == 1 && cb != null) {
            Uri[] r = null;
            if (rs == RESULT_OK && d != null) {
                if (d.getClipData() != null) {
                    int n = d.getClipData().getItemCount(); r = new Uri[n];
                    for (int i = 0; i < n; i++) r[i] = d.getClipData().getItemAt(i).getUri();
                } else if (d.getData() != null) r = new Uri[]{d.getData()};
            }
            cb.onReceiveValue(r); cb = null;
        }
    }
    @Override protected void onResume() {
        super.onResume();
        web.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
    }
    @Override public void onBackPressed() { /* launcher: stay home */ web.evaluateJavascript("document.querySelectorAll('.win.open').forEach(w=>w.classList.remove('open'))", null); }
}
EOF_NOVA
python3 - <<'EOF_PY'
p = "app/src/main/assets/index.html"
h = open(p, encoding="utf-8").read()
st = 'style="width:100%;border:0;color:inherit;font:inherit;text-align:right;cursor:pointer"'
btn1 = '<button id="mkdef" class="row" ' + st + '>⭐ تنظیم به‌عنوان لانچر پیش‌فرض</button>'
btn2 = '<button id="goback" class="row" ' + st + '>↩ بازگشت به لانچر قبلی</button>'
h = h.replace('<div class="row">تم پس‌زمینه</div>', btn1 + btn2 + '<div class="row">تم پس‌زمینه</div>', 1)
new = ("{id:'tel',n:'تلفن',i:'📞',c:'#2d9d4f',sys:'phone'},"
 "{id:'cam',n:'دوربین',i:'📷',c:'#343a40',sys:'camera'},"
 "{id:'gal',n:'گالری',i:'🖼️',c:'#e76f51',sys:'gallery'},"
 "{id:'plato',n:'Plato VPN',i:'🛡️',c:'#5b3df5',name:'plato',pkg:'com.platolite.android'},"
 "{id:'cod',n:'Call of Duty',i:'🪖',c:'#3d4a2a',pkg:'com.activision.callofduty.shooter'},"
 "{id:'rbx',n:'Roblox',i:'🧱',c:'#e2231a',pkg:'com.roblox.client'},"
 "{id:'ig',n:'Instagram',i:'📸',c:'linear-gradient(45deg,#f9ce34,#ee2a7b,#6228d7)',pkg:'com.instagram.android'},")
h = h.replace("{id:'notes',n:'یادداشت',i:'📝',c:'#f4a261'},", new + "{id:'notes',n:'یادداشت',i:'📝',c:'#f4a261'},", 1)
h = h.replace("const DOCK=['game','web','music','set'];", "const DOCK=['tel','web','gal','cam'];", 1)
op = ("function openApp(a){\n"
 "  if(a.sys){if(window.NovaApp){NovaApp.openSystem(a.sys)}else{alert('این برنامه فقط در نسخه‌ی نصب‌شده کار می‌کند')}return}\n"
 "  if(a.name){if(window.NovaApp){NovaApp.openByName(a.name,a.pkg)}else{window.open('https://play.google.com/store/apps/details?id='+a.pkg,'_blank')}return}\n"
 "  if(a.pkg){if(window.NovaApp){NovaApp.openApp(a.pkg)}else{window.open('https://play.google.com/store/apps/details?id='+a.pkg,'_blank')}return}\n")
h = h.replace("function openApp(a){\n", op, 1)
js = "document.getElementById('mkdef').onclick=function(){if(window.NovaApp){NovaApp.setDefault()}else{alert('این دکمه فقط در برنامه‌ی نصب‌شده کار می‌کند')}};document.getElementById('goback').onclick=function(){if(window.NovaApp){NovaApp.openHomeSettings()}else{alert('این دکمه فقط در برنامه‌ی نصب‌شده کار می‌کند')}};"
i = h.rfind('</script>')
h = h[:i] + js + '\n' + h[i:]
open(p, "w", encoding="utf-8").write(h)
EOF_PY
python3 - <<'EOF_PY2'
p = "app/src/main/assets/index.html"
h = open(p, encoding="utf-8").read()
h = h.replace("const APPS=[", "var APPS=[", 1)
h = h.replace("</style>", "#status{background:#FFD400;color:#1a1a1a;font-weight:bold;padding-top:10px}</style>", 1)
ob = "const u=()=>$('#bat').textContent='🔋 '+fa(Math.round(b.level*100))+'٪';u();b.onlevelchange=u"
nb = "const u=()=>$('#bat').textContent=(b.charging?'⚡ ':'🔋 ')+fa(Math.round(b.level*100))+'٪';u();b.onlevelchange=u;b.onchargingchange=u"
assert ob in h
h = h.replace(ob, nb, 1)
old = """${a.i}</div><span>"""
new = """${a.icon?'<img src="data:image/png;base64,'+a.icon+'" style="width:58px;height:58px;border-radius:16px">':a.i}</div><span>"""
assert old in h
h = h.replace(old, new, 1)
js = """var INST=null;
function loadInst(){if(INST===null){try{INST=(window.NovaApp&&NovaApp.getApps)?JSON.parse(NovaApp.getApps()):[]}catch(e){INST=[]}}return INST}
(function(){
  if(!(window.NovaApp&&NovaApp.getApps))return;
  var inst=loadInst();
  if(!inst.length)return;
  var keep=['game'];
  var base=APPS.filter(function(a){return keep.indexOf(a.id)>-1});
  var more=inst.map(function(a){return {id:'i_'+a.p,n:a.n,i:'',icon:a.i,c:'transparent',pkg:a.p}});
  APPS=base.concat(more);
  render(APPS);
})();
document.getElementById('clock').onclick=function(){document.getElementById('w-set').classList.add('open')};
"""
i = h.rfind('</script>')
h = h[:i] + js + h[i:]
open(p, "w", encoding="utf-8").write(h)
EOF_PY2
touch .gen_ok
