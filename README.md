# Unsplash-iOS

## [How to run the project]

### Create Access Key

1. Go to the link **[Unsplash Developers](https://unsplash.com/developers)**

2. SignIn or Register as a developer

3. Go to **Your apps** menu

4. Register a new application

5. Go to the Keys item of the registered app

6. Copy Access Key

### Project Setting

1. Open the **Unsplash-iOS.xcodeproj**

2. Create **unsplash.plist** in the location of **Info.plist**

3. Add Access key to unsplash.plist as below

```xml
<dict>
	<key>unsplash</key>
	<string>Your access key</string>
</dict>
```

4. Build the project

5. The app runs successfully!




