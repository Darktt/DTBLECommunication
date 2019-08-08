# 藍牙周邊 (Peripheral)

因為 iOS 的藍牙周邊的架構較為複雜，因此寫下這篇作為記錄，讓下次也能順利的使用此功能。

## 周邊結構
> * CBPeripheralManager
> * Services (CBMutableService)
>     * Include Services (CBMutableService)
>     * Characteristics (CBMutableCharacteristic)
>         * Properties（CBCharacteristicProperties）
>         * Permissisons（CBAttributePermissions）
>         * Descriptors（CBMutableDescriptor）
> * CBCentral

---------------

### 周邊建立流程
> 1. 在 viewDidLoad 建立 CBPeripheralManager。
> 2. 建立 CBMutableCharacteristic 並依需求設定 CBCharacteristicProperties 為 *notify* 或 *read*、*write*（可以重複設定）與 CBAttributePermissions 為 *readable* 或 *writeable*（可以重複設定）。
> 3. 建立 CBMutableService 並加入 CBMutableCharacteristic。
> 4. 確定 CBPeripheralManager 的 state 為 powerOn，之後加入建立好的 > CBMutableService。
> 5. 使用 CBPeripheralManager startAdvertising(_:) 開始廣播。

### CBPeripheralManager
> 它是負責檢查認證狀態、加入 Service (從 Delegate 得知加入成功)、廣播等功能。<br/>
> 可用的參數：
>> * 藍牙狀態 `state`，唯讀，此資訊由父物件 `CBManager` 提供。
* 廣播中 `isAdvertising`，唯讀，此參數用來判斷是否正在廣播中。

> 可用的方法：
>> * `authorizationStatus()`<br/>
    取得現在的認證狀態，如果需要在背景傳輸資料的時候，就一定要透過它來確認狀態。<br/>
    **（Class Method）**
>> * `init(delegate:queue:)`<br/>
    建立周邊物件，如果 queue 給 nil 的時候，就代表使用的是 main queue。
>> * `init(delegate:queue:options:)`<br/>
    同樣是建立中心物件，不過差別是多了option的參數。
>> * `add(_:)`<br/>
    增加服務（CBMutableService），*這個設定一定要在狀態為 powerOn 之後才能設定*；<br/>
    設定成功的通知會透過 CBPeripheralManager 的 `peripheralManager(_:didAdd:error:)` 得知。
>> * `remove(_:)`<br/>
    移除指定的服務。
>> * `removeAllServices()`<br/>
    移除所有的服務。
>> * `startAdvertising(_:)`<br/>
    開始廣播周邊訊號，*這個功能一定要在狀態為 powerOn 之後才能使用*；<br/>
    開始廣播時會透過 CBPeripheralManager 的 `peripheralManagerDidStartAdvertising(_:error:)` 得知。
>> * `stopAdvertising()`<br/>
    停止廣播周邊訊號。
>> * `updateValue(_:for:onSubscribedCentrals:)`<br/>
    傳送通知訊息給已訂閱的中心（CBCentral）。<br/>
    *訂閱的中心從 CBPeripheralManager 的 `peripheralManager(_:central:didSubscribeTo:)` 取得，<br/>
    以及取消訂閱的中心從 CBPeripheralManager 的 `peripheralManager(_:central:didUnsubscribeFrom:)` 得知哪一個中心取消訂閱。*
>> * `respond(to:withResult:)`<br/>
    當收到讀取請求或寫入請求時的回應給中心的方法。<br/>
    *從 CBPeripheralManager 的 `peripheralManager(_:didReceiveRead:)` 得知中心的讀取請求回傳對應的資料，
    與 `peripheralManager(_:didReceiveWrite:)` 接收從中心的來資訊，回應已經接收到的訊息。*
>> * `setDesiredConnectionLatency(_:for:)`<br/>
    從還原取得的中心進行連線。

### CBMutableService
> 它是周邊提供的服務，一個周邊可以擁有多個服務，區分服務的方式只能透過 UUID 來區分，服務所持有的資料有：
>>
* 可用的特色 `characteristics: [CBCharacteristic]?`，提供一個裝這特色物件的陣列，讓中心可以取得。
* 包含的服務 `includedServices: [CBService]? `，提供一個裝這服務物件的陣列，讓中心可以取得。

> 可用的方法：
>> `init(type:primary:)`<br/>
    建立服務物件，同時決定是否是主要的服務。
    
### CBMutableCharacteristic
> 它是服務提供的特色，一個服務可以擁有多個特色，區分特色的方式只能透過 UUID 來區分，特色所持有的資料有：
>>
>> * 傳送的值 `value: Data?`，發送通知時需要提供的資料，此資料在其他的時間點皆為空值。
>> * 資產 `properties: CBCharacteristicProperties`，設定這個特色的值（value）是否支援讀或寫，此參數可以設定複數值，如 `[.notify, .read, .write]`。
>> * 權限 `permissions: CBAttributePermissions`，設定這個特色可用的權限，此參數可以設定複數值，如 `[.readable, .writeable]`。
>> * 以訂閱的中心 	`subscribedCentrals: [CBCentral]?`，唯讀，當中心訂閱這個特色成功的時候，即可從這裡取得中心資料。
>> * 描述 `descriptors: [CBDescriptor]?`，提供描述給中心使用，這個尚未實作過，所以還不確定它的功能。

### CBMutableDescriptor
> 它是特色提供的描述資訊，這個尚未實作過，所以還不確定它的功能。

### CBATTRequest
> 它是從中心做讀取請求與寫入請求的時候才會產生的物件，搭配 `respond(to:withResult:)` 使用，所持有的資料有：
>> 
>> * 中心 `central: CBCentral`，唯讀，傳送請求的中心。
>> * 特色 `characteristic: CBCharacteristic`，唯讀，紀錄中心透過那個特色發送請求。
>> * 傳送的值 `value: Data?`，唯讀，取得讀取請求的時候才有值，其他時候皆為空值。