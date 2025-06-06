Countdown Timer Uygulaması

Kullanıcıların geri sayım sayaçları oluşturabileceği, bilgilerini kaydedip 
takip edebileceği çok platformlu bir Flutter uygulamasıdır. Android, Web ve Windows desteklidir.


Projenin Amacı

Kullanıcıların kişisel sayaçlar oluşturarak etkinliklerini, önemli tarihlerini kolayca planlamaları ve 
takip etmeleri amaçlanmıştır. Kullanıcı dostu bir arayüz ile güçlü Flutter yapısı birleştirilerek 
mobil ve masaüstü dünyasında aktif çalışan bir uygulama hedeflenmiştir.


Teknik Detaylar

Flutter: Ana geliştirme platformu
Firebase: Kullanıcı girişi/kimlik doğrulama
Supabase: Kullanıcı profil bilgilerinin tutulduğu veritabanı
SQLite: Uygulama içi offline veri tutma (local db)
Shared Preferences: Kullanıcı UID, e-posta, ad bilgileri saklanır
BLoC: Durum yönetimi (auth_cubit.dart, auth_state.dart)


Klasör Yapısı ve Sayfa Yönetimi

Sayfalar (pages/auth)
-Hazırlayan: Enes Ocakçı
1-Giriş Yap Ekranı(login_page.dart)
-Kullanıcı e-posta ve şifre ile giriş yapabilir.
-"Kayıt Ol" ,"Gmail" ve "Github" seçenekleri mevcuttur.
-Başarılı girişten sonra kullanıcı ana sayfaya yönlendirilir.

2-Kayıt Ol Ekranı(registe_page.dart)
-Hazırlayan: Enes Ocakçı
-Kullanıcı , e-posta,şifre,adı-soyadı,yaşadığı il,Doğum yeri, doğum tarihi bilgilerini girerek yeni hesap oluşturabilir.
-Firebase Authentication kullarak kullanıcı kaydı gerçekleştirilir.
-Başarılı kayıt sonrası ekrana uyarı mesajı gelerek kullanıcı hesabını oluşturmuştur
-Hesap oluşturduktan sonra "kayıt ol" ekranında bulunan giriş yap butonuna tıklayarak login ekranın yönlendirilir
-kullanıcı hangi e-posta ve şifre ile kayıt olduysa login ekranına bilgileri girerek ana sayfaya yönlendirilir.

3-Ana Sayfa(home_screen.dart)
-Hazırlayan: Ahmet Enes Keleş
-Kullanıcın hesabında eklediği sayaç yok ise ekranda "henüz hiç bir sayaç eklemediniz" yazısı çıkaçaktır
-kullaancı sayaç eklediği zaman uyarı mesajı ekrandan silicek ve sayacımız ana ekranda gözükecektir.
-kullanıcı sayaç eklediği zaman ana sayfaya eklediği sayaç gelecektir.sayaç kartına basarak diyalog sayfası açılır ve sayacı silebilir
-kullancı sayç eklediği zaman ana sayfada arama texti gelecektir
-kullanıcı arama textine eklediği sayaç ismi yazarak o yazdığı isimli sayaç gelecektir
-Ana sayfada sol üst menüde drawer sekmesi vardır kullanıcı bu kısımdan hızlı işlemler 
yapabilir(ana sayfa,yeni sayaç ekle,geçmiş sayaçlar,profilim)


4-Yeni Sayaç Ekle(add_counter.dart)
-Hazırlayan: Ahmet Enes Keleş
-kullanıcı drawer menüden bu sayfaya gelebilir.
-kullancı bu sayfada sayaç adını,sayaç tarhini ve sayaç saatini belirler,
-kaydet butonuna tıklayarak ekrana mesaj gelir(sayaç eklendi)
-eklenen sayaçı ana sayfada görebilir

5-Geçmiş Sayaçlar(past_counters_page.dart)
-Hazırlayan: Enes Ocakçı
-kullanıcı drawer menüden bu sayfaya gelebilir.
-bu ekranda kullanıcı eklediği sayaçın süresi geçtiyse "geçmiş sayaçlar" sayfasına düşecektir ve tarihi geçen sayaç anada sayfadan silinir
-kullanıcı bu ekranda sayaç kartına basarak diyalog sayfası açılır ve sayacı silebilir


6-Profilim(profile_page.dart)
-Hazırlayan: Ahmet Enes Keleş
-kullanıcı hangi hesabıyla uygulamaya girdiyse burada bilgileri gözükür.
-eğer kullanıcı gmail ve github hesabı ile uygulamaya girdiyse uygulama kullancın bilgilerinin boş olduğunu anlar ve profil sayfasında "bilgilerimi tamamla" sayfası açılır ve kullanıcı eksik bilgilerini girer kaydet butonuna basınce profil sayfasında bilgileri gözükür



Login Bilgilerinin Saklanması
-firebase e-posta=enesocakci343434@gmail.com  -firebase şifre=enesenes3456
kullanıcı giriş bilgileri Firebase authentication kullanılarak güvenli bir şekilde saklanmaktadır:
-kullanıcı e-posta ve şifre ile giriş yaptığında bilgiler firebase authentication'a gönderilir
-firebase kullanıcı bilgilerini kendi güvenli veritabanında saklar,


supabase hesabı
enesocakci343434@gmail.com
Enesenes3456*

🔐 Giriş Bilgileri (Firebase Authentication)

Örnek kullanıcılar:
- **Kullanıcı 1**  
  E-posta: `test1@gmail.com`  
  UID: `mIcm0w42a5WvQbPKAAoB6SKMdfE2`

- **Kullanıcı 2**  
  E-posta: `test2@gmail.com`  
  UID: `0BymmOsWEaMKQUzumqjxgvWaMuP2`

- **Kullanıcı 3**  
  E-posta: `enesocakci343434@gmail.com`  
  Şifre: `enesenes3456`  
  UID: `bGyOkvlKvecx4XRsOwrTAcBVDpG3`


🔧 Firebase Yapılandırması

Uygulama `firebase_options.dart` dosyası ile aşağıdaki platformlar için yapılandırılmıştır:

- Android
- Web
- Windows



## 🧩 Bileşenler ve Widgetlar

- `drawer_menu.dart`: Uygulama menüsü
- `counter_card.dart`: Sayaç kartı bileşeni
- `button.dart`: Genel butonlar
- `custom_app_bar.dart`: Uygulama üst başlığı
- `date_picker.dart`: Tarih seçici
- `show_dialog.dart`: Sayaç silme/onay mesajı
- `text_field.dart`: Giriş alanları (gizli/gizli olmayan)
- `time_picker.dart`: Saat seçici

ekranlar
-her bir ekran ayrı ayrı klasörlerde tanımlanmıştır
-bu ekranlar ilgili işlevseliikleri kapsar ve diğer bileşenlerle kolayca entegre edilebirir

## ⚙️ Durum Yönetimi & Servisler

- `BLoC`: Auth işlemleri için kullanılır
- `Repository`: Auth işlemlerini soyutlar
- `Shared Preferences`: Oturum verilerini tutar


## 📌 Notlar

- GitHub ve Gmail ile girişlerde, eksik kullanıcı bilgileri otomatik tespit edilerek `missing_info` sayfasına yönlendirilir.
- Uygulama çevrimdışı çalışabilir (local DB + shared prefs).
- Tüm kullanıcı sayaçları hem Firebase hem Supabase tarafında eş zamanlı olarak saklanır.


#   c o u n t d o w n _ t i m e r 
 
 
