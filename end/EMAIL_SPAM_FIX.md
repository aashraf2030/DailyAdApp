# حل مشكلة وصول رسائل البريد الإلكتروني إلى مجلد Spam

## التغييرات التي تمت في الكود

تم تحديث جميع أماكن إرسال البريد الإلكتروني في `AuthController.php` لإضافة:
- عنوان "From" صريح
- رأس "Reply-To"
- رؤوس إضافية لتقليل احتمالية وصول الرسائل إلى Spam

## الإعدادات المطلوبة على الخادم (مهم جداً!)

### 1. إعدادات SPF Record
يجب إضافة SPF record في DNS الخاص بالدومين:

```
TXT record: v=spf1 include:mail.spacemail.com ~all
```

أو إذا كنت تستخدم خادم بريد آخر:
```
TXT record: v=spf1 a mx ip4:YOUR_SERVER_IP ~all
```

### 2. إعدادات DKIM
يجب تفعيل DKIM signing في خادم البريد. اتصل بمزود البريد (spacemail.com) لتفعيل DKIM.

### 3. إعدادات DMARC
أضف DMARC record في DNS:

```
TXT record: _dmarc
Value: v=DMARC1; p=quarantine; rua=mailto:YOUR_EMAIL@adsapp-abu-sultan.com
```

### 4. التحقق من إعدادات .env
تأكد من أن ملف `.env` يحتوي على:

```env
MAIL_MAILER=smtp
MAIL_HOST=mail.spacemail.com
MAIL_PORT=465
MAIL_USERNAME=your_email@adsapp-abu-sultan.com
MAIL_PASSWORD=your_password
MAIL_ENCRYPTION=ssl
MAIL_FROM_ADDRESS=info@adsapp-abu-sultan.com
MAIL_FROM_NAME="Ads App - Abu Sultan"
```

### 5. نصائح إضافية

1. **استخدم عنوان بريد من نفس الدومين**: تأكد أن `MAIL_FROM_ADDRESS` يستخدم نفس الدومين الخاص بالموقع
2. **تجنب استخدام كلمات ممنوعة**: تجنب كلمات مثل "free", "urgent", "click here" في الموضوع
3. **أضف رابط Unsubscribe**: تم إضافة رأس List-Unsubscribe تلقائياً
4. **اختبر البريد**: استخدم أدوات مثل [Mail-Tester](https://www.mail-tester.com) لفحص البريد

### 6. التحقق من الإعدادات

بعد تطبيق التغييرات، اختبر إرسال بريد وتحقق من:
- أن عنوان "From" يطابق الدومين
- أن SPF و DKIM و DMARC records موجودة
- أن البريد لا يحتوي على روابط مشبوهة

### 7. إذا استمرت المشكلة

1. تحقق من سجل البريد (mail logs) للبحث عن أخطاء
2. تأكد من أن خادم البريد غير مدرج في قوائم Blacklist
3. استخدم خدمة بريد احترافية مثل SendGrid أو Mailgun أو AWS SES

