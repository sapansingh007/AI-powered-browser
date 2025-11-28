# Environment Setup Guide

## 🔐 Secure API Key Setup

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Set Up Your Environment

1. **Copy the template:**
   ```bash
   cp .env.example .env
   ```

2. **Edit the .env file:**
   ```bash
   # Open .env and add your actual API key
   OPENAI_API_KEY=sk-proj-your-actual-openai-api-key-here
   ```

3. **Get your OpenAI API Key:**
   - Visit: https://platform.openai.com/api-keys
   - Create a new API key
   - Copy it to your `.env` file

### 3. Security Features

✅ **.gitignore Protection:**
- `.env` file is automatically ignored by Git
- Your secrets will never be committed
- Safe to share your code publicly

✅ **Fallback System:**
- If `.env` is missing, app uses demo key
- App won't crash if environment setup fails
- Graceful error handling

### 4. Run the App

**Development:**
```bash
flutter run
```

**Production Build:**
```bash
flutter build apk --release
```

### 5. Verify Setup

1. Run the app
2. Navigate to any webpage
3. Click the summarize button
4. Check if AI summaries work

If you see "demo-api-key" in logs, your `.env` setup needs fixing.

## 🚨 Important Security Notes

- **NEVER** commit `.env` to Git
- **NEVER** share your `.env` file
- **ALWAYS** keep `.env` in `.gitignore`
- **USE** different keys for development/production

## 🔄 Team Collaboration

When sharing with team members:

1. Share `.env.example` (safe to commit)
2. Each member creates their own `.env`
3. Never share actual `.env` files
4. Use environment-specific keys

## 🐛 Troubleshooting

**"API key not working":**
- Check your `.env` file exists
- Verify the key is correct
- Restart the app after changing `.env`

**"Demo mode active":**
- `.env` file not found or invalid
- Check console for error messages
- Ensure `flutter_dotenv` is installed

**Git push blocked:**
- Check if `.env` is accidentally staged
- Run: `git status` to see staged files
- Remove `.env` from staging if needed
