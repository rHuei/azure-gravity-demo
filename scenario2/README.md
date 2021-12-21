# Scenario2

### 目的 :

情境 2 目的在於演示 Gravity 快速延展多個資料庫，解決單一資料庫附載過重的問題，此演示將沿用 Scenario1的 Data Node 來做資料庫的擴展

### 資料流 (Data pipeline) :

此情境是透過 gravity-adapter-mssql (Gravity Adapter) 擷取 Ｍicrosoft SQL Server 的 CDC 資料後，經由 Gravity 核心的資料處理並建立一份資料的 Snapshot，再往後傳遞給 gravity-transmitter-postgres (Gravity Transmitter) 與 gravity-transmitter-mysql，寫入至 PostgreSQL與 MySQL，達成快速延展資料庫的目的 (1 對 2)

### 操作方式：
```
cd ~/azure-gravity-demo/scenario2/
```

1. 搭建一座 MySQL (v8.0)

```
kubectl -n gravity-demo apply -f ./mysql
```
##### MySQL  連線資訊:
* host: demo2-mysql
* port: 3306
* dbname: gravity
* table name: users 
* username: mysql
* password: 1qaz@WSX

##### MySQL users table scheam:
```
create table users(
	id varchar(50) primary key,
	name varchar(50),
	gender int(10),
	username varchar(50),
	email varchar(80),
	phone varchar(50)
);
```

2. 建立 Gravity Transmitter (將 Gravity 內部的資料傳至 MySQL) :

```
kubectl -n gravity-demo apply -f 00-transmitter-mysql.yaml
```

3. 到接收端的 MySQL 確認資料總筆數與內容

```
kubectl -n gravity-demo exec -it demo2-mysql -- mysql -u mysql -p1qaz@WSX -D gravity
> select count(*) from users;
> select * from users limit 10;
```
