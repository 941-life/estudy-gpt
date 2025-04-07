# Estudy Web

## Caution (You must follow the following installation process)

This command is based on linux environment (May have some different on window based system)

### 1. [Install firebase CLI](https://firebase.google.com/docs/cli?hl=ko&_gl=1*1u9etbv*_up*MQ..*_ga*NDkyOTg0OTY0LjE3NDM5ODM3OTA.*_ga_CW55HF8NVT*MTc0Mzk4Mzc5MC4xLjAuMTc0Mzk4Mzc5MC4wLjAuMA..#install-cli-mac-linux)

```
curl -sL https://firebase.tools | bash
```

### 2. Login firebase

First Login to firebase

```
firebase login
```

Then run following code to install FlutterFire CLI

```
dart pub global activate flutterfire_cli
```

### 3. Configure app to use Firebase

```
flutterfire configure
```

After this, select project name and environment (I only select android, ios, web)
