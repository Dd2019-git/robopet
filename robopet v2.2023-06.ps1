<# bot 2023 for WG
давно назревшее обновление до 2.2023-01 (2 большая редакция, 2023 год, выпуск 01)
1. Что будет добавлено
1.1. Парочка новых сайтов
1.2. Подтягивание токена из файла - потому что в коде такое хранить так себе. 
1.3. Сводный репорт в файл логов по результатам отчета
1.4. И общая переборка

Получение токена группы: https://habr.com/ru/post/262247/
https://ramziv.com/article/6 
https://api.telegram.org/bot<ваш_токен>/getUpdates 

Описание.
1. Создаваемые файлы
$SettingsFile = "MySettings22023Cfg.xml"
$LogFile01 = "MyLogs22023.txt"
$LogFile02Global = "MyGlobalLogs22023.txt"
$TokenFileProd = "TokenFileProd.xml"
$TokenFileTest = "TokenFileTest.xml" - конечно можно было бы обойтись и одним глобальным файлом. 


2. Настройки системы
Set-ExecutionPolicy Unrestricted

3. настройки планировщика
Powershell.exe 
-ExecutionPolicy Bypass myscript.ps1
Powershell.exe -ExecutionPolicy Bypass -file "c:\fqdn_path.ps1"

4. Список сайтов 
Ограничение: по 3-4 последние новости с каждого, а не 5-10 как раньше. 
4.1 "https://www.vmgu.ru"
4.2 "https://vmind.ru"
4.3 $DreamUrlxmlrpc = "https://www.dreamwidth.org/interface/xmlrpc" - а тут хитро, тут через RPC идут данные. 

4.4 Exchange build - https://learn.microsoft.com/en-us/exchange/new-features/build-numbers-and-release-dates

5. http://www.yellow-bricks.com - Duncan Epping is a Chief Technologist in the Office of CTO of the Cloud Platform BU at VMware.  AS MUST




5. First run
При первом запуске, при настройке переменной $RunMode как firstrun, система создаст файлы по списку выше.
После этого надо отредактировать TokenFile - оба - добавив туда токены для бота, ид чата, логины и пароли для сайтов. 
Отредактировать вручную. Конечно можно и автоматизировать, сделать ввод с GUI. После этого сменить $RunMode = "test" 


6. Переписать глобальные переменные в функциях. И поправить везде где !!плохо!!

7. И чтобы лишний раз не перезаписывать файл с последним использованным обновлением, посчитать или хеш или ввести показатель "настройки надо перезаписать". 
7.1 Одного хватит, файл то перезаписывается целиком. 

8. Addons
robopet v2.2023-03 - добавлен обработчик http://www.yellow-bricks.com - Duncan Epping
robopet v2.2023-04 - добавлен обработчик https://cormachogan.com
robopet v2.2023-05 - убраны некоторые лишние жесткие привязки в коде ConvertToClassMainSettingInFile
robopet v2.2023-05 - переделан текст логов для читаемости и однообразности.

9. Неплохо бы все это перевести в облако, например Quickstart for PowerShell in Azure Cloud Shell

ConvertToClassMainSettingInFile надо почистить от абсолютных значений. 

https://learn.microsoft.com/en-us/azure/cloud-shell/quickstart-powershell
#>


############################ classes begin #addon 1.6 updated 1.8 - update 2.2023-01 
class MainSettingInFile {
    [string]$DataSourceOrFrom #from site 
    [string]$ItemidCountInRawArray #Not used since 1.6
    [string]$ItemidDataFull  #Not used since 1.6
    
    [string]$NumberOrID 
    [string]$TimeStampReserv 
    [string]$IsLast 
    [string]$TimestampFromPost # Их два, logtime и eventtime. Этот оставлен для совместимости. #Not used since 1.6
    [string]$Subject 
    [string]$DataFromPost #event # eventtime
    [string]$Link #url
    [string]$DreamAnum
    [string]$DreamItemid
    [string]$DreamLogtime
    [string]$DreamEventtime
    [string]$Reserv001 
    [string]$Reserv002 
}

<#оставлено как образец    $F_TestTokenObj = New-Object -TypeName psobject # 
    $F_TestTokenObj | Add-Member -MemberType NoteProperty -Name TokenName -Value "TestTgBotID"    #>

class TokensInFile {
    [string]$ItemidCountInRawArray #Просто счетчик, чтобы различать. Все данные строкой, чтобы не путать. 
    [string]$TokenName  #
    [string]$BotToken  # 4 telegram
    [string]$ChatID   # 4 telegram
    [string]$DomainName   # 4 telegram and Dream
    [string]$Username   # 4 Dream
    [string]$PasswordRAW   # 4 telegram and Dream
    [string]$PasswordCrypted #not used
    [string]$Token01 #not used
    [string]$Token02 #not used
}




############################ Functions
function DoLogs {
    param([string]$F_PathToFileLogsFQDN, $F_Text4Output)
    $F_CM = (Get-Date).ToString() + " || Function DoLogs DL01 " +  $F_Text4Output
    Write-Host $F_CM
    Out-File $F_PathToFileLogsFQDN -Append -NoClobber -InputObject $F_CM   }



function FirtsRunCreateTOkenFilesTEmplate {   #эта функция вызывается только при $RunMode = "firstrun" и создает файл с шаблоном под токены и логины-пароли.
<#оставлено как образец    $F_TestTokenObj = New-Object -TypeName psobject # 
    $F_TestTokenObj | Add-Member -MemberType NoteProperty -Name TokenName -Value "TestTgBotID"    #>
    
    $F_TestTokenObj = @()
    for ($F_MainCounter=0; $F_MainCounter -le 5) {   
        $F_Token = [TokensInFile]::new() #Создаем переменную каждый раз. Не забывая удалить. 
        $F_Token.ItemidCountInRawArray = $F_MainCounter.ToString() #Просто счетчик, чтобы различать. Все данные строкой, чтобы не путать. 
        $F_Token.TokenName  = "Example Name " + $F_MainCounter.ToString()#
        $F_Token.BotToken = "Token:1234" # 4 telegram
        $F_Token.ChatID = "-123chatid"  # 4 telegram
        $F_Token.DomainName = "contoso.me"  # 4 telegram and Dream
        $F_Token.Username = "user1"  # 4 Dream
        $F_Token.PasswordRAW = "pass1"  # 4 telegram and Dream
        $F_Token.PasswordCrypted = "Crypt1"#not used
        $F_Token.Token01 = "tkn1" #not used
        $F_Token.Token02 = "tkn2" #not used
        $F_TestTokenObj += $F_Token
        Remove-Variable F_Token
        $F_MainCounter ++
    }


    # Проверим наличие файла. Если есть - хорошо Если нет (как сейчас) - создадим.
    $F_Fqdn01 = ($ScriptDir + "\" + $TokenFileTest)
    $F_CheckTokenTest = Test-Path ($F_Fqdn01)
    # Write-Host $F_CheckTokenTest

    $F_Msg01 = "function FirtsRunCreateTOkenFilesTEmplate B001A report - token XML file named "
    # token test creation
    if ($F_CheckTokenTest -eq $True)                                    {$F_Msg01 = $F_Msg01 + $TokenFileTest + " already created B001A"; Write-Host $F_Msg01; Out-File $LogFile02GlobalFQDN -Append -NoClobber -InputObject ( $TimeNow.ToString() + " " + $F_Msg01)  } #  
    else {Export-Clixml -path ($F_Fqdn01) -InputObject $F_TestTokenObj ; $F_Msg01 = $F_Msg01 + $TokenFileTest +" creation complete B001B"; Write-Host $F_Msg01; Out-File $LogFile02GlobalFQDN -Append -NoClobber -InputObject ( $TimeNow.ToString() + " " + $F_Msg01)  }
    Remove-Variable F_Msg01

    $F_Fqdn01 = ($ScriptDir + "\" + $TokenFileProd)
    $F_CheckTokenTest = Test-Path ($F_Fqdn01)
    $F_Msg01 = "function FirtsRunCreateTOkenFilesTEmplate B001B report - token XML file named "
    # token file prod creation
    if ($F_CheckTokenTest -eq $True) {$F_Msg01 = $F_Msg01 + $TokenFileProd + " already created B001C "; Write-Host $F_Msg01; Out-File $LogFile02GlobalFQDN -Append -NoClobber -InputObject ( $TimeNow.ToString() + " " + $F_Msg01)  } #  
    else     { Export-Clixml -path ($F_Fqdn01) -InputObject $F_TestTokenObj; $F_Msg01 = $F_Msg01  + $TokenFileProd + " creation complete B001D"; Write-Host $F_Msg01; Out-File $LogFile02GlobalFQDN -Append -NoClobber -InputObject ( $TimeNow.ToString() + " " + $F_Msg01)  }
    Remove-Variable F_Msg01
    
}


function update_in_telegram_test_send_01 {  #отладочная функция для тестовых прогонов. с жестко забитым "что читаем" !!плохо!!
    $F_TimeNow = Get-Date
    foreach ($BotFindTestId in $TokenFileFQDNContent) {
        if (($BotFindTestId.TokenName -eq  "TestTGbotIDUnicID12964")  -and ($BotFindTestId.ItemidCountInRawArray -eq "1")){
            $F_BotToken = $BotFindTestId.BotToken ;             $F_ChatID = $BotFindTestId.ChatID}}

    $F_Text = '&text="Pet call F1 "' + $F_TimeNow.ToString()
    # $F_Test = 'https://api.telegram.org/bot' + $F_BotToken + '/sendMessage?chat_id=' + $F_ChatID + '&text="Pet call F1"'
    $F_Test = 'https://api.telegram.org/bot' + $F_BotToken + '/sendMessage?chat_id=' + $F_ChatID + $F_Text
    $F_CM = $TimeNow.ToString() + ' update_in_telegram_test_send_01 ' + $F_Test ; Write-Host $F_CM 
    Invoke-WebRequest -Uri $F_Test -OutFile $LogFile01FQDN -PassThru # |  Out-File  -FilePath $LogFile01FQDN -Append -NoClobber
}


function update_in_telegram_prod_send_01 {  #отладочная функция для тестовых прогонов. с жестко забитым "что читаем" !!плохо!!
    
    param([string]$F_TokenFileFQDN)
    $F_TokenFileFQDN = $ScriptDir + "\" +$F_TokenFileFQDN
    $F_TokenFileFQDNContent = Import-Clixml -Path $F_TokenFileFQDN
    
    $F_TimeNow = Get-Date 
    foreach ($BotFindTestId in $F_TokenFileFQDNContent) {
        if (($BotFindTestId.TokenName -eq  "Prod token1 241D1DFDDA")  -and ($BotFindTestId.ItemidCountInRawArray -eq "1")){
            $F_BotToken = $BotFindTestId.BotToken ;             $F_ChatID = $BotFindTestId.ChatID}}

    $F_Text = '&text="Baa Baa, UTC time "' + $F_TimeNow.ToUniversalTime().ToString()
    # $F_Test = 'https://api.telegram.org/bot' + $F_BotToken + '/sendMessage?chat_id=' + $F_ChatID + '&text="Pet call F1"'
    $F_Test = 'https://api.telegram.org/bot' + $F_BotToken + '/sendMessage?chat_id=' + $F_ChatID + $F_Text
    
    Invoke-WebRequest -Uri $F_Test -OutFile $LogFile01FQDN -PassThru # |  Out-File  -FilePath $LogFile01FQDN -Append -NoClobber
    # $F_CM = $TimeNow.ToString() + ' update_in_telegram_prod_send_01 ' + $F_Test ; Write-Host $F_CM 
}

# update_in_telegram_prod_send_01 $TokenFileProd # Baa Baa

# функции получения - vmguru
function get_updates_from_vmguru{
    class DatafromVmguRu{
    [string]$DataSourceOrFrom
    [string]$ItemidCountInRawArray
    [string]$ItemidDataFull 
    
    [string]$NumberOrID 
    [string]$TimeStampReserv 
    [string]$IsLast 
    [string]$TimestampFromPost # Их два, logtime и eventtime. Этот оставлен для совместимости. 
    [string]$Subject 
    [string]$DataFromPost #event
    [string]$Link #url
    [string]$Reserv001 
    [string]$Reserv002 
    }


    $F_CM = "Start get_updates_from_vmguru" ;Write-Host $F_CM 
    $F_VmguRuDirectUrl = "https://www.vmgu.ru" 
    
    $F_FullGet_0A = Invoke-WebRequest -Uri $F_VmguRuDirectUrl # -UseBasicParsing
# $F_FullGet = (Invoke-WebRequest -Uri $F_VmguRuDirectUrl).Content #может надо будет другие свойства \ методы дернуть. 
# типа так https://adamtheautomator.com/invoke-webrequest-powershell/
# https://social.technet.microsoft.com/Forums/en-US/26f6a32e-e0e0-48f8-b777-06c331883555/invokewebrequest-encoding?forum=winserverpowershell
# https://docs.microsoft.com/en-us/powershell/scripting/components/vscode/understanding-file-encoding?view=powershell-7
# не, не требуется. И не работает "быстро". 

    $F_FullGet = $F_FullGet_0A.Content
    $F_Split01 = '<div class="rec_news_cont">' # кажется не используется.
    $F_Split02 = '<h1 class="blog">' 
    $F_Split03 = '</span>'
    $F_Split04 = '</a>'

    $F_FullPageTextTMP01 = ($F_FullGet -Split($F_Split02)) # порезали по числу заголовков новостей
    # Write-Output "Control count news from vmguru - " $F_FullPageTextTMP01.count   # вывели контрольный счетчик - должен быть 11. 10 новостей и первый блок до них.

    $F_VmguRuResult = @()  # это мы отдадим из функции. 
    $F_FullPageTextTMP02 = @() # а с этим будем работать  дальше. 

# delete first block and other non-standard - remove first block with not-news. 
    Foreach ($F_TextBlock in $F_FullPageTextTMP01){
    if ( ($F_TextBlock.Substring(0,9)) -eq '<a href="') {
    $F_FullPageTextTMP02 += $F_TextBlock    }
}


# $F_FullPageTextTMP02[0] - begin news block parse 

    Foreach ($F_TextBlock2 in $F_FullPageTextTMP02){
    $F_BlockCurrent = [DatafromVmguRu]::new()
    $F_BlockCurrent.DataSourceOrFrom = "vmgu.ru"
    
    $F_Tmp01 = ($F_TextBlock2 -split '</span>') 
    $F_Tmp02 = $F_Tmp01[0]
    $F_CloseAtag = $F_Tmp02 -Split(">")
    <# $Tmp02
    получили строку вида 
    <a href="/news/vmware-vsphere-platinum-end-of-availability">Ïðèøëî è óøëî, íèêòî è íå çàìåòèë - VMware îáúÿâèëà î ñíÿòèè ñ ïðîèçâîäñòâà vSphere Platinum</a><span class='small_caption
    '>05/03/2020
    и с ней работаем. Точнее, сначала сконвертировали ее из 1252 в 1251 обратно. ну или потом, нам только текст из нее нужен.
    #>
    $enc1251 = [System.Text.Encoding]::GetEncoding("windows-1251")
    $enc1252 = [System.Text.Encoding]::GetEncoding("windows-1252")
        
    

    
    $F_BlockCurrent.TimestampFromPost =  $F_CloseAtag[3]
    $F_BlockCurrent.Subject = $enc1251.GetString($enc1252.GetBytes($F_CloseAtag[1])) 
    $F_BlockCurrent.Subject = $F_BlockCurrent.Subject.Substring(0,$F_BlockCurrent.Subject.Length-3) # отрезали </a в конце
    # Write-Host "test 4links  " $F_CloseAtag[0].substring(9,($F_CloseAtag[0].length-10))  #отрезали <a href в начале ссылки
    $F_BlockCurrent.Link = $F_VmguRuDirectUrl + $F_CloseAtag[0].substring(9,($F_CloseAtag[0].length-10))

    $F_BlockCurrent.NumberOrID = $F_BlockCurrent.Subject # закончили формирование блока. 
    $F_BlockCurrent.Reserv001 = "2023-v01"
    $F_VmguRuResult += $F_BlockCurrent    
    
}
    
    DoLogs $LogFile02GlobalFQDN (" || Function get_updates_from_vmguru, total count in F_GetFinalResult " + $F_VmguRuResult.Count)
return $F_VmguRuResult
}


# функции получения - vmind
function get_updates_from_vmind{
    $F_SiteDirectUrl = "https://vmind.ru"
    $F_FullGet = (Invoke-WebRequest -Uri $F_SiteDirectUrl).Content
    $F_GetFinalResult = @()  # это мы отдадим из функции. 
    $F_FullPageTextTMP02 = @() # а с этим будем работать  дальше. 
    # $F_FullPageTextTMP01 = ($F_FullGet -Split('data-a2a-url="')) # порезали по числу заголовков новостей
    <# Заголовок поменялся похоже 24-10-2021. БЫл data-a2a-url
    стал <h2 class="entry-title"><a href="https://vmind.ru/2021/10/14/vmware-vsphere-7-update-3-obnovleniya-sluzhby-vcls/" #>
    $F_FullPageTextTMP01 = ($F_FullGet -Split('<h2 class="entry-title">')) # порезали по числу заголовков новостей
    
    foreach ($F_TextBlock in $F_FullPageTextTMP01) {
    # if ( ($F_TextBlock.Substring(0,16)) -eq 'https://vmind.ru') {   # old 24-10-2021
    if ( ($F_TextBlock.Substring(9,16)) -eq 'https://vmind.ru') {
        # $F_TextBlockParser01 = $F_TextBlock -Split('"><a class="a2a_button_facebook"') # old before 24-10-2021
        # addon 24-10-2021
        $F_TextBlockParser01 = $F_TextBlock -Split('</a></h2>') # new
        $F_FullPageTextTMP02 += $F_TextBlockParser01[0]
    }}

    <# write-host $F_FullPageTextTMP02[1]
    на входе имеем строку вида
    https://vmind.ru/2020/03/03/kak-ne-utopit-proekt-vdi/" data-a2a-title="Как (не) утопить проект VDI?">
    https://vmind.ru/2020/02/28/the-printer-is-beeping/" data-a2a-title="The printer is beeping">
    Конвертировать ее 1252-1251 не надо (и то хорошо)
    addon 24-10-2021 
    На входе строки вида 
    <a href="https://vmind.ru/2021/10/20/veeam-ready/" rel="bookmark">Veeam Ready
    <a href="https://vmind.ru/2021/10/19/zametki-v-baze-znanij-vmware-po-platforme-vsphere-7-0-update-3/" rel="bookmark">Заметки в базе знаний VMware по платформе vSphere 7.0 Update 3
    <a href="https://vmind.ru/2021/10/15/vmware-vsphere-7-0-update-3-chto-slomali-na-etot-raz/" rel="bookmark">VMware vSphere 7.0 update 3 &#8212; что сломали на 
    addon 2023-02 new view 
    <a href="https://vmind.ru/2023/02/15/otval-fc-hba-emulex-8-16-gb-s-posle-obnovleniya-vmware-esxi-7-0-update-3/" rel="bookmark">Отвал FC HBA        

#>
    Write-Host 'break mark vmind'
    Foreach ($F_TextBlock2 in $F_FullPageTextTMP02){
        $F_BlockCurrent = [MainSettingInFile]::new()
        $F_BlockCurrent.DataSourceOrFrom = "vmind.ru"
        # $F_BlockCurrent.TimestampFromPost = $F_TextBlock2.Substring(17,10) # old v14
        $F_BlockCurrent.TimestampFromPost = $F_TextBlock2.Substring(26,10) # new v14r
        # $F_SplitTmp = $F_TextBlock2 -split('" data-a2a-title="') # old 
        $F_SplitTmp = $F_TextBlock2 -split('rel="bookmark">') #ну и в 2023 так же
        # $F_BlockCurrent.Link = $F_SplitTmp[0]  #.substring(0,($F_SplitTmp[0].length-1)) # отрезали лишнюю кавычку и потом поправили текст разрезания
        $LenghtTmpCut01 = $F_SplitTmp[0].length-2-9 # 8 потому что с 9 символа.ю а не с ноля*
        $F_BlockCurrent.Link = ($F_SplitTmp[0].substring(9,$LenghtTmpCut01))
        $F_BlockCurrent.Subject = $F_SplitTmp[1]
        $F_BlockCurrent.NumberOrID = $F_BlockCurrent.Subject
        $F_GetFinalResult += $F_BlockCurrent
        # Write-Host 'break mark vmind 2'
    }
    DoLogs $LogFile02GlobalFQDN (" || Function get_updates_from_vmind, total count in F_GetFinalResult " + $F_GetFinalResult.Count)
    Write-Host $F_GetFinalResult[0]
    Return $F_GetFinalResult
}
# end of get_updates_from_vmind


function LoadSettings {
    param([string]$F_PathToFileWithSettings)

    # Проверим наличие файла. Если есть - считаем из него данные. Если нет (как сейчас) - создадим. 
    $F_CM = $TimeNow.ToString() + " || Function LoadSettings execution LS001 " +  $F_PathToFileWithSettings
    Write-Host $F_CM
    Out-File $LogFile02GlobalFQDN -Append -NoClobber -InputObject $F_CM   #ой как плохо использовать глобальные переменные. !!плохо!! 

    $F_MainSettingFirstRunArr = @() # массив из двух объектов по умолчанию. Объект ниже. Объект СТРОГО из не менее 2, иначе сложение потом не работает

    for ($F_MainCounter=0; $F_MainCounter -le 1) {    
    <# оставлено для истории и чтобы не забыть
        $MainSettingFirstRun_defObj = New-Object -TypeName psobject # вообще по уму тут нужен ввод класс объекта, чтобы не копипастить изменения каждый раз
        $MainSettingFirstRun_defObj | Add-Member -MemberType NoteProperty -Name DataSrc(From) -Value "MyFirstRun"

        $MainSettingFirstRun_defObj | Add-Member -MemberType NoteProperty -Name Reserv002 -Value ("Reserv02b-" + $MainCounter.ToString())#>
        
        $MainSettingFirstRun_defObj = [MainSettingInFile]::new()
        $MainSettingFirstRun_defObj.DataSourceOrFrom = ("MyFirstRun - " + $F_MainCounter.ToString())# источник данных
        $MainSettingFirstRun_defObj.ItemidCountInRawArray = ("00000Ndef-" + $F_MainCounter.ToString()) #номер в массиве по которому ищем.
        $MainSettingFirstRun_defObj.ItemidDataFull = "itemidDataFull" #вся строка - #нужен только для отладки
        $MainSettingFirstRun_defObj.Link = "Link html" #html link
        $MainSettingFirstRun_defObj.NumberOrID = "NumberOrID" # то что взяли из html линка
        $MainSettingFirstRun_defObj.TimeStampReserv = $TimeNow.ToString()
        $MainSettingFirstRun_defObj.IsLast = "NO"
        $MainSettingFirstRun_defObj.Subject = "ReservSubject"
        $MainSettingFirstRun_defObj.DataFromPost = "ReservData"
        $MainSettingFirstRun_defObj.TimestampFromPost = "Reservfirsttime"
        $MainSettingFirstRun_defObj.Reserv001 = ("Reserv01a-" + $F_MainCounter.ToString())
        $MainSettingFirstRun_defObj.Reserv002 = ("Reserv02b-" + $F_MainCounter.ToString())

        $F_MainSettingFirstRunArr += $MainSettingFirstRun_defObj
        $F_MainCounter ++
    }


    $F_LoadSettingsFromFileIsCreated = Test-Path $F_PathToFileWithSettings # для первого запуска. Если файл есть - хорошо, если нет - создали. 
        if ($F_LoadSettingsFromFileIsCreated -eq $True)    {$F_CM =  (Get-Date).ToString() + " || Function LoadSettings B01 report - main XML path returned " + $F_LoadSettingsFromFileIsCreated  + " for file " + $F_PathToFileWithSettings + " means file already created"; Write-Host $F_CM } #  
        else     { $F_MainSettingFirstRunArr | Export-Clixml -path $F_PathToFileWithSettings }


    $F_LoadSettingsFromFileIsCreated = Test-Path $F_PathToFileWithSettings # еще раз проверили. Может его только создали и он уже есть (а не было)  
        if ($F_LoadSettingsFromFileIsCreated -eq $True){
        $F_MainSettingFromFile = Import-Clixml -Path $F_PathToFileWithSettings } #считали из xml 
        else {$F_CM = "какая-то беда - потеряли главный файл F_LoadSettingsFromFileIsCreated, надо бы поискать"; Out-File $LogFile02GlobalFQDN -Append -NoClobber -InputObject $F_CM} #конечно это бы в логи надо писать. 


    return $F_MainSettingFromFile 
}





function update_in_telegram_from_src_wo_proxy_univ01 { # переписана из функции выше. попытка сделать универсальную функцию
    param ([string]$F_ChatID, $F_Token, $F_NewsFromDream, $F_Src)


    Write-Host "Start function update_in_telegram_from_src_wo_proxy_univ01 update send from " $F_Src  " to tlg"
# By default powershell uses TLS 1.0 the site security requires TLS 1.2
# https://stackoverflow.com/questions/41618766/powershell-invoke-webrequest-fails-with-ssl-tls-secure-channel
# https://somoit.net/powershell/could-not-create-ssltls-secure-channel
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $F_Text = "Обновление на сайте " + $F_Src +" - " + $F_NewsFromDream.Subject +  " %0A" + "link: " + $F_NewsFromDream.Link
<# %0A - https://medium.com/@trevin/using-curl-to-send-a-message-to-telegram-with-bolding-and-newlines-d0ac77b09608 
In all other places characters '_‘, ’*‘, ’[‘, ’]‘, ’(‘, ’)‘, ’~‘, ’`‘, ’>‘, ’#‘, ’+‘, ’-‘, ’=‘, ’|‘, ’{‘, ’}‘, ’.‘, ’!‘ must be escaped with the preceding character ’\'.
https://core.telegram.org/bots/api#html-style
#>

    $F_Text = $F_Text.Replace("<","&lt;").Replace(">","&gt;").Replace("&","&amp;")
# $F_Text = $F_Text.Replace("#","\#") # экранирование # для телеграмма не работает почему-то. Придется просто прибить. Но делать придется потом ибо теги.
    $F_Text = $F_Text.Replace("#"," ")
    $F_Text = $F_Text.Replace("&"," ")
#$F_Text = $F_Text.Replace("[","\'[").Replace("]","\']").Replace("(","\'(").Replace(")","\')").Replace("+","\'+").Replace("#","\#")

<#$F_EscArr1 = @("_", "'*'", "'~'", "'`'", ">", "-", "=", "|", "{", "}", ".", "!")
foreach ($EscSymbol in $F_EscArr1){
$F_Text = $F_Text.Replace($EscSymbol,("\" + "'" + $EscSymbol))}
#>

    [string]$F_Total = "https://api.telegram.org/bot" + $F_Token +  "/sendMessage?chat_id=" + $F_ChatID + "&text=" + $F_Text + "&parse_mode=HTML" + "&disable_web_page_preview=true"
    Invoke-WebRequest  -Uri $F_Total  #without proxy
    Write-Host "End function update univ01 from " $F_Src
}


function do_clear2023 {
    param ($F_Arr4Clear)
    $F_Cleared02 = @()
    foreach ($F_DataBlock in $F_Arr4Clear){
        if ($F_DataBlock.DataSourceOrFrom -ne $null) {
       $F_Cleared02 += $F_DataBlock}}
       Write-Host "End function do_clear2023"
       return $F_Cleared02
 }


 function DoPostTestMessage01FromDream23{
    param([string]$F_UserID, [string]$F_UserPass)

    $Now = Get-Date
    $ReturnTextPostTestMessage01 = ''

    $ReturnTextPostTestMessage01 = '
    <?xml version="1.0"?>
    <methodCall>
<methodName>LJ.XMLRPC.postevent</methodName>
<params>
<param>

<value><struct>
<member><name>username</name>
<value><string>' + $F_UserID + '</string></value>
</member>'

$ReturnTextPostTestMessage01 = $ReturnTextPostTestMessage01 + 

# auth_method
#'<member><name>auth_method</name>
#<value><string>cookie</string></value>
#</member>' 
"<member>
<name>password</name>
<value><string>" + $F_UserPass + "</string></value>
</member>"



$ReturnTextPostTestMessage01 = $ReturnTextPostTestMessage01 + 
'<member><name>event</name>
<value><string>This is a test post 001 Alpha</string></value>
</member>

<member><name>subject</name>
<value><string>Test subject 002 B</string></value>
</member>
<member><name>lineendings</name>

<value><string>pc</string></value>
</member>
<member><name>year</name>
<value><int>' + ($Now.Year).ToString() + '</int></value>

</member>
<member><name>mon</name>
<value><int>' + ($Now.Month).ToString() + '</int></value>
</member>
<member><name>day</name>

<value><int>'+ $Now.Day.ToString() +'</int></value>
</member>
<member><name>hour</name>
<value><int>' +$Now.Hour.ToString() + '</int></value>

</member>
<member><name>min</name>
<value><int>' + $Now.Minute.ToString() + '</int></value>
</member>
</struct></value>

</param>
</params>
</methodCall>'

# $ReturnTextPostTestMessage01 = $ReturnTextPostTestMessage01.Replace("`r`n","`0") #incorrect - 3F 3E !---00!--- 3C 6D
$ReturnTextPostTestMessage01 = $ReturnTextPostTestMessage01.Replace("`r`n","")
return $ReturnTextPostTestMessage01
}


# https://www.livejournal.com/doc/server/ljp.csp.xml-rpc.getevents.html
function GetMessage01FromDream23{

    param([string]$F_UserID, [string]$F_UserPass)
    $HowManyMessages = 8

    $ReturnTextGetMessage01 = '' + 
'<?xml version="1.0"?>
<methodCall>
<methodName>LJ.XMLRPC.getevents</methodName>
<params>
<param>
<value><struct>
<member>
<name>username</name>
<value><string>' + $F_UserID + '</string></value>
</member>
<member>
<name>password</name>
<value><string>' + $F_UserPass + '</string></value>
</member>
<member>
<name>ver</name>
<value><int>1</int></value>
</member>
<member>
<name>truncate</name>
<value><int>20</int></value>
</member>
<member>
<name>selecttype</name>
<value><string>lastn</string></value>
</member>
<member>
<name>howmany</name>
<value><int>'+$HowManyMessages+'</int></value>
</member>
<member>
<name>noprops</name>
<value><boolean>1</boolean></value>
</member>
<member>
<name>lineendings</name>
<value><string>unix</string></value>
</member>
</struct></value>
</param>
</params>
</methodCall>'

# addon 1.4
$ReturnTextGetMessage01 = $ReturnTextGetMessage01.Replace("`r`n","")

return $ReturnTextGetMessage01

}

function XMLFromDreamIntoArrayv02 {
param($F_Str)
class DreamParseClass01
{
[string]$anum
[string]$itemid
[string]$logtime
[string]$subject
[string]$eventtime
[string]$url
[string]$event
    [string]$Reserv001 
    [string]$Reserv002 

}
$F_TMPSTR01 = $F_Str.Content.Replace('<?xml version="1.0" encoding="UTF-8"?>','')
$F_TMPSTR02 = ($F_TMPSTR01 -Split('<value><struct>')) -Split('</struct></value>') # порезали набор строк из массива на сами обьекты массива.

$F_ArrayCleared = @() #массив, очищенный от заголовков и пустых позиций.
for ($i1 = 2; $i1 -lt ($F_TMPSTR02.Count-2); $i1++){
    if (($F_TMPSTR02[$i1] -ne $null) -and ($F_TMPSTR02[$i1] -ne "") -and ($F_TMPSTR02[$i1] -notlike "Info post num 0*") )
        {$F_ArrayCleared += $F_TMPSTR02[$i1]}
}

$ParsedXmlv002AsArray = @()

foreach ($TMP3 in $F_ArrayCleared) {
    $TMP004 = [DreamParseClass01]::new()

    $STRTMP005 = ($TMP3 -Split('><') | foreach {"<" + $_ + ">" }) #Получили набор строк для будущего элемента массива и порезали по строкам 
    $STRTMP005[0] = $STRTMP005[0].Replace("<<","<") # убрали артефакты резки с первого элемента 
    $STRTMP005[-1] = $STRTMP005[-1].Replace(">>",">") # убрали артефакты резки с последнего элемента 
    # получили массив субблоков $STRTMP005 для каждого блока строк. и разбираем этот элемент. 
    for ($i5 = 0; $i5 -lt ($STRTMP005.Count); $i5++){
            # fix base 64 somewhere here
            if (($STRTMP005[$i5] -eq "<name>subject</name>") -and ($STRTMP005[($i5+2)] -like "<base64>*"))
            {$Basex64CodedString = $STRTMP005[($i5+2)].Replace("</base64>","").Replace("<base64>","")
             $Basex64DeCodedString=[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Basex64CodedString))}
             else {$Basex64DeCodedString = $STRTMP005[($i5+2)]}

            #end of fix base64
        switch ($STRTMP005[$i5]){
        # "<name>logtime</name>" {$TMP004.logtime = $STRTMP005[($i5+2)].Substring(8,19)}
        "<name>logtime</name>" {$TMP004.logtime = ($STRTMP005[($i5+2)].Replace("</string>","").Replace("<string>",""))}
        "<name>subject</name>" {$TMP004.subject = $Basex64DeCodedString.Replace("</string>","").Replace("<string>","") }
        "<name>eventtime</name>" {$TMP004.eventtime = $STRTMP005[($i5+2)].Replace("</string>","").Replace("<string>","")}
        "<name>anum</name>" {$TMP004.anum = $STRTMP005[($i5+2)].Replace("</string>","").Replace("<string>","").Replace("</int>","").Replace("<int>","")}
        "<name>itemid</name>" {$TMP004.itemid = $STRTMP005[($i5+2)].Replace("</string>","").Replace("<string>","").Replace("</int>","").Replace("<int>","")}
        "<name>event</name>" {$TMP004.event = $STRTMP005[($i5+2)].Replace("</string>","").Replace("<string>","")}
        "<name>url</name>" {$TMP004.url = $STRTMP005[($i5+2)].Replace("</string>","").Replace("<string>","")}
        }
        
    }
    # $TMP004
    $ParsedXmlv002AsArray += $TMP004
    }

    # $ParsedXmlv002AsArray | Sort-Object -Property url -Descending
Return $ParsedXmlv002AsArray
}


function ConvertToClassMainSettingInFile {
    param ($F_Input4Convert, [string]$F_Replacer01) # массив из xml элементов.  
      
    $F_ArrayOfLinksConverted = @()
    DoLogs $LogFile02GlobalFQDN " || Execution ConvertToClassMainSettingInFile"
    
    # Write-Host "Remove me 001"
    ## Сделано !!!Плохо!!!, но параметр замены берется из файла с паролями - TokenFileTest22023 - Dreamtest123098.Token01
    # точнее из переменной $TokenFileFQDNContent
    # Write-Host $F_Replacer01
    # Write-Host "Remove me 001"

    foreach ($Str in $F_Input4Convert){


        $NumberOrID = ($Str.url.Replace($F_Replacer01,"")).replace(".html","")
        # Write-Host "Comment me 12345" + $NumberOrID
        $StrObject = [MainSettingInFile]::new()
        $StrObject.DataSourceOrFrom = "DreamRobo"
        $StrObject.ItemidCountInRawArray = "Not used since 1.6" #$DreamAnswer004.IndexOf($Str) #номер в массиве по которому ищем. Стал не нужен.
        $StrObject.ItemidDataFull = "Not used since 1.6" # $Str  #нужен только для отладки

        $StrObject.NumberOrID = $NumberOrID.ToString()
        $StrObject.TimeStampReserv = $TimeNow.ToString()
        $StrObject.IsLast = "NO"
        $StrObject.TimestampFromPost = "Not used since 1.6"
        
        $StrObject.Subject = $Str.subject
        $StrObject.DataFromPost = $Str.event
        $StrObject.Link = $Str.url
        $StrObject.DreamAnum = $Str.anum
        $StrObject.DreamItemid = $Str.itemid
        $StrObject.DreamLogtime = $Str.logtime
        $StrObject.DreamEventtime = $Str.eventtime
    
        $StrObject.Reserv001 = "Reserv01"
        $StrObject.Reserv002 = "Reserv02"
        #endif}

        $F_ArrayOfLinksConverted += $StrObject
        }
Return $F_ArrayOfLinksConverted
        
}


function get_updates_from_yellow-bricks{
param([string]$F_GlobalEBURL)

    # $F_GlobalEBURL
    # Write-Host (Get-Date).ToString()
    $F_CM = "Start get_updates_from_http://www.yellow-bricks.com" ;Write-Host $F_CM 
    
    
    $F_EBResult = @()  # это мы отдадим из функции. 

    $F_FullGet_0A = Invoke-WebRequest -Uri $F_GlobalEBURL
    # write-host "Recieved " + $F_FullGet_0A.Content.Length
    # $F_FullGet_0A.ParsedHtml | gm

    # data in thr strings like 
    # </div></article><article class="post-21126 post type-post status-publish format-standard has-post-thumbnail category-bcdr tag-advanced-setting tag-fdm tag-vsphere-ha entry" aria-label="Disable the re-registering of HA disabled VMs on other hosts!" itemscope itemtype="https://schema.org/CreativeWork"><header class="entry-header"><h2 class="entry-title" itemprop="headline"><a class="entry-title-link" rel="bookmark" href="https://www.yellow-bricks.com/2023/01/24/disable-the-re-registering-of-ha-disabled-vms-on-other-hosts/">Disable the re-registering of HA disabled VMs on other hosts!</a></h2>

    # отсюда можно брать lastModified                    : 02/18/2023 12:09:04
    # Get-Date
    # write-host "Waiting 40 seconds for useless parse "
    # man https://www.pluralsight.com/blog/tutorials/measure-powershell-scripts-speed 
    # Measure-Command -Expression {$F_PageDataStamp = $F_FullGet_0A.ParsedHtml.lastModified}   # какая то оооочень , ооочень долга функция. невозможно, секунд 10-20.
    # $F_PageDataStamp = $F_FullGet_0A.ParsedHtml.lastModified
    # 42 sec by Measure-Command 
    # man https://habr.com/ru/post/680936/
    # man https://habr.com/ru/post/682298/
    # откровенно оба требуют установки библилтек и избыточны. 
    $F_FullGet = $F_FullGet_0A.Content
    $F_Split01 = "article class="
    # Вообще выходит кроме этой строки ничего не надо, НО это одна большая строка, которую все равно придется перебирать. А не единый массив.
    # поэтому split, не вижу других вариантов так сразу. 
    $F_FullPageTextTMP01 = ($F_FullGet -Split($F_Split01)) # порезали по числу заголовков новостей
    # Write-host "Control count news from vmguru CC001 after split = " + $F_FullPageTextTMP01.count.ToString()   # вывели контрольный счетчик - должен быть 6. Ну пусть так. 
    
    # на этом этапе надо выкинуть пустой нолевой блок. Ну или обрабатывать с первого. Раньше выкидывал. Но это лишний проход по циклу, да и ладно, короткий.
    # хотя там пересприсвоение списку \ массиву, это долго.

    #aria-label=
    # <h2 class="entry-title" itemprop="headline"><a class="entry-title-link" rel="bookmark" href="https://www.yellow-bricks.com/2023/02/09/why-is-vcenter-server-trying-to-access-assets-contentstack-io-or-send-dns-requests-for-it/">Why is vCenter Server trying to access assets.contentstack.io or send DNS requests for it?</a></h2>

    # Сначала обработаю единичный экземпляр $F_FullPageTextTMP01[1]
    
    $F_Split02 = 'a class="entry-title-link'
    $F_Split03 = '</a></h2>'
    $F_Split04 =  '/">'

    for ($F_EBCount=1; $F_EBCount -lt $F_FullPageTextTMP01.count; $F_EBCount ++) { 
        $F_SplitMark = 0
        # Write-host 'F_EBCount = ' $F_EBCount
        $F_SingleEB = [MainSettingInFile]::new() 
        $F_EBSingleLongStr01 = @($F_FullPageTextTMP01[$F_EBCount] -split $F_Split02)
        # Write-host "Control count split mark1 - " + $F_SplitMark.ToString(); $F_SplitMark++

        $F_EBSingleLongStr02 = @(($F_EBSingleLongStr01[1] -split $F_Split03)[0])
        # Write-host "Control count split mark2 - " + $F_SplitMark.ToString(); $F_SplitMark++
        $F_len1 = ('" rel="bookmark" href="').Length
        $F_len2 = $F_EBSingleLongStr02[0].Length - $F_len1
        $F_EBSingleLongStr03 = $F_EBSingleLongStr02.Substring($F_len1,$F_len2)
        # $F_EBSingleLongStr03  
# result as https://www.yellow-bricks.com/2023/02/09/why-is-vcenter-server-trying-to-access-assets-contentstack-io-or-send-dns-requests-for-it/">
# Why is vCenter Server trying to access assets.contentstack.io or send DNS requests for it?
        # Write-host "Control count split mark3 - " + $F_SplitMark.ToString(); $F_SplitMark++
        $F_EBSingleLongStr04 = @($F_EBSingleLongStr03  -split$F_Split04)
        # $F_EBSingleLongStr04 #вроде ок.
        # Write-host "Control count split mark4 - " + $F_SplitMark.ToString(); $F_SplitMark++
        
        $F_SingleEB.DataSourceOrFrom = "https://www.yellow-bricks.com"
        # Write-host "Control count split mark5 - " + $F_SplitMark.ToString(); $F_SplitMark++
        
        # $F_SingleEB.TimestampFromPost = $F_PageDataStamp
        # Write-host "Control count split mark6 - " + $F_SplitMark.ToString(); $F_SplitMark++
        $F_SingleEB.DataFromPost = $F_EBSingleLongStr04[0].Substring(30,10)
        $F_SingleEB.Link = $F_EBSingleLongStr04[0]
        $F_SingleEB.NumberOrID = $F_EBSingleLongStr04[1] # entry-title-link as ID
        $F_SingleEB.Subject = $F_EBSingleLongStr04[1] # entry-title-link  as ID
        # Write-host "Control count split mark 004"
        # Write-host $F_SingleEB
        $F_EBResult += $F_SingleEB
        # Write-Host "Control count split 004 mark over"
        # Write-Host "test1234 "$F_EBResult
        Remove-Variable F_SingleEB
        
    }
    # Write-Host "test5678 "$F_EBResult
        return $F_EBResult
    }

function get_updates_from_cormachogan{
param([string]$F_GlobalCormachoganURL)
# $F_GlobalEBURL
    $F_Reserv001TimeStamp = (Get-Date).ToString()
    # Write-Host (Get-Date).ToString()
    $F_CM = "Start get_updates_from_cormachogan" ;Write-Host $F_CM 
    $F_CormachoganResult = @()  # это мы отдадим из функции. 
    # Invoke-WebRequest -Uri $GlobalCormachoganURL
    # Write-Host "1234 " + $F_GlobalCormachoganURL
    $F_FullGet01 = Invoke-WebRequest -Uri $F_GlobalCormachoganURL
    # $F_FullGet01

    # write-host "Recieved 01 " + $F_FullGet01.Content.Length
    $F_FullGet02 = $F_FullGet01.Content
    
     # write-host "Recieved 02 " + $F_FullGet02.Length
     # тут так не работает, но бывает
    <# обрабатываем строку вида 
    <script type="application/ld+json" class="yoast-schema-graph">
    {"@context":"https://schema.org","@graph":[{"@type":"Article","@id":"https://cormachogan.com/2023/02/16/self-service-database-backup-restore-in-vmware-data-services-manager-video/#article"
    ,"isPartOf":{"@id":"https://cormachogan.com/2023/02/16/self-service-database-backup-restore-in-vmware-data-services-manager-video/"},
    "author":{"name":"Cormac","@id":"https://cormachogan.com/#/schema/person/b702ebe7b37b24af7c1e8c91c6ce88eb"},"
    headline":"Self-Service Database Backup &#038; Restore in VMware Data Services Manager (Video)","
    datePublished":"2023-02-16T16:30:37+00:00","dateModified":"2023-02-16T16:27:46+00:00","
    mainEntityOfPage":{"@id":"https://cormachogan.com/2023/02/16/self-service-database-backup-restore-in-vmware-data-services-manager-video/"},
    "wordCount":135,"commentCount":0,"publisher":{"@id":"https://cormachogan.com/#/schema/person/b702ebe7b37b24af7c1e8c91c6ce88eb"},
    "image":{"@id":"https://cormachogan.com/2023/02/16/self-service-database-backup-restore-in-vmware-data-services-manager-video/#primaryimage"},
    "thumbnailUrl":"https://cormachogan.com/wp-content/uploads/2023/01/dsm-vintage.jpg","keywords":["backup","Data Services Manager","databases","restore"],
    "articleSection":["Data Services Manager","VMware"],"inLanguage":"en","potentialAction":[{"@type":"CommentAction","name":"Comment","target":["https://cormachogan.com/2023/02/16/self-service-database-backup-restore-in-vmware-data-services-manager-video/#respond"]}]},
    
    {"@type":"WebPage","@id":"https://cormachogan.com/2023/02/16/self-service-database-backup-restore-in-vmware-data-services-manager-video/",
    "url":"https://cormachogan.com/2023/02/16/self-service-database-backup-restore-in-vmware-data-services-manager-video/",
    "name":"Self-Service Database Backup & Restore in VMware Data Services Manager (Video) - CormacHogan.com"
    
    ,"isPartOf":{"@id":"https://cormachogan.com/#website"},"primaryImageOfPage":{
    "@id":"https://cormachogan.com/2023/02/16/self-service-database-backup-restore-in-vmware-data-services-manager-video/#primaryimage"},
    "image":{"@id":"https://cormachogan.com/2023/02/16/self-service-database-backup-restore-in-vmware-data-services-manager-video/#primaryimage"},
    "thumbnailUrl":"https://cormachogan.com/wp-content/uploads/2023/01/dsm-vintage.jpg","
    
    datePublished":"2023-02-16T16:30:37+00:00","dateModified":"2023-02-16T16:27:46+00:00"
    ,"description":"see how this end user can consume the database, whilst also carrying out important tasks such as on-the-fly backups","breadcrumb":
    {"@id":"https://cormachogan.com/2023/02/16/self-service-database-backup-restore-in-vmware-data-services-manager-video/#breadcrumb"},"inLanguage":"en","potentialAction":[{"@type":"ReadAction","target":["https://cormachogan.com/2023/02/16/self-service-database-backup-restore-in-vmware-data-services-manager-video/"]}]},{"@type":"ImageObject","inLanguage":"en",
    "@id":"https://cormachogan.com/2023/02/16/self-service-database-backup-restore-in-vmware-data-services-manager-video/#primaryimage","url":"https://i0.wp.com/cormachogan.com/wp-content/uploads/2023/01/dsm-vintage.jpg?fit=787%2C792&ssl=1","contentUrl":"https://i0.wp.com/cormachogan.com/wp-content/uploads/2023/01/dsm-vintage.jpg?fit=787%2C792&ssl=1",
    "width":787,"height":792},{"@type":"BreadcrumbList","@id":"https://cormachogan.com/2023/02/16/self-service-database-backup-restore-in-vmware-data-services-manager-video/#breadcrumb","itemListElement":[{"@type":"ListItem","position":1,"name":"Home","item":"https://cormachogan.com/"},
    
    {"@type":"ListItem","position":2,"name":"Self-Service Database Backup &#038; Restore in VMware Data Services Manager (Video)"}]},{"@type":"WebSite","@id":"https://cormachogan.com/#website","url":"https://cormachogan.com/","name":"CormacHogan.com","description":"Storage, Virtualization, Container Orchestration","publisher":{"@id":"https://cormachogan.com/#/schema/person/b702ebe7b37b24af7c1e8c91c6ce88eb"},"potentialAction":[
    {"@type":"SearchAction","target":{"@type":"EntryPoint","urlTemplate":"https://cormachogan.com/?s={search_term_string}"},"query-input":"required name=search_term_string"}],
    "inLanguage":"en"},{"@type":["Person","Organization"],"@id":"https://cormachogan.com/#/schema/person/b702ebe7b37b24af7c1e8c91c6ce88eb","name":"Cormac","image":{"@type":"ImageObject","inLanguage":"en","@id":"https://cormachogan.com/#/schema/person/image/","url":"https://i0.wp.com/cormachogan.com/wp-content/uploads/2014/12/cormac-china.png?fit=643%2C477&ssl=1","contentUrl":
    "https://i0.wp.com/cormachogan.com/wp-content/uploads/2014/12/cormac-china.png?fit=643%2C477&ssl=1",
    "width":643,"height":477,"caption":"Cormac"},"logo":{"@id":"https://cormachogan.com/#/schema/person/image/"},
    "sameAs":["http://cormachogan.com","https://twitter.com/CormacJHogan"],"url":"https://cormachogan.com/author/cormacblog2012/"}]}</script>


    #>


    $F_Split01 = '<h1 class="entry-title"><a href="'
    $F_FullPageTextTMP01 = ($F_FullGet02  -Split($F_Split01)) # порезали по числу заголовков новостей
    # Write-host "Control count news from vmguru CC001 after split = " + $F_FullPageTextTMP01.count.ToString() 
    # $F_FullPageTextTMP01[1]
    $F_Split02 = '</a></h1>'
    $F_Split03 =  '" rel="bookmark">'
    for ($F_CHCCount=1; $F_CHCCount -lt $F_FullPageTextTMP01.count; $F_CHCCount ++) { 
        $F_SplitMark = 0
        $F_CHCSingleLongStr01 = @($F_FullPageTextTMP01[$F_CHCCount] -split $F_Split02)
        # Write-host "Control count split mark1 - " + $F_SplitMark.ToString(); $F_SplitMark++
        # Write-host $F_CHCSingleLongStr01[0]
        # Write-host "tmp break 11" $F_CHCSingleLongStr01[0]


        # получили строку "https://cormachogan.com/2023/02/16/self-service-database-backup-restore-in-vmware-data-services-manager-video/" rel="bookmark">Self-Service Database Backup &#038; Restor
        # e in VMware Data Services Manager (Video)
        
        $F_len1 = ('https://cormachogan.com/').Length
        # $F_len2 = $F_EBSingleLongStr02[0].Length - $F_len1
        
        # $F_CHCTimeFromLinks = $F_CHCSingleLongStr01[0].Substring($F_len1,10)
        $F_CHCSingleLongStr02 = @($F_CHCSingleLongStr01[0] -split $F_Split03)

        # Write-host "tmp break 12" 
        $F_SingleCHC = [MainSettingInFile]::new() 
        $F_SingleCHC.DataFromPost = $F_CHCSingleLongStr01[0].Substring($F_len1,10)
        $F_SingleCHC.Link = $F_CHCSingleLongStr02[0]
        $F_SingleCHC.NumberOrID = $F_CHCSingleLongStr02[1]
        $F_SingleCHC.Subject = $F_CHCSingleLongStr02[1]
        $F_SingleCHC.Reserv001 = $F_Reserv001TimeStamp #так в файле смотреть удобнее, в остальном не нужен


        $F_SingleCHC.DataSourceOrFrom = $F_GlobalCormachoganURL

        $F_CormachoganResult += $F_SingleCHC
        Remove-Variable F_SingleCHC
        # Write-host "tmp break 12" 

        }
    return $F_CormachoganResult

}


########################### End of functions


############################local var
#v22023 new #run mode for first start -
# $RunMode = "firstrun"  # other = prod, test, 
# $RunMode = "test1"  # other = prod, test, 
$RunMode = "test"  # other = prod, test, 
$CurrentScriptVersion = "2.006"

$TimeNow = Get-Date # кстати дальше бы это надо обновлять время от времени
# $TimeNow.ToUniversalTime()
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path  # $ScriptDir откуда запустился скрипт
$CurrentScriptName = $MyInvocation.MyCommand.Name # $CurrentScriptName  текущее имя файла
$SettingsFile01 = "MySettings22023Cfg.xml"  # здесь хранится что куда отправляли. 
$LogFile01 = "MyCurrentLogs22023.txt"       # лог ТЕКУЩЕЙ \ последней сессии 
$LogFile02Global = "MyGlobalLogs22023.txt"  #Может какие то логи и задублируются, и за размером надо будет следить. Полный глобальный лог.
$TokenFileProd = "TokenFileProd22023.xml"
$TokenFileTest = "TokenFileTest22023.xml"


$SettingsFileFQDN = $ScriptDir + "\" + $SettingsFile01 #на самом деле это не совсем настройки, это файл с отчетом какие новости были уже отосланы
$LogFile01FQDN = $ScriptDir + "\" + $LogFile01 # а это вообще не используется, пока что. Но будет нужно для логов текущей сессии. Сейчас все пишется в глобальный
$LogFile02GlobalFQDN =  $ScriptDir + "\" + $LogFile02Global


#end of local war

########################### main code 

DoLogs $LogFile02GlobalFQDN (" || ***********" )   
DoLogs $LogFile02GlobalFQDN (" || ***********  ***********   global start ***********   ***********  " + $CurrentScriptVersion ) 
DoLogs $LogFile02GlobalFQDN (" || Start label A001" + " || Current RunMode " + $RunMode) #CM == current Message отчитались про начало

# $CM = $TimeNow.ToString() + " || Start label A001" + " || Current RunMode " + $RunMode #CM == current Message отчитались про начало
# Write-Host $CM ; Out-File $LogFile02GlobalFQDN -Append -NoClobber -InputObject $CM




# выбрали имя токена и что делать при первом запуске
If ($RunMode -eq "test") {$TokenFile01 = $TokenFileTest ; $CM = ( $TimeNow.ToString() + " || Load file " + $TokenFileTest + " for current RunMode " + $RunMode); Write-Host $CM ; Out-File $LogFile02GlobalFQDN -Append -NoClobber -InputObject $CM }
elseif ($RunMode -eq "prod") {$TokenFile01 = $TokenFileProd ; $CM = ( $TimeNow.ToString() + " current RunMode " + $RunMode); Write-Host $CM ; Out-File $LogFile02GlobalFQDN -Append -NoClobber -InputObject $CM }
elseif ($RunMode -eq "firstrun") {FirtsRunCreateTOkenFilesTEmplate ; $CM = ( $TimeNow.ToString() + " current RunMode " + $RunMode); Write-Host $CM ; Out-File $LogFile02GlobalFQDN -Append -NoClobber -InputObject $CM ;Exit }
else {$CM = ( $TimeNow.ToString() + " current RunMode incorrect " + $RunMode); Write-Host $CM ; Out-File $LogFile02GlobalFQDN -Append -NoClobber -InputObject $CM ;Exit }

# считали токены по имени 
$TokenFileFQDN = $ScriptDir + "\" + $TokenFile01  #описываем откуда и как берем токены - пароли
$CM = $TimeNow.ToString() + " || Start label 02 " +  "Load xml for token file " + $TokenFileFQDN #CM == current Message
Write-Host $CM ;Out-File $LogFile02GlobalFQDN -Append -NoClobber -InputObject $CM # отчитались в логи

# Проверим наличие файла. Если есть - хорошо Если нет - вылет
$TokenFileFQDN_Exist = Test-Path $TokenFileFQDN
# Write-Host $TokenFileFQDN_Exist
if ($F_CheckTokenTest -eq $False) {$CM = $TimeNow.ToString() + " Load xml for token file broken " + $TokenFileFQDN; Write-Host $CM;Out-File $LogFile02GlobalFQDN -Append -NoClobber -InputObject $CM } 
else {$CM = $TimeNow.ToString() + " || Token file exist " + $TokenFileFQDN; Write-Host $CM;Out-File $LogFile02GlobalFQDN -Append -NoClobber -InputObject $CM }

$TokenFileFQDNContent = Import-Clixml -Path $TokenFileFQDN 
# If ($RunMode -eq "test") {$CM = "Test Run start TR001"; $CM ; update_in_telegram_test_send_01 ; } # проверили что отправка в телегу вообще работает
# очень, очень плохо подтягивать в функции update_in_telegram_test_send_01 - глобальные параметры. А они туда подтянуты
# и еще в xml parser - ConvertToClassMainSettingInFile !!!ПЛОХО!!!

DoLogs $LogFile02GlobalFQDN " || Telegram send test disabled" #можно и отдельной переменной сделать

$CM = $TimeNow.ToString() + " || Start label 03 " +  "Load xml for SettingsFileFQDN file " + $SettingsFileFQDN #CM == current Message
Write-Host $CM ;Out-File $LogFile02GlobalFQDN -Append -NoClobber -InputObject $CM

$MainSettingFromFile23 = @()
$MainSettingFromFile23 = LoadSettings $SettingsFileFQDN

# Общую подготовку закончили, токены считаны, ключевой файл с тем что отправляли в прошлый раз считан, идем дальше. 

$GetDataFromVmguruRaw01 = @() #Сюда получаем совсем сырые данные из функции
$GetDataFromVmguruRaw02 = @() #Сюда получаем из $GetDataFromVmindRaw01 те, что с данными. Такая странноватая очистка
$GetDataFromVmguruReady4Sent = @() # перебираем сырой массив данных обновления GetDataFromVmguruRaw02 и в этот массив отправляем данные которых нет. ПОд отправку.
$GetDataFromVmguruRaw01 = get_updates_from_vmguru  # получили список новостей, ВСЕХ. В хз каком формате, не важно.
# очень, очень плохо подтягивать в функции - глобальные параметры. 
DoLogs $LogFile02GlobalFQDN (" || Block Vmguru C01 - Control count RAW news from vmguru - must be 10 " + $GetDataFromVmguruRaw01.count)   # вывели контрольный счетчик - должен быть 10 новостей.

# на всякий случай чистка, которая не понятно как отработает. Нужна, если у нас что-то с функцией и приехало 11.
# это какое-то легаси, которое я вообще не помню зачем делал и какая ошибка у меня приезжала в обработке. 
# Судя по тексту, приезжало где-то Null, отчего и нужна эта переборка.

foreach ($DataBlock in $GetDataFromVmguruRaw01){
    if ($DataBlock.DataSourceOrFrom -ne $null) {
       $GetDataFromVmguruRaw02 += $DataBlock        }}
DoLogs $LogFile02GlobalFQDN (" || Clear mode CM1-1 complete, total count GetDataFromVmguruRaw02 " + $GetDataFromVmguruRaw02.Count)
# получили чистый GetDataFromVmguruRaw02



$VmGuruLastUpd = "0" #опять перебираем last update in file MainSettingFromFile23 в поисках нашего обновления. 
# $VmGuruLastUpd в итоге станет строкой, полученной прошлый раз и хранимой в файле
foreach ($LastUpdTmp in $MainSettingFromFile23) {
    if ($LastUpdTmp.DataSourceOrFrom -eq "vmgu.ru") {
    $VmguruLastUpd = $LastUpdTmp.NumberOrID  }}  #Номер получили, при первом запуске все равно будет ноль. 
#id выглядит как строка заголовка- например <S N="NumberOrID">Узнайте первыми о новых возможностях Veeam Backup and Replication v12</S>
# Теперт сравниваем очищенный массив всех новостей $GetDataFromVmguruRaw02 и строку S N="NumberOrID , формируя массив к отправке.
for ($i = 0; $i -lt ($GetDataFromVmguruRaw02.Count); $i++){
    if ($GetDataFromVmguruRaw02[$i].NumberOrID -ne $VmGuruLastUpd) {
        $GetDataFromVmguruReady4Sent += $GetDataFromVmguruRaw02[$i]}
        else {$i = $GetDataFromVmguruRaw02.Count} # ну не спортивно, наверное. Но это и не спорт. 
        }
DoLogs $LogFile02GlobalFQDN (" || Clear mode CM1-2 complete, total count GetDataFromVmguruReady4Sent " + $GetDataFromVmguruReady4Sent.Count)

# перебираем сырой массив данных обновления GetDataFromVmguruRaw02
# сравнили данные. Как только попали в совпадение строки - удалили остальные элементы. Типа "если строка не совпала, то копируем в новый массив
# массив считаем отсортированным, ну он так все равно формируется сортированным как результат нарезки.
#id выглядит как строка заголовка- например <S N="NumberOrID">Узнайте первыми о новых возможностях Veeam Backup and Replication v12</S>

Write-host "Preparing for Vmguru Export for breakpoint"

if ($VmGuruLastUpd -ne "0") {  # фактически 0 будет только при первом запуске и отладке. 
    for ($i = 0; $i -lt ($MainSettingFromFile23.Count); $i++){
    if ($MainSettingFromFile23[$i].DataSourceOrFrom -eq "vmgu.ru")   {
        $MainSettingFromFile23[$i] = $GetDataFromVmguruRaw02[0]  # 
        $RoboRewriteID = "Done"    }}}

Else {$MainSettingFromFile23 += $GetDataFromVmguruRaw02[0]}  # то есть добавили к xml с данными что уже отправлено - элемент для поиска из $GetDataFromVmguruReady4Sent[0]

# Уже можно образец и в файл записать. 
# и выгрузили все что надо в файл. для всех сразу. 
# выгружать надо до отправки, а то так и будет по сто раз отправляться. 

# тут бы бекап сразу сделать. 
Write-host "Do backup in time"
$timestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
# $timestamp
$PackDestFQDN  = $ScriptDir + "\" + "old\" + $timestamp + $SettingsFile01 +".zip"
# Compress-Archive -LiteralPath $SettingsFileFQDN -DestinationPath $PackDestFQDN !!после отладки разблокировать. Ну или нет". 

$MainSettingFromFile23 | Export-Clixml -path $SettingsFileFQDN  
# В файл выгрузили новые данные по строкам, можно продолжать. 

# и затем отправили массив $GetDataFromVmguruReady4Sent в тележку.
Write-host "Get chat - bot ID"
foreach ($BotFindTestIdVMGURU in $TokenFileFQDNContent) {
        if (($BotFindTestIdVMGURU.TokenName -eq  "TestTGbotIDUnicID12964")  -and ($BotFindTestIdVMGURU.ItemidCountInRawArray -eq "1")){
            $F1_BotToken = $BotFindTestIdVMGURU.BotToken ;             $F1_ChatID = $BotFindTestIdVMGURU.ChatID}}

# $F1_BotToken
# $F1_ChatID
$GetDataFromVmguruReady4Sent = ($GetDataFromVmguruReady4Sent | Select-Object -First 4)
# Write-host  "will send " + $GetDataFromVmguruReady4Sent

foreach ($VmguruUpdate23 in $GetDataFromVmguruReady4Sent) { #но это будут все 10, не пойдет. Надо 3. 

    # nowadays (sinve v 2023) its in dofferent cgf files
    update_in_telegram_from_src_wo_proxy_univ01 $F1_ChatID $F1_BotToken $VmguruUpdate23 "Vmgu.ru"
    # $VmguruUpdate - это весь обьект новости, поштучно. # "Vmgu.ru" используется в новости в виде "Обновление на сайте " + $F_Src
    start-sleep -Seconds 5
    Write-host "Send test"
}

DoLogs $LogFile02GlobalFQDN (" || VMguru done - vmind prepare")


# Ок этот блок работает, идем к vmind

$GetDataFromVmindRaw01 = @() 
$GetDataFromVmindRaw02 = @()
$GetDataFromVmindReady4Sent = @()
$GetDataFromVmindRaw01 = get_updates_from_vmind  # получили список новостей, ВСЕХ. В не понятно каком формате, не важно.
# $GetDataFromVmindRaw01.Count
# $GetDataFromVmindRaw01[0] # вот тут надо следить, потому что теряется и Subject и NumberOrID
$GetDataFromVmindRaw02 = do_clear2023 $GetDataFromVmindRaw01 #чистка # не понятно почему вынесено в функции !!!Плохо!!!
# $GetDataFromVmindRaw02.Count $GetDataFromVmindRaw02[2]


Write-Host "Mark for start vmind search"
$VmindLastUpd = "0" #опять перебираем last update in file MainSettingFromFile в поисках нашего обновления. теперь для vmind
foreach ($LastUpdTmp in $MainSettingFromFile23) {
    if ($LastUpdTmp.DataSourceOrFrom -eq "vmind.ru") {
    $VmindLastUpd = $LastUpdTmp.NumberOrID  }}


# перебираем сырой массив данных обновления GetDataFromVmguruRaw02
# сравнили данные. Как только попали в совпадение строки - удалили остальные элементы. Типа "если строка не совпала, то копируем в новый массив
# массив считаем отсортированным, ну он так все равно формируется сортированным как результат нарезки.
for ($i = 0; $i -lt ($GetDataFromVmindRaw02.Count); $i++){
    if ($GetDataFromVmindRaw02[$i].NumberOrID -ne $VmindLastUpd) {
        $GetDataFromVmindReady4Sent += $GetDataFromVmindRaw02[$i]}
     else {$i = $GetDataFromVmindRaw02.Count} # ну не спортивно, наверное. Но это и не спорт. 
        }  #теоретически это тоже можно в функцию унести. 5 строк..
                # сохранили последний элемент (то есть первый) в файл 

# при этом надо учитывать, что $GetDataFromVmindReady4Sent может быть пустым, поэтому конечно лучше не менять ничего и сэкономить операцию записи.
# но нам одна операция записи не критична, все равно весь файл каждый раз перезаписывается (хотя нам бы и не помешал бекап  настроек). 
# Поэтому берем данные из всего очищенного массива  $GetDataFromVmindReady4Sent \ GetDataFromVmindRaw02
# а раз нам пофиг, то можно было бы данные каждый раз и перезаписывать, в лоб, НО нам же все равно надо ИЛИ перезаписать или добавить.

if ($VmindLastUpd -ne "0") {
    for ($i = 0; $i -lt ($MainSettingFromFile23.Count); $i++){
    if ($MainSettingFromFile23[$i].DataSourceOrFrom -eq "vmind.ru")   {
        $MainSettingFromFile23[$i] = $GetDataFromVmindRaw02[0]  # 
        $RoboRewriteID = "Done"    }}} # хз зачем эта строчка, в дриме использовал
Else {$MainSettingFromFile23 += $GetDataFromVmindRaw02[0]} # это только при совсем первом запуске или потере конфиг файла 
    
Write-Host "Mark for vmind export"
$MainSettingFromFile23 | Export-Clixml -path $SettingsFileFQDN  
# В файл выгрузили новые данные по строкам, можно продолжать. 
 
# DoLogs $LogFile02GlobalFQDN (" || Preparing for vmind send GetDataFromVmindReady4Sent = " + $GetDataFromVmindReady4Sent.Count)
 
if ($GetDataFromVmindReady4Sent.Count -eq 0) {Write-Host "No Vmind updates, nothing to send"}
    else {Write-Host "Vmind updates - "$GetDataFromVmindReady4Sent.Count }

  # upd vmind update only 4.
DoLogs $LogFile02GlobalFQDN (" || Clear mode CM2-1 complete, total count GetDataFromVmindReady4Sent " + $GetDataFromVmindReady4Sent.Count ) # $GetDataFromVmindRaw02[0]

$GetDataFromVmindReady4Sent = ($GetDataFromVmindReady4Sent | Select-Object -First 4)
 # и затем отправили массив $GetDataFromVmindReady4Sent в тележку.
foreach ($UpdateVmind23 in $GetDataFromVmindReady4Sent) {
    update_in_telegram_from_src_wo_proxy_univ01 $F1_ChatID $F1_BotToken $UpdateVmind23 "Vmind.ru"  #send into telegram - group
    start-sleep -Seconds 5}



# Блок для Dream. Даже не уверен, нужно ли его переносить, поскольку я туда мало что пишу. Вообще не пишу, времени нет. Но пусть будет для совместимости.
# логин пароль лежит там же, в $TokenFileFQDNContent в блоке <S N="TokenName">Dreamtest123098</S>
$DreamUsername23 = "ttt" ; $DreamPass23 = "qqq"
$DreamTokenParser23 = "123"
foreach ($DreamSearch23 in $TokenFileFQDNContent) {
    if ($DreamSearch23.TokenName -eq "Dreamtest123098") {$DreamUsername23 =  $DreamSearch23.Username ; $DreamPass23 = $DreamSearch23.PasswordRAW
    $DreamUrlxmlrpc23 = $DreamSearch23.DomainName ; 
    $DreamTokenParser23 = $DreamSearch23.Token01
    } #$DreamSearch23 
}

# сотворить здесь можно. Оставлено как пример, для работы унести в функцию. 
$Body4Post23 = DoPostTestMessage01FromDream23 $DreamUsername23 $DreamPass23  # пример работы post
# Write-Output "Start Block Dream A01 - get data from internet ---"
# $DreamAnswer002 = Invoke-WebRequest -Uri $DreamUrlxmlrpc -Method Post  -Body $Body4Post -ContentType "text/xml" # -UserAgent "XMLRPC Client 1.0"
# $DreamAnswer002.Content

# вот это бы тоже унести в функцию. 
$Body4GetFromDream23 = GetMessage01FromDream23 $DreamUsername23 $DreamPass23
$DreamAnswer003RAWv23 = Invoke-WebRequest -Uri $DreamUrlxmlrpc23 -Method Post  -Body $Body4GetFromDream23 -ContentType "text/xml" # -UserAgent "XMLRPC Client 1.0"
# Вот тут нужна проверка, а чего мы получили и все ли там хорошо. Например все ли хорошо с паролями.
Write-Host "Dream compare"
if ($DreamAnswer003RAWv23.Content.Substring(0,120) -like "*faultString*") {DoLogs $LogFile02GlobalFQDN (" || Something wrong in module Dream Get")}
else {DoLogs $LogFile02GlobalFQDN (" || Dream Get looks good")}

<#
Content           : <?xml version="1.0" encoding="UTF-8"?><methodResponse><params><param><value><struct><member><name>events</name><value><array><data><value><struct><me
                    mber><name>logtime</name><value><string>2020-01-29 ...
а при некорректном логине \ пароле \ ответе - 
Content           : <?xml version="1.0" encoding="UTF-8"?><methodResponse><params><param><value><struct><member><name>events</name><value><array><data><value><struct><me
                    mber><name>logtime</name><value><string>2020-01-29 ...#>

# $DreamAnswer004v23 = XMLIntoArray01 $DreamAnswer003v23 #а это вообще используется дальше ? 
$DreamAnswer004AsArrayv23 = XMLFromDreamIntoArrayv02 $DreamAnswer003RAWv23  # получили набор данных от сайта. Теперь надо его привести к ранее данному виду.

$DreamAnswEditionv23 = ConvertToClassMainSettingInFile $DreamAnswer004AsArrayv23 $DreamTokenParser23 
$DreamAnswEditionv23Sorted = ($DreamAnswEditionv23 | Sort-Object { [int]$_.NumberOrID } -Descending)

DoLogs $LogFile02GlobalFQDN (" || Clear mode CM3-1 complete, DreamAnswEditionv23Sorted count " + $DreamAnswEditionv23Sorted.Count)

$DreamLastUpd = "0" #fromfile
foreach ($LastUpdTmp in $MainSettingFromFile23) {
    if ($LastUpdTmp.DataSourceOrFrom -eq "DreamRobo") {
    $DreamLastUpd = $LastUpdTmp.NumberOrID  }
    }

Write-host "Start block Dream D04, write last events into a file ---"
# запишем последнюю строку в файл. 
$RoboRewriteID = "Not found"
for ($i = 0; $i -lt ($MainSettingFromFile23.Count); $i++){
    if ($MainSettingFromFile23[$i].DataSourceOrFrom -eq "DreamRobo")   {
        $DreamAnswEditionv23Sorted[0].IsLast = "Yes"
        $MainSettingFromFile23[$i] = $DreamAnswEditionv23Sorted[0]
        $RoboRewriteID = "Done"    }}


If ($RoboRewriteID -ne "Done") {
    $MainSettingFromFile23 += $DreamAnswEditionv23Sorted[0]}

Write-Host "Mark for Dream MainSettingFromFile23export in the MainSettingFromFile23 file"
$MainSettingFromFile23 | Export-Clixml -path $SettingsFileFQDN  

Write-host "Dream send preparation up to max" + $DreamAnswEditionv23Sorted.Count

# dream mass upd for main group
$DreamAnswEditionv23Sorted = ($DreamAnswEditionv23Sorted | Select-Object -First 3)

# Почему-то сравнение не работает. Потому что DreamLastUpd = 0, а там потому что MainSettingFromFile23 не поправил
# Вот тут кстати не сделана переборка в массив со счетчиком. 
$DreamAnswEditionv23SortedReady4Send = @()

foreach ($LastUpdStr2 in $DreamAnswEditionv23Sorted){
    if  ($LastUpdStr2.NumberOrID.ToInt64($null) -gt $DreamLastUpd.ToInt64($null))
    {# Write-Output $LastUpd.NumberOrID.ToInt64($null) $DreamLastUpd.ToInt64($null)
    Write-host "Dindin Block C1 works and send " + $LastUpdStr2.Link
    $DreamAnswEditionv23SortedReady4Send += $LastUpdStr2

    start-sleep -Seconds 5
    }
}

$DreamAnswEditionv23SortedReady4Send = ($DreamAnswEditionv23SortedReady4Send | Select-Object -First 4)
foreach ($DreamUpd23 in $DreamAnswEditionv23SortedReady4Send) {
    update_in_telegram_from_src_wo_proxy_univ01 $F1_ChatID $F1_BotToken $DreamUpd23 "Dream" ; start-sleep -Seconds 5
}

DoLogs $LogFile02GlobalFQDN (" || Clear mode CM3-2 complete, total count DreamAnswEditionv23SortedReady4Send " + $DreamAnswEditionv23SortedReady4Send.Count)




## начало блока про http://www.yellow-bricks.com

$GlobalEB = "http://www.yellow-bricks.com"
$Body4GetFromEB23RAW01 = @()
$Body4GetFromEB23RAW02 = @()
$Body4GetFromEB23RAW03Ready4Send = @()
$Body4GetFromEB23RAW01 = get_updates_from_yellow-bricks $GlobalEB

#традиционная чистка на случай, если из функции приехало что-то не то. 

foreach ($DataBlock in $Body4GetFromEB23RAW01){
    if ($DataBlock.DataSourceOrFrom -ne $null) {
       $Body4GetFromEB23RAW02 += $DataBlock        }}
DoLogs $LogFile02GlobalFQDN (" || Clear mode CM4-1 complete, total count Body4GetFromEB23RAW02 " + $Body4GetFromEB23RAW02.Count)

# получили чистый Body4GetFromEB23RAW02
$YellowbricksLastUpd = "0" #опять перебираем last update in file MainSettingFromFile23 в поисках нашего обновления. 
foreach ($LastUpdTmp in $MainSettingFromFile23) {
    if ($LastUpdTmp.DataSourceOrFrom -eq "https://www.yellow-bricks.com") {
        $YellowbricksLastUpd = $LastUpdTmp.NumberOrID  }}  #Номер получили, при первом запуске все равно будет ноль.

#id выглядит как строка заголовка- например Subject               : Why is vCenter Server trying
# Теперь сравниваем очищенный массив всех новостей $Body4GetFromEB23RAW02 и строку S N="NumberOrID , формируя массив к отправке.
for ($i = 0; $i -lt ($Body4GetFromEB23RAW02.Count); $i++){
    if ($Body4GetFromEB23RAW02[$i].NumberOrID -ne $YellowbricksLastUpd) {
        $Body4GetFromEB23RAW03Ready4Send += $Body4GetFromEB23RAW02[$i]}
        else {$i = $Body4GetFromEB23RAW02.Count} # ну не спортивно, наверное. Но это и не спорт. 
        }
DoLogs $LogFile02GlobalFQDN (" || Clear mode CM4-1 complete, total count Body4GetFromEB23RAW03Ready4Send " + $Body4GetFromEB23RAW03Ready4Send.Count)
# перебираем сырой массив данных обновления GetDataFromVmguruRaw02
# сравнили данные. Как только попали в совпадение строки - удалили остальные элементы. Типа "если строка не совпала, то копируем в новый массив
# массив считаем отсортированным, ну он так все равно формируется сортированным как результат нарезки.

if ($YellowbricksLastUpd -ne "0") {  # фактически 0 будет только при первом запуске и отладке. 
    for ($i = 0; $i -lt ($MainSettingFromFile23.Count); $i++){
    if ($MainSettingFromFile23[$i].DataSourceOrFrom -eq "https://www.yellow-bricks.com")   {
        $MainSettingFromFile23[$i] = $Body4GetFromEB23RAW02[0]  # 
        $EBRewriteID = "Done"    }}}

Else {$MainSettingFromFile23 += $Body4GetFromEB23RAW02[0]}  # то есть добавили к xml с данными что уже отправлено - элемент для поиска из $GetDataFromVmguruReady4Sent[0]

# IF ($EBRewriteID -eq "Done") {$MainSettingFromFile23 | Export-Clixml -path $SettingsFileFQDN  }
# тут надо глобально логику поправить, чтобы не каждый раз переписывать текст \ файл конфига. То есть один раз за весь прогон - вполне достаточно.
# Иначе тут уже 4. 
$MainSettingFromFile23 | Export-Clixml -path $SettingsFileFQDN    #отключено на время отладки Body4GetFromEB23RAW03Ready4Send

# и наконец отправка $Body4GetFromEB23RAW03Ready4Send. в тележку. 
$Body4GetFromEB23RAW03Ready4Send = ($Body4GetFromEB23RAW03Ready4Send | Select-Object -First 4)
Write-Host "Ready EB send"
foreach ($EBUpdate23 in $Body4GetFromEB23RAW03Ready4Send) {
    update_in_telegram_from_src_wo_proxy_univ01 $F1_ChatID $F1_BotToken $EBUpdate23 "yellow-bricks.com"
    start-sleep -Seconds 5
}


# robopet addon 23-2 https://cormachogan.com/
$GlobalCormachoganURL = "https://cormachogan.com"

$Body4GetFromCormachogan23RAW01 = @()
$Body4GetFromCormachogan23RAW02 = @()
$Body4GetFromCHC23RAW03Ready4Send = @()
$Body4GetFromCormachogan23RAW01 = get_updates_from_cormachogan $GlobalCormachoganURL
# $Body4GetFromCormachogan23RAW01.count

#традиционная чистка на случай, если из функции приехало что-то не то. 

foreach ($DataBlock in $Body4GetFromCormachogan23RAW01)
    { if ($DataBlock.DataSourceOrFrom -ne $null) {$Body4GetFromCormachogan23RAW02 += $DataBlock        }}
DoLogs $LogFile02GlobalFQDN (" || Clear mode CM5-1 complete, total count Body4GetFromCormachogan23RAW02 " + $Body4GetFromCormachogan23RAW02.Count)
# получили чистый Body4GetFromCormachogan23RAW02
$CHCLastUpd = "0" #опять перебираем last update in file MainSettingFromFile23 в поисках нашего обновления. 
foreach ($LastUpdTmp in $MainSettingFromFile23) {
    if ($LastUpdTmp.DataSourceOrFrom -eq $GlobalCormachoganURL) {
        $CHCLastUpd = $LastUpdTmp.NumberOrID  }}  #Номер получили, при первом запуске все равно будет ноль.
#id выглядит как строка заголовка- например Subject  
# Теперь сравниваем очищенный массив всех новостей $Body4GetFromEB23RAW02 и строку S N="NumberOrID , формируя массив к отправке.
for ($i = 0; $i -lt ($Body4GetFromCormachogan23RAW02.Count); $i++){
    if ($Body4GetFromCormachogan23RAW02[$i].NumberOrID -ne $CHCLastUpd) {
        $Body4GetFromCHC23RAW03Ready4Send += $Body4GetFromCormachogan23RAW02[$i]}
        else {$i = $Body4GetFromCormachogan23RAW02.Count} # ну не спортивно, наверное. Но это и не спорт. 
        }
DoLogs $LogFile02GlobalFQDN (" || Clear mode CM5-2 complete, total count Body4GetFromCHC23RAW03Ready4Send " + $Body4GetFromCHC23RAW03Ready4Send.Count)

if ($CHCLastUpd -ne "0") {  # фактически 0 будет только при первом запуске и отладке. 
    for ($i = 0; $i -lt ($MainSettingFromFile23.Count); $i++){
    if ($MainSettingFromFile23[$i].DataSourceOrFrom -eq $GlobalCormachoganURL)   {
        $MainSettingFromFile23[$i] = $Body4GetFromCormachogan23RAW02[0]  # 
        $CHCRewriteID = "Done"    }}}

Else {$MainSettingFromFile23 += $Body4GetFromCormachogan23RAW02[0]} 

# тут надо глобально логику поправить, чтобы не каждый раз переписывать текст \ файл конфига. То есть один раз за весь прогон - вполне достаточно.
# Иначе тут уже 5. 
$MainSettingFromFile23 | Export-Clixml -path $SettingsFileFQDN    
Write-Host "Ready CHC send " + $GlobalCormachoganURL
$Body4GetFromCHC23RAW03Ready4Send = ($Body4GetFromCHC23RAW03Ready4Send | Select-Object -First 4)
foreach ($CHCUpdate23 in $Body4GetFromCHC23RAW03Ready4Send) {
    update_in_telegram_from_src_wo_proxy_univ01 $F1_ChatID $F1_BotToken $CHCUpdate23 $GlobalCormachoganURL
    start-sleep -Seconds 5
}



# Отчеты о глобальной отправке 
Write-Host "Send report"
Write-Host "Report 1 reserv"
Write-Host "Report 2 - total count GetDataFromVmguruReady4Sent "  $GetDataFromVmguruReady4Sent.Count 
Write-Host "Report 3 - total count GetDataFromVmindReady4Sent "  $GetDataFromVmindReady4Sent.Count  
Write-Host "Report 4 - total count DreamAnswEditionv23SortedReady4Send "  $DreamAnswEditionv23SortedReady4Send.Count
Write-Host "Report 5 - total count Body4GetFromEB23RAW03Ready4Send "  $Body4GetFromEB23RAW03Ready4Send.Count
Write-Host "Report 6 - total count Body4GetFromCHC23RAW03Ready4Send "  $Body4GetFromCHC23RAW03Ready4Send.Count
DoLogs $LogFile02GlobalFQDN (" || ........  ........ global end ........ ........  " + $CurrentScriptVersion ) 