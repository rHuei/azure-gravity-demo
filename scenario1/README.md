# Scenario1

### 目的 :

情境 1 目的在於演示 Gravity 的基本功能，透過擴展異質資料庫達到 CQRS 的效果，改善資料庫讀取效能方面的問題

### 資料流 (Data pipeline) :

此情境是透過 gravity-adapter-mssql (Gravity Adapter) 擷取 Ｍicrosoft SQL Server 的 CDC 資料後，經由 Gravity 核心的資料處理並建立一份資料的 Snapshot，再往後傳遞給 gravity-transmitter-postgres (Gravity Transmitter) 寫入至 PostgreSQL，達成異質資料庫資料轉換與同步的目的

### 操作方式：
0. 開啟 pietty 選擇 gravity-demo username: gravity password: gravity

1. 建立 gravity-demo 的 namespace

```
cd scenario1
kubectl create ns gravity-demo
```

2. 搭建一座 Microsoft SQL Server 2017 資料庫 (demo1-mssql)

```
kubectl -n gravity-demo apply -f ./mssql
```

3. 確認 demo1-mssql pod 建立完成後進入 demo1-mssql 內部執行建表與開啟 CDC 的功能

```
kubectl -n gravity-demo get pods
```
```
kubectl -n gravity-demo exec -it demo1-mssql -- bash
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 1qaz@WSX -i /docker-entrypoint-initdb.d/init.sql
# 等待腳本執行完成後即可退出
exit
```
##### Microsoft SQL Server 連線資訊:

* host: demo1-mssql
* port: 1433
* dbname: TestDB
* table name: users
* username: SA
* password: 1qaz@WSX

##### SQL Server users table schema:
```
create table users(
	id varchar(50) primary key,
	name varchar(50),
	nickname varchar(50),
	gender int,
	disabled bit,
	username varchar(50),
	password varchar(256),
	address text,
	email varchar(80),
	phone varchar(20)
);
```

4. 建立 User 基礎資料

```
kubectl -n gravity-demo apply -f ./genuser
```

5. 搭建一座 PostgreSQL (v13.3)

```
kubectl -n gravity-demo apply -f ./postgres
```

##### PostgreSQL  連線資訊:

* host: demo1-postgres
* port: 5432
* dbname: postgres
* table name: users 
* username: postgres
* password: 1qazWWSX

##### PostgreSQL users table scheam:
```
create table users(
	id varchar(50) primary key,
	name varchar(50),
	gender int,
	username varchar(50),
	email varchar(80),
	phone varchar(20)
);
```

6. 建立 Gravity DataNode :

```
kubectl -n gravity-demo apply -f 10-gravity.yaml
```

7. 建立 Gravity Adapter (擷取 Ｍicrosoft SQL Server 的 CDC 資料) :

```
kubectl -n gravity-demo apply -f 20-adapter.yaml
```

8. 建立 Gravity Transmitter (將 Gravity 內部的資料傳至 PostgreSQL) :

```
kubectl -n gravity-demo apply -f 30-transmitter.yaml
```

9. 到接收端的 PostgreSQL 確認資料總筆數與內容

```
kubectl -n gravity-demo get pods | grep demo1-postgres
kubectl -n gravity-demo exec -it demo1-postgres-7c6b68cf48-nlfbg -- bash

echo "select count(*) from users;" |psql -U postgres -w 1qazWWSX -d postgres

echo "select * from users limit 10;" |psql -U postgres -w 1qazWWSX -d postgres
exit
```

---

### 附加功能 :

Gravity QueryKit 與 Gravity Presenter 是一組方便開發 RESTful API 與網頁呈現資料的工具，在此演示中，將使用：

1. gravity-querykit-postgres 讀取 PostgreSQL 的資料
2. gravity-presenter-rest 透過網頁來呈現 PostgreSQL 所同步出來的資料

### 操作方式：

1. 建立 gravity-querykit-postgres

```
kubectl -n gravity-demo apply -f 40-querykit.yaml
```

2. 建立 presenter template (設計RESTful API 與網頁呈現資料的框架)

```
kubectl -n gravity-demo create configmap gravity-template --from-file=./template
```

3. 建立 gravity-presenter-rest

```
kubectl -n gravity-demo apply -f 50-presenter.yaml
```

4. 更改service type 取得連線埠號
``` bash
kubectl -n gravity-demo edit svc demo1-presenter-rest
```

更改spec.type 由ClusterIP 改為LoadBalancer
```
spec:
  clusterIP: 10.96.142.128
  externalTrafficPolicy: Cluster
  ports:
  - name: demo1-presenterrest
    nodePort: 30453
    port: 44148
    protocol: TCP
    targetPort: 44148
  selector:
    app: gravity-presenter
    component: rest
    release: demo1-presenter
  sessionAffinity: None
  type: LoadBalancer

```
```
kubectl -n gravity-demo get svc demo1-presenter-rest
demo1-presenter-rest              LoadBalancer    10.96.142.128    <IP>        44148:30453/TCP     3m53s
```
資料呈現網址 : http://<IP>:44148/user?page=1&limit=100
