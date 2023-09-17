# current version: test 6
# извинения. Код набит комментариями, кусками тестов и не актуальным кодом 
# для того, чтобы мне было легче вспомнить, что я тут делал. 
# добавление к версии 3. Переписана запись в файлы в функцию, иначе отлаживать неудобно.
# v4 добавлена выборка уникальных элементов, потому что not in и сравнение set не работают в моем случае.
# имена переменных приведены к более менее одинаковому состоянию.
# v5 добавлено чтение из файла данных для отправки в телеграм и немного чистки
# общие данные
# v6 телега только только
# а еще надо бы начинать прикручивать логи выполнения. Потом. 
# для работы нужен питон (у меня 3.7), и потом 
# C:\Python34\Scripts\pip.exe install selenium
# C:\Python34\Scripts\pip.exe install webdriver-manager
# и еще пути прописать и к питону и не только.
# при работе используется 7 файлов ( 6 создаются при первом запуске) в той же папке что и скрипт.
# два - логи селениума, "file1_depr.log" и "file1_newout.log", их пишет сам селениум. 
# два - коллеция ссылок в бинарном виде, 'Robo_ReleaseNotes_full.4bot' + 'Robo_AllLinkv3_full.4bot'
# оба нешифрованные бинарники.  
# два - тестовый и продуктивный файлы с ид чатов и идентификатором для API 
# 'Robo_TlgDatatxt_test.4bot' и 'Robo_TlgDatatxt_prod.4bot' - 
# для создания второго надо раскоментировать соотв строку и закоментировать соответственно. 
# файлы текстовые, в них надо ВРУЧНУЮ прописать нужные ид чата и апи. 
# Пока только 1 чат на тест и 1 на прод  
# и седьмой файл это прочие логи, чтобы не в консоль падало - Robo_textlog.4bot

# Прочие ссылки и руководства
# 01 https://habr.com/ru/articles/248559/
# 02 https://habr.com/ru/articles/250921/
# 03 https://selenium-python.readthedocs.io/getting-started.html
# 04 need install pip install webdriver-manager for firefox 
# other https://github.com/SergeyPirogov/webdriver_manager#use-with-firefox
# man bug https://github.com/SeleniumHQ/selenium/issues/12300
# https://www.tutorialspoint.com/how-to-get-rid-of-firefox-logging-in-selenium for Jabva
# python https://stackoverflow.com/questions/50960539/how-do-i-disable-geckodrivers-log-on-selenium-python-3
# https://www.selenium.dev/documentation/webdriver/troubleshooting/logging/
# https://stackoverflow.com/questions/52317807/how-to-configure-geckodriver-with-log-level-and-log-location-through-selenium-an
# bug/ https://github.com/SeleniumHQ/selenium/issues/11061

# api https://pythoninoffice.com/fixing-attributeerror-webdriver-object-has-no-attribute-find_element_by_xpath/
# https://stackoverflow.com/questions/38534241/how-to-locate-a-span-with-a-specific-text-in-selenium-using-java
# https://pythoninoffice.com/fixing-attributeerror-webdriver-object-has-no-attribute-find_element_by_xpath/

# для работы с файлами # https://stackoverflow.com/questions/4530611/saving-and-loading-objects-and-using-pickle
# # r+ is used for reading, and writing mode. 
# b is for binary. r+b (rb) mode is open the binary file in read or write mode.
# https://docs.python.org/2/tutorial/inputoutput.html#reading-and-writing-files

# https://stackoverflow.com/questions/59637048/how-to-find-element-by-part-of-its-id-name-in-selenium-with-python
# http://makeseleniumeasy.com/2020/11/11/wildcard-characters-in-xpath-selenium-webdriver/
# https://stackoverflow.com/questions/56370561/how-to-pass-wildcard-for-xpath-to-be-consumed-by-seleniumc
# https://selenium-by-arun.blogspot.com/2017/04/341-using-wild-card-in-xpath-statements.html


# сам код 
CurrentVersion = " 06 "
from selenium import webdriver # Модуль selenium.webdriver предоставляет весь функционал WebDriver'а. 
from selenium.webdriver.common.keys import Keys # Класс Keys обеспечивает взаимодействие с командами клавиатуры, такими как RETURN, F1, ALT и т.д…
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.service import Service as FirefoxService
from webdriver_manager.firefox import GeckoDriverManager
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.firefox.options import Log

import pickle #это для файлов https://java2blog.com/save-object-to-file-python/
import os.path # и это для путей в файлах
import xml.etree.ElementTree as ET # это для работы в читаемом человеком xml
import sys # для путей
import requests #это для работы http \ api \ telegram
import datetime #это для отметок времени в логах

#v3
options = webdriver.FirefoxOptions()
ScriptDir2 = os.path.dirname(os.path.abspath(sys.argv[0]))
# log_path = "file1.log" #  DeprecationWarning: log_path has been deprecated, please use log_output
# log_output = "file2.log"  
log_path = ScriptDir2 + "\\" + "file1_depr.log" # это селениума
log_output = ScriptDir2 + "\\" + "file1_newout.log" # и это селениума пока что не пишется
MyLogPath = ScriptDir2 + "\\" + "Robo_textlog.4bot"

print("Time")
# ct stores current time
ct = datetime.datetime.now()
print("current time:-", ct)
 
# ts store timestamp of current time
ts = ct.timestamp()
print("timestamp:-", ts)
if os.path.isfile(MyLogPath) == False:
    with open(MyLogPath, 'w') as file_handler_logs:
        file_handler_logs.write("first run V " + CurrentVersion + "\n" + str(ct) + "\n" + str(ts))
        file_handler_logs.close
if os.path.isfile(MyLogPath) == True:
    with open(MyLogPath, 'a') as file_handler_logs:
        file_handler_logs.write("Regular run V " + CurrentVersion + "\n" + str(ct) + "\n" + str(ts))
        file_handler_logs.close

print("Just warning")
service = webdriver.firefox.service.Service(GeckoDriverManager().install(), log_path=log_path, log_output=log_output)
driver = webdriver.Firefox(service=service, options=options)
print("Please proceed")

#v6
driver.get("https://docs.vmware.com/en/VMware-vSphere/index.html")
Elem02 = driver.find_element(By.XPATH, "//span[.='Expand All']")
Elem02.click() # это сделает expand all на странице. 
# https://www.geeksforgeeks.org/find_element_by_xpath-driver-method-selenium-python/
# https://pythonexamples.org/python-selenium-find-element-by-xpath/
# https://www.guru99.com/xpath-selenium.html Xpath=//*[contains(@name,'btn')] Xpath=//*[contains(text(),'here')] 
# The problem is that you are using find_element_by_xpath which return only one WebElement (which is not iterable), the find_elements_by_xpath return a list of WebElements.
# Solution: replace find_element_by_xpath with find_elements_by_xpath
# https://stackoverflow.com/questions/35695647/get-link-text-using-selenium-and-java
# get_attribute('href') to get the link string.

# block 8
All_Elem21 = driver.find_elements(By.XPATH, "//a[contains(@href, '/en/VMware-vSphere')]") # так тоже работает
# получили в переменной All_Elem21 вообще все ссылки 
# сформируем класс для выгрузки сравнений в файл.  # https://python-scripts.com/python-class
class MegaLink:
    def __init__(self, text, link, is_used_before):
        self.text = text
        self.link = link
        self.is_used_before = is_used_before

ArrOfMegaLinkv1All = [] # весь список все что есть вообще - используется для первичного сбора и отсева ниже
ArrOfLink_ReleaseNotesFromSite = [] # только релиз ноты
ArrOfLink_AllVmwareLinksFromSite = [] # все ссылки с вмвари, кроме фейсбука и рекламы
for SingleItem in All_Elem21:
    NewSingleLinkOnj = MegaLink("t1", "l1", "u1") # это экземпляр класса
    NewSingleLinkOnj.text = SingleItem.text
    NewSingleLinkOnj.link = SingleItem.get_attribute('href')
    NewSingleLinkOnj.is_used_before = "Recieved from page"
    # print(NewSingleLinkOnj.text, NewSingleLinkOnj.link)
    # print("**---------------------")
    ArrOfMegaLinkv1All.append(NewSingleLinkOnj) # добавили в список единичный элемент
    ReleaseNoteDetect = NewSingleLinkOnj.text.find("Release Notes")
    VmwareComDetect = NewSingleLinkOnj.link.startswith("https://docs.vmware.com")
    # после переделки пробелов строка про ArrOfLink_ReleaNotesFromSite перестала работать
    # и заработала после добавления строки         print("Addon ArrOfLink_ReleaNotesFromSite done")
    if (NewSingleLinkOnj.text != None) and (NewSingleLinkOnj.link != None) and (ReleaseNoteDetect != -1):
        ArrOfLink_ReleaseNotesFromSite.append(NewSingleLinkOnj)
        # print("Addon ArrOfLink_ReleaNotesFromSite done") # без этой строки что-то глючило
    # if (VmwareComDetect == True) and (NewSingleLinkOnj.text != None): 
    # # все равно тут какая-то дичь, не работает для text=none элемента
    if (VmwareComDetect == True) and (NewSingleLinkOnj.link != "https://docs.vmware.com/en/VMware-vSphere/index.html"):
        ArrOfLink_AllVmwareLinksFromSite.append(NewSingleLinkOnj)
    del NewSingleLinkOnj

print("Mark 0014 count ArrOfMegaLinkv1All ", len(ArrOfMegaLinkv1All))
print("Mark 0015 count ArrOfLink_ReleaNotesFromSite ",len(ArrOfLink_ReleaseNotesFromSite)) 
#еще можно (print(dir(DataFromFileTest2[0])))
print("Mark 0016 count ArrOfLink_AllVmwareLinksFromSite ", len(ArrOfLink_AllVmwareLinksFromSite))

# ok, вроде так работает. https://java2blog.com/save-object-to-file-python/ теперь в файл загрузим.
# block 10. Надо подумать про логику и описать ее. 
# У нас есть полученные из интернета свежие ArrOfMegaLinkv2ReleaNotes и ArrOfMegaLinkv3AllVmware
# надо проверить существование файлов. Если файлы существуют, то считать данные из них.
# если файлы НЕ существуют, то вписать туда текущие данные без первого элемента. 
# почему так - Чтобы было чего в отладку отправлять. 

# block 12 data reader from files
# https://stackoverflow.com/questions/4530611/saving-and-loading-objects-and-using-pickle

# чтобы не возиться import inspect
def write_2_file_if_not_exist(F_FileName, F_List, F_PositionFrom, F_comment): #функция для записи в файл
    print("Exec write_2_file_if_not_exist", F_comment)
    if os.path.isfile(F_FileName) == False:
        F_ArrOfMegaLinks = F_List[F_PositionFrom:]
        with open(F_FileName, 'wb') as f_file_handler_tmp:
            pickle.dump(F_ArrOfMegaLinks , f_file_handler_tmp)
            f_file_handler_tmp.close
            print(f'Object successfully saved to "{F_FileName}"')
    return("write_2_file_if_not_exist done")

# print("Mark 0017-1 count")
# для целей отладки использую  два урезанных массива и два полных. Сначала тестовые
ScriptDir = os.path.dirname(os.path.abspath(sys.argv[0]))
# print(ScriptDir)
# exit
# print("Mark 0017-2 files")
# file_nameonly_1 = 'C:/1234/Robo_ReleaseNotes_full.4bot' #оставлено как пример
file_nameonly_1 = ScriptDir + '\\' + 'Robo_ReleaseNotes_full.4bot' 
file_nameonly_2 = ScriptDir + '\\' + 'Robo_AllLinkv3_full.4bot' 
file_nameonly_1_4test = ScriptDir + '\\' + 'Robo_ReleaseNotes_4test.4bot' #test once
file_nameonly_2_4test = ScriptDir + '\\' + 'Robo_AllLinkv3_4test.4bot' #test once

# write_2_file_if_not_exist(file_nameonly_1_4test,ArrOfLink_ReleaNotesFromSite,3,"Comment1") #отладка
# write_2_file_if_not_exist(file_nameonly_2_4test,ArrOfLink_AllVmwareLinksFromSite,5,"Comment2") #отладка
# почему 1 - а для отладки, чтобы по одной ссылке при первом запуске НЕ было в файле.  
write_2_file_if_not_exist(file_nameonly_1,ArrOfLink_ReleaseNotesFromSite,1,"Comment 3") #рабочий файл с -1 для первого отладочного запуска
write_2_file_if_not_exist(file_nameonly_2,ArrOfLink_AllVmwareLinksFromSite,1,"Comment 4") #рабочий файл с -1 для первого отладочного запуска

# раз уж файл создали на прошлом шаге в любом случае, то  считаем в переменную.
def load_from_file(F_LoadDataFromName,F_comment): 
    # то что получили - вывалиться в return
    F_ArrayFormFile_handler = open(F_LoadDataFromName, "rb")
    F_Data = pickle.load(F_ArrayFormFile_handler)
    print("load_from_file exec OK",len(F_Data), F_comment )
    return F_Data

ArrOfLink_ReleaseNotesDFromFile = load_from_file(file_nameonly_1, "file 01")
ArrOfLink_VmwareDFromFile = load_from_file(file_nameonly_2, "file 02")

# сравнение через set не работает, через Not in не работает. # Потому что нет метода equal. Переписано в функцию. 
# функцию бы можно переписать, потому что больше первых 3 элементов ни сравнивать, ни хранить не нужно.
# но пока оставлю. 
def LinkCompare1 (F_BigFromInternet, F_SmallFromFile, F_Comment):
    F_LinkArrReturn = []
    if len(F_BigFromInternet) == len(F_SmallFromFile):
        print("F Nothing new in LinkCompare1", F_Comment)
    elif len(F_BigFromInternet) < len(F_SmallFromFile):
        print("F LinkCompare1 Something wrong in parameters , Internet count low then file", F_Comment)
        print("F LinkCompare1 Big Internet count",len(F_BigFromInternet))
        print("F LinkCompare1 Small file count",len(F_SmallFromFile))
    elif len(F_BigFromInternet) > len(F_SmallFromFile):
        print("F Exec normal LinkCompare1 big ", len(F_BigFromInternet), " small ", len(F_SmallFromFile), F_Comment)
 
        for F_Single_FromInternet in F_BigFromInternet:
            F_IndicatorNotInArr = "NotIn"
            for F_SingleFromFile in F_SmallFromFile:
                if (F_Single_FromInternet.link == F_SingleFromFile.link):
                    F_IndicatorNotInArr = "InIn 2"
                    # Compare TS 
                    break

            if F_IndicatorNotInArr == "NotIn":
                F_LinkArrReturn.append(F_Single_FromInternet)
    return(F_LinkArrReturn)

# Получили из файлов ArrofLink_ReleaseNotesDFromFile, ArrOfLink_VmwareDFromFile
# при самом первом запуске, когда файлы только созданы, в них на 1 запись меньше
# Получили из интернета ArrOfLink_ReleaseNotesFromSite, ArrOfLink_AllVmwareLinksFromSite
print("Mark 0021-1")
ArrOfDelta_ReleaseNotes = LinkCompare1(ArrOfLink_ReleaseNotesFromSite, ArrOfLink_ReleaseNotesDFromFile,"Release notes delta")
print("Delta release len " + str(len(ArrOfDelta_ReleaseNotes)))
print("Mark 0021-2")
ArrOfDelta_AllVmwareLinks = LinkCompare1(ArrOfLink_AllVmwareLinksFromSite,ArrOfLink_VmwareDFromFile, "All links")
print("Delta All links  " + str(len(ArrOfDelta_AllVmwareLinks)))
# Вот тут бы новое и записать. 
# Конечно для отладки МОЖНО было бы при ПЕРВОМ запуске писать в все файлы как все данные -1, функция позволяет
# а если файл уже есть, то ничего не писать, но тут вопрос в том, нужно ли. Я решил что "нет"
# Хотя, для первого запуска можно и нужно сделать -1 и -3. 
# Где-то тут надо сформировать, что если из интернета больше чем, то переписать файлы.
# и переходить к чтению файла с данными для отправки в телеграм
def OverwriteFiles1(F_Array,F_FileName,F_Comment):
    with open(F_FileName, 'wb') as f_file_handler_tmp:
            pickle.dump(F_Array , f_file_handler_tmp)
            f_file_handler_tmp.close
            print(f'Object successfully rewrited -OverwriteFiles1 - to "{F_FileName}", F_Comment')
    return("OverwriteFiles1 done")

if len(ArrOfDelta_ReleaseNotes) > 0:
    OverwriteFiles1(ArrOfLink_ReleaseNotesFromSite,file_nameonly_1,"release overwrite")

if len(ArrOfDelta_AllVmwareLinks) >0:
    OverwriteFiles1(ArrOfLink_AllVmwareLinksFromSite,file_nameonly_2,"All links")
# файлы перезаписаны, считаем файлы из файла с паролями
FileWithTGDataName = ScriptDir + '\\' + 'Robo_TlgDatatxt_test.4bot' 
# FileWithTGDataName = ScriptDir + '\\' + 'Robo_TlgDatatxt_prod.4bot' 
TGGroupExample = "CHAT-12345" #4 знака под индикатор что это, потом ID
TGAPIIDxample = "APIT-a5678:b7890" #4 знака под индикатор что это, потом ID
# пока что бот не умеет работать с несколькими ключами, 
# но отдельно написать генератор файла ключей-час с кофе.
if os.path.isfile(FileWithTGDataName) == False:
    with open(FileWithTGDataName, 'w') as file_handler_tg:
        file_handler_tg.write(TGGroupExample + "\n" + TGAPIIDxample ) #"\r" автоматом идет в винде но это не точно
        file_handler_tg.close

if os.path.isfile(FileWithTGDataName) == True:
    with open(FileWithTGDataName, 'r') as file_handler_tg:
        TGData = []
        TGData = file_handler_tg.readlines()
        if TGData[0] == TGGroupExample or TGData[1] == TGAPIIDxample:
            print("REWRITE ID in format ")
        # # https://stackoverflow.com/questions/24946640/removing-r-n-from-a-python-list-after-importing-with-readlines
        # TGData = file_handler_tg.read().splitlines работает плохо
        file_handler_tg.close  

TGCHAT = (TGData[0].replace("\n",""))[4:]  # ну прекрасно, оно еще и с пробелом если без магии replace
TGAPIID = (TGData[1])[4:]
# https://ramziv.com/article/6 Это как найти ID чата.
def send_to_telegram_tests(f_chat, f_api, f_message):
    apiURL = f'https://api.telegram.org/bot{f_api}/sendMessage'
    try:
        response = requests.post(apiURL, json={'chat_id': f_chat, 'text': f_message})
        print(response.text)
    except Exception as e:
        print(e)

MessageTest1 = "Hello from Python 12345!"
MessageTest2 = "Hello I'm a new bot for Release notes"
# send_to_telegram_tests(TGCHAT, TGAPIID, MessageTest2) #Работает 
# так, к отправке у нас два списка - ArrOfDelta_ReleaseNotes ArrOfDelta_AllVmwareLinks
print("Mark 0022") # тут будет два вызова для двух отправок. Может в функцию?
def send_to_telegram_mainv1(F_chat, F_api, F_list4send, F_message4log):
    apiURL = f'https://api.telegram.org/bot{F_api}/sendMessage'
    if len(F_list4send)>0:
        if len(F_list4send) >=3:
            F_Temp4Send=F_list4send[:3]
        else:
            F_Temp4Send = F_list4send
    else:
        print("F send_to_telegram_mainv1 Zero - nothing to send ", F_message4log)
        return #выход из функции 
        # exit() #это из модуля выход или как - или как, из всего кода
    
    print("F exec send_to_telegram_mainv1", F_message4log)
    print("F Prepare send ", len(F_Temp4Send))
    for F_SingEl in F_Temp4Send:
        F_message = "Something new in " + F_message4log + F_SingEl.text + " Link " + F_SingEl.link
        try:
            F_response = requests.post(apiURL, json={'chat_id': F_chat, 'text': F_message})
            print("F report ", F_response.text)
        except Exception as F_result1:
            print(F_result1)
            
    return("F exec send_to_telegram_mainv1 done ")
    
# так, к отправке у нас два списка - ArrOfDelta_ReleaseNotes ArrOfDelta_AllVmwareLinks
print("Mark 0023-1")
send_to_telegram_mainv1(TGCHAT, TGAPIID, ArrOfDelta_ReleaseNotes, " Release notes ")
print("Mark 0023-2")
send_to_telegram_mainv1(TGCHAT, TGAPIID, ArrOfDelta_AllVmwareLinks, " All links ")
# тут так и просится выход через sys.exit() если слать нечего.

driver.close()  # это на потом
print("Mark 0024")
ct = datetime.datetime.now()
print("current time:-", ct)
