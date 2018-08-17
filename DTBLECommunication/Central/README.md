# 藍牙中心 (Central)

因為 iOS 的藍牙中心的架構較為複雜，因此寫下這篇作為記錄，讓下次也能順利的使用此功能。

## 中心結構
>* CBCentralManager
    * CBPeripheral
        * Services (CBService)
            * Include Services (CBService)
            * Characteristics (CBCharacteristic)
                * Descriptors（CBDescriptor）

---------------

### CBCentralManager
> 它是中心的主要物件，主要功能是找尋**周邊（CBPeripheral）**，以及取得曾經連線過的**周邊**，<br/>
完成周邊連線之後它的工作就結束了。可用的方法：
>>
* `init(delegate:, queue:)`<br/>
	建立中心物件，如果 queue 給 nil 的時候，就代表使用的是 main queue。
* `init(delegate:queue:options:)`<br/>
	同樣是建立中心物件，不過差別是多了option的參數。
* `retrievePeripherals(withIdentifiers:)`<br/>
	取回已知的周邊，如果 identifiers 給空陣列的話會取得所有這個 app 找到的周邊。
* `retrieveConnectedPeripherals(withServices:)`<br/>
	取回曾經連線過的周邊，如果 identifiers 給空陣列的話會取得所有這個 app 找到的周邊。
* `scanForPeripherals(withServices:options:)`<br/>
	開始尋找周邊，如果 services 是給 nil 的時候，會找到所有的周邊，如果不想取得重複的周邊的話，可以在 options 增加 `CBCentralManagerScanOptionAllowDuplicatesKey` 的參數為 false 即可。<br/>
	找尋到的周邊都會透過 CBCentralManagerDelegate 的 `centralManager(_:didDiscover:advertisementData:rssi:)` 取得；<br/>
	周邊的實體需要被變數保留，不然周邊在連線之後會斷線。<br/>
	*尋找周邊的時候必須 state 為 poweredOn 的時候才能使用，能在建立完成中心物件之後透過 CBCentralManagerDelegate 的 `centralManagerDidUpdateState(_)` 取得現在狀態。*
* `stopScan()` <br/>
	停止尋找周邊，當中心找到周邊或是放棄尋找周邊的時候就使用這個方法。
* `connect(_:options:)`<br/>
	連線周邊，option 中可以提供 CBConnectPeripheralOptionNotifyOnConnectionKey、CBConnectPeripheralOptionNotifyOnDisconnectionKey、CBConnectPeripheralOptionNotifyOnNotificationKey 用來得知周邊狀態變動時的通知。<br/>
	（*需要裝置為螢幕鎖定狀態，並且為系統自動通知，app 無從得知。*）
* `cancelPeripheralConnection(_:)`<br/>
	取消周邊連線，主動取消連線。<br/>
	*當周邊的實體被釋放的時候也會自動取消連線。*
	
### CBPeripheral
> 它是被找到的周邊物件，周邊所持有的資料有：
>>
* 識別碼 `identifier: UUID`，唯讀，此資訊由中心提供，用來取得曾經連線過的周邊用。
* 設備名稱 `name: String?`，唯讀，可能為空。
* 連線狀態 `state: CBPeripheralState`，唯讀。
* 可用服務 `services: [CBService]?`，唯讀，需要執行尋找服務的動作才能取得可用的服務。
* 訊號強度 `rssi: NSNumber?`，唯讀，在 iOS8 之後廢棄，改用 `readRSSI()` 從 CBPeripheralDelegate 的 `func peripheral(CBPeripheral, didReadRSSI: NSNumber, error: Error?)` 取得資訊。

> 可用的方法：
>>
* `discoverServices(_:)`<br/>
	使用 UUID 來尋找服務，這個同時也會根據提供的 UUID 來過濾服務，找到服務時會從 CBPeripheralDelegate，`peripheral(_:, didDiscoverServices:)` 取得已找到的服務或失敗訊息。
	*取回曾經連線過的周邊的時候，如果有成功找到服務，那就不需要再次尋找，取回時會一併取得。*
* `discoverCharacteristics(_:,for:)` <br/>
	從服務來尋找特色，找到特色時會從 CBPeripheralDelegate，`peripheral(_:didDiscoverCharacteristicsFor:error:)` 取得已找到的特色或失敗訊息。
	*取回曾經連線過的周邊的時候，如果有成功找到特色，那就不需要再次尋找，取回時會一併取得。*
* `setNotifyValue(_:for:)`<br/>
	用來訂閱有通知功能的特色（可以從 `CBCharacteristic.properties` 得知是否有訂閱功能），結果會從 CBPeripheralDelegate `peripheral(_:didUpdateNotificationStateFor:error:)` 得知是否成功訂閱。
* `writeValue(_:for:)` & `writeValue(_:for:type:)`<br/>
	用來傳送資料到週邊端，這個只要提供特色即可，但是 `CBCharacteristic.properties` 要包含 write 的功能，不然會失敗，另外一個 type 的參數是決定這個傳送是否有回應。
* `readValue(for:)`<br/>
	讀取從周邊傳送的資訊，能讀取的對象有兩個，一個是特色 *CBCharacteristic* 另一個是描述 *CBDescriptor* ：<br/>
	以特色當對象傳送的時候要注意 `CBCharacteristic.properties` 是否包含 read 的功能，不然會失敗；<br/>
	以描述當對象傳送的時候……這個就沒測試到了，未來有機會再看看吧。
	
### CBService
> 它是周邊所提供的服務，服務可以有多個，區分服務的方式只能透過 UUID 來區分，服務所持有的資料有：
>>
* 依附的周邊 `peripheral: CBPeripheral`，唯讀，通常不會使用它，因為周邊的實體已經被持有了。
* 是否是主要的服務 `isPrimary: Bool`，唯讀。
* 包含的額外服務 `includedServices: [CBService]?`，唯讀，需要執行尋找額外服務動作才能取得可用的服務。
* 可用的特色 `characteristics: [CBCharacteristic]?`，唯讀，需要執行尋找特色動作才能取得可用的特色。

> 可用的方法： 
>> *無，一切的操作都是透過周邊來控制的。*

### CBCharacteristic
> 它是服務所提供的特色，特色可以有多個，特色與服務同樣是根據 UUID 來區分，特色所持有的資料有：
>>
* 依附的服務 `service: CBService`，唯讀
* 讀取到的資料 `value: Data?`，唯讀，這個資料是從周邊提供的
* 可用的描述 `descriptors: [CBDescriptor]?`，唯讀，需要執行尋找描述動作才能取得可用的描述。
* 資產 `properties: CBCharacteristicProperties`，唯讀，決定這個特色是否支援讀或寫與資料加密的參數。
* 是否是正在訂閱的特色 `isNotifying: Bool`，唯讀，當使用 CBPeripheral `setNotifyValue(_:for:)` 並且設定成功時，會得到 true。

> 可用的方法： 
>> *無，一切的操作都是透過周邊來控制的。*

### CBDescriptor
> 它是特色提供的描述資訊，這個尚未實作過，所以還不確定它的功能。