# Scenario 3

### 目的 :

情境 3 目的在於演示 Gravity 跨雲快速延展多個資料庫與增加資料處理邏輯 (如: 資料去識別化) 的進階功能，解決資料跨越不同環境、資料庫快速延展至客戶服務端與敏感資料即時處理的問題，此演示將沿用 Scenario1 的 Data Node 來做資料庫的擴展

### 資料流 (Data pipeline) :

此情境是透過 adapter-native (Gravity Adapter) 擷取 Scenario1 Data Node 的資料後，經由 gravity (Gravity 核心) 的資料處理 (資料去識別化) 並建立一份新的資料 Snapshot，再往後傳遞給 gravity-transmitter-mysql (Gravity Transmitter)，從地端的 Gravity Data Node 寫入至雲端 Microsoft Azure 搭建的 MySQL，達成跨不同環境與即時資料處理的目的

### 操作方式：
```
cd ~/azure-gravity-demo/scenario3
```

1. 搭建一座  MySQL (v8.0)

```
kubectl -n gravity-demo apply -f ./mysql
```
MySQL  連線資訊:
* host: demo3-mysql
* port: 3306
* dbname: gravity
* table name: users 
* username: mysql
* password: 1qaz@WSX

2. 建立 Gravity 核心實現資料即時處理的功能 (去識別化) :

```
kubectl -n gravity-demo apply -f 00-gravity.yaml
```

3. 建立 Gravity Adapter  (將 Scenario 1 Gravity Data Node 內的資料導到新的 Data Node) :

```
kubectl -n gravity-demo apply -f 10-adapter-native.yaml
```

4. 建立 Gravity Transmitter (將去識別化後的資料傳至 MySQL) :

```
kubectl -n gravity-demo apply -f 20-transmitter-mysql.yaml
```

5. 到接收端的 MySQL 確認資料總筆數與內容

```
kubectl -n gravity-demo exec -it demo3-mysql -- mysql -u mysql -p1qaz@WSX -D gravity
> select count(*) from users;
> select * from users limit 10;
> exit
```

