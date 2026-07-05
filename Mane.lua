require "import"
import "android.media.MediaPlayer"
import "android.widget.*"
import "android.view.*"
import "java.io.File"
import "org.json.JSONObject"
import "android.os.Handler"
import "android.view.WindowManager"
import "android.content.Intent"
import "android.net.Uri"

--========================
-- ملف الإعدادات
--========================
settingsFile = File(activity.getFilesDir(), "settings.json")

--========================
-- القيم الافتراضية
--========================
currentLanguage = "العربية"
currentStation = 1
sleepTimerEnabled = false
autoPlayEnabled = false
autoPlayPending = false

sleepHandler = Handler()
sleepRunnable = nil

--========================
-- الإذاعات
--========================
stations = {
  { key="station1", url="http://eu4.fastcast4u.com:5672/1/" },
  { key="station2", url="https://usa11.fastcast4u.com/proxy/alserajr" } ,
{ key="station3", url="https://stream.zeno.fm/c0k2yvree0hvv" } ,
{ key="station4", url="https://stream.zeno.fm/8ev660n10ehvv" } ,
{ key="station5", url="https://stream.zeno.fm/t4k42t0rm2zuv" } ,{ key="station6", url="https://stream.zeno.fm/mzv7atqy4rhvv" }
,{ key="station7", url="https://s1.cdn1.iranseda.ir:1935/liveedge/radio-ziarat/playlist.m3u8" } ,
{ key="station8", url="http://audiostreaming.itworkscdn.com:9066/" } ,
{ key="station9", url="https://s1.ettehadlive.com/radio/maaref/playlist.m3u8" } ,
{ key="station10", url="https://streamer.radio.co/sb38bf6e66/listen" ,}
}

--========================
-- اللغات
--========================
languages = { "العربية", "English", "فارسی" }

--========================
-- النصوص
--========================
texts = {
  ["العربية"] = {
    app_title="مشغل الإذاعة",
    play="تشغيل",
    pause="إيقاف",
    next="التالي",
    prev="السابق",
    settings="الإعدادات",
    sleep_timer="مؤقت الإيقاف (30 دقيقة)",
    auto_play="تشغيل تلقائي",
    back="رجوع",
    language="اللغة",
    about="حول المطور",
    open_channel="فتح القناة",
    contact="التواصل",
    station1="السراج",
    station2="السراج قرآن" , station3="حسينيات" ,
station4="إذاعة روايات اهل البيت" ,
station5="اذاعة القران الكريم" ,
station6="المناجاة" ,
station7="اذاعة الزيارة " ,
station8="اذاعة النور" ,
station9="اذاعة المعارف"
, station10="اذاعة البلاد"
  },
  ["English"] = {
    app_title="Radio Player",
    play="Play",
    pause="Pause",
    next="Next",
    prev="Previous",
    settings="Settings",
    sleep_timer="Sleep Timer (30 min)",
    auto_play="Automatic Play",
    back="Back",
    language="Language",
    about="About Developer",
    open_channel="Open Channel",
    contact="Contact",
    station1="Al-Siraj",
    station2="Al-Siraj Quran"
,station3="Husayniyat (ho-say-NEE-yat)" ,
station4="Radio Riwayat Ahl Albayt" ,
station5="Quran Alkareem" ,
station6="Munaja" ,
station7="Ziarat" ,
station8="Radio Al-Nour" ,
station9="Radio Maaref" ,
station10="Radio Al-Bilad " ,
  },

  ["فارسی"] = {
    app_title="پخش رادیو",
    play="پخش",
    pause="توقف",
    next="بعدی",
    prev="قبلی",
    settings="تنظیمات",
    sleep_timer="تایمر خواب (۳۰ دقیقه)",
    auto_play="پخش خودکار",
    back="بازگشت",
    language="زبان",
    about="درباره توسعه‌دهنده",
    open_channel="باز کردن کانال",
    contact="ارتباط",
    station1="السراج",
    station2="قرآن السراج"
, station3="حسینیه‌ها" ,
station4="رادیو روایات اهل‌بیت" ,
station5="قرآن کریم" ,
station6="مناجات" ,
station7="زیارت" ,
station8="رادیو النور" ,
station9="رادیو معارف" ,
station10="رادیو بلاد" ,
  }
}

--========================
-- نصوص حول المطور
--========================
aboutTexts = {
  ["العربية"] =
"اسم المطور: حسين كامل\n\n"..
"قناة التليجرام:\nمحتوى للمكفوفين\n\n"..
"الهدف من التطبيق:\n"..
"تمكين المستمعين من التواصل من خلال أداة بسيطة دون تحميل تطبيقات تستهلك ذاكرة الهاتف.\n\n"..
"التطبيق يتضمن الإذاعات الإسلامية الأكثر طلبًا.\n\n"..
"للتواصل:\n@husseiniq950",

  ["English"] =
"Developer Name: Hussein Kamel\n\n"..
"Telegram Channel:\nBlind Content\n\n"..
"App Goal:\n"..
"Enable listeners to communicate using a simple tool without installing heavy apps.\n\n"..
"The app includes the most requested Islamic radio stations.\n\n"..
"Contact:\n@husseiniq950",

  ["فارسی"] =
"نام توسعه‌دهنده: حسین کامل\n\n"..
"کانال تلگرام:\nمحتوای نابینایان\n\n"..
"هدف برنامه:\n"..
"ایجاد ابزار ساده برای ارتباط بدون نیاز به نصب برنامه‌های حجیم.\n\n"..
"این برنامه شامل محبوب‌ترین رادیوهای اسلامی است.\n\n"..
"ارتباط:\n@husseiniq950"
}

--========================
-- تحميل الإعدادات
--========================
function loadSettings()
  if settingsFile.exists() then
    local f = io.open(settingsFile.getPath(), "r")
    local data = JSONObject(f:read("*a"))
    f:close()
    currentLanguage = data.optString("language", currentLanguage)
    currentStation = data.optInt("station", currentStation)
    sleepTimerEnabled = data.optBoolean("sleepTimer", false)
    autoPlayEnabled = data.optBoolean("autoPlay", false)
  end
end

--========================
-- حفظ الإعدادات
--========================
function saveSettings()
  local data = JSONObject()
  data.put("language", currentLanguage)
  data.put("station", currentStation)
  data.put("sleepTimer", sleepTimerEnabled)
  data.put("autoPlay", autoPlayEnabled)
  local f = io.open(settingsFile.getPath(), "w")
  f:write(data.toString())
  f:close()
end

loadSettings()

--========================
-- MediaPlayer
--========================
player = MediaPlayer()

function getStationName(i)
  return texts[currentLanguage][stations[i].key]
end

--========================
-- تحميل وتشغيل المحطة (التعديل الوحيد هنا)
--========================
function loadStation(i)
  local wasPlaying = player.isPlaying() -- حفظ حالة التشغيل

  player.reset()
  player.setDataSource(stations[i].url)
  player.setOnPreparedListener{
    onPrepared=function(mp)
      if wasPlaying or autoPlayEnabled or autoPlayPending then
        mp.start()
        autoPlayPending = false
        if sleepTimerEnabled then startSleepTimer() end
      end
      updateTexts()
    end
  }
  player.prepareAsync()
  saveSettings()
end

--========================
-- Sleep Timer
--========================
function startSleepTimer()
  stopSleepTimer()
  sleepRunnable = Runnable{
    run=function()
      if player.isPlaying() then
        player.stop()
        updateTexts()
      end
    end
  }
  sleepHandler.postDelayed(sleepRunnable, 30 * 60 * 1000)
end

function stopSleepTimer()
  if sleepRunnable then
    sleepHandler.removeCallbacks(sleepRunnable)
    sleepRunnable = nil
  end
end
function onResume()
activity.getWindow().addFlags(
WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
end
function onPause()
  activity.getWindow().clearFlags(
    WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
  stopSleepTimer()
  if player and player.isPlaying() then
    player.stop()
  end
  activity.finish()  -- يغلق التطبيق نهائيًا
end

--========================
-- الواجهة الرئيسية
--========================
function mainLayout()
  layout = LinearLayout(activity)
  layout.setOrientation(1)
  layout.setPadding(20,20,20,20)

  stationName = TextView(activity)
  stationName.setTextSize(18)
  layout.addView(stationName)

  controls = LinearLayout(activity)
  controls.setGravity(Gravity.CENTER)

  prevBtn = Button(activity)
  playBtn = Button(activity)
  nextBtn = Button(activity)

  controls.addView(prevBtn)
  controls.addView(playBtn)
  controls.addView(nextBtn)
  layout.addView(controls)

  settingsBtn = Button(activity)
  layout.addView(settingsBtn)

  activity.setContentView(layout)
end

--========================
-- الإعدادات
--========================
function settingsLayout()
  layout = LinearLayout(activity)
  layout.setOrientation(1)
  layout.setPadding(20,20,20,20)

  langSpinner = Spinner(activity)
  langSpinner.setAdapter(
    ArrayAdapter(activity,
    android.R.layout.simple_spinner_dropdown_item,
    languages)
  )

  for i=0,#languages-1 do
    if languages[i+1]==currentLanguage then
      langSpinner.setSelection(i)
    end
  end

  sleepSwitch = Switch(activity)
  autoPlaySwitch = Switch(activity)
  aboutBtn = Button(activity)
  backBtn = Button(activity)

  sleepSwitch.setChecked(sleepTimerEnabled)
  autoPlaySwitch.setChecked(autoPlayEnabled)

  layout.addView(langSpinner)
  layout.addView(sleepSwitch)
  layout.addView(autoPlaySwitch)
  layout.addView(aboutBtn)
  layout.addView(backBtn)

  activity.setContentView(layout)

  langSpinner.setOnItemSelectedListener{
    onItemSelected=function(_,_,pos,_)
      currentLanguage = languages[pos+1]
      updateTexts()
      saveSettings()
    end
  }

  sleepSwitch.setOnCheckedChangeListener{
    onCheckedChanged=function(_,checked)
      sleepTimerEnabled = checked
      if checked then startSleepTimer() else stopSleepTimer() end
      saveSettings()
    end
  }

  autoPlaySwitch.setOnCheckedChangeListener{
    onCheckedChanged=function(_,checked)
      autoPlayEnabled = checked
      saveSettings()
    end
  }

  aboutBtn.setOnClickListener{
    onClick=function()
      aboutLayout()
    end
  }

  backBtn.setOnClickListener{
    onClick=function()
      mainLayout()
      bindEvents()
      updateTexts()
    end
  }
end

--========================
-- واجهة حول المطور
--========================
function aboutLayout()
  layout = LinearLayout(activity)
  layout.setOrientation(1)
  layout.setPadding(20,20,20,20)

  info = TextView(activity)
  info.setTextSize(16)
  info.setText(aboutTexts[currentLanguage])

  openBtn = Button(activity)
  contactBtn = Button(activity)
  backBtn = Button(activity)

  openBtn.setOnClickListener{
    onClick=function()
      activity.startActivity(
        Intent(Intent.ACTION_VIEW,
        Uri.parse("https://t.me/Blindapps_hu"))
      )
    end
  }

  contactBtn.setOnClickListener{
    onClick=function()
      activity.startActivity(
        Intent(Intent.ACTION_VIEW,
        Uri.parse("https://t.me/husseiniq950"))
      )
    end
  }

  backBtn.setOnClickListener{
    onClick=function()
      settingsLayout()
      updateTexts()
    end
  }

  layout.addView(info)
  layout.addView(openBtn)
  layout.addView(contactBtn)
  layout.addView(backBtn)

  activity.setContentView(layout)
  updateTexts()
end

--========================
-- تحديث النصوص
--========================
function updateTexts()
  local t = texts[currentLanguage]
  activity.setTitle(t.app_title)
  stationName.setText(getStationName(currentStation))
  prevBtn.setText(t.prev)
  nextBtn.setText(t.next)
  playBtn.setText(player.isPlaying() and t.pause or t.play)
  settingsBtn.setText(t.settings)
  if sleepSwitch then sleepSwitch.setText(t.sleep_timer) end
  if autoPlaySwitch then autoPlaySwitch.setText(t.auto_play) end
  if aboutBtn then aboutBtn.setText(t.about) end
  if backBtn then backBtn.setText(t.back) end
  if openBtn then openBtn.setText(t.open_channel) end
  if contactBtn then contactBtn.setText(t.contact) end
end

--========================
-- ربط الأحداث
--========================
function bindEvents()
  playBtn.setOnClickListener{
    onClick=function()
      if player.isPlaying() then
        player.pause()
      else
        player.start()
        if sleepTimerEnabled then startSleepTimer() end
      end
      updateTexts()
    end
  }

  nextBtn.setOnClickListener{
    onClick=function()
      currentStation = currentStation % #stations + 1
      loadStation(currentStation)
    end
  }

  prevBtn.setOnClickListener{
    onClick=function()
      currentStation = currentStation - 1
      if currentStation < 1 then currentStation = #stations end
      loadStation(currentStation)
    end
  }

  settingsBtn.setOnClickListener{
    onClick=function()
      settingsLayout()
      updateTexts()
    end
  }
end

--========================
-- تشغيل التطبيق
--========================
mainLayout()
bindEvents()
loadStation(currentStation)
updateTexts()

if autoPlayEnabled then
  autoPlayPending = true
end

--========================
-- تنظيف
--========================
function onDestroy()
  stopSleepTimer()
  if player then player.release() end
end