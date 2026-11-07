name: Build Dsign App

on:
  push:
    branches: [ main, master ]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Compile Dsign App
        run: |
          set -e
          rm -rf Payload Dsign.ipa
          mkdir -p Payload/Dsign.app
          
          # تجميع ملف الكود المصدري dsign_main.m
          xcrun -sdk iphoneos clang -arch arm64 -fobjc-arc dsign_main.m \
            -o Payload/Dsign.app/Dsign \
            -framework UIKit -framework Foundation -framework CoreGraphics

          chmod +x Payload/Dsign.app/Dsign

          # إنشاء ملف Info.plist الأساسي للتطبيق
          cat << 'EOF' > Payload/Dsign.app/Info.plist
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
          <plist version="1.0">
          <dict>
              <key>CFBundleIdentifier</key>
              <string>com.dsign.cert.app</string>
              <key>CFBundleName</key>
              <string>Dsign</string>
              <key>CFBundleExecutable</key>
              <string>Dsign</string>
              <key>CFBundleVersion</key>
              <string>1.0</string>
              <key>LSRequiresIPhoneOS</key>
              <true/>
              <key>MinimumOSVersion</key>
              <string>15.0</string>
          </dict>
          </plist>
          EOF

          zip -r Dsign.ipa Payload

      - name: Upload Artifact
        uses: actions/upload-artifact@v4
        with:
          name: Dsign-IPA
          path: Dsign.ipa
