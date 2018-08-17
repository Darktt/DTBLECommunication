#藍牙中心 (Central)

##中心結構

---------------
* CBCentralManager
    * CBPeripheral
        * Services (CBService)
            * Include Services (CBService)
            * Characteristics (CBCharacteristic)
                * Descriptors（CBDescriptor）

---------------

###CBCentralManager
它是中心的主要物件，主要功能是找尋**周邊（CBPeripheral）**，以及取得曾經連線過的**周邊**，

完成周邊連線之後它的工作就結束了。

###CBPeripheral
它是被找到的周邊物件，周邊所持有的資料有：

* 識別碼 `identifier: UUID`，唯讀，此資訊由中心提供，用來取得曾經連線過的周邊用。
* 設備名稱 `name: String?`，唯讀，可能為空。
* 連線狀態 `state: CBPeripheralState`，唯讀。
* 可用服務 `services: [CBService]?`，唯讀，需要執行尋找服務的動作才能取得可用的服務。
* 訊號強度 `rssi: NSNumber?`，唯讀，在 iOS8 之後廢棄，改用 `readRSSI()` 從 CBPeripheralDelegate 的 `func peripheral(CBPeripheral, didReadRSSI: NSNumber, error: Error?)` 取得資訊。

可用的方法：

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
	
###CBService
它是周邊所提供的服務，服務可以有多給，區分服務的方式只能透過 UUID 來區分，服務所持有的資料有：

