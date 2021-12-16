# 以 GRAVITY 輕鬆擴展資料上雲 on Microsoft Azure
本次工作坊將帶領學員搭建 AKS（Azure Kubernetes Service），並在 AKS 上建立 Gravity 數據中台的資料管線，透過幾種應用情境的實作，享受 AKS 平台功能及輕鬆做到資料同步及上雲。

# 課程大綱
Gravity 情境應用
- 異質資料庫同步
- 一對多資料庫同步
- 上雲去識別化

# 安裝 Gravity Operator
1. 建立 Storage Class
```
kubectl apply -f azure-file-sc.yaml
```

2. Create Gravity Operator Namespace
```
kubectl create namespace gravity-operator
```

3. Add Helm Chart Repository
```
helm repo add brobridge https://brobridgeorg.github.io/helm-repo/

helm repo list
```

4. Install Operator
```
helm install gravity-operator brobridge/gravity-operator -n gravity-operator --version 4.2.0
helm install gravity-adapter-operator brobridge/gravity-adapter-operator -n gravity-operator --version 3.1.0
helm install gravity-exporter-operator brobridge/gravity-exporter-operator -n gravity-operator --version 2.2.0
helm install gravity-transmitter-operator brobridge/gravity-transmitter-operator -n gravity-operator --version 2.1.0
helm install gravity-querykit-operator brobridge/gravity-querykit-operator -n gravity-operator --version 1.0.2
helm install gravity-presenter-operator brobridge/gravity-presenter-operator -n gravity-operator --version 1.0.2
```

5. 檢查狀態
```
kubectl get pods -n gravity-operator
```
